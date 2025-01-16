import 'package:flutter/material.dart';
import 'package:google_ml_face_detection/Utils/utils/images.dart';
import 'package:google_ml_face_detection/Utils/utils/pinput.dart';
import 'package:google_ml_face_detection/Utils/utils/sized_box.dart';
import 'package:google_ml_face_detection/Utils/utils/utils.dart';
import 'package:google_ml_face_detection/Utils/utils/validation.dart';
import 'package:google_ml_face_detection/provider/sign_in_provider/sign_in_provider.dart';
import 'package:provider/provider.dart';

class SignInScreen extends StatelessWidget{
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    print("build");
    SignInProvider signInProvider = Provider.of<SignInProvider>(context, listen: false);
    // signInProvider.getSingleUserDataFromFirebase();
    return GestureDetector(
      onTap: ()=> CommonMethodsClass.closeKeyboard(context),
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: true,
        body: SingleChildScrollView(
          //controller: signInProvider.scrollController,
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Form(
              key: signInProvider.formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  sizedBoxHeight_40,
                  Utils.svgAssetImage(assetPath: AppImages.kCompanyLogo),
                  sizedBoxHeight_50,
                  Align(
                      alignment: Alignment.centerLeft,
                      child: Utils.defaultText(text: "Login", fontSize: 24, fontWeight: FontWeight.w700, color: Colors.black)),
                  sizedBoxHeight_25,
                  Selector<SignInProvider, bool>(
                      selector: (context, signInProvider) => signInProvider.isOtpReceived,
                      builder: (context, isOtpReceived, child) {
                        print("build only selector item");
                        print("isOtpReceived--> $isOtpReceived");
                        return Column(
                          children: [

                            /// Email text field
                            Utils.defaultTextFormField(
                                controller: signInProvider.emailController,
                                validationCallback: (value)=> Validation.emailValidation(value),
                                hintText: "Enter Email",
                                labelText: "Email",
                                readOnly : isOtpReceived,
                                textInputType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.done,
                                prefix: Utils.defaultIcon(icon :Icons.email, color: Colors.grey),
                                suffix: (isOtpReceived) ? InkWell(
                                    onTap: ()=> signInProvider.changeEmail(),
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

                             Utils.defaultText(text: "An 6 digit code has been sent to ${signInProvider.emailController.text}", fontSize: 15, fontWeight: FontWeight.w400, color: Colors.grey),

                             /// Otp enter pinput field
                             Padding(
                               padding: const EdgeInsets.symmetric(vertical: 20.0),
                               child: PinputScreen(
                                 controller: signInProvider.pinputController,
                                  onChangedCallback: (otp){
                                        print("OTP entered: $otp");
                                        signInProvider.otp = otp;
                                      }),
                               )
                            ],

                            /// Submit Button
                            (!isOtpReceived) ?
                            Utils.defaultElevatedButton(
                                 onPressed: () {
                                 if(signInProvider.formKey.currentState!.validate()){
                                     signInProvider.getOtp();
                                  }
                                }, buttonText: 'Submit', icon: Icons.arrow_right,
                               )
                                : Utils.defaultElevatedButton(
                              onPressed: () {
                                 if((signInProvider.otp?.length??0) > 5){
                                      signInProvider.callSignUpSignInMethod();
                                 }else{
                                    Utils.defaultFlutterToast(text: "Please enter valid otp.");
                                  }
                              }, buttonText: 'Continue', icon: Icons.arrow_right, fontSize: 20
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