import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inekturleri/view/details_page.dart';
import 'package:inekturleri/view_model/image_classify.dart';

///Sınıflandırma sonuçlarının gözüktüğü widget
class Sonuclar extends StatefulWidget {
  const Sonuclar({Key key, @required this.ready}) : super(key: key);
  final bool ready;

  @override
  _SonuclarState createState() => _SonuclarState();
}

enum SubscriptionState { active, done }

class _SonuclarState extends State<Sonuclar> {
  List<dynamic> _currentRecognition = [];
  StreamSubscription _streamSubscription;

  @override
  void initState() {
    super.initState();

    // starts the streaming to tensorflow results
    _startRecognitionStreaming();
  }

  _startRecognitionStreaming() {
    _streamSubscription ??= Get.find<ImageClassify>().recognitionStream.listen((recognition) {
      if (recognition != null) {
        // rebuilds the screen with the new recognitions
        setState(() {
          _currentRecognition = recognition;
        });
      } else {
        _currentRecognition = [];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: SizedBox(
        height: 200,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF120320),
                ),
                height: 200,
                width: MediaQuery.of(context).size.width,
                child: Column(
                  children: widget.ready
                      ? <Widget>[
                          Container(
                            padding: const EdgeInsets.only(top: 15, left: 20, right: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const <Widget>[
                                Text(
                                  "Sonuçlar",
                                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.w300),
                                ),
                              ],
                            ),
                          ),
                          _contentWidget(),
                        ]
                      : <Widget>[],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _contentWidget() {
    var _width = MediaQuery.of(context).size.width;
    var _padding = 20.0;
    var _labelWidth = 150.0;
    var _labelConfidence = 30.0;
    var _barWitdth = _width - _labelWidth - _labelConfidence - _padding * 2.0;

    if (_currentRecognition.isNotEmpty) {
      return SizedBox(
        height: 150,
        child: ListView.builder(
          itemCount: _currentRecognition.length,
          itemBuilder: (context, index) {
            if (_currentRecognition.length > index) {
              return SizedBox(
                height: 40,
                child: InkWell(
                  onTap: () async {
                    try {
                      Get.dialog(AlertDialog(
                        content: Row(
                          children: [
                            const CircularProgressIndicator(),
                            Container(
                                margin: const EdgeInsets.only(left: 7),
                                child: const Text("Yükleniyor...")),
                          ],
                        ),
                      ));
                      var cows = await FirebaseFirestore.instance
                          .collection("cows")
                          .where("name", isEqualTo: "${_currentRecognition[index]['label']}")
                          .get();
                      Get.back();
                      var cow = cows.docs.first;
                      Get.to(() => DetailsPage(
                            info: cow,
                          ));
                    } catch (e) {
                      if (Get.isDialogOpen) {
                        Get.back();
                      }
                      throw Exception(e);
                    }
                  },
                  child: Row(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.only(left: _padding, right: _padding),
                        width: _labelWidth,
                        child: Text(
                          _currentRecognition[index]['label'] ?? "",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(
                        width: _barWitdth,
                        child: LinearProgressIndicator(
                          backgroundColor: Colors.transparent,
                          value: _currentRecognition[index]['confidence'] ?? 0,
                        ),
                      ),
                      SizedBox(
                        width: _labelConfidence,
                        child: Text(
                          ((_currentRecognition[index]['confidence'] ?? 0) * 100)
                                  .toStringAsFixed(0) +
                              '%',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      )
                    ],
                  ),
                ),
              );
            } else {
              return Container();
            }
          },
        ),
      );
    } else {
      return const Text('');
    }
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }
}
