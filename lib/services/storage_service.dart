import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../models/user_model.dart';
import '../utils/constants.dart';

class StorageService {
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<void> saveToken(String token) async {
    await _prefs.setString(AppConstants.tokenKey, token);
  }

  static String? getToken() {
    return _prefs.getString(AppConstants.tokenKey);
  }

  static Future<void> saveUser(UserModel user) async {
    await _prefs.setString(AppConstants.userKey, jsonEncode(user.toJson()));
  }

  static UserModel? getUser() {
    final userStr = _prefs.getString(AppConstants.userKey);
    if (userStr != null) {
      return UserModel.fromJson(jsonDecode(userStr));
    }
    return null;
  }

  static Future<void> clearStorage() async {
    await _prefs.clear();
  }
}