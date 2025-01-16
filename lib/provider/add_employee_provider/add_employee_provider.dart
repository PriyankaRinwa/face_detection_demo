import 'dart:io';
import 'package:google_ml_face_detection/Utils/routes/routes_name.dart';
import 'package:google_ml_face_detection/Utils/service/supabase_service.dart';
import 'package:google_ml_face_detection/view/face_detector_screen/image_converter.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:google_ml_face_detection/Utils/utils/utils.dart';
import 'package:google_ml_face_detection/models/employee_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddEmployeeProvider extends ChangeNotifier{
  TextEditingController employeeIdController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String? _imagePath;
  String? _imageNetworkUrl;
  List? predictedArray;

  String? get imagePath => _imagePath;
  String? get imageNetworkUrl => _imageNetworkUrl;


  Future<void> fetchSingleEmployeeData({required int id}) async {
    try {
      EmployeeModel? employeeModel = await SupaBaseService().getSingleEmployeeData(id: id);
      if (employeeModel != null) {
        _imageNetworkUrl = employeeModel.imageUrl;
        print("url is: $imageNetworkUrl");
        predictedArray = employeeModel.imageData;
        employeeIdController.text = employeeModel.empId ?? "";
        nameController.text = employeeModel.name ?? "";
        emailController.text = employeeModel.email ?? "";
        String dateTime = DateTime.parse(employeeModel.createdAt!).toIso8601String();
        print("timestamp is--> ${DateTime.parse(dateTime).millisecondsSinceEpoch}");
        notifyListeners();
      }
    } catch (e) {
      print("Error fetching single employee data: $e");
    }

  }

  Future<void> setUserDetails(EmployeeModel employeeModel) async {
    try {
      Utils.customLoadingWidget();

      /// fetching data using firebase get method
      List<EmployeeModel>? employees = await SupaBaseService().fetchAllEmployees();
      if(employees!=null){
        for (var employeeData in employees) {
          print("userData");
          if(employeeData.empId?.toUpperCase() == employeeModel.empId?.toUpperCase()){
            Get.back();
            Utils.defaultFlutterToast(text: "Employee id shouldn't be equal");
            return;
          }
        }

        if(imagePath!=null) {
          File? file = await correctImageOrientation(File(imagePath!));
          if(file!=null) {
            String? imageUrl = await SupaBaseService().uploadImage(file, employeeModel.createdAt ?? DateTime.now().toIso8601String(), employeeModel.empId??"0");
            employeeModel.imageUrl = imageUrl;
          }
        }

          SupaBaseService().addEmployeeDetails(employeeModel).then((value) {
            // Get.close(2);
            Get.until((route)=> Get.currentRoute == RoutesName.dashBoardScreen);
            Utils.defaultFlutterToast(text: "Employee data successfully added.");
           // clearProviderValues();
          });
        }


    }on PostgrestException catch (error) {
      Utils.defaultFlutterToast(text:error.message);
      Get.back();
    } catch (e) {
       Get.back();
      print("error--> $e"); // Return error message
    }
    finally{
      // Get.back();
    }
    // LocalDB.setUserDetails(user);
  }

  Future<void> updateUserDetails(EmployeeModel employeeModel, int id) async {
    try {
      Utils.customLoadingWidget();

     // List<EmployeeModel> users = await FirebaseService().fetchAllEmployeeDetailsExceptOwn(documentId);
      List<EmployeeModel>? employees = await SupaBaseService().fetchAllEmployeesExceptOwnData(id: id);
      /// fetching data using firebase get method
      if(employees!=null) {
        for (var employeeData in employees) {
          print("userData");
          if (employeeData.empId?.toUpperCase() == employeeModel.empId?.toUpperCase()) {
            Get.back();
            Utils.defaultFlutterToast(text: "Employee id shouldn't be equal");
            return;
          }
        }
      }

      if(imagePath!=null) {
        File? file = await correctImageOrientation(File(imagePath!));
        if(file!=null) {
          String? imageUrl = await SupaBaseService().uploadImage(file, employeeModel.createdAt ?? DateTime.now().toIso8601String(), employeeModel.empId??"0");
          employeeModel.imageUrl = imageUrl;
        }
      }else{
        employeeModel.imageUrl = _imageNetworkUrl;
      }

      SupaBaseService().updateEmployeeDetails(employeeModel, id).then((value) {
        Get.until((route)=> Get.currentRoute == RoutesName.dashBoardScreen);
        Utils.defaultFlutterToast(text: "Employee data successfully updated.");
        // clearProviderValues();
      });
    } on PostgrestException catch (error) {
      Utils.defaultFlutterToast(text:error.message);
      Get.back();
    } catch (e) {
      Get.back();
      print("error--> $e"); // Return error message
    }
    // LocalDB.setUserDetails(user);
  }

  updateProfile(String? image){
    _imagePath = image;
    _imageNetworkUrl = null;
    notifyListeners();
  }


  void clearProviderValues() {
    _imagePath = null;
    _imageNetworkUrl = null;
    predictedArray = null;
    employeeIdController.clear();
    nameController.clear();
    emailController.clear();
  }

}