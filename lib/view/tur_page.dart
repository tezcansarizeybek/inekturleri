import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inekturleri/view/details_page.dart';

class TurPage extends StatelessWidget {
  const TurPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    getCows();
    return Scaffold(
        appBar: AppBar(
          title: const Text("Türler"),
          centerTitle: true,
        ),
        body: Container(
            width: Get.size.width,
            decoration: const BoxDecoration(
                // Background image
                image: DecorationImage(
                    colorFilter: ColorFilter.mode(
                        Colors.black38, BlendMode.hue), // With %38 opacity-black hue
                    image: NetworkImage(
                        "https://upload.wikimedia.org/wikipedia/commons/thumb/f/fb/CH_cow_2.jpg/1200px-CH_cow_2.jpg"),
                    fit: BoxFit.cover)),
            child: FutureBuilder(
                future: getCows(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Text("No father no");
                  } else {
                    return ListView.builder(
                      itemBuilder: (context, index) => Card(
                        color: Colors.black12,
                        child: ListTile(
                          title: Text("${snapshot.data.elementAt(index)["name"]}"),
                          onTap: () {
                            Get.to(() => DetailsPage(info: snapshot.data.elementAt(index)));
                          },
                        ),
                      ),
                      itemCount: snapshot.data.length,
                    );
                  }
                })));
  }

  /// Function to get cow list from firestore
  getCows() async {
    CollectionReference cows = FirebaseFirestore.instance.collection("cows");
    var docs = await cows.get();
    return docs.docs;
  }
}
