import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_ml_face_detection/Utils/routes/routes_name.dart';
import 'package:google_ml_face_detection/Utils/utils/images.dart';
import 'package:google_ml_face_detection/Utils/utils/pinput.dart';
import 'package:google_ml_face_detection/Utils/utils/sized_box.dart';
import 'package:google_ml_face_detection/Utils/utils/utils.dart';
import 'package:google_ml_face_detection/provider/set_passcode_provider/set_passcode_provider.dart';
import 'package:provider/provider.dart';

class SetPasscodeScreen extends StatelessWidget {
  SetPasscodeScreen({super.key});
  var argumentData = Get.arguments;
  String fromScreen = RoutesName.signInScreen;

  @override
  Widget build(BuildContext context) {
    SetPasscodeProvider setPasscodeProvider = Provider.of<SetPasscodeProvider>(context, listen: false);
    fromScreen = argumentData["from_screen"];
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop){
        if(didPop){
          return;
        }
        Get.back();
      },
      child: GestureDetector(
        onTap: ()=> CommonMethodsClass.closeKeyboard(context),
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            scrolledUnderElevation: 0.0,
            backgroundColor: Colors.white,
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
                  Utils.defaultText(text: "Set Passcode", fontSize: 24, fontWeight: FontWeight.w700, color: Colors.black),
                  sizedBoxHeight_18,
                  Utils.defaultText(text: "Please enter your 6-digit code for new passcode.", fontSize: 15, fontWeight: FontWeight.w400, color: Colors.grey),
                  sizedBoxHeight_15,
                  PinputScreen(
                      controller: setPasscodeProvider.pinputController,
                      onChangedCallback: (code){
                        print("code entered: $code");
                        setPasscodeProvider.callPasscode(code);
                      }),
                  sizedBoxHeight_25,

                  Container(
                    alignment: Alignment.centerRight,
                    child: Utils.defaultElevatedButton(
                        onPressed: () {
                          setPasscodeProvider.callPasscodeMethod(fromScreen);
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
