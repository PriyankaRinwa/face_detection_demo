import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_ml_face_detection/Utils/routes/routes_name.dart';
import 'package:google_ml_face_detection/Utils/utils/images.dart';
import 'package:google_ml_face_detection/Utils/utils/pinput.dart';
import 'package:google_ml_face_detection/Utils/utils/sized_box.dart';
import 'package:google_ml_face_detection/Utils/utils/utils.dart';
import 'package:google_ml_face_detection/provider/passcode_provider/passcode_provider.dart';
import 'package:provider/provider.dart';

class PasscodeScreen extends StatelessWidget {
  const PasscodeScreen({super.key});


  @override
  Widget build(BuildContext context) {
    PasscodeProvider passcodeProvider = Provider.of<PasscodeProvider>(context, listen: false);
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop){
        if(didPop){
          return;
        }
        Get.offAllNamed(RoutesName.cameraDetectionScreen, arguments: {
          "is_new_user": false,
        });
      },
      child: GestureDetector(
        onTap: ()=> CommonMethodsClass.closeKeyboard(context),
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar:
          // (!fromLogin) ?
          AppBar(
            scrolledUnderElevation: 0.0,
            backgroundColor: Colors.white,
            leading: InkWell(
                onTap: ()=>  Get.offAllNamed(RoutesName.cameraDetectionScreen, arguments: {
                  "is_new_user": false,
                }),
                child: Padding(
                  padding: const EdgeInsets.only(left: 16.0, top: 16),
                  child: CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.black,
                      child: Utils.defaultIcon(icon: Icons.chevron_left, color: Colors.white, size: 26)),
                )),
            automaticallyImplyLeading: false,
          ),
              // :  null,
          body: SingleChildScrollView(
            child: Padding(
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
                 // Utils.defaultText(text: "Passcode", fontSize: 24, fontWeight: FontWeight.w700, color: Colors.black),
                   Utils.defaultText(text: "Enter Passcode", fontSize: 24, fontWeight: FontWeight.w700, color: Colors.black),
                  sizedBoxHeight_18,
                  Utils.defaultText(text: "Please enter your 6-digit code.", fontSize: 15, fontWeight: FontWeight.w400, color: Colors.grey),
                  sizedBoxHeight_15,
                  PinputScreen(
                      controller: passcodeProvider.pinputController,
                      onChangedCallback: (code){
                        print("code entered: $code");
                        passcodeProvider.callPasscode(code);
                  }),
                  sizedBoxHeight_25,

                    Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 25.0),
                      child: Utils.defaultTextWithClickable(
                          voidCallback: () {
                            passcodeProvider.callForgotPasscodeScreen();
                          },
                          text: "Forgot Passcode?", fontSize: 14, fontWeight: FontWeight.w700, color: Colors.blueAccent),
                    ),
                  ),

                    Container(
                    alignment: Alignment.centerRight,
                    child: Utils.defaultElevatedButton(
                        onPressed: () {
                          passcodeProvider.callPasscodeMethod();
                        }, buttonText: 'Continue', icon: Icons.arrow_right
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
