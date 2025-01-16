import 'package:flutter/material.dart';
import 'package:google_ml_face_detection/Utils/utils/images.dart';
import 'package:google_ml_face_detection/Utils/utils/utils.dart';
import 'package:google_ml_face_detection/provider/splash_screen_provider/splash_screen_provider.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget  {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    initializeAnimation();
    Provider.of<SplashScreenProvider>(context, listen: false).openScreen();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  void initializeAnimation(){

    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..forward();

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
            child: ScaleTransition(
                scale: _animation,
                child: Utils.svgAssetImage(assetPath: AppImages.kCompanyLogo),
               // Image.asset("assets/splash_screen_logo.png", width: Get.width * 0.5, height: Get.height * 0.2, fit: BoxFit.fill)
            )
        )
    );
  }

}