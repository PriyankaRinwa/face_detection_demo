import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class FaceDetectorService {
  List<Face> _facesDetected = [];

  List<Face> get facesDetected => _facesDetected;

  late FaceDetector _faceDetector;

  FaceDetector get faceDetector => _faceDetector;

  void initialize() {
    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(enableContours: true, enableLandmarks: true, enableClassification: true, performanceMode: FaceDetectorMode.accurate),
    );
  }


  Future<void> detectFacesFromImage(CameraImage image, InputImageRotation? cameraRotation) async {

    // Uint8List newImg = _yuv420ToNV21(image);

    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format == null || (GetPlatform.isAndroid && format != InputImageFormat.nv21) || (GetPlatform.isIOS && format != InputImageFormat.bgra8888)) return;

   // since format is constraint to nv21 or bgra8888, both only have one plane
    if (image.planes.length != 1) return;
     final plane = image.planes.first;

    InputImageMetadata inputImageMetadata = InputImageMetadata(
         rotation: cameraRotation ?? InputImageRotation.rotation0deg, // used only in Android

          // inputImageFormat: InputImageFormat.yuv_420_888,

          format: InputImageFormatValue.fromRawValue(image.format.raw)
              // InputImageFormatMethods.fromRawValue(image.format.raw) for new version
              ??
              InputImageFormat.nv21,
          // used only in iOS
          size: Size(image.width.toDouble(), image.height.toDouble()),
          bytesPerRow: plane.bytesPerRow

          // image.planes.map(
          //       (Plane plane) {
          //     return InputImagePlaneMetadata(
          //       bytesPerRow: plane.bytesPerRow,
          //       height: plane.height,
          //       width: plane.width,
          //     );
          //   },
          // ).toList(),

          //plane.bytesPerRow // used only in iOS
      );

      // for mlkit 13
      final WriteBuffer allBytes = WriteBuffer();
      for (final Plane plane in image.planes) {
        allBytes.putUint8List(plane.bytes);
      }
      final bytes = allBytes.done().buffer.asUint8List();

      InputImage inputImage = InputImage.fromBytes(
        // bytes: image.planes[0].bytes,
        bytes: bytes,
        metadata: inputImageMetadata,
      );
      // for mlkit 13

      _facesDetected = await _faceDetector.processImage(inputImage);
    }

    dispose() {
      _faceDetector.close();
    }

  Uint8List _yuv420ToNV21(CameraImage image) {
    var nv21 = Uint8List(image.planes[0].bytes.length +
        image.planes[1].bytes.length +
        image.planes[2].bytes.length);

    var yBuffer = image.planes[0].bytes;
    var uBuffer = image.planes[1].bytes;
    var vBuffer = image.planes[2].bytes;

    nv21.setRange(0, yBuffer.length, yBuffer);

    int i = 0;
    while (i < uBuffer.length) {
      nv21[yBuffer.length + i] = vBuffer[i];
      nv21[yBuffer.length + i + 1] = uBuffer[i];
      i += 2;
    }

    return nv21;
  }
}