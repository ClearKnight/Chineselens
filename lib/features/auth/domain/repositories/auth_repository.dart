import 'package:chinese_lens/features/auth/domain/models/user_model.dart';

abstract class AuthRepository {
  /// Sign in with email and password
  Future<UserModel> signIn({
    required String email,
    required String password,
  });

  /// Sign up with email and password
  Future<UserModel> signUp({
    required String email,
    required String password,
    String? name,
  });

  /// Sign in with Google account
  Future<UserModel> signInWithGoogle();

  /// Sign out current user
  Future<void> signOut();

  /// Reset password for the provided email
  Future<void> resetPassword(String email);

  /// Get current signed in user
  Future<UserModel?> getCurrentUser();

  /// Check if a user is signed in
  Future<bool> isSignedIn();

  /// Update user profile
  Future<UserModel> updateUserProfile({
    required String userId,
    String? name,
    String? nativeLanguage,
    String? learningLevel,
  });
}
