import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:help_find_the_missing/screens/missing_person_info.dart';
import 'package:help_find_the_missing/build_image.dart';
import 'package:help_find_the_missing/constants.dart';

const List def = [];

class MissingPersonCard extends StatelessWidget {
  final QueryDocumentSnapshot<Object?> doc;
  final List info;
  const MissingPersonCard({required this.doc, this.info = def});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        elevation: 4,
        borderRadius: kDefaultBorderRadius,
        child: GestureDetector(
          child: Container(
            // height: 130,
            decoration: const BoxDecoration(
              // color: themeColor,
              borderRadius: kDefaultBorderRadius,
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      BuildImage(
                          imageURL: (doc['image'] != null)
                              ? doc['image']
                              : 'no_image.jpg'),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 12),
                        child: SizedBox(
                          height: 100,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                doc.get('name'),
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              Row(
                                children: [
                                  Text(
                                    doc.get('gender'),
                                    style: const TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  Text(
                                    doc.get('age').toString(),
                                    style: const TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  (info.length == 2)
                      ? SizedBox(
                          height: 15,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                  'Accuracy : ${info.elementAt(0).toStringAsFixed(2)}%'),
                              Text(
                                  'Distance : ${info.elementAt(1).toStringAsFixed(2)} Km')
                            ],
                          ),
                        )
                      : Row()
                ],
              ),
            ),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MissingPersonInfo(doc: doc),
              ),
            );
          },
        ),
      ),
    );
  }
}

// Text(
// 'Accuracy : ${info.elementAt(0).toStringAsFixed(2)}%'),
// Text(
// 'Distance : ${info.elementAt(1).toStringAsFixed(2)} Km')
