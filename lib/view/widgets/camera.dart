import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

///Kamera widgetı, kameradan elde edilen anlık görüntüler burada gözükür.
class CameraScreen extends StatefulWidget {
  const CameraScreen({Key key, @required this.controller}) : super(key: key);
  final CameraController controller;
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  @override
  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (rect) {
        return const LinearGradient(begin: Alignment.topCenter, end: Alignment.center, colors: [Colors.black, Colors.transparent])
            .createShader(Rect.fromLTRB(0, 0, rect.width, rect.height / 4));
      },
      blendMode: BlendMode.darken,
      child: CameraPreview(widget.controller),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
