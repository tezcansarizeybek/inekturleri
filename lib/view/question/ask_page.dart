import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inekturleri/model/question_model.dart';
import 'package:inekturleri/view/question/chat_page.dart';
import 'package:uuid/uuid.dart';

class AskQuestionsPage extends StatelessWidget {
  AskQuestionsPage({Key key}) : super(key: key);

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _questionController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Soru Sor"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  validator: (value) => value.isEmpty ? "İsim Boş Olamaz" : null,
                  controller: _nameController,
                  decoration:
                      const InputDecoration(labelText: "İsim", border: OutlineInputBorder()),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  validator: (value) => value.isEmpty ? "E-Posta Boş Olamaz" : null,
                  controller: _emailController,
                  decoration:
                      const InputDecoration(labelText: "E-Posta", border: OutlineInputBorder()),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  validator: (value) => value.isEmpty ? "Soru Boş Olamaz" : null,
                  controller: _questionController,
                  decoration: const InputDecoration(
                    labelText: "Soru",
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 8,
                ),
              ),
              ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState.validate()) {
                      var uuid = const Uuid().v4();
                      var question = QuestionModel(
                              name: _nameController.text,
                              email: _emailController.text,
                              question: _questionController.text,
                              datetime: DateTime.now().toString(),
                              id: uuid)
                          .toJson();
                      await FirebaseFirestore.instance.collection("questions").add({
                        "name": _nameController.text,
                        "id": uuid,
                        "datetime": DateTime.now().toString()
                      });
                      var collection = await FirebaseFirestore.instance
                          .collection("questions")
                          .where("id", isEqualTo: uuid)
                          .get();
                      await FirebaseFirestore.instance
                          .collection("questions")
                          .doc(collection.docs.first.id)
                          .collection("question")
                          .add(question);
                      question.addAll({"doc": collection.docs.first.id});
                      Get.to(() => ChatPage(info: question));
                    }
                  },
                  child: const Text("Soru Sor"))
            ],
          ),
        ),
      ),
    );
  }
}
