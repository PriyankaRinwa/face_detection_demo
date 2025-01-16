import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinput/pinput.dart';

class PinputScreen extends StatelessWidget {
  Function(dynamic)? onCompleteCallback;
  Function(dynamic)? onChangedCallback;
  TextEditingController controller;

  PinputScreen({this.onCompleteCallback, this.onChangedCallback, required this.controller, super.key});

  @override
  Widget build(BuildContext context) {
    return Pinput(
      controller: controller,
      autofocus: false,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly, // Allow only digits
      ],
      length: 6, // Set the number of OTP digits
      onCompleted: (otp) {
        if(onCompleteCallback!=null) onCompleteCallback!(otp);// Handle OTP submission
      },
      showCursor: true,
      onChanged: (value) {
        if(onChangedCallback!=null) onChangedCallback!(value);
      },
      keyboardType: TextInputType.number,
      scrollPadding: const EdgeInsets.only(bottom: 200),
      focusedPinTheme: PinTheme(
        width: 56,
        height: 56,
        textStyle: const TextStyle(
          fontSize: 20,
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.black, width: 1.5),
        ),
      ),
      defaultPinTheme: PinTheme(
        width: 56,
        height: 56,
        textStyle: const TextStyle(
          fontSize: 20,
          color: Colors.grey,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey),
        ),
      ),
      submittedPinTheme: PinTheme(
        width: 56,
        height: 56,
        textStyle: const TextStyle(
          fontSize: 20,
          color: Colors.black,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.black, width: 1.5),
        ),
      ),
    );
  }
}
