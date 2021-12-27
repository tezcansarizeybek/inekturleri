import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inekturleri/model/question_model.dart';
import 'package:intl/intl.dart';

class ChatPage extends StatelessWidget {
  ChatPage({Key key, this.info}) : super(key: key);
  final Map<String, dynamic> info;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Soru"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Stack(children: [
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection("questions")
                  .doc(info["doc"])
                  .collection("question")
                  .where("id", isEqualTo: info["id"])
                  .orderBy("datetime", descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                    itemBuilder: (context, index) {
                      var data = QuestionModel.fromJson(snapshot.data.docs.elementAt(index).data());
                      return Column(
                        children: [
                          data.question != ""
                              ? Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      SizedBox(
                                        width: Get.size.width / 2,
                                        child: Card(
                                          color: Colors.red.shade500,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              data.question,
                                              style: const TextStyle(
                                                  letterSpacing: 0.8, wordSpacing: 0.8),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: Get.size.width / 2,
                                        child: Card(
                                          color: Colors.greenAccent.shade400,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              data.answer,
                                              style: const TextStyle(
                                                  letterSpacing: 0.8, wordSpacing: 0.8),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Row(
                              mainAxisAlignment: data.question != ""
                                  ? MainAxisAlignment.end
                                  : MainAxisAlignment.start,
                              children: [
                                Text(
                                  DateFormat("HH:mm:ss").format(
                                      DateFormat("yyyy-MM-dd HH:mm:ss").parse(data.datetime)),
                                ),
                              ],
                            ),
                          )
                        ],
                      );
                    },
                    itemCount: snapshot.data.docs.length,
                  );
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              }),
          Positioned(
            bottom: 2,
            left: 2,
            right: 2,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    hintText: "Mesaj",
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: () => sendMessage(),
                    )),
                controller: _msgController,
                onSubmitted: (value) => sendMessage(),
              ),
            ),
          )
        ]),
      ),
    );
  }

  sendMessage() async {
    if (_msgController.text != "") {
      await FirebaseFirestore.instance
          .collection("questions")
          .doc(info["doc"])
          .collection("question")
          .add(QuestionModel(
            id: info["id"],
            datetime: DateTime.now().toString(),
            name: info["name"],
            email: info["email"],
            question: _msgController.text,
          ).toJson());
      await FirebaseFirestore.instance
          .collection("questions")
          .doc(info["doc"])
          .update({"datetime": DateTime.now().toString()});
      _msgController.text = "";
    }
  }

  final TextEditingController _msgController = TextEditingController();
}
