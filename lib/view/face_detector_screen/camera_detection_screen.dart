import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_ml_face_detection/Utils/routes/routes_name.dart';
import 'package:google_ml_face_detection/Utils/service/supabase_service.dart';
import 'package:google_ml_face_detection/Utils/utils/sized_box.dart';
import 'package:google_ml_face_detection/Utils/utils/utils.dart';
import 'package:google_ml_face_detection/locator.dart';
import 'package:google_ml_face_detection/main.dart';
import 'package:google_ml_face_detection/models/attendance_record_model.dart';
import 'package:google_ml_face_detection/models/employee_model.dart';
import 'package:google_ml_face_detection/Utils/service/face_detector_service.dart';
import 'package:google_ml_face_detection/Utils/service/ml_service.dart';
import 'package:google_ml_face_detection/view/face_detector_screen/overlay_painter.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;

class CameraDetectionScreen extends StatefulWidget {
  const CameraDetectionScreen({super.key});

  @override
  State<CameraDetectionScreen> createState() => _CameraDetectionScreenState();
}

class _CameraDetectionScreenState extends State<CameraDetectionScreen> with WidgetsBindingObserver{
  CameraController? _cameraController;
  // late FaceDetector _faceDetector;
  // bool _isDetecting = false;

  // final _orientations = {
  //   DeviceOrientation.portraitUp: 0,
  //   DeviceOrientation.landscapeLeft: 90,
  //   DeviceOrientation.portraitDown: 180,
  //   DeviceOrientation.landscapeRight: 270,
  // };

  double detectionRadius = 100.0;  // Customize the radius of the detection area.
  Offset detectionCenter = const Offset(200, 300);

  // final _debouncer = Debouncer(milliseconds: 4000);

  bool _isCameraPermissionGranted = true;
  String cameraRestrictedText = "";
  // late Size size;
  // List<Face> facesDetected = [];
  final MLService _mlService = MLService();
  var argumentData = Get.arguments;
  bool isNewUser = false;
  InputImageRotation? cameraRotation;

  final FaceDetectorService _faceDetectorService = locator<FaceDetectorService>();
  bool _saving = false;
  Face? faceDetected;
  bool pictureTaken = false;
  String? imagePath;

  static const platform = MethodChannel('com.iAttendy.app.pinning');
  bool showPinOption = false;
  bool isUserAlreadyExists = true;

  Rect? _boundingBox;
  bool fairFaceDistance = true;
  bool isEyeBlinkedTextShow = false;
  bool isSmilingTextShow = false;
  Timer? timer;
  // ui.Image? _image;
  // bool isLoading = true;

  @override
  void initState() {
    isNewUser = argumentData["is_new_user"];

    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    WidgetsBinding.instance.addObserver(this);
    initializeCamera();
    _faceDetectorService.initialize();
    startTimer();
    // if(!isNewUser) {
    //   pinScreen();
    // }
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print("AppLifecycleState is: $state");

    final CameraController? cameraController = _cameraController;

    // App state changed before we got the chance to initialize.
    if (cameraController == null || !(cameraController.value.isInitialized)) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      // Free up memory when camera not active
      // cameraController.stopImageStream();
      cameraController.dispose();
      // timer?.cancel();
      //_cameraController?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      // Reinitialize the camera with same properties
      // if we are future builder that's why only need to call set State
      // setState(() {});
      initializeCamera();
    }
  }

  // Function to pin the screen
  Future<void> pinScreen() async {
    try {
      await platform.invokeMethod('pinScreen');
    } on PlatformException catch (e) {
      print("Failed to pin screen: '${e.message}'.");
    }
  }

  Future<void> initializeCamera() async {
    CameraDescription description = await _getCameraDescription();
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    CameraController controller = CameraController(
        description,
        GetPlatform.isAndroid ? androidInfo.brand != "samsung" ? ResolutionPreset.medium : ResolutionPreset.high : ResolutionPreset.medium,
        imageFormatGroup: GetPlatform.isAndroid ? ImageFormatGroup.nv21 : ImageFormatGroup.bgra8888,
        );

    _cameraController = controller;

    // CameraDescription description = await _getCameraDescription();
    cameraRotation = rotationIntToImageRotation(
      description.sensorOrientation,
    );

    await _cameraController?.initialize().then((_){
      if (!mounted) {
        return;
      }
      // _cameraController?.setZoomLevel(1.2);
      _isCameraPermissionGranted = true;
      setState(() {});

      if(!isNewUser && !showPinOption) {
        pinScreen();
        showPinOption = true;
      }

      startImageStreaming();

     // _cameraController?.startImageStream((image){});

      // bool isDetecting = false;
      // _cameraController?.startImageStream((CameraImage image) {
      //   print("processing");
      //   if (isDetecting) return;
      //   isDetecting = true;
      //
      //   // _debouncer.run(() async {
      //   // print("called after 4 seconds");
      //
      //   //await _predictFacesFromImage(image: image);
      //   //_isDetecting = false;
      //
      //   _predictFacesFromImage(image: image).then((value){
      //      print("detecting completed");
      //      isDetecting = false;
      //   });
      //
      // //  });
      //
      // });

    }).catchError((Object e) {
      if (e is CameraException) {
        _isCameraPermissionGranted = false;
        print("error: ${e.code}");
        cameraRestrictedText = e.code;
        setState(() {});

        switch (e.code) {
          case 'CameraAccessDenied':
          // Handle access errors here.
            break;
          case 'CameraAccessDeniedWithoutPrompt':
          // Handle access errors here.
            break;
          case 'CameraAccessRestricted':
          // Handle access errors here.
            break;
          case 'AudioAccessDenied':
          // Handle access errors here.
            break;
          case 'AudioAccessDeniedWithoutPrompt':
          // Handle access errors here.
            break;
          case 'AudioAccessRestricted':
          // Handle access errors here.
            break;
          default:
          // Handle other errors here.
            break;
        }
      }
    });
  }

  startImageStreaming(){
    bool isDetecting = false;
    _cameraController?.startImageStream((CameraImage image) {
      print("processing");
      if (isDetecting) return;
      isDetecting = true;

      _predictFacesFromImage(image: image)
          .then((value){
        print("detecting completed");
        isDetecting = false;
      });

    });
  }

  // bool _isFaceInDetectionArea(Face face) {
  //   // Get the center of the face bounding box.
  //   final faceCenter = Offset(
  //     face.boundingBox.center.dx,
  //     face.boundingBox.center.dy,
  //   );
  //   print("face center--> $faceCenter");
  //
  //   // Calculate the distance between face center and detection center.
  //   double distance = (faceCenter - detectionCenter).distance;
  //   print("circle distance--> $distance");
  //   // Return true if the face is within the detection area radius.
  //   return distance <= detectionRadius;
  // }

  Future<CameraDescription> _getCameraDescription() async {
    return cameras.firstWhere((CameraDescription camera) =>
    camera.lensDirection == CameraLensDirection.front,
    orElse: () => cameras.first);
  }

  InputImageRotation rotationIntToImageRotation(int rotation) {
    switch (rotation) {
      case 90:
        return InputImageRotation.rotation90deg;
      case 180:
        return InputImageRotation.rotation180deg;
      case 270:
        return InputImageRotation.rotation270deg;
      default:
        return InputImageRotation.rotation0deg;
    }
  }

  @override
  void dispose() {
    print("dispose");
    WidgetsBinding.instance.removeObserver(this);
    // _cameraController?.stopImageStream();
    //_cameraController?.dispose();
    _faceDetectorService.dispose();
    timer?.cancel();
    super.dispose();
  }

  Widget _buildRequestPermission(){
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Utils.defaultElevatedButton(
          onPressed: ()=> requestCamAudPermission(), buttonText: 'Allow Permission', icon: Icons.arrow_right, fontSize: 20
      ),
    );
   }

  requestCamAudPermission() async {
    PermissionStatus cameraPermissionStatus = await Permission.camera.request();
    PermissionStatus audioPermissionStatus = await Permission.microphone.request();

    print("cameraPermissionStatus --> $cameraPermissionStatus");
    print("audioPermissionStatus --> $audioPermissionStatus");

    if((cameraPermissionStatus.isGranted || cameraPermissionStatus.isLimited) && (audioPermissionStatus.isGranted || audioPermissionStatus.isLimited)){
      initializeCamera();
      return;
    }
    callDialog();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    const double mirror = math.pi;
    print("mirror value is: $mirror");

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop){
        if(didPop){
          return;
        }
        navigateTo();
      },
      child: Scaffold(
        appBar: (!_isCameraPermissionGranted) ? AppBar(
          backgroundColor: Colors.black,
          title: Utils.defaultText(text: "Permissions".tr, color: Colors.white),
          automaticallyImplyLeading: false,
          centerTitle: true,
          leading: InkWell(
              onTap: () => navigateTo(),
              child: Utils.defaultIcon(icon: Icons.chevron_left, color: Colors.white, size: 26)),
        ) : null,
        floatingActionButton: !_isCameraPermissionGranted ? _buildRequestPermission() : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        backgroundColor: Colors.white,
        // backgroundColor: Colors.black.withOpacity(0.5),

        body: (_isCameraPermissionGranted)
            ? _cameraController != null && (_cameraController?.value.isInitialized??false)
            ? Stack(
          children: [

            (!pictureTaken && (_cameraController?.value.isInitialized??false)) ?
            Transform.scale(
              scale: 1.0,
              child: AspectRatio(
                aspectRatio: MediaQuery.of(context).size.aspectRatio,
                child: OverflowBox(
                  alignment: Alignment.center,
                  child: FittedBox(
                    fit: BoxFit.fitHeight,
                    child: SizedBox(
                      width: width,
                      height: width * _cameraController!.value.aspectRatio,
                      child: Stack(
                        fit: StackFit.expand,
                        children: <Widget>[
                          (_cameraController!=null) ? CameraPreview(_cameraController!) : const SizedBox(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ) : const SizedBox(),

            (pictureTaken) ?
            SizedBox(
              width: width,
              height: height,
              child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.rotationY(mirror),
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: Image.file(File(imagePath!)),
                  )),
            ): const SizedBox(),

            CustomPaint(
                painter: OverlayPainter(
                  // screenWidth: _cameraController?.value.previewSize?.width ?? width,
                  // screenHeight: _cameraController?.value.previewSize?.height ?? height,
                  //screenHeight: _cameraController?.value.previewSize?.height ?? height,
                  screenWidth: width,
                  screenHeight: height
                )
            ),

            if(isEyeBlinkedTextShow)
            Align(
                alignment: Alignment.topCenter,
                child: Container(
                    margin: EdgeInsets.only(top: Get.height*0.15),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.0)
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Utils.defaultText(text: "Please blink your eyes for processing..", fontSize: 12),
                    )),
              ),

            Positioned(
                left: 30,
                right: 30,
                bottom: 100,
                child: Utils.defaultText(text: "Please ensure your face is within the circular frame for accurate face detection.", color: Colors.white, fontWeight: FontWeight.w600, textAlign: TextAlign.center)),

            Positioned(
                left: 30,
                right: 30,
                bottom: 30,
                child:
                //(fairFaceDistance) ?
                Utils.defaultElevatedButton(buttonText: (isEyeBlinkedTextShow) ? "Cancel" : (!pictureTaken) ? "Capture" :  "Re Capture", icon: Icons.camera, buttonBackgroundColor: Colors.white, textColor: Colors.black, iconColor: Colors.black,
                    onPressed: (isEyeBlinkedTextShow) ? cancel : (!pictureTaken) ? _onShot : _reload)),
            // : Utils.defaultElevatedButton(buttonText: "Capture",  buttonBackgroundColor: Colors.white.withOpacity(0.5), textColor: Colors.black, iconColor: Colors.black)),

            Positioned(
                left: 30,
                right: 30,
                top: 50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                        onTap: () {
                         if(!isNewUser) {
                           Get.offNamed(RoutesName.passcodeScreen, arguments: {
                             "from_screen": RoutesName.cameraDetectionScreen
                           });
                         }else{
                           Get.back();
                         }
                        },
                        child: CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.white,
                            child: Utils.defaultIcon(icon: Icons.chevron_left, color: Colors.black, size: 26))),
                    (pictureTaken && !isUserAlreadyExists && isNewUser) ? InkWell(
                        onTap: ()=> Get.back(result: {"predicated_image_data": _mlService.predictedArray, "image_path": imagePath}),
                        child: CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.white,
                            child: Utils.defaultIcon(icon: Icons.check, color: Colors.black, size: 26))) : const SizedBox(),
                  ],
                )),

            // if(!fairFaceDistance)
            // Align(
            //   alignment: Alignment.topCenter,
            //   child: Container(
            //     margin: EdgeInsets.only(top: Get.height*0.15),
            //     decoration: BoxDecoration(
            //         color: Colors.white,
            //         borderRadius: BorderRadius.circular(12.0)
            //       ),
            //       child: Padding(
            //         padding: const EdgeInsets.all(6.0),
            //         child: Utils.defaultText(text: "employee is far from mobile", fontSize: 12),
            //       )),
            // ),

            // if(_mlService.flippedImg!=null)
            // Center(
            //   child: FittedBox(
            //     child: SizedBox(
            //       width: _boundingBox?.width.toDouble(),
            //       height: _boundingBox?.height.toDouble(),
            //       child: CustomPaint(
            //         painter: FacePainter(_mlService.flippedImg!, _faceDetectorService.facesDetected),
            //       ),
            //     ),
            //   ),
            // ),

            // if(_faceDetected)
            // Positioned(
            //   left: _boundingBox?.left,
            //   top: _boundingBox?.top,
            //   // right: _boundingBox?.right,
            //   // bottom: _boundingBox?.bottom,
            //   width: _boundingBox?.width,
            //   height: _boundingBox?.height,
            //   child: Container(
            //     decoration: BoxDecoration(
            //       border: Border.all(color: Colors.green, width: 3),
            //       borderRadius: BorderRadius.circular(8),
            //     ),
            //   ),
            // ),

          ],
        ) : const Center(child: CircularProgressIndicator())
            : Padding(
            padding: EdgeInsets.all(20.0),
            child: Center(child: Text("This app requires camera and audio access to take photos. Please allow camera and audio permission.".tr, style: const TextStyle(fontSize: 18), textAlign: TextAlign.center,))),

        // body: FutureBuilder<void>(
        //   future: initializeCamera(),
        //   builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
        //     if (snapshot.connectionState == ConnectionState.done) {
        //
        //       // double scale = size.aspectRatio * (_cameraController?.value.aspectRatio ?? 16/9);
        //       //
        //       // // to prevent scaling down, invert the value
        //       // if (scale < 1) scale = 1 / scale;
        //
        //       final deviceRatio = size.width / size.height;
        //       final xScale = _cameraController?.value.aspectRatio??16/9 / deviceRatio;
        //       // Modify the yScale if you are in Landscape
        //       const yScale = 1;
        //
        //       return Stack(
        //         // alignment: Alignment.center,
        //         children: [
        //
        //       Center(
        //         child: AspectRatio(
        //           aspectRatio: 1 / _cameraController!.value.aspectRatio,
        //           child: _cameraController?.buildPreview(),
        //         ),
        //       ),
        //
        //       //     AspectRatio(
        //       //   aspectRatio: deviceRatio,
        //       //   child: Transform(
        //       //     alignment: Alignment.center,
        //       //     transform: Matrix4.diagonal3Values(xScale, yScale.toDouble(), 1),
        //       //     child: CameraPreview(_cameraController!),
        //       //   ),
        //       // ),
        //
        //           CustomPaint(
        //               painter: OverlayPainter(
        //                    // screenWidth: _cameraController?.value.previewSize?.width ?? width,
        //                    // screenHeight: _cameraController?.value.previewSize?.height ?? height,
        //                    // screenHeight: _cameraController?.value.previewSize?.height ?? height
        //                    screenWidth: width,
        //                    screenHeight: height
        //               )
        //           ),
        //
        //           // Container(
        //           //   height: height,
        //           //   width: width,
        //           //   color: Colors.black.withOpacity(0.2),
        //           //   child: Container(
        //           //     color: Colors.transparent,
        //           //     width: detectionRadius * 2.2,
        //           //     height: detectionRadius * 2.2,
        //           //   ),
        //           // ),
        //
        //           // Positioned(
        //           //   left: 20,
        //           //   right: 20,
        //           //   top: 0,
        //           //   bottom: 0,
        //           //   // top: detectionCenter.dy - detectionRadius,
        //           //   child: DottedBorder(
        //           //     borderType: BorderType.Circle,
        //           //     radius: const Radius.circular(50),
        //           //     color: Colors.white,
        //           //     dashPattern: const [12, 4],
        //           //     child: Container(
        //           //       width: detectionRadius * 2.0,
        //           //       height: detectionRadius * 2.0,
        //           //       decoration: const BoxDecoration(
        //           //         shape: BoxShape.circle,
        //           //         // border: Border.all(color: Colors.redAccent, width: 2),
        //           //       ),
        //           //     ),
        //           //   ),
        //           // ),
        //
        //         ],
        //       );
        //     }
        //     else {
        //       return const Center(child: CircularProgressIndicator());
        //     }
        //   },
        //
        // ),
      ),
    );

  }

  Future<void> callDialog() {
    return Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0)
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Utils.defaultText(text: "Permissions are necessary to use camera feature. Please enable it in settings.".tr, fontSize: 16.0, color: Colors.black, fontWeight: FontWeight.w500),
              sizedBoxHeight_20,
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Utils.defaultTextWithClickable(text: "Cancel", voidCallback: ()=> Get.back(), fontSize: 14.0, color: Colors.red, fontWeight: FontWeight.w500 ),
                  sizedBoxWidth_15,
                  Utils.defaultTextWithClickable(text: "Setting", voidCallback: () {
                    Get.back();
                    openAppSettings();
                  }, fontSize: 14.0, color: Colors.blue, fontWeight: FontWeight.w500),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> setCurrentPrediction({required image, required Face? face}) async {
    print("set current prediction");
     // Utils.customLoadingWidget();
    EmployeeModel? employeeModel = await _mlService.predict(
        cameraImage: image,
        face: face,
        isNewUser: isNewUser,
        callBack: (double distance){
          isUserAlreadyExists = true;
          setState(() {});
          if(distance <= 0.85){
            Utils.defaultCupertinoDialog(context: context, contentText: 'Face detected'.tr, confirmCallback: () {
              Get.back();
            });
          }
          else{
            Utils.defaultCupertinoDialog(context: context, contentText: 'Please ensure your face is within the circular frame for accurate face detection.'.tr, confirmCallback: () => Get.back());
          }
        }
    );
    print("employee data is--> ${employeeModel?.name}${employeeModel?.empId}");
      Get.back();
    if(isNewUser){
      // register case
      // Get.back();
      // if(employeeModel==null) {
        isUserAlreadyExists = false;
        setState(() {});
        Utils.defaultCupertinoDialog(context: context, contentText: 'Face detected'.tr, confirmCallback: () {
          // setState(() {
          //   _saving = false;
          // });
          Get.back();
        });
      // }
      // else {
      //   isUserAlreadyExists = true;
      //   setState(() {});
      //   Utils.defaultCupertinoDialog(context: context, contentText: 'Face detected but Employee already exists!'.tr, titleText:  "Oops! ${employeeModel.name}".tr, confirmCallback: () {
      //     // setState(() {
      //     //   _saving = false;
      //     // });
      //     Get.back();
      //   });
      // }
    }else {
      if (employeeModel == null) {
        // Get.back();
        print("Unknown User");
        Utils.defaultCupertinoDialog(context: context, contentText: "Employee not found.".tr,
            titleText:  "Oops!".tr,
            confirmCallback: () {
              // setState(() {
              //   _saving = false;
              // });
              Get.back();
            }
        );
        // Utils.defaultFlutterToast(text: 'Unknown User');
      } else {
        // Get.back();
        try {
          /// check type of last record(clock in or clock out)
          AttendanceRecordModel? attendanceRecordModel = await SupaBaseService().getSingleAttendancesRecord(employeeModel: employeeModel, todayDate: DateTime.now());
          int type = 0;
          if(attendanceRecordModel!=null) {
            print("type--> ${attendanceRecordModel.type}");
            if (attendanceRecordModel.type == 0) {
              type = 1;
            } else {
              type = 0;
            }
          }

            await SupaBaseService().addEmployeeAttendanceRecord(
                context: context,
                employeeModel: employeeModel,
                type: type,
                voidCallback: () {
                  _reload();
                });

            String dateTimeInString = DateTime.now().toIso8601String();
            DateTime dateTine = DateTime.parse(dateTimeInString);
            String formattedTime = DateFormat('hh:mm:ss a').format(dateTine);

            if(type==0) {
              Utils.defaultCupertinoDialog(context: context, contentText: "You are successfully clock in at: $formattedTime",
                  titleText: "Thankyou! ${employeeModel.name}".tr,
                  confirmCallback: () {
                    // setState(() {
                    //   _saving = false;
                    // });
                    Get.back();
                    _reload();
                  }
              );
            }else{
              Utils.defaultCupertinoDialog(context: context, contentText: "You are successfully clock out at $formattedTime",
                  titleText: "Thankyou! ${employeeModel.name}".tr,
                  confirmCallback: () {
                    // setState(() {
                    //   _saving = false;
                    // });
                    Get.back();
                    _reload();
                  }
              );
            }
        } on PostgrestException catch (error) {
          Utils.defaultFlutterToast(text:error.message);
        } catch (e) {
          print("error--> $e"); // Return error message
          Utils.defaultFlutterToast(text: e.toString());
        }
      }
     }
  }

  Future<void> _predictFacesFromImage({required CameraImage  image}) async {
    try {
      await _faceDetectorService.detectFacesFromImage(image, cameraRotation);
      // await detectFacesFromImage(image);

      // // Convert camera image to InputImage for ML Kit
      // final inputImage = _inputImageFromCameraImage(image);
      // print("input image is: $inputImage");
      //
      // if(inputImage!=null) {
      //   facesDetected = await _faceDetector.processImage(inputImage);
      //   print("face properties is: $facesDetected");
      //

      if (_faceDetectorService.facesDetected.isNotEmpty) {
        print("face detected");

        faceDetected = _faceDetectorService.facesDetected[0];

        startTimer();

        // for (Face face in facesDetected) {

        // if (_isFaceInDetectionArea(_faceDetectorService.facesDetected[0])) {
        // Process the face (e.g., draw a box around it or perform further analysis).
        // Only works if within the defined circular region.
        // Access face properties, e.g., face.boundingBox

        // final FaceLandmark? leftEar = _faceDetectorService.facesDetected[0].landmarks[FaceLandmarkType.leftEar];
        // final FaceLandmark? rightEar = _faceDetectorService.facesDetected[0].landmarks[FaceLandmarkType.rightEar];
        // final FaceLandmark? leftCheek = _faceDetectorService.facesDetected[0].landmarks[FaceLandmarkType.leftCheek];
        // final FaceLandmark? rightCheek = _faceDetectorService.facesDetected[0].landmarks[FaceLandmarkType.rightCheek];
        // final FaceLandmark? bottomMouth = _faceDetectorService.facesDetected[0].landmarks[FaceLandmarkType.bottomMouth];
        // final FaceLandmark? leftMouth = _faceDetectorService.facesDetected[0].landmarks[FaceLandmarkType.leftMouth];
        // final FaceLandmark? rightMouth = _faceDetectorService.facesDetected[0].landmarks[FaceLandmarkType.rightMouth];
        // final FaceLandmark? noseBase = _faceDetectorService.facesDetected[0].landmarks[FaceLandmarkType.noseBase];
        // if (leftEar == null && rightEar==null && leftCheek==null && rightCheek==null && bottomMouth==null && leftMouth==null && rightMouth==null && leftEye==null && rightEye==null && noseBase==null) {
        //     print("not proper visible");
        // }
        // final FaceLandmark? leftEye = _faceDetectorService.facesDetected[0].landmarks[FaceLandmarkType.leftEye];
        // final FaceLandmark? rightEye = _faceDetectorService.facesDetected[0].landmarks[FaceLandmarkType.rightEye];

        print("left eye open probability--> ${faceDetected?.leftEyeOpenProbability} right eye open probability--> ${faceDetected?.rightEyeOpenProbability}");
        print("smile probability--> ${faceDetected?.smilingProbability}");

        _boundingBox = _faceDetectorService.facesDetected[0].boundingBox;
        print('Detected face at: $_boundingBox');
        final double faceWidth = _boundingBox!.width;
        // final double faceHeight = _boundingBox!.height;

        // You can use the width or height of the bounding box to estimate distance
        print('face width is: $faceWidth');
        double estimatedDistance = 0.0;
        // Example: If face width is larger, it means the face is closer to the camera
        // We use a simple inverse relationship (this is just an example; tuning may be necessary)
        estimatedDistance = 1000 / faceWidth;  // Scale factor for face size to distance ratio
        print('Estimated distance: $estimatedDistance meters');

         // if(estimatedDistance.toInt() <= 6.00) {

           // if(!fairFaceDistance) {
           //   fairFaceDistance = true;
           //   setState(() {});
           // }

           // if (!_saving) {
          if(isEyeBlinkedTextShow) {
            if ((faceDetected?.leftEyeOpenProbability ?? 1.0) < 0.9 && (faceDetected?.rightEyeOpenProbability ?? 1.0) < 0.9) {
                   XFile? xFile;
                   if(_cameraController!=null) {
                      print("taking picture");
                      xFile = await _cameraController?.takePicture();
                   }
                    // if(isSmilingTextShow) {
                    //   if ((faceDetected?.smilingProbability ?? 0.0) > 0.6) {
                    Utils.customLoadingWidget();
                    // _saving = true;

                    isEyeBlinkedTextShow = false;
                    isSmilingTextShow = false;
                    imagePath = xFile!.path;
                    pictureTaken = true;
                    //_loadImage(File(imagePath!));
                    setState(() {});
                    await _cameraController?.stopImageStream();
                    await setCurrentPrediction(image: image, face: faceDetected);
                    //  }
                   // }
              }
                   //  if (!_saving) return;
                   //   await setCurrentPrediction(image: image, face: faceDetected);
        }

              // setState(() {
              //   _saving = false;
              // });
              // }

        // } else{
        //     if(fairFaceDistance) {
        //       fairFaceDistance = false;
        //       isEyeBlinkedTextShow = false;
        //       // isSmilingTextShow = false;
        //       setState(() {});
        //     }
        // }

        // }
        // }
      }

      else{
        faceDetected = null;
        // if(!fairFaceDistance || isEyeBlinkedTextShow) {
        if(isEyeBlinkedTextShow) {
          fairFaceDistance = true;
          isEyeBlinkedTextShow = false;
          // isSmilingTextShow = false;
          setState(() {});
        }
      }

      // }
    }catch(e){
      if(e is CameraException) {
        Get.back();
        Utils.defaultFlutterToast(text: e.description??"");
      }
      print("error--> $e");
    }
  }

  Future<void> _onShot() async {
    // Utils.customLoadingWidget();
    if (faceDetected == null) {
      // Get.back();
      Utils.defaultCupertinoDialog(context: context, contentText: 'No face detected!',
          confirmCallback: (){
            Get.back();
          }
      );

      // showDialog(
      //   context: context,
      //   builder: (context) {
      //     return const AlertDialog(
      //       content: Text('No face detected!'),
      //     );
      //   },
      // );

    } else {
      // Future.delayed(Duration(milliseconds: 500));
      isEyeBlinkedTextShow = true;
      isSmilingTextShow = true;
      setState(() {});
    }
  }

  cancel(){
     isEyeBlinkedTextShow = false;
     isSmilingTextShow = false;
    setState(() {});
  }

  _reload() {
    print("reload");
    faceDetected = null;
    setState(() {
     // _saving = false;
      pictureTaken = false;
      isUserAlreadyExists = false;
     // _mlService.img = null;
    });
    startImageStreaming();
    //initializeCamera();
  }

  void startTimer() {
    if(timer?.isActive??false){
      print("timer cancel");
      timer?.cancel();
    }
    int start = 300;
    timer = Timer.periodic(Duration(seconds: 1), (timer){
      if(start==0){
        navigateTo();
      }else{
        print("start--> $start");
        start --;
      }
    });
  }

  void navigateTo() {
    _cameraController?.dispose();
    timer?.cancel();
    if(!isNewUser) {
      Get.offAllNamed(RoutesName.passcodeScreen, arguments: {
        "from_screen": RoutesName.cameraDetectionScreen
      });
    }else{
      Get.back();
    }
  }

  // _loadImage(File file) async {
  //   final data = await file.readAsBytes();
  //   await decodeImageFromList(data).then(
  //         (value) => setState(() {
  //           _image = value;
  //           isLoading = false;
  //     }),
  //   );
  // }


}

class FacePainter extends CustomPainter {
  final ui.Image image;
  final List<Face> faces;
  final List<Rect> rects = [];

  FacePainter(this.image, this.faces) {
    for (var i = 0; i < faces.length; i++) {
      rects.add(faces[i].boundingBox);
    }
  }

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 15.0
      ..color = Colors.blue;

    canvas.drawImage(image, Offset.zero, Paint());
    for (var i = 0; i < faces.length; i++) {
      canvas.drawRect(rects[i], paint);
    }
  }

  @override
  bool shouldRepaint(FacePainter oldDelegate) {
    return image != oldDelegate.image || faces != oldDelegate.faces;
  }
}

