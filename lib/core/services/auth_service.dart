import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String?> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == "user-not-found") {
        return "No user found for this email.";
      } else if (e.code == 'wrong-password') {
        return "Incorrect password.";
      } else if (e.code == 'invalid-email') {
        return "Invalid email address.";
      } else {
        return "Login failed. Please try again.";
      }
    }
  }

  Future<String?> register(String email, String password, String name) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await userCredential.user!.updateProfile(displayName: name);
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == "email-already-in-use") {
        return "Email is already in use.";
      } else if (e.code == 'weak-password') {
        return "Password is too weak.";
      } else if (e.code == 'invalid-email') {
        return "Invalid email address.";
      } else {
        return "Registration failed. Please try again.";
      }
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
