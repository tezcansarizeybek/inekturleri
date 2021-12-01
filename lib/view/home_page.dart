import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inekturleri/view/widgets/camera.dart';
import 'package:inekturleri/view/widgets/recognition.dart';
import 'package:inekturleri/view_model/camera.dart';
import 'package:inekturleri/view_model/image_classify.dart';

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
        _cameraService.startStreaming();
      });
    } else {
      await Get.find<ImageClassify>().loadModel();
      _cameraService.startStreaming();
    }
  }

  stopRecognitions() async {
    // closes the streams
    await _cameraService.stopImageStream();
    await Get.find<ImageClassify>().stopRecognitions();
  }

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
