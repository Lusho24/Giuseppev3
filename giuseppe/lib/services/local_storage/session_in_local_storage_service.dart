import 'package:shared_preferences/shared_preferences.dart';

class SessionInLocalStorageService{

  Future<void> saveSession(String userId, bool isAdmin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', userId);
    await prefs.setBool('isAdmin', isAdmin);
  }

  Future<Map<String, dynamic>?> fetchSession() async {
    final prefs = await SharedPreferences.getInstance();
    final String? userId = prefs.getString('userId');
    final bool? isAdmin = prefs.getBool('isAdmin');

    if (userId != null && isAdmin != null) {
      return {'userId': userId, 'isAdmin': isAdmin};
    }
    return null;
  }

  Future<void> removeSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

}