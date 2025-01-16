import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:google_ml_face_detection/Utils/routes/routes_name.dart';
import 'package:google_ml_face_detection/Utils/service/supabase_service.dart';
import 'package:google_ml_face_detection/Utils/shared_preference/shared_prefrence.dart';
import 'package:google_ml_face_detection/models/user_model.dart';

class SplashScreenProvider extends ChangeNotifier{

  Future<void> openScreen() async {
    debugPrint("calling");
    Future.delayed(const Duration(seconds: 3), () async {
      String accessToken = await SharedPref.getAccessToken();
      if(accessToken!="") {
        UserModel? userModel = await SupaBaseService().getSingleUSerData();
        if (userModel != null) {
          // Checks Is passcode already set or not
          if (userModel.passcode == null) {
            Get.toNamed(RoutesName.passcodeScreen,
                arguments: {"from_screen": RoutesName.signInScreen});
          } else {
            Get.offAllNamed(RoutesName.cameraDetectionScreen, arguments: {
              "is_new_user": false,
            });
          }
        }
       }else {
          Get.offNamed(RoutesName.signInScreen);
        }
    });
    //callForceUpdateApi();
  }

}