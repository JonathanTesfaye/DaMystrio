import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/core/services/userService.dart'; // NEW import

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserService _userService = UserService(); // NEW instance

  // Stream of user state (for listening to login/logout)
  Stream<User?> get user => _auth.authStateChanges();

  // Current user (synchronous)
  User? get currentUser => _auth.currentUser;

  // Login with email/password – returns error message or null on success
  Future<String?> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return _mapAuthError(e);
    } catch (e) {
      return "An unexpected error occurred";
    }
  }

  // Register with email/password and display name – returns error message or null
  Future<String?> register(String email, String password, String name) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Set display name in Auth
      await result.user?.updateDisplayName(name);
      await result.user?.reload();

      // NEW: Save user data to Realtime Database
      await _userService.saveUserData(result.user!.uid, email, name);

      return null;
    } on FirebaseAuthException catch (e) {
      return _mapAuthError(e);
    } catch (e) {
      return "An unexpected error occurred";
    }
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
  }

  String _mapAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password should be at least 6 characters.';
      case 'invalid-email':
        return 'Invalid email address.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}
