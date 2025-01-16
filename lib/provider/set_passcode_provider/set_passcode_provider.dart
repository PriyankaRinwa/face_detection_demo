import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:google_ml_face_detection/Utils/routes/routes_name.dart';
import 'package:google_ml_face_detection/Utils/utils/utils.dart';

class SetPasscodeProvider extends ChangeNotifier{
  String? _passcode;
  TextEditingController pinputController = TextEditingController();

  String? get passcode => _passcode;


  callPasscode(String code){
    _passcode = code;
  }


  Future<void> callPasscodeMethod(String fromScreen) async {
    if ((_passcode?.length ?? 0) < 5) {
      Utils.defaultFlutterToast(text: "Please submit passcode");
    } else{
      Get.toNamed(RoutesName.confirmPasscodeScreen, arguments: {
        "passcode": _passcode,
        "from_screen": fromScreen
      });
    }
  }


}