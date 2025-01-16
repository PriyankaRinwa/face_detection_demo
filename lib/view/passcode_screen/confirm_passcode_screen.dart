import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_ml_face_detection/Utils/utils/images.dart';
import 'package:google_ml_face_detection/Utils/utils/pinput.dart';
import 'package:google_ml_face_detection/Utils/utils/sized_box.dart';
import 'package:google_ml_face_detection/Utils/utils/utils.dart';
import 'package:google_ml_face_detection/provider/confirm_passcode_provider/confirm_passcode_provider.dart';
import 'package:provider/provider.dart';

class ConfirmPasscodeScreen extends StatelessWidget {
  ConfirmPasscodeScreen({super.key});
  var argumentData = Get.arguments;
  String? fromScreen;
  String enterPasscode = "";

  @override
  Widget build(BuildContext context) {
    ConfirmPasscodeProvider confirmPasscodeProvider = Provider.of<ConfirmPasscodeProvider>(context, listen: false);
    enterPasscode = argumentData["passcode"];
    fromScreen = argumentData["from_screen"];
    return GestureDetector(
      onTap: ()=> CommonMethodsClass.closeKeyboard(context),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          scrolledUnderElevation: 0.0,
          leading: InkWell(
              onTap: ()=> Get.back(),
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0, top: 16),
                child: CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.black,
                    child: Utils.defaultIcon(icon: Icons.chevron_left, color: Colors.white, size: 26)),
              )),
          automaticallyImplyLeading: false,
        ),
        resizeToAvoidBottomInset: false,
        body: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               sizedBoxHeight_10,
              Align(
                  alignment: Alignment.center,
                  child: Utils.svgAssetImage(assetPath: AppImages.kCompanyLogo)),
              sizedBoxHeight_70,
              Utils.defaultText(text: "Confirm Passcode", fontSize: 24, fontWeight: FontWeight.w700, color: Colors.black),
              sizedBoxHeight_18,
              Utils.defaultText(text: "Confirm your passcode you just entered." , fontSize: 15, fontWeight: FontWeight.w400, color: Colors.grey),
              sizedBoxHeight_15,
              PinputScreen(
                  controller: confirmPasscodeProvider.pinputController,
                  onChangedCallback: (code){
                    print("OTP entered: $code");
                    confirmPasscodeProvider.callConfirmPasscode(code);
                  }),
              sizedBoxHeight_25,
              Container(
                alignment: Alignment.centerRight,
                child: Utils.defaultElevatedButton(
                    onPressed: () {
                      confirmPasscodeProvider.callConfirmPasscodeMethod(enterPasscode, fromScreen!);
                    }, buttonText: 'Continue', icon: Icons.arrow_right
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
