import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_application_1/core/services/authService.dart';

class PresenceService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();
  final AuthService _auth = AuthService();

  StreamSubscription? _connectionStatusSubscription;
  String? _currentUserId;

  // Stream of all online users (status not 'offline')
  Stream<List<Map<String, dynamic>>> get onlineUsersStream {
    return _db.child('userStatus').onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>? ?? {};
      final List<Map<String, dynamic>> users = [];
      data.forEach((key, value) {
        final user = Map<String, dynamic>.from(value);
        if (user['status'] != 'offline') {
          users.add({
            'uid': key,
            'name': user['name'] ?? 'Player',
            'status': user['status'] ?? 'offline',
          });
        }
      });
      return users;
    });
  }

  // Initialize presence (call after login)
  Future<void> init() async {
    _currentUserId = _auth.currentUser?.uid;
    if (_currentUserId == null) return;

    final userRef = _db.child('userStatus/$_currentUserId');
    // Set initial status
    await userRef.set({
      'name':
          _auth.currentUser?.displayName ??
          _auth.currentUser?.email ??
          'Player',
      'status': 'in lobby',
      'lastSeen': ServerValue.timestamp,
    });
    // When disconnected, set status to offline
    userRef.onDisconnect().update({
      'status': 'offline',
      'lastSeen': ServerValue.timestamp,
    });
  }

  // Update user status
  Future<void> updateStatus(String status) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    await _db.child('userStatus/$uid').update({
      'status': status,
      'lastSeen': ServerValue.timestamp,
    });
  }

  // Call on logout to remove presence
  Future<void> clear() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    await _db.child('userStatus/$uid').remove();
  }

  void dispose() {
    _connectionStatusSubscription?.cancel();
  }
}
