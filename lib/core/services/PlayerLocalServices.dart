import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class PlayerLocalService {
  static const String _uidKey = 'player_uid';
  static const String _displayNameKey = 'player_display_name';

  static Future<String> getUid() async {
    final prefs = await SharedPreferences.getInstance();
    String? uid = prefs.getString(_uidKey);
    if (uid == null) {
      uid = const Uuid().v4();
      await prefs.setString(_uidKey, uid);
    }
    return uid;
  }

  static Future<String> getDisplayName() async {
    final prefs = await SharedPreferences.getInstance();
    String? name = prefs.getString(_displayNameKey);
    if (name == null || name.isEmpty) {
      name = "Player ${DateTime.now().millisecondsSinceEpoch % 10000}";
      await prefs.setString(_displayNameKey, name);
    }
    return name;
  }

  static Future<void> setDisplayName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_displayNameKey, name);
  }
}
