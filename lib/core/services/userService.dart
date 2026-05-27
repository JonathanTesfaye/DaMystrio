import 'package:firebase_database/firebase_database.dart';

class UserService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  /// Save user data after successful registration
  Future<void> saveUserData(String uid, String email, String username) async {
    final userRef = _db.child('users/$uid');
    final snapshot = await userRef.get();
    if (!snapshot.exists) {
      await userRef.set({
        'id': uid,
        'email': email,
        'username': username,
        'status': 'idle',
        'createdAt': ServerValue.timestamp,
        'chips': 1000,
        'wins': 0,
        'losses': 0,
      });
    } else {
      // If user exists but missing game fields, update them
      await userRef.update({
        'chips': 1000,
        'wins': 0,
        'losses': 0,
        'createdAt': ServerValue.timestamp,
      });
    }
  }

  /// Fetch user data
  Future<Map<dynamic, dynamic>?> getUserData(String uid) async {
    final snapshot = await _db.child('users/$uid').get();
    if (snapshot.exists) {
      return snapshot.value as Map<dynamic, dynamic>;
    }
    return null;
  }

  /// Update username
  /// Update username (display name)
  Future<void> updateUsername(String uid, String newUsername) async {
    await _db.child('users/$uid/username').set(newUsername);
  }

  /// Update user chips after a game
  Future<void> updateChips(String uid, int newChips) async {
    await _db.child('users/$uid/chips').set(newChips);
  }

  /// Update win/loss stats
  Future<void> updateStats(String uid, int winsDelta, int lossesDelta) async {
    await _db.child('users/$uid').update({
      'wins': ServerValue.increment(winsDelta),
      'losses': ServerValue.increment(lossesDelta),
    });
  }

  /// Update online status
  Future<void> updateStatus(String uid, String status) async {
    await _db.child('users/$uid/status').set(status);
  }
}
