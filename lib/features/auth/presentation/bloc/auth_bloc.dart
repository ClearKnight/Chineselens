import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chinese_lens/features/auth/domain/entities/user.dart'
    as app_user;
import 'package:chinese_lens/features/auth/presentation/bloc/auth_event.dart';
import 'package:chinese_lens/features/auth/presentation/bloc/auth_state.dart';
import 'package:chinese_lens/config/constants.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final FirebaseFirestore _firestore;
  StreamSubscription<firebase_auth.User?>? _authUserSubscription;

  AuthBloc({
    firebase_auth.FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
    FirebaseFirestore? firestore,
  })  : _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn(),
        _firestore = firestore ?? FirebaseFirestore.instance,
        super(AuthState.unknown()) {
    on<AppStarted>(_onAppStarted);
    on<LogInRequested>(_onLogInRequested);
    on<SignUpRequested>(_onSignUpRequested);
    on<GoogleSignInRequested>(_onGoogleSignInRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<ForgotPasswordRequested>(_onForgotPasswordRequested);
    on<UserStreamRequested>(_onUserStreamRequested);
    on<VerifyEmailRequested>(_onVerifyEmailRequested);
    on<UpdateUserProfileRequested>(_onUpdateUserProfileRequested);
    on<DeleteAccountRequested>(_onDeleteAccountRequested);

    // Subscribe to auth state changes
    _authUserSubscription = _firebaseAuth.userChanges().listen((user) {
      if (user != null) {
        _mapFirebaseUserToUser(user).then((appUser) {
          add(const UserStreamRequested());
        });
      } else {
        add(const UserStreamRequested());
      }
    });
  }

  @override
  Future<void> close() {
    _authUserSubscription?.cancel();
    return super.close();
  }

  Future<void> _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
    try {
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser != null) {
        final appUser = await _mapFirebaseUserToUser(currentUser);
        emit(AuthState.authenticated(appUser));
      } else {
        emit(AuthState.unauthenticated());
      }
    } catch (e) {
      emit(AuthState.unauthenticated(errorMessage: e.toString()));
    }
  }

  Future<void> _onLogInRequested(
      LogInRequested event, Emitter<AuthState> emit) async {
    try {
      emit(state.copyWith(isLoading: true));
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );
      if (userCredential.user != null) {
        final appUser = await _mapFirebaseUserToUser(userCredential.user!);
        // Update last login timestamp
        await _firestore
            .collection(FirebaseCollections.users)
            .doc(appUser.id)
            .update({
          'lastLoginAt': DateTime.now().millisecondsSinceEpoch,
        });
        emit(AuthState.authenticated(appUser));
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      emit(AuthState.unauthenticated(errorMessage: _mapAuthErrorToMessage(e)));
    } catch (e) {
      emit(AuthState.unauthenticated(errorMessage: e.toString()));
    }
  }

  Future<void> _onSignUpRequested(
      SignUpRequested event, Emitter<AuthState> emit) async {
    try {
      emit(state.copyWith(isLoading: true));
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );
      if (userCredential.user != null) {
        // Update user profile
        await userCredential.user!.updateDisplayName(event.name);

        // Create user document in Firestore
        final now = DateTime.now();
        await _firestore
            .collection(FirebaseCollections.users)
            .doc(userCredential.user!.uid)
            .set({
          'id': userCredential.user!.uid,
          'email': event.email,
          'name': event.name,
          'isEmailVerified': false,
          'createdAt': now.millisecondsSinceEpoch,
          'lastLoginAt': now.millisecondsSinceEpoch,
        });

        // Send email verification
        await userCredential.user!.sendEmailVerification();

        // Get updated user
        final appUser = await _mapFirebaseUserToUser(userCredential.user!);
        emit(AuthState.authenticated(appUser));
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      emit(AuthState.unauthenticated(errorMessage: _mapAuthErrorToMessage(e)));
    } catch (e) {
      emit(AuthState.unauthenticated(errorMessage: e.toString()));
    }
  }

  Future<void> _onGoogleSignInRequested(
      GoogleSignInRequested event, Emitter<AuthState> emit) async {
    try {
      emit(state.copyWith(isLoading: true));
      // Start the Google sign-in process
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        emit(state.copyWith(isLoading: false));
        return;
      }

      // Get the authentication details
      final googleAuth = await googleUser.authentication;
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final userCredential =
          await _firebaseAuth.signInWithCredential(credential);
      if (userCredential.user != null) {
        // Check if user exists in Firestore
        final userDoc = await _firestore
            .collection(FirebaseCollections.users)
            .doc(userCredential.user!.uid)
            .get();

        final now = DateTime.now();
        if (!userDoc.exists) {
          // Create new user document
          await _firestore
              .collection(FirebaseCollections.users)
              .doc(userCredential.user!.uid)
              .set({
            'id': userCredential.user!.uid,
            'email': userCredential.user!.email,
            'name': userCredential.user!.displayName,
            'photoUrl': userCredential.user!.photoURL,
            'isEmailVerified': userCredential.user!.emailVerified,
            'createdAt': now.millisecondsSinceEpoch,
            'lastLoginAt': now.millisecondsSinceEpoch,
          });
        } else {
          // Update last login timestamp
          await _firestore
              .collection(FirebaseCollections.users)
              .doc(userCredential.user!.uid)
              .update({
            'lastLoginAt': now.millisecondsSinceEpoch,
          });
        }

        final appUser = await _mapFirebaseUserToUser(userCredential.user!);
        emit(AuthState.authenticated(appUser));
      }
    } catch (e) {
      emit(AuthState.unauthenticated(errorMessage: e.toString()));
    }
  }

  Future<void> _onLogoutRequested(
      LogoutRequested event, Emitter<AuthState> emit) async {
    try {
      emit(state.copyWith(isLoading: true));
      await Future.wait([
        _firebaseAuth.signOut(),
        _googleSignIn.signOut(),
      ]);
      emit(AuthState.unauthenticated());
    } catch (e) {
      emit(AuthState.unauthenticated(errorMessage: e.toString()));
    }
  }

  Future<void> _onForgotPasswordRequested(
      ForgotPasswordRequested event, Emitter<AuthState> emit) async {
    try {
      emit(state.copyWith(isLoading: true));
      await _firebaseAuth.sendPasswordResetEmail(email: event.email);
      emit(state.copyWith(
        isLoading: false,
        status: AuthStatus.unauthenticated,
        errorMessage: '密码重置链接已发送到您的邮箱',
      ));
    } on firebase_auth.FirebaseAuthException catch (e) {
      emit(AuthState.unauthenticated(errorMessage: _mapAuthErrorToMessage(e)));
    } catch (e) {
      emit(AuthState.unauthenticated(errorMessage: e.toString()));
    }
  }

  Future<void> _onUserStreamRequested(
      UserStreamRequested event, Emitter<AuthState> emit) async {
    try {
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser != null) {
        final appUser = await _mapFirebaseUserToUser(currentUser);
        emit(AuthState.authenticated(appUser));
      } else {
        emit(AuthState.unauthenticated());
      }
    } catch (e) {
      emit(AuthState.unauthenticated(errorMessage: e.toString()));
    }
  }

  Future<void> _onVerifyEmailRequested(
      VerifyEmailRequested event, Emitter<AuthState> emit) async {
    try {
      emit(state.copyWith(isLoading: true));
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser != null) {
        await currentUser.sendEmailVerification();
        emit(state.copyWith(
          isLoading: false,
          errorMessage: '验证邮件已发送',
        ));
      } else {
        emit(AuthState.unauthenticated(errorMessage: '用户未登录'));
      }
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onUpdateUserProfileRequested(
      UpdateUserProfileRequested event, Emitter<AuthState> emit) async {
    try {
      emit(state.copyWith(isLoading: true));
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser != null) {
        if (event.name != null) {
          await currentUser.updateDisplayName(event.name);
        }
        if (event.photoUrl != null) {
          await currentUser.updatePhotoURL(event.photoUrl);
        }

        // Update Firestore
        final updates = <String, dynamic>{};
        if (event.name != null) updates['name'] = event.name;
        if (event.photoUrl != null) updates['photoUrl'] = event.photoUrl;

        if (updates.isNotEmpty) {
          await _firestore
              .collection(FirebaseCollections.users)
              .doc(currentUser.uid)
              .update(updates);
        }

        final appUser = await _mapFirebaseUserToUser(currentUser);
        emit(AuthState.authenticated(appUser));
      } else {
        emit(AuthState.unauthenticated(errorMessage: '用户未登录'));
      }
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onDeleteAccountRequested(
      DeleteAccountRequested event, Emitter<AuthState> emit) async {
    try {
      emit(state.copyWith(isLoading: true));
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser != null) {
        // Delete user document from Firestore
        await _firestore
            .collection(FirebaseCollections.users)
            .doc(currentUser.uid)
            .delete();

        // Delete user authentication
        await currentUser.delete();
        emit(AuthState.unauthenticated());
      } else {
        emit(AuthState.unauthenticated(errorMessage: '用户未登录'));
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        emit(AuthState.unauthenticated(errorMessage: '需要重新登录以完成此操作'));
      } else {
        emit(
            AuthState.unauthenticated(errorMessage: _mapAuthErrorToMessage(e)));
      }
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<app_user.User> _mapFirebaseUserToUser(
      firebase_auth.User firebaseUser) async {
    // Try to get user data from Firestore
    final userDoc = await _firestore
        .collection(FirebaseCollections.users)
        .doc(firebaseUser.uid)
        .get();

    if (userDoc.exists && userDoc.data() != null) {
      return app_user.User.fromMap(userDoc.data()!);
    }

    // If not in Firestore yet, create from Firebase user object
    return app_user.User(
      id: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      name: firebaseUser.displayName,
      photoUrl: firebaseUser.photoURL,
      isEmailVerified: firebaseUser.emailVerified,
      createdAt: firebaseUser.metadata.creationTime ?? DateTime.now(),
      lastLoginAt: firebaseUser.metadata.lastSignInTime ?? DateTime.now(),
    );
  }

  String _mapAuthErrorToMessage(firebase_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return '未找到此邮箱对应的用户';
      case 'wrong-password':
        return '密码错误';
      case 'invalid-email':
        return '邮箱格式无效';
      case 'user-disabled':
        return '此用户已被禁用';
      case 'email-already-in-use':
        return '此邮箱已被注册';
      case 'operation-not-allowed':
        return '此操作不被允许';
      case 'weak-password':
        return '密码强度太弱';
      case 'network-request-failed':
        return '网络请求失败，请检查您的网络连接';
      case 'too-many-requests':
        return '请求次数过多，请稍后再试';
      case 'invalid-credential':
        return '提供的凭据无效';
      case 'account-exists-with-different-credential':
        return '此邮箱已经使用其他登录方式注册';
      case 'requires-recent-login':
        return '需要重新登录以完成此操作';
      default:
        return e.message ?? '认证出错，请稍后再试';
    }
  }
}
