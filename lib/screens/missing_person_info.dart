import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:help_find_the_missing/build_image.dart';
import 'package:help_find_the_missing/my_label_widget.dart';
import '../constants.dart';

class MissingPersonInfo extends StatelessWidget {
  final QueryDocumentSnapshot<Object?> doc;
  const MissingPersonInfo({required this.doc});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: themeColor,
        title: Text(doc.get('name')),
      ),
      body: Container(
        padding: EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            BuildImage(
              imageURL: (doc['image'] != null) ? doc['image'] : 'no_image.jpg',
              height: 200,
              width: 200,
            ),
            const SizedBox(
              height: 10,
            ),
            Expanded(
              child: Row(
                children: [
                  Column(),
                  Column(),
                ],
              ),
            )
            // Column(
            //   children: [
            //     myLabelWidget(labelName: 'Name'),
            //     myLabelWidget(labelName: 'Gender'),
            //   ],
            // ),
          ],
        ),
      ),
    );
  }
}
