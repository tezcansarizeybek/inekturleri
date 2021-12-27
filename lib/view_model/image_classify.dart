import 'dart:async';

import 'package:camera/camera.dart';
import 'package:get/get.dart';
import 'package:tflite/tflite.dart';
import 'package:image/image.dart' as imglib;

class ImageClassify extends GetxController {
  var outputs = [].obs;
  var model = "model(1)";

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
    await Tflite.loadModel(model: "assets/object_detection.tflite", labels: "assets/object_detection_label.txt");
  }

  List<dynamic> recognitions = [];
  classifyImage(CameraImage image, setRecognitions) async {
    var bytes = image.planes.map((plane) => plane.bytes).toList();
    List<dynamic> recgs = await Tflite.detectObjectOnFrame(
      bytesList: bytes,
      imageHeight: image.height,
      imageWidth: image.width,
      threshold: 0.5,
    );
    var cows = recgs.where((element) => element["detectedClass"] == "cow");
    if (cows.isNotEmpty) {
      await Tflite.loadModel(model: "assets/$model.tflite", labels: "assets/model.txt");
      recognitions = await Tflite.runModelOnFrame(
        bytesList: bytes,
        imageHeight: image.height,
        imageWidth: image.width,
        numResults: 3,
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
      outputs.assignAll(recognitions);
    } else {
      outputs.assignAll([]);
    }
    await Tflite.loadModel(model: "assets/object_detection.tflite", labels: "assets/object_detection_label.txt");

    setRecognitions(recgs, image.height, image.width);
  }

  imglib.Image copyCrop(imglib.Image src, int x, int y, int w, int h) {
    // Make sure crop rectangle is within the range of the src image.
    x = x.clamp(0, src.width - 1).toInt();
    y = y.clamp(0, src.height - 1).toInt();
    if (x + w > src.width) {
      w = src.width - x;
    }
    if (y + h > src.height) {
      h = src.height - y;
    }

    final dst = imglib.Image(w, h, channels: src.channels, exif: src.exif, iccp: src.iccProfile);

    for (var yi = 0, sy = y; yi < h; ++yi, ++sy) {
      for (var xi = 0, sx = x; xi < w; ++xi, ++sx) {
        dst.setPixel(xi, yi, src.getPixel(sx, sy));
      }
    }

    return dst;
  }

  var shift = (0xFF << 24);
  Future<imglib.Image> convertYUV420toImageColor(CameraImage image, rect) async {
    final int width = image.width;
    final int height = image.height;
    final int uvRowStride = image.planes[1].bytesPerRow;
    final int uvPixelStride = image.planes[1].bytesPerPixel;

    var img = imglib.Image(width, height);

    for (int x = 0; x < width; x++) {
      for (int y = 0; y < height; y++) {
        final int uvIndex = uvPixelStride * (x / 2).floor() + uvRowStride * (y / 2).floor();
        final int index = y * width + x;

        final yp = image.planes[0].bytes[index];
        final up = image.planes[1].bytes[uvIndex];
        final vp = image.planes[2].bytes[uvIndex];
        int r = (yp + vp * 1436 / 1024 - 179).round().clamp(0, 255);
        int g = (yp - up * 46549 / 131072 + 44 - vp * 93604 / 131072 + 91).round().clamp(0, 255);
        int b = (yp + up * 1814 / 1024 - 227).round().clamp(0, 255);

        img.data[index] = shift | (b << 16) | (g << 8) | r;
      }
    }

    imglib.PngEncoder pngEncoder = imglib.PngEncoder(level: 0, filter: 0);
    List<int> png = pngEncoder.encodeImage(img);
    var converted = imglib.Image.fromBytes(width, height, png);
    var cropped = copyCrop(converted, int.tryParse(rect["x"].toString()) ?? 0, int.tryParse(rect["y"].toString()) ?? 0, int.tryParse(rect["w"].toString()) ?? 0,
        int.tryParse(rect["h"].toString()) ?? 0);
    return cropped;
  }

  Future<void> stopRecognitions() async {
    if (!_recognitionController.isClosed) {
      _recognitionController.add(null);
      _recognitionController.close();
    }
  }
}
