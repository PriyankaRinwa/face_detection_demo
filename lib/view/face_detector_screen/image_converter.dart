import 'dart:io';
import 'dart:typed_data';
import 'package:google_ml_face_detection/Utils/utils/utils.dart';
import 'package:google_ml_face_detection/main.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as imglib;
import 'package:camera/camera.dart';

import 'package:path_provider/path_provider.dart';


imglib.Image? convertToImage(CameraImage image, Face faceDetected) {
  try {
    if(image.format.group == ImageFormatGroup.nv21){
      return _convertNV21(image, faceDetected);
    } else if (image.format.group == ImageFormatGroup.yuv420) {
      return _convertYUV420(image);
    } else if (image.format.group == ImageFormatGroup.bgra8888) {
      return _convertBGRA8888(image);
    }
    throw Exception('Image format not supported');
  } catch (e) {
    print("ERROR:$e");
  }
  return null;
}

imglib.Image _convertBGRA8888(CameraImage image) {
  ByteBuffer byteBuffer = (image.planes[0].bytes).buffer;
  return imglib.Image.fromBytes(
    width: image.width,
    height: image.height,
    bytes: byteBuffer
    // bytes: image.planes[0].bytes,
    //format: imglib.Format.bgra,
  );
}

imglib.Image _convertYUV420(CameraImage image) {
  int width = image.width;
  int height = image.height;
  var img = imglib.Image(width: width, height: height);
  const int hexFF = 0xFF000000;
  final int uvyButtonStride = image.planes[1].bytesPerRow;
  final int? uvPixelStride = image.planes[1].bytesPerPixel;
  for (int x = 0; x < width; x++) {
    for (int y = 0; y < height; y++) {
      final int uvIndex =
          uvPixelStride! * (x / 2).floor() + uvyButtonStride * (y / 2).floor();
      final int index = y * width + x;
      final yp = image.planes[0].bytes[index];
      final up = image.planes[1].bytes[uvIndex];
      final vp = image.planes[2].bytes[uvIndex];
      int r = (yp + vp * 1436 / 1024 - 179).round().clamp(0, 255);
      int g = (yp - up * 46549 / 131072 + 44 - vp * 93604 / 131072 + 91)
          .round()
          .clamp(0, 255);
      int b = (yp + up * 1814 / 1024 - 227).round().clamp(0, 255);
      img.setPixelRgba(x, y, r, g, b, 255);
      // return img;
     // img.data.[index]  = hexFF | (b << 16) | (g << 8) | r;
    }
  }

  return img;
}

imglib.Image _convertNV21(CameraImage cameraImage, Face faceDetected) {

  // int totalBrightness = 0;
  // int pixelCount = 0;

  // Get the width and height from the camera image
  int width = cameraImage.width;
  int height = cameraImage.height;

  // Create a new image with the same dimensions as the camera image
  imglib.Image image = imglib.Image(width: width, height: height);

  // Extract the Y, U, and V planes
  List<Plane> planes = cameraImage.planes;
  Uint8List yPlane = planes[0].bytes;  // Y plane (luminance)
  List<int> uvPlane = cameraImage.planes.length > 1 ? cameraImage.planes[1].bytes : [];


  // Handle YUV to RGB conversion (for NV21 format)
  if (uvPlane.isNotEmpty) {
    // If UV data exists (interleaved in the second plane)
    // Iterate through each pixel and reconstruct RGB from NV21 format
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        // Get the Y value for the current pixel
        int yIndex = y * width + x;
        int yValue = yPlane[yIndex];

        // Get the U and V values (interleaved in the UV plane)
        // U and V are interleaved, so we use the formula to get U and V values
        int uvIndex = (y ~/ 2) * (width ~/ 2) + (x ~/ 2) * 2;
        int u = uvPlane[uvIndex] - 128; // U value
        int v = uvPlane[uvIndex + 1] - 128; // V value

        // Convert YUV to RGB using the YUV-to-RGB formula
        int r = (yValue + (1.402 * v)).clamp(0, 255).toInt();
        int g = (yValue - (0.344136 * u) - (0.714136 * v)).clamp(0, 255).toInt();
        int b = (yValue + (1.772 * u)).clamp(0, 255).toInt();

        // Set the RGB values in the image object
        image.setPixelRgba(x, y, r, g, b , 255);
      }
    }
  }else{
    // If only Y data exists, handle as grayscale image or simple color conversion
    for (int i = 0; i < height; i++) {
      for (int j = 0; j < width; j++) {
        int y = yPlane[i * width + j]; // Y component

        // // Get the brightness (Y value) of the pixel
        // int brightness = yPlane[y];
        //
        // if (j >= faceDetected.boundingBox.left && j <= faceDetected.boundingBox.right && i >= faceDetected.boundingBox.top && i <= faceDetected.boundingBox.bottom) {
        //   print("continue");
        //   continue;
        // }
        //
        // // Sum the brightness values for the background
        // totalBrightness += brightness;
        // pixelCount++;

        // Simple grayscale conversion (just Y for each pixel)
        int gray = y;
        gray = gray.clamp(0, 255).toInt();

        // Set pixel color (gray)
        image.setPixelRgba(j, i, gray, gray, gray, 255);
      }
   }

    // Step 3: Calculate the average brightness of the background
    // if (pixelCount > 0) {
    //   double averageBrightness = totalBrightness / pixelCount;
    //
    //   print("brightness--> $averageBrightness");
    //   Utils.defaultFlutterToast(text: "$averageBrightness");
    //   // Step 4: Categorize light density based on the average brightness
    //   if (averageBrightness < 85) {
    //     print("Low background light density");
    //   } else if (averageBrightness < 170) {
    //     print("Medium background light density");
    //   } else {
    //     print("High background light density");
    //   }
    // } else {
    //   print("No background pixels to analyze");
    // }
  }

  return image;
}

// imglib.Image _convertYUV420(CameraImage image) {
//   var img = imglib.Image(width: image.width, height: image.height); // Create Image buffer
//
//   Plane plane = image.planes[0];
//   const int shift = (0xFF << 24);
//
//   // Fill image buffer with plane[0] from YUV420_888
//   for (int x = 0; x < image.width; x++) {
//     for (int planeOffset = 0;
//     planeOffset < image.height * image.width;
//     planeOffset += image.width) {
//       final pixelColor = plane.bytes[planeOffset + x];
//       // color: 0x FF  FF  FF  FF
//       //           A   B   G   R
//       // Calculate pixel color
//       var newVal = shift | (pixelColor << 16) | (pixelColor << 8) | pixelColor;
//
//       // img.data![planeOffset + x] = newVal;
//       img.data?.toUint8List()[planeOffset + x] = newVal;
//     }
//   }
//
//   return img;
// }

Future<File?> correctImageOrientation(File imageFile) async {
  // Read the captured image
  List<int> imageBytes = await imageFile.readAsBytes();
  imglib.Image? capturedImage = imglib.decodeImage(
      Uint8List.fromList(imageBytes));

  if (capturedImage != null) {
    // Check the orientation and rotate accordingly
    imglib.Image rotatedImage;

    CameraDescription description = cameras.firstWhere((CameraDescription camera) => camera.lensDirection == CameraLensDirection.front);
    if (description.lensDirection == CameraLensDirection.front) {
      // For front camera, rotate 180 degrees
      print("front");
      capturedImage = imglib.flipHorizontal(capturedImage);
      rotatedImage = imglib.copyRotate(capturedImage, angle:360);
    } else {
      rotatedImage = capturedImage;
    }

    // Save the rotated image
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/rotated_image.jpg';
    final rotatedImageFile = File(path)
      ..writeAsBytesSync(imglib.encodeJpg(rotatedImage));

    // // Load the image file
    // imglib.Image image = imglib.decodeImage(await imageFile.readAsBytes())!;
    //
    // // Rotate the image 180 degrees if needed
    // imglib.Image rotatedImage = imglib.copyRotate(image, math.pi);
    //
    // // Save the rotated image to a new file
    // final rotatedFile = File(imageFile.path.replaceFirst(RegExp(r'\.\w+$'), '_rotated.jpg'))
    //   ..writeAsBytesSync(imglib.encodeJpg(rotatedImage));
    //
    return rotatedImageFile;
  }
  return null;
}

