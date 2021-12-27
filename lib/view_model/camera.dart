import 'package:camera/camera.dart';
import 'package:get/get.dart';
import 'package:inekturleri/view_model/image_classify.dart';

class CameraService {
  static final CameraService _cameraService = CameraService._internal();

  factory CameraService() {
    return _cameraService;
  }
  CameraService._internal();

  //Kameraya erişebilmek için bir kamera kontrol değişkeni tanımlanır
  CameraController _cameraController;
  CameraController get cameraController => _cameraController;

  //Kameranın o an aktif olma durumu
  bool available = true;

  Future startService(CameraDescription cameraDescription) async {
    _cameraController = CameraController(
      cameraDescription,
      ResolutionPreset.veryHigh,
    );

    return _cameraController.initialize();
  }

  dispose() {
    _cameraController.dispose();
  }

  //Kamera açılır ve nesne tanıma methodları çağırılır
  Future<void> startStreaming(setRecognitions) async {
    _cameraController.startImageStream((img) async {
      if (available) {
        available = false;
        await Get.find<ImageClassify>().classifyImage(img, setRecognitions);
        await Future.delayed(const Duration(seconds: 1));
        available = true;
      }
    });
  }

  Future stopImageStream() async {
    await _cameraController.stopImageStream();
  }
}
