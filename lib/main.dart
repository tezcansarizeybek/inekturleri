import 'dart:developer';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inekturleri/view/home_page.dart';
import 'package:inekturleri/view/widgets/settings/remove_scroll_glow.dart';
import 'package:inekturleri/view_model/image_classify.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_core/firebase_core.dart';

List<CameraDescription> cameras = [];
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    Firebase.initializeApp();
    await Permission.camera.request();
    cameras = await availableCameras();
  } on CameraException catch (e) {
    log('Hata: ${e.code}\n${e.description}');
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.put(ImageClassify());
    return GetMaterialApp(
      title: 'İnek Türleri',
      debugShowCheckedModeBanner: false,
      darkTheme: ThemeData.dark(),
      theme: ThemeData(primarySwatch: Colors.blue),
      builder: (context, child) {
        return ScrollConfiguration(
          behavior: RemoveScrollGlow(),
          child: child,
        );
      },
      home: HomePage(
        camera: cameras.first,
      ),
    );
  }
}
