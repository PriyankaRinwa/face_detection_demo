import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:google_ml_face_detection/Utils/routes/routes_name.dart';
import 'package:google_ml_face_detection/Utils/service/supabase_service.dart';
import 'package:google_ml_face_detection/Utils/utils/utils.dart';
import 'package:google_ml_face_detection/models/user_model.dart';

class PasscodeProvider extends ChangeNotifier{
  String? _passcode;
  TextEditingController pinputController = TextEditingController();

  String? get passcode => _passcode;

  static const platform = MethodChannel('com.iAttendy.app.pinning');

  callPasscode(String code){
    _passcode = code;
  }


  Future<void> callPasscodeMethod() async {
    if ((_passcode?.length ?? 0) < 5) {
        Utils.defaultFlutterToast(text: "Please submit passcode");
      } else{
      try {
        Utils.customLoadingWidget();
        UserModel? userModel = await SupaBaseService().getSingleUSerData();
        if (userModel != null) {
          // Checks Is passcode already set or not
          if (userModel.passcode == _passcode) {
            _passcode = null;
            pinputController.clear();
            unpinScreen();
            Get.offAllNamed(RoutesName.dashBoardScreen);
          } else {
            Get.back();
            Utils.defaultFlutterToast(text: "Passcode is not matched");
          }
        }
      } catch (e) {
        Get.back();
        print("error--> $e"); // Return error message
      }
      }
  }

  // Function to unpin the screen
  Future<void> unpinScreen() async {
    try {
      await platform.invokeMethod('unpinScreen');
    } on PlatformException catch (e) {
      print("Failed to unpin screen: '${e.message}'.");
    }
  }


  void callForgotPasscodeScreen(){
    _passcode = null;
    pinputController.clear();
    Get.toNamed(RoutesName.forgotPaasCodeScreen);
  }

}