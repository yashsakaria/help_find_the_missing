import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:help_find_the_missing/my_label_widget.dart';
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
            decoration: const BoxDecoration(
              borderRadius: kDefaultBorderRadius,
            ),
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                Row(
                  children: [
                    BuildImage(
                        imageURL: (doc['image'] != null)
                            ? doc['image']
                            : 'no_image.jpg'),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: SizedBox(
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
                    ? Column(
                        children: [
                          const SizedBox(
                            height: 6,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    'Accuracy : ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF000610),
                                    ),
                                  ),
                                  Text('${info.elementAt(0)}%'),
                                ],
                              ),
                              Row(
                                children: [
                                  const Text(
                                    'Distance : ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF000610),
                                    ),
                                  ),
                                  Text('${info.elementAt(1)} km'),
                                ],
                              ),
                            ],
                          ),
                        ],
                      )
                    : const SizedBox(),
              ],
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
