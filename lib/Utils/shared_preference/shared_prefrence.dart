import 'dart:convert';

import 'package:google_ml_face_detection/Utils/shared_preference/shared_preference_const.dart';
import 'package:google_ml_face_detection/models/employee_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPref {

  static Future<bool> setAccessToken({required String accessToken}) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setString(SharedPrefConst.login, accessToken);
    return true;
  }

  static Future<String> getAccessToken() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    return sp.getString(SharedPrefConst.login) ?? "";
  }

  static Future<bool> clearSharedPreference() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    return sp.clear();
  }


  static Future<bool> setPasscode(String passcode) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setString(SharedPrefConst.passcode, passcode);
    return true;
  }

  static Future<String> getPasscode() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    return sp.getString(SharedPrefConst.passcode) ?? "";
  }

  static Future<bool> setUid(String uid) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setString(SharedPrefConst.userId, uid);
    return true;
  }

  static Future<String> getUid() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    return sp.getString(SharedPrefConst.userId) ?? "";
  }

  // Save list of users to SharedPreferences
  static Future<void> saveUsers(List<EmployeeModel> users) async {
    final prefs = await SharedPreferences.getInstance();

    // Convert the list of UserModel objects to a list of maps
    List<Map<String, dynamic>> userMaps = users.map((user) => user.toJson()).toList();

    // Convert the list of maps to a JSON string
    String userJson = jsonEncode(userMaps);

    // Save the JSON string to SharedPreferences
    await prefs.setString(SharedPrefConst.employeeList, userJson);
  }

  // Retrieve list of users from SharedPreferences
  static Future<List<EmployeeModel>> getUsers() async {
    final prefs = await SharedPreferences.getInstance();
    String? userJson = prefs.getString(SharedPrefConst.employeeList);

    if (userJson != null) {
      // Convert the JSON string back to a list of maps
      List<dynamic> userMaps = jsonDecode(userJson);

      // Convert the list of maps to a list of UserModel objects
      List<EmployeeModel> users = userMaps.map((map) => EmployeeModel.fromJson(map)).toList();

      return users;
    } else {
      return [];
    }
  }


}