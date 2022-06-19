import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:help_find_the_missing/build_image.dart';
import 'package:help_find_the_missing/my_label_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants.dart';

final _firestore = FirebaseFirestore.instance;

class MissingPersonInfo extends StatefulWidget {
  final QueryDocumentSnapshot<Object?> doc;
  const MissingPersonInfo({required this.doc});

  @override
  State<MissingPersonInfo> createState() => _MissingPersonInfoState();
}

class _MissingPersonInfoState extends State<MissingPersonInfo> {
  String postedBy = '';

  @override
  void initState() {
    widget.doc.get('posted_by').get().then((DocumentSnapshot au) {
      setState(() {
        postedBy = au.get('email').toString();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: themeColor,
        title: Text(widget.doc.get('name')),
      ),
      body: Container(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            BuildImage(
              imageURL: (widget.doc['image'] != null)
                  ? widget.doc['image']
                  : 'no_image.jpg',
              height: 200,
              width: 200,
            ),
            const SizedBox(
              height: 10,
            ),
            Expanded(
              child: ListView(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: const <Widget>[
                            myLabelWidget(labelName: 'Name  : '),
                            myLabelWidget(labelName: 'Age  : '),
                            myLabelWidget(labelName: 'Gender  : '),
                            myLabelWidget(labelName: 'Guardian Name  : '),
                            myLabelWidget(labelName: 'Guardian Contact  : '),
                            myLabelWidget(labelName: 'Height  : '),
                            myLabelWidget(labelName: 'Weight  : '),
                            myLabelWidget(labelName: 'Pincode  : '),
                            myLabelWidget(labelName: 'City  : '),
                            myLabelWidget(labelName: 'District  : '),
                            myLabelWidget(labelName: 'State  : '),
                            myLabelWidget(labelName: 'Place of Missing  : '),
                            myLabelWidget(labelName: 'Date of Missing  : '),
                            myLabelWidget(labelName: 'Last seen wearing  : '),
                            myLabelWidget(labelName: 'Posted By : '),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            myLabelWidget(labelName: widget.doc.get('name')),
                            myLabelWidget(
                                labelName: widget.doc.get('age').toString()),
                            myLabelWidget(labelName: widget.doc.get('gender')),
                            myLabelWidget(
                                labelName: widget.doc.get('parent_name')),
                            myLabelWidget(
                                labelName: widget.doc.get('parent_contact')),
                            myLabelWidget(
                                labelName:
                                    widget.doc.get('height')[0].toString() +
                                        'cm - ' +
                                        widget.doc.get('height')[1].toString() +
                                        'cm'),
                            myLabelWidget(
                                labelName:
                                    widget.doc.get('weight').toString() + 'kg'),
                            myLabelWidget(
                                labelName:
                                    widget.doc.get('pincode').toString()),
                            myLabelWidget(labelName: widget.doc.get('city')),
                            myLabelWidget(
                                labelName: widget.doc.get('district')),
                            myLabelWidget(labelName: widget.doc.get('state')),
                            myLabelWidget(labelName: widget.doc.get('pom')),
                            myLabelWidget(labelName: widget.doc.get('dom')),
                            myLabelWidget(
                                labelName: widget.doc.get('last_outfit')),
                            myLabelWidget(labelName: postedBy),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            )
          ],
        ),
      ),
    );
  }
}
