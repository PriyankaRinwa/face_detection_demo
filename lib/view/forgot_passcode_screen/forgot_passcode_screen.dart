import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_ml_face_detection/Utils/utils/images.dart';
import 'package:google_ml_face_detection/Utils/utils/pinput.dart';
import 'package:google_ml_face_detection/Utils/utils/sized_box.dart';
import 'package:google_ml_face_detection/Utils/utils/utils.dart';
import 'package:google_ml_face_detection/Utils/utils/validation.dart';
import 'package:google_ml_face_detection/provider/forgot_passcode_provider/forgot_passcode_provider.dart';
import 'package:provider/provider.dart';

class ForgotPaasCodeScreen extends StatelessWidget{
  const ForgotPaasCodeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    print("build");
    ForgotPassCodeProvider forgotPassCodeProvider = Provider.of<ForgotPassCodeProvider>(context, listen: false);
     forgotPassCodeProvider.getUserData();
    return GestureDetector(
      onTap: ()=> CommonMethodsClass.closeKeyboard(context),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar:
        AppBar(
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
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Form(
              key: forgotPassCodeProvider.formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  sizedBoxHeight_20,
                  Utils.svgAssetImage(assetPath: AppImages.kCompanyLogo),
                  sizedBoxHeight_50,
                  Align(
                      alignment: Alignment.centerLeft,
                      child: Utils.defaultText(text: "Forgot Password?", fontSize: 24, fontWeight: FontWeight.w700, color: Colors.black)),
                  sizedBoxHeight_25,
                  Selector<ForgotPassCodeProvider, bool>(
                    selector: (context, forgotPassCodeProvider) => forgotPassCodeProvider.isOtpReceived,
                    builder: (context, isOtpReceived, child) {
                      print("build only selector item");
                      print("isOtpReceived--> $isOtpReceived");
                      return Column(
                        children: [

                          /// Email text field
                          Utils.defaultTextFormField(
                            controller: forgotPassCodeProvider.emailController,
                            validationCallback: (value)=> Validation.emailValidation(value),
                            hintText: "Enter Email",
                            labelText: "Email",
                            readOnly : isOtpReceived,
                            textInputType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.done,
                            prefix: Utils.defaultIcon(icon :Icons.email, color: Colors.grey),
                            suffix: (isOtpReceived) ? InkWell(
                                onTap: ()=> forgotPassCodeProvider.changeEmail(),
                                child: Utils.defaultIcon(icon :Icons.edit, color: Colors.grey))
                                : null,
                          ),
                          sizedBoxHeight_25,

                          if(isOtpReceived)
                            ...[

                              Align(
                                  alignment: Alignment.centerLeft,
                                  child: Utils.defaultText(text: "Enter Otp", fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black, textAlign: TextAlign.start)),

                              sizedBoxHeight_8,

                              Utils.defaultText(text: "An 6 digit code has been sent to ${forgotPassCodeProvider.emailController.text}", fontSize: 15, fontWeight: FontWeight.w400, color: Colors.grey),

                              /// Otp enter pinput field
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 20.0),
                                child: PinputScreen(
                                    controller: forgotPassCodeProvider.pinputController,
                                    onChangedCallback: (otp){
                                      print("OTP entered: $otp");
                                      forgotPassCodeProvider.otp = otp;
                                    }),
                              )
                            ],

                          /// Submit Button
                          (!isOtpReceived) ?
                          Utils.defaultElevatedButton(
                            onPressed: () {
                              if(forgotPassCodeProvider.formKey.currentState!.validate()){
                                  forgotPassCodeProvider.getOtp();
                              }
                            }, buttonText: 'Reset Password', icon: Icons.arrow_right,
                          )
                              : Utils.defaultElevatedButton(
                              onPressed: () {
                                if((forgotPassCodeProvider.otp?.length??0) > 5){
                                  forgotPassCodeProvider.verifyOtp();
                                }else{
                                  Utils.defaultFlutterToast(text: "Please enter valid otp.".tr);
                                }
                              }, buttonText: 'Continue'.tr, icon: Icons.arrow_right, fontSize: 20
                          )

                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}