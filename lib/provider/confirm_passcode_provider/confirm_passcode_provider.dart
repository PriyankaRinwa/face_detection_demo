import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:google_ml_face_detection/Utils/routes/routes_name.dart';
import 'package:google_ml_face_detection/Utils/service/supabase_service.dart';
import 'package:google_ml_face_detection/Utils/utils/utils.dart';

class ConfirmPasscodeProvider extends ChangeNotifier{
  String? _confirmPasscode;
  TextEditingController pinputController = TextEditingController();

  String? get confirmPasscode => _confirmPasscode;

  callConfirmPasscode(String code){
    _confirmPasscode = code;
  }

  callConfirmPasscodeMethod(String passcode, String fromScreen){
    if ((_confirmPasscode?.length ?? 0) < 5) {
      Utils.defaultFlutterToast(text: "Please submit confirm passcode");
    } else if (passcode != _confirmPasscode) {
      Utils.defaultFlutterToast(text: "passcode should be same");
    } else {
      try {
        Utils.customLoadingWidget();
        SupaBaseService().updatePasscode(passcode: passcode).whenComplete((){
          // _confirmPasscode = null;
          Get.back();
          clearValues();
          if(fromScreen == RoutesName.signInScreen) {
            Get.offAllNamed(RoutesName.cameraDetectionScreen, arguments: {
              "is_new_user": false,
            });
          }else{
            Get.until((route)=> Get.currentRoute == RoutesName.passcodeScreen);
            Utils.defaultFlutterToast(text: "Passcode is successfully changed.");
          }
        });
      } catch (e) {
        Get.back();
        print("error--> $e"); // Return error message
      }
    }
  }

  clearValues(){
    _confirmPasscode = null;
    pinputController.clear();
  }

}