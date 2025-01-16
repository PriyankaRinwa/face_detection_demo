import 'package:get/get.dart';
import 'package:google_ml_face_detection/Utils/routes/routes_name.dart';
import 'package:google_ml_face_detection/view/add_employee_screen/add_employee_screen.dart';
import 'package:google_ml_face_detection/view/attendance_record_screen/attendance_record_screen.dart';
import 'package:google_ml_face_detection/view/dashboard_screen/dashboard_screen.dart';
import 'package:google_ml_face_detection/view/face_detector_screen/camera_detection_screen.dart';
import 'package:google_ml_face_detection/view/forgot_passcode_screen/forgot_passcode_screen.dart';
import 'package:google_ml_face_detection/view/passcode_screen/confirm_passcode_screen.dart';
import 'package:google_ml_face_detection/view/passcode_screen/passcode_screen.dart';
import 'package:google_ml_face_detection/view/passcode_screen/set_passcode_screen.dart';
import 'package:google_ml_face_detection/view/sign_in_screen/sign_in_screen.dart';
import 'package:google_ml_face_detection/view/splash_screen/splash_screen.dart';

class Routes{
  static List<GetPage>? appRoutes()=>
    [
      GetPage(name: RoutesName.splashScreen, page: () => const SplashScreen()),
      GetPage(name: RoutesName.signInScreen, page: () => const SignInScreen()),
      GetPage(name: RoutesName.cameraDetectionScreen, page: () => const CameraDetectionScreen()),
      GetPage(name: RoutesName.passcodeScreen, page: () => PasscodeScreen()),
      GetPage(name: RoutesName.setPasscodeScreen, page: () => SetPasscodeScreen()),
      GetPage(name: RoutesName.confirmPasscodeScreen, page: () => ConfirmPasscodeScreen()),
      GetPage(name: RoutesName.dashBoardScreen, page: () => const DashboardScreen()),
      GetPage(name: RoutesName.addEmployeeScreen, page: () => AddEmployeeScreen()),
      GetPage(name: RoutesName.forgotPaasCodeScreen, page: () => const ForgotPaasCodeScreen()),
      GetPage(name: RoutesName.attendanceRecordScreen, page: () => const AttendanceRecordScreen()),
    ];

}