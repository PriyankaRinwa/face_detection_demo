
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_ml_face_detection/Utils/routes/routes_name.dart';
import 'package:google_ml_face_detection/Utils/service/supabase_service.dart';
import 'package:google_ml_face_detection/Utils/shared_preference/shared_prefrence.dart';
import 'package:google_ml_face_detection/Utils/utils/utils.dart';
import 'package:package_info_plus/package_info_plus.dart';

class DashboardProvider extends ChangeNotifier{
   // List<EmployeeModel> _users = [];
 // List<EmployeeModel> get users => _users;
 // final bool _isLoading = true;
  String _appVersion = "1.0.0";

  // late final Stream<List<EmployeeModel>> _counterStream = _controller.stream;
  // late final StreamController<List<EmployeeModel>> _controller = StreamController<List<EmployeeModel>>();

  // bool get isLoading => _isLoading;
  String get appVersion => _appVersion;


  // getEmployeeList() async {
  //   Stream<List<EmployeeModel>> arrEmployeeModel = SupaBaseService().fetchAllEmployeesStream();
  //   _controller.add(arrEmployeeModel);
  // }

  // getEmployeeList() async {
  //   try {
  //     // Utils.customLoadingWidget();
  //     // _users = LocalDB.getAllUsers();
  //     updateLoadingStatus(true);
  //
  //     _users = await FirebaseService().fetchEmployeeDetails();
  //
  //     updateLoadingStatus(false);
  //   } on FirebaseAuthException catch (e) {
  //     updateLoadingStatus(false);
  //     print("error--> ${e.message}"); // Return error message
  //   }
  // }

  // getEmployeeList(){
  //   _users = LocalDB.getAllUsers();
  //   print("users list is--> $users");
  //   notifyListeners();
  // }

  deleteSingleUser(int id, String empId, String createdAt) async {
  //  await LocalDB.deleteUser(key);
  try{
    Utils.customLoadingWidget();
    SupaBaseService().deleteSingleEmployeeDetails(id, empId, createdAt).then((value) {
      Get.back();
     }
    );
  } catch (e) {
     Get.back();
     print("error--> $e"); // Return error message
  }
  }

  logoutUser() async {
    Utils.customLoadingWidget();
    try{
      await SupaBaseService().signOut();
      await SharedPref.clearSharedPreference();
      Get.offAllNamed(RoutesName.signInScreen);
    }
    catch(e){
      Get.back();
      print("error--> $e");
    }
  }

  getDeviceVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    _appVersion = packageInfo.version;
    debugPrint("version is: $_appVersion");
  }

  void updateUi() {
    print("update Ui");
    notifyListeners();
  }

}