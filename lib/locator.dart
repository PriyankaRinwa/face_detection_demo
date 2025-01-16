import 'package:get_it/get_it.dart';
import 'package:google_ml_face_detection/Utils/service/face_detector_service.dart';

final locator = GetIt.instance;

void setupServices() {
  locator.registerLazySingleton<FaceDetectorService>(() => FaceDetectorService());
}
