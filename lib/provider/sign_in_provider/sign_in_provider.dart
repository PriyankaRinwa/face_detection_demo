import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:google_ml_face_detection/Utils/routes/routes_name.dart';
import 'package:google_ml_face_detection/Utils/service/supabase_service.dart';
import 'package:google_ml_face_detection/Utils/shared_preference/shared_prefrence.dart';
import 'package:google_ml_face_detection/Utils/utils/utils.dart';
import 'package:google_ml_face_detection/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignInProvider extends ChangeNotifier{
  TextEditingController emailController = TextEditingController();
  bool _isOtpReceived = false;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String? otp;
  String? email;
  bool get isOtpReceived => _isOtpReceived;
  TextEditingController pinputController = TextEditingController();
  // bool _isLoading = false;
  // bool get isLoading => _isLoading;

  changeEmail(){
    pinputController.clear();
    _isOtpReceived = false;
    notifyListeners();
  }

  /*  Future<void> getSingleUserDataFromFirebase() async {
    try {

      // Utils.customLoadingWidget();

      FirebaseService().getSingleUserData().then((data) {
        print("data is: $data");
        if (data != null) {
          otp = data["otp"] ?? "123456";
          email = data["email"] ?? "";
        }
        // Get.back();
        // _isOtpReceived = true;
        // notifyListeners();
      });

    } on FirebaseAuthException catch (e) {
      // Get.back();
      debugPrint("error is: $e");
    }
  }*/

  Future<void> getOtp() async {
    try {
      Utils.customLoadingWidget();
      await SupaBaseService().signInWIthOtp(email: emailController.text);
      Get.back();
      _isOtpReceived = true;
        notifyListeners();
    }
    catch (e) {
      print("error--> $e");
      Get.back();
      if(e is AuthException){
        Utils.defaultFlutterToast(text: e.message);
      }else{
        Utils.defaultFlutterToast(text: e.toString());
      }
    }

  }

  // Future<bool> isEmailExistInCloudFirestore() async {
  //   List<Map<String, dynamic>> arrEmail = await FirebaseService().fetchUsersEmail();
  //   print("arrEmail--> $arrEmail");
  //   for(var email in arrEmail){
  //     if(emailController.text == email["email"]){
  //       return true;
  //     }
  //   }
  //   return false;
  // }

  Future<void> callSignUpSignInMethod() async{

    try {
      Utils.customLoadingWidget();
      AuthResponse? authResponse = await SupaBaseService().verifyOtp(email: emailController.text, otp: otp!);
      Get.back();
      if (authResponse?.session != null && authResponse?.user != null) {
        SharedPref.setAccessToken(accessToken: authResponse?.session!.accessToken??"");
        //Check if the user exists in the "users" table
        UserModel? userModel = await SupaBaseService().getSingleUSerData();
        if (userModel == null) {
          // No user found; this is a first-time login, so add user details
          await SupaBaseService().addUserDetails();
          Get.toNamed(RoutesName.setPasscodeScreen, arguments: {"from_screen": RoutesName.signInScreen});
        }
        else {
          print("old user detected.");
          if(userModel.passcode==null){
            Get.toNamed(RoutesName.setPasscodeScreen, arguments: {"from_screen": RoutesName.signInScreen});
          }else{
            Get.offAllNamed(RoutesName.cameraDetectionScreen, arguments: {
              "is_new_user": false,
            });
          }
        }
        clearValues();
      }
    }
    // on AuthException{
    //   Get.back();
    //   Fluttertoast.showToast(msg: msg);
    //   // AuthException().statusCode. == 403
    // }
    catch (e) {
      print("error--> $e");
      Get.back();
      if(e is AuthException){
        Utils.defaultFlutterToast(text: e.message);
      }else{
        Utils.defaultFlutterToast(text: e.toString());
      }// Return error message
    }
  }

  void clearValues() {
   // emailController.clear();
    _isOtpReceived = false;
    pinputController.clear();
    notifyListeners();
  }

}