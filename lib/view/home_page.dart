import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inekturleri/view/classification_page.dart';
import 'package:inekturleri/view/tur_page.dart';

class HomePage extends StatefulWidget {
  final CameraDescription camera;
  const HomePage({
    Key key,
    @required this.camera,
  }) : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> with TickerProviderStateMixin, WidgetsBindingObserver {
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("İnek Türleri"),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(onPressed: () => Get.to(() => ClassifyPage(camera: widget.camera)), child: const Text("Tür Bul")),
            ElevatedButton(onPressed: () => Get.to(() => const TurPage()), child: const Text("Bulunabilecek TÜrler"))
          ],
        ),
      ),
    );
  }
}
