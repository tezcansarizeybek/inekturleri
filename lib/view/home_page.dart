import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inekturleri/view/question/ask_page.dart';
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("İnek Türleri"),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black45,
        child: const Icon(
          Icons.question_answer,
          color: Colors.blue,
        ),
        onPressed: () => Get.to(() => AskQuestionsPage()),
      ),
      body: Stack(
        children: [
          FadeInImage(
              height: Get.size.height,
              fit: BoxFit.cover,
              placeholder: const AssetImage('assets/loading.gif'),
              image: const NetworkImage(
                  'https://upload.wikimedia.org/wikipedia/commons/thumb/f/fb/CH_cow_2.jpg/1200px-CH_cow_2.jpg')),
          Positioned(
            top: 200,
            left: 40,
            right: 40,
            child: Card(
              color: Colors.black12,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                child: Column(
                  children: [
                    ElevatedButton(
                      onPressed: () => Get.to(() => ClassifyPage(camera: widget.camera)),
                      child: const Text("Tür Bul"),
                      style: ButtonStyle(
                          minimumSize: MaterialStateProperty.all(const Size.fromHeight(40))),
                    ),
                    ElevatedButton(
                      onPressed: () => Get.to(() => const TurPage()),
                      child: const Text("Bulunabilecek TÜrler"),
                      style: ButtonStyle(
                          minimumSize: MaterialStateProperty.all(const Size.fromHeight(40))),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
