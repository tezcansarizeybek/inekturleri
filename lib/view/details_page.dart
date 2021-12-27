import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DetailsPage extends StatelessWidget {
  const DetailsPage({Key key, this.info}) : super(key: key);
  final QueryDocumentSnapshot info;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${info["name"]}"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(20.0),
                  child: FadeInImage.assetNetwork(
                    placeholder: 'assets/loading.gif',
                    image: "${info["image"]}",
                    fit: BoxFit.fill,
                    width: Get.size.width,
                    alignment: Alignment.center,
                  )),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "${info["description"]}",
                style: const TextStyle(letterSpacing: 0.8),
              ),
            )
          ],
        ),
      ),
    );
  }
}
