import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_ml_face_detection/Utils/routes/routes_name.dart';
import 'package:google_ml_face_detection/Utils/service/supabase_service.dart';
import 'package:google_ml_face_detection/Utils/utils/utils.dart';
import 'package:google_ml_face_detection/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ForgotPassCodeProvider extends ChangeNotifier{
  TextEditingController emailController = TextEditingController();
  bool _isOtpReceived = false;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String? otp;
  String? email;
  bool get isOtpReceived => _isOtpReceived;
  TextEditingController pinputController = TextEditingController();
  String? userEmail;

  changeEmail(){
    pinputController.clear();
    _isOtpReceived = false;
    notifyListeners();
  }


  Future<void> getOtp() async {
    if (userEmail == emailController.text) {
        try{
            Utils.customLoadingWidget();
            await SupaBaseService().signInWIthOtp(email: emailController.text);
            Get.back();
            _isOtpReceived = true;
            notifyListeners();
          } catch (e) {
             print("error--> $e");
            Get.back();
            if(e is AuthException){
            Utils.defaultFlutterToast(text: e.message);
           }else{
              Utils.defaultFlutterToast(text: e.toString());
            }
          }
      }else{
          Utils.defaultFlutterToast(text: "Sign in email is not matched");
        }

  }

  Future<void> verifyOtp() async {
    try{
      Utils.customLoadingWidget();
      AuthResponse? authResponse = await SupaBaseService().verifyOtp(email: emailController.text, otp: otp!);
      Get.back();
      if (authResponse?.session != null && authResponse?.user != null) {
        clearValues();
        Get.toNamed(RoutesName.setPasscodeScreen, arguments: {"from_screen": RoutesName.forgotPaasCodeScreen});
      }else{
        Utils.defaultFlutterToast(text: "something went wrong");
      }
  } catch (e) {
    print("error--> $e");
     Get.back();
     if(e is AuthException){
       Utils.defaultFlutterToast(text: e.message);
     }else{
       Utils.defaultFlutterToast(text: e.toString());
     }
   }
  }

  void clearValues() {
     _isOtpReceived = false;
     pinputController.clear();
     notifyListeners();
  }

  Future<void> getUserData() async {
    UserModel? userModel = await SupaBaseService().getSingleUSerData();
    if (userModel != null) {
      userEmail = userModel.email;
      emailController.text = userEmail!;
    }
    else{

    }
  }


}