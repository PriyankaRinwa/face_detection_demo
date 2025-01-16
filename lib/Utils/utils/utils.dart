import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_ml_face_detection/Utils/utils/sized_box.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Utils{

  static Widget defaultTextWithClickable({VoidCallback? voidCallback, required String text, double? fontSize, FontWeight? fontWeight, Color? color, TextAlign? textAlign}){
    return InkWell(
        onTap: (){
          if(voidCallback!=null) voidCallback();
        },
        child: Text(text, style: TextStyle(fontSize: fontSize, fontWeight: fontWeight, color: color), textAlign: textAlign));
  }

  static Widget defaultText({required String text, double? fontSize, FontWeight? fontWeight, Color? color, TextAlign? textAlign}){
    return Text(text, style: TextStyle(fontSize: fontSize, fontWeight: fontWeight, color: color), textAlign: textAlign);
  }

  static defaultSnackBar({required BuildContext context, required String text}){
    SnackBar snackBar = SnackBar(
        content: Text(text),
        duration: const Duration(milliseconds: 100));

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static Widget defaultElevatedButton({Function? onPressed, required String buttonText, IconData? icon, double? width, Color buttonBackgroundColor = Colors.black, Color textColor = Colors.white, double? fontSize, Color iconColor = Colors.white}){
    return SizedBox(
      height: 48,
      width: width ?? Get.width,
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: buttonBackgroundColor
          ),
          onPressed: (){
            if(onPressed!=null) onPressed();
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Utils.defaultText(text: buttonText, color: textColor, fontSize: fontSize),
              sizedBoxWidth_8,
              if(icon!=null)defaultIcon(icon: icon, color: iconColor)
            ],
          )
      ),
    );
  }

  static Icon defaultIcon({required IconData icon, double size = 20, Color color = Colors.white}){
   return Icon(icon, size: size, color: color);
  }

  static defaultFlutterToast({required String text}){
    Fluttertoast.showToast(
        msg: text,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        textColor: Colors.white,
        backgroundColor: Colors.blueAccent,
        fontSize: 16.0
    );
  }

  static  defaultAlertDialog({required String contentText, VoidCallback? cancelCallBack, VoidCallback? confirmCallback}){
    // return showDialog(
    //     context: context, builder: (BuildContext context) {
    //     return AlertDialog(
    //       content: Text("bsdbivbdishv"),
    //     );
    // },
    // );

     return Get.dialog(
        AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Utils.defaultText(text: contentText, fontSize: 18, fontWeight: FontWeight.w500),
              sizedBoxHeight_20,
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Utils.defaultTextWithClickable(text: "Cancel", voidCallback: () {
                    if(cancelCallBack!=null) cancelCallBack();
                  }, color: Colors.red),
                  sizedBoxWidth_12,
                  Utils.defaultTextWithClickable(text: "Confirm", voidCallback: () {
                    if(confirmCallback!=null) confirmCallback();
                  }, color: Colors.blue),
                ],
              )
            ],
          ),
        )
        );
  }

  static defaultCupertinoDialog({required BuildContext context, required String contentText, String? titleText, VoidCallback? cancelCallBack, VoidCallback? confirmCallback})  {
    return showCupertinoDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          //  title: Text('Alert Title'),
          // content: Text('Are you sure you want to delete this chat.',),
          title: (titleText!=null) ?
           Padding(
             padding: const EdgeInsets.only(bottom: 4.0),
             child: Utils.defaultText(
              text: titleText,
              fontSize: 18.0,
              fontWeight: FontWeight.w500,
              color: Colors.blue,
                       ),
           )
              : null,
          content: Utils.defaultText(
            text: contentText,
            fontSize: 15.0,
            fontWeight: FontWeight.w400,
            color: Colors.black,
          ),
          actions: <Widget>[
            if(cancelCallBack!=null)
              CupertinoDialogAction(
              child: const Text('Cancel', style: TextStyle(color: Colors.red)),
              onPressed: () {
                cancelCallBack();
              },
            ),
            if(confirmCallback!=null)
            CupertinoDialogAction(
              child: const Text('Ok', style: TextStyle(color: Colors.blue)),
              onPressed: () {
                confirmCallback();
              },
            ),
          ],
        );
      },
    );
  }

  static TextFormField defaultTextFormField({required TextEditingController controller, Function(String?)? validationCallback, String? hintText, String? labelText, Widget? prefix, Widget? suffix, bool readOnly = false, TextInputType? textInputType, TextInputAction? textInputAction, List<TextInputFormatter>? textInputFormatter}){
    return TextFormField(
        controller: controller,
        readOnly: readOnly,
        keyboardType: textInputType,
        validator: (value) => validationCallback!=null ? validationCallback(value) : null,
        textInputAction: textInputAction,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        inputFormatters: textInputFormatter,
        decoration: InputDecoration(
            hintText: hintText,
            labelText: labelText,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: const BorderSide(color: Colors.grey, width: 1.5)
            ),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: const BorderSide(color: Colors.grey, width: 1.5)
            ),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: const BorderSide(color: Colors.grey, width: 1.5)
            ),
          prefixIcon: prefix,
          suffixIcon: suffix
        )
    );
  }

  static SvgPicture svgAssetImage({required String assetPath}){
    return SvgPicture.asset(
        assetPath,
        semanticsLabel: 'Logo'
    );
  }

  static customLoadingWidget(){
    return Get.dialog(
        Container(
          height: Get.height,
          width: Get.width,
          color: Colors.black.withOpacity(0.5),
          child: const SpinKitWave(
            color: Colors.white,
             size: 40,
          ),
        ));
  }

}

class CommonMethodsClass{

  static closeKeyboard(BuildContext context){
    FocusScopeNode currentFocus = FocusScope.of(context);
    if(!currentFocus.hasPrimaryFocus){
      currentFocus.unfocus();
    }
  }


}