import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:google_ml_face_detection/Utils/service/supabase_service.dart';
import 'package:google_ml_face_detection/models/employee_model.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as imglib;
import '../../view/face_detector_screen/image_converter.dart';

class MLService {
  Interpreter? _interpreter;
  List? _predictedArray;
  // ui.Image? flippedImg;

  List? get predictedArray => _predictedArray;

  Future<EmployeeModel?> predict({required CameraImage cameraImage, required Face? face, required bool isNewUser, Function(double)? callBack}) async {
    if (face == null) throw Exception('Face is null');
    await initializeInterpreter();
    if (_interpreter == null) throw Exception('Interpreter is null');

    List input =  _preProcess(cameraImage, face);

    input = input.reshape([1, 112, 112, 3]);

    List output = List.generate(1, (index) => List.filled(192, 0));

    _interpreter?.run(input, output);
    output = output.reshape([192]);

    _predictedArray = List.from(output);

    // if (isFaceRecognization) {

      /// fetching data using firebase get method
      List<EmployeeModel>? users = await SupaBaseService().fetchAllEmployees();

      /// fetching data using firebase listen or snapshot method
      // FirebaseService().fetchEmployeeDetails().listen((data){
      //    users = data.docs.map((doc) => UserModel.fromDocument(doc)).toList();
      // });
      // List<UserModel> users = LocalDB.getAllUsers();

      //  print("user List --> ${users[0].name}");

      /// fetching data using shared preference
      // List<UserModel> users = await SharedPref.getUsers();

      print("user List --> ${users?.length}");
      if(users!=null) {
        if (users.isNotEmpty) {
          int userId = 0;
          double previousDistance = 0.82;
          for (var user in users) {
            print('Name: ${user.name}, Email: ${user.email}, imageData: ${user.imageData}');
            List userArray = user.imageData!;
            int minDist = 999;
            double threshold = 0.82;
            // List? predictedArray = _predictedArray;
            var dist = euclideanDistance(_predictedArray, userArray);
            print("user array is: ${user.name}");
            print("distance--> $dist");
            if (dist <= threshold && dist < minDist) {
                print("previous distance--> $previousDistance");
                if(previousDistance >= dist) {
                  previousDistance = dist;
                  userId = user.id!;
                }
              }
          }

          if(userId!=0) {
            EmployeeModel? employeeModel = await SupaBaseService().getSingleEmployeeData(id: userId);
            return employeeModel;
          }
          return null;

        }

      }

      // if(distance<=0.85) {
      //  if(callBack!=null) callBack(distance);
      // }


    return null;
  }

  euclideanDistance(List? l1, List? l2) {
    if (l1 == null || l2 == null) throw Exception("Null argument");
    double sum = 0;
    for (int i = 0; i < l1.length; i++) {
      sum += pow((l1[i] - l2[i]), 2);
    }

    print("sqrt of sum is--> ${sqrt(sum)}");
    print("pow of sum is--> ${pow(sum, 0.5)}");

    return sqrt(sum);
  }

  initializeInterpreter() async {
    Delegate? delegate;
    try {
      if (Platform.isAndroid) {
        delegate = GpuDelegateV2(
            options: GpuDelegateOptionsV2(
          isPrecisionLossAllowed: false,
          inferencePreference: 0,
          inferencePriority1: 2,
          inferencePriority2: 0,
          inferencePriority3: 0,
        ));
      } else if (Platform.isIOS) {
        delegate = GpuDelegate(
          options: GpuDelegateOptions(
              allowPrecisionLoss: true,
              waitType: 1),
        );
      }
      var interpreterOptions = InterpreterOptions()..addDelegate(delegate!);

      _interpreter = await Interpreter.fromAsset('assets/mobilefacenet.tflite', options: interpreterOptions);

    } catch (e) {
      print('Failed to load model.');
      print(e);
    }
  }

  List _preProcess(CameraImage image, Face faceDetected)  {
    imglib.Image croppedImage = _cropFace(image, faceDetected);
    imglib.Image img = imglib.copyResizeCropSquare(croppedImage, size: 112);

    // Its just for checking
    //flippedImg = await convertImgToUiImage(img);

    Float32List imageAsList = _imageToByteListFloat32(img);
    return imageAsList;
  }

  imglib.Image _cropFace(CameraImage image, Face faceDetected)  {
    imglib.Image convertedImage = _convertCameraImage(image, faceDetected);

    double x = faceDetected.boundingBox.left - 10.0;
    double y = faceDetected.boundingBox.top - 10.0;
    double w = faceDetected.boundingBox.width + 10.0;
    double h = faceDetected.boundingBox.height + 10.0;
    return imglib.copyCrop(convertedImage, x: x.round(), y: y.round(), width: w.round(), height: h.round());
  }

  imglib.Image _convertCameraImage(CameraImage image, Face faceDetected)  {
    var img = convertToImage(image, faceDetected);
    var img1 = imglib.copyRotate(img!, angle: -90);
    return img1;
    //var img2 = imglib.flipHorizontal(img1);
    //flippedImg = await convertImgToUiImage(img2);
    //return img2;
  }

  Float32List _imageToByteListFloat32(imglib.Image image) {
    var convertedBytes = Float32List(1 * 112 * 112 * 3);
    var buffer = Float32List.view(convertedBytes.buffer);
    int pixelIndex = 0;

    for (var i = 0; i < 112; i++) {
      for (var j = 0; j < 112; j++) {
        imglib.Pixel pixel = image.getPixel(j, i);

        int r = pixel.r.toInt();
        int g = pixel.g.toInt();
        int b = pixel.b.toInt();

        // Extract RGBA components from pixel value
        // int r = (red >> 24) & 0xFF;
        // int g = (green >> 16) & 0xFF;
        // int b = (blue >> 8) & 0xFF;

        buffer[pixelIndex++] = (r - 128) / 128;
        buffer[pixelIndex++] = (g - 128) / 128;
        buffer[pixelIndex++] = (b - 128) / 128;
      }
    }
    return convertedBytes.buffer.asFloat32List();
  }
}

