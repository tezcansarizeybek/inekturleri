import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inekturleri/view_model/txt_vm.dart';

class TurPage extends StatelessWidget {
  const TurPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Türler"),
        centerTitle: true,
      ),
      body: GetBuilder<TxtVM>(initState: (_) async {
        Get.put(TxtVM());
        await Get.find<TxtVM>().readTxtFile();
      }, builder: (c) {
        return Obx(() {
          return ListView.builder(
            itemBuilder: (context, index) => ListTile(
              title: Text("${c.turList.elementAt(index) ?? ''}"),
            ),
            itemCount: c.turList.length,
          );
        });
      }),
    );
  }
}
