import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:get/get.dart';
import 'package:google_ml_face_detection/Utils/routes/routes.dart';
import 'package:google_ml_face_detection/Utils/routes/routes_name.dart';
import 'package:google_ml_face_detection/Utils/service/notification_service.dart';
import 'package:google_ml_face_detection/Utils/utils/service_key.dart';
import 'package:google_ml_face_detection/locator.dart';
import 'package:google_ml_face_detection/provider/add_employee_provider/add_employee_provider.dart';
import 'package:google_ml_face_detection/provider/attendance_record_provider/attendance_record_provider.dart';
import 'package:google_ml_face_detection/provider/confirm_passcode_provider/confirm_passcode_provider.dart';
import 'package:google_ml_face_detection/provider/set_passcode_provider/set_passcode_provider.dart';
import 'package:google_ml_face_detection/provider/sign_in_provider/sign_in_provider.dart';
import 'package:google_ml_face_detection/provider/splash_screen_provider/splash_screen_provider.dart';
import 'package:google_ml_face_detection/view/unknown_route_screen/unknown_route_screen.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'provider/dashboard_provider/dashboard_provider.dart';
import 'provider/forgot_passcode_provider/forgot_passcode_provider.dart';
import 'provider/passcode_provider/passcode_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );
  await Supabase.initialize(
    url: ServiceKey.superBaseUrl,
    anonKey: ServiceKey.superBaseAnonKey,
  );
  setupServices();
  // await Hive.initFlutter();
  // await HiveBoxes.initialize();
  cameras = await availableCameras();
  NotificationService.requestPermissions();
  NotificationService.initialize();
  // mainCommon();
  runApp(const MyApp());
}

List<CameraDescription> cameras = [];

// Future<void> mainCommon() async{
//   WidgetsFlutterBinding.ensureInitialized();
//   cameras = await availableCameras();
// }

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_)=> SplashScreenProvider()),
        ChangeNotifierProvider(create: (_)=> SignInProvider()),
        ChangeNotifierProvider(create: (_)=> PasscodeProvider()),
        ChangeNotifierProvider(create: (_)=> SetPasscodeProvider()),
        ChangeNotifierProvider(create: (_)=> ConfirmPasscodeProvider()),
        ChangeNotifierProvider(create: (_)=> DashboardProvider()),
        ChangeNotifierProvider(create: (_)=> AddEmployeeProvider()),
        ChangeNotifierProvider(create: (_)=> ForgotPassCodeProvider()),
        ChangeNotifierProvider(create: (_)=> AttendanceRecordProvider()),
      ],
      child: GetMaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
          useMaterial3: true,
        ),
        initialRoute: RoutesName.splashScreen,
        getPages: Routes.appRoutes(),
        unknownRoute: GetPage(name: RoutesName.unknownRoute, page: () => const UnknownRouteScreen()),
       // home: const MyHomePage(title: 'Flutter Demo Home Page'),
      ),
    );
  }
}
