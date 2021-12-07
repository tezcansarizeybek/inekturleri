import 'package:flutter/services.dart';
import 'package:get/get.dart';

class TxtVM extends GetxController {
  var turList = [].obs;

  readTxtFile() async {
    var txt = await rootBundle.loadString('assets/model.txt');
    var list = txt.split('\n');
    for (var element in list) {
      turList.add(element);
    }
  }
}
