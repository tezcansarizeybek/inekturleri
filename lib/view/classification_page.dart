import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inekturleri/view/widgets/bnd_box.dart';
import 'package:inekturleri/view/widgets/camera.dart';
import 'package:inekturleri/view/widgets/recognition.dart';
import 'package:inekturleri/view_model/camera.dart';
import 'dart:math' as math;
import 'package:inekturleri/view_model/image_classify.dart';

class ClassifyPage extends StatefulWidget {
  final CameraDescription camera;
  const ClassifyPage({Key key, @required this.camera}) : super(key: key);

  @override
  _ClassifyPageState createState() => _ClassifyPageState();
}

class _ClassifyPageState extends State<ClassifyPage> with TickerProviderStateMixin, WidgetsBindingObserver {
  final CameraService _cameraService = CameraService();

  Future<void> _initializeControllerFuture;

  AppLifecycleState _appLifecycleState;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    startUp();
  }

  Future startUp() async {
    if (!mounted) {
      return;
    }
    if (_initializeControllerFuture == null) {
      _initializeControllerFuture = _cameraService.startService(widget.camera).then((value) async {
        await Get.find<ImageClassify>().loadModel();
        _cameraService.startStreaming(setRecognitions);
      });
    } else {
      await Get.find<ImageClassify>().loadModel();
      _cameraService.startStreaming(setRecognitions);
    }
  }

  stopRecognitions() async {
    // closes the streams
    await _cameraService.stopImageStream();
    await Get.find<ImageClassify>().stopRecognitions();
  }

  setRecognitions(recognitions, imageHeight, imageWidth) async {
    setState(() {
      _recognitions = recognitions;
      _imageHeight = imageHeight;
      _imageWidth = imageWidth;
    });
  }

  List<dynamic> _recognitions;
  int _imageHeight = 0;
  int _imageWidth = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the Future is complete, display the preview.
            return Stack(
              children: <Widget>[
                CameraScreen(
                  controller: _cameraService.cameraController,
                ),
                BndBox(_recognitions ?? [], math.max(_imageHeight, _imageWidth), math.min(_imageHeight, _imageWidth), Get.size.height - 200, Get.size.width, ""),
                const Sonuclar(
                  ready: true,
                ),
              ],
            );
          } else {
            // Otherwise, display a loading indicator.
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _appLifecycleState = state;
    if (_appLifecycleState == AppLifecycleState.resumed) {
      startUp();
    }
  }

  @override
  void dispose() {
    _cameraService.dispose();
    Get.find<ImageClassify>().dispose();
    _initializeControllerFuture = null;
    super.dispose();
  }
}
