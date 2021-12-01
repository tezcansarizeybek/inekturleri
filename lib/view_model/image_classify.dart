import 'dart:async';

import 'package:camera/camera.dart';
import 'package:get/get.dart';
import 'package:tflite/tflite.dart';

class ImageClassify extends GetxController {
  var outputs = [].obs;
  var model = "model";

  static final ImageClassify _imageClassify = ImageClassify._internal();

  factory ImageClassify() {
    return _imageClassify;
  }
  ImageClassify._internal();

  //Tanınan öğelerin kontrolü için Stream olarak bir recognitionController çağırılır
  StreamController<List<dynamic>> _recognitionController = StreamController();
  Stream get recognitionStream => _recognitionController.stream;

  //Assets klasöründen model ve labelları yükler
  loadModel() async {
    await Tflite.loadModel(
      model: "assets/$model.tflite",
      labels: "assets/$model.txt",
    );
  }

  classifyImage(CameraImage image) async {
    List<dynamic> recognitions = await Tflite.runModelOnFrame(
      bytesList: image.planes.map((plane) {
        return plane.bytes;
      }).toList(), //Bu kısımda görüntü düzlemlerinin byteları alınarak Tflite paketindeki runModelOnFrame methoduna byte olarak gönderilir.
      imageHeight: image.height, //Kameradan alınan görüntünün pixel olarak yüksekliği
      imageWidth: image.width, //"" genişliği
      numResults: 3, //Max 3 adet sonuç gösterilir, daha fazla istenirse buradan artırılabilir
    );
    //Eğer sınıflandırma sonucu varsa
    if (recognitions.isNotEmpty) {
      //Stream kapandıysa bir daha açılır
      if (_recognitionController.isClosed) {
        _recognitionController = StreamController();
      }
      _recognitionController.add(recognitions);
    }
    //Çıktılar verisine sınıflandırma sonuçları işlenir
    outputs.value = recognitions ?? [];
  }

  Future<void> stopRecognitions() async {
    if (!_recognitionController.isClosed) {
      _recognitionController.add(null);
      _recognitionController.close();
    }
  }
}
