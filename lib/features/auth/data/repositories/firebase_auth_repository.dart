import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:chinese_lens/config/constants.dart';
import 'package:chinese_lens/core/utils/logger.dart';
import 'package:chinese_lens/features/auth/domain/models/user_model.dart';
import 'package:chinese_lens/features/auth/domain/repositories/auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  FirebaseAuthRepository({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  @override
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw Exception('User not found');
      }

      // Update last login timestamp
      await _updateLastLogin(userCredential.user!.uid);

      return await _getUserFromFirestore(userCredential.user!.uid);
    } on FirebaseAuthException catch (e) {
      AppLogger.e('Firebase signIn error: ${e.code}', e);
      throw _mapFirebaseAuthExceptionToMessage(e);
    } catch (e) {
      AppLogger.e('Unexpected signIn error', e);
      throw Exception('Failed to sign in: $e');
    }
  }

  @override
  Future<UserModel> signUp({
    required String email,
    required String password,
    String? name,
  }) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw Exception('Failed to create user');
      }

      // Create user document in Firestore
      final user = UserModel(
        id: userCredential.user!.uid,
        email: email,
        name: name,
        nativeLanguage: null,
        learningLevel: 'beginner',
        createdAt: DateTime.now(),
        lastLogin: DateTime.now(),
      );

      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.id)
          .set(user.toJson());

      return user;
    } on FirebaseAuthException catch (e) {
      AppLogger.e('Firebase signUp error: ${e.code}', e);
      throw _mapFirebaseAuthExceptionToMessage(e);
    } catch (e) {
      AppLogger.e('Unexpected signUp error', e);
      throw Exception('Failed to sign up: $e');
    }
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      // Start the Google sign-in process
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Google sign-in was cancelled by the user');
      }

      // Obtain auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create credentials for Firebase
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with credentials
      final userCredential =
          await _firebaseAuth.signInWithCredential(credential);

      if (userCredential.user == null) {
        throw Exception('Failed to sign in with Google');
      }

      // Check if the user exists in Firestore
      final userDoc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userCredential.user!.uid)
          .get();

      if (!userDoc.exists) {
        // First time login, create user document
        final user = UserModel(
          id: userCredential.user!.uid,
          email: userCredential.user!.email!,
          name: userCredential.user!.displayName,
          nativeLanguage: null,
          learningLevel: 'beginner',
          createdAt: DateTime.now(),
          lastLogin: DateTime.now(),
        );

        await _firestore
            .collection(AppConstants.usersCollection)
            .doc(user.id)
            .set(user.toJson());

        return user;
      } else {
        // Update last login timestamp
        await _updateLastLogin(userCredential.user!.uid);

        return await _getUserFromFirestore(userCredential.user!.uid);
      }
    } catch (e) {
      AppLogger.e('Google sign-in error', e);
      throw Exception('Failed to sign in with Google: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await Future.wait([
        _firebaseAuth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      AppLogger.e('Sign out error', e);
      throw Exception('Failed to sign out: $e');
    }
  }

  @override
  Future<void> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      AppLogger.e('Reset password error: ${e.code}', e);
      throw _mapFirebaseAuthExceptionToMessage(e);
    } catch (e) {
      AppLogger.e('Unexpected reset password error', e);
      throw Exception('Failed to send password reset email: $e');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final currentUser = _firebaseAuth.currentUser;
    if (currentUser == null) {
      return null;
    }

    try {
      return await _getUserFromFirestore(currentUser.uid);
    } catch (e) {
      AppLogger.e('Get current user error', e);
      return null;
    }
  }

  @override
  Future<bool> isSignedIn() async {
    return _firebaseAuth.currentUser != null;
  }

  @override
  Future<UserModel> updateUserProfile({
    required String userId,
    String? name,
    String? nativeLanguage,
    String? learningLevel,
  }) async {
    try {
      // Update user document in Firestore
      final userDoc =
          _firestore.collection(AppConstants.usersCollection).doc(userId);

      // Build update data
      final Map<String, dynamic> updateData = {};
      if (name != null) updateData['name'] = name;
      if (nativeLanguage != null) updateData['nativeLanguage'] = nativeLanguage;
      if (learningLevel != null) updateData['learningLevel'] = learningLevel;

      // Update Firestore document
      await userDoc.update(updateData);

      // Get updated user
      return await _getUserFromFirestore(userId);
    } catch (e) {
      AppLogger.e('Update user profile error', e);
      throw Exception('Failed to update user profile: $e');
    }
  }

  // Helper method to update last login timestamp
  Future<void> _updateLastLogin(String userId) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .update({'lastLogin': FieldValue.serverTimestamp()});
    } catch (e) {
      AppLogger.e('Update last login error', e);
      // Don't throw, this is not critical
    }
  }

  // Helper method to get user from Firestore
  Future<UserModel> _getUserFromFirestore(String userId) async {
    try {
      final docSnapshot = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .get();

      if (!docSnapshot.exists) {
        throw Exception('User document not found in Firestore');
      }

      final data = docSnapshot.data() as Map<String, dynamic>;
      data['id'] = userId; // Ensure ID is set

      return UserModel.fromJson(data);
    } catch (e) {
      AppLogger.e('Get user from Firestore error', e);
      throw Exception('Failed to get user data: $e');
    }
  }

  // Helper method to map Firebase exceptions to user-friendly messages
  Exception _mapFirebaseAuthExceptionToMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return Exception('Invalid email address');
      case 'user-disabled':
        return Exception('This account has been disabled');
      case 'user-not-found':
        return Exception('No account found with this email');
      case 'wrong-password':
        return Exception('Incorrect password');
      case 'email-already-in-use':
        return Exception('An account already exists with this email');
      case 'weak-password':
        return Exception('Password is too weak');
      case 'operation-not-allowed':
        return Exception('This operation is not allowed');
      default:
        return Exception(e.message ?? 'Authentication failed');
    }
  }
}
