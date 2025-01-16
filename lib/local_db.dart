// import 'package:google_ml_face_detection/models/employee_model.dart';
// import 'package:hive_flutter/hive_flutter.dart';
//
// class HiveBoxes {
//   static const userDetails = "user_details";
//
//   static Box userDetailsBox() => Hive.box(userDetails);
//
//   static initialize() async {
//     await Hive.openBox(userDetails);
//   }
//
//   static clearAllBox() async {
//     await HiveBoxes.userDetailsBox().clear();
//   }
// }
//
// class LocalDB {
//   static EmployeeModel getUser() => EmployeeModel.fromJson(HiveBoxes.userDetailsBox().toMap());
//
//   static String getUserName() => HiveBoxes.userDetailsBox().toMap()["name"];
//
//   static String getUserEmail() => HiveBoxes.userDetailsBox().toMap()["email"];
//
//   static String getUserArray() => HiveBoxes.userDetailsBox().toMap()["image_data"];
//
//   static setUserDetails(EmployeeModel user) {
//      HiveBoxes.userDetailsBox().add(user.toJson());
//      print("values is : ${HiveBoxes.userDetailsBox().values}");
//   }
//
//   static List<EmployeeModel> getAllUsers() {
//     List<EmployeeModel> users = HiveBoxes.userDetailsBox().keys.map((e) {
//        print("e is: $e");
//        dynamic res = HiveBoxes.userDetailsBox().get(e);
//        print("res is --> $res");
//        EmployeeModel user = EmployeeModel.fromJson(res);
//        return user;
//       }
//     ).toList();
//
//     return users;
//   }
//
//   static Future<void> deleteUser(int key) => HiveBoxes.userDetailsBox().delete(key);
//
//   static int getUserKey(int index) => HiveBoxes.userDetailsBox().keyAt(index);
//
// }
