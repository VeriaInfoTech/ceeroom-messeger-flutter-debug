import 'package:shared_preferences/shared_preferences.dart';

class AppSharedPreferences {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  void saveToken(String token) async {
    final SharedPreferences prefs = await _prefs;
    await prefs.setString('token', token);
  }

  Future<String?> getToken() async {
    final SharedPreferences prefs = await _prefs;
    return prefs.getString('token');
  }

  Future<bool> clearToken() async {
    final SharedPreferences prefs = await _prefs;
    return prefs.remove('token');
  }
  void saveLifeCycleState(String state) async {
    final SharedPreferences prefs = await _prefs;
    await prefs.setString('lifeCycle', state);
  }

  Future<String?> getLifeCycleState() async {
    final SharedPreferences prefs = await _prefs;
    return prefs.getString('lifeCycle');
  }

  Future<bool> clearLifeCycleState() async {
    final SharedPreferences prefs = await _prefs;
    return prefs.remove('lifeCycle');
  }
}
