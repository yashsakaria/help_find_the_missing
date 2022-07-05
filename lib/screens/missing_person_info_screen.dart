import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:help_find_the_missing/constants/constants.dart';
import 'package:help_find_the_missing/my_widgets/build_image.dart';
import 'package:help_find_the_missing/my_widgets/my_label_widget.dart';
import 'package:help_find_the_missing/my_widgets/combo_label_widget.dart';

final _firestore = FirebaseFirestore.instance;
final _auth = FirebaseAuth.instance;
late User loggedInUser;

class MissingPersonInfo extends StatefulWidget {
  final QueryDocumentSnapshot<Object?> doc;
  const MissingPersonInfo({required this.doc});

  @override
  State<MissingPersonInfo> createState() => _MissingPersonInfoState();
}

class _MissingPersonInfoState extends State<MissingPersonInfo> {
  String postedBy = '';

  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();

  @override
  void initState() {
    widget.doc.get('posted_by').get().then((DocumentSnapshot au) {
      setState(() {
        postedBy = au.get('email').toString();
      });
    });
    getCurrentUser();
    super.initState();
  }

  void getCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: themeColor,
        title: Text(widget.doc.get('name') + '\'s Info'),
      ),
      floatingActionButton: Visibility(
        visible: (loggedInUser.email != null),
        child: FloatingActionButton(
          onPressed: () {
            FirebaseStorage.instance
                .ref()
                .child('${widget.doc.id}.jpg')
                .delete()
                .then((value) {
              _firestore
                  .collection('missing_person')
                  .doc(widget.doc.id)
                  .delete()
                  .then((doc) {
                print("Deleted");
                Navigator.of(context).pop();
              });
            });
          },
          child: const Icon(Icons.delete_outline),
          backgroundColor: themeColor,
        ),
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
                  Column(
                    children: [
                      ComboLabelWidget(
                        title: 'Name  :',
                        content: widget.doc.get('name'),
                      ),
                      ComboLabelWidget(
                        title: 'Age  :',
                        content: widget.doc.get('age').toString(),
                      ),
                      ComboLabelWidget(
                        title: 'Gender :',
                        content: widget.doc.get('gender'),
                      ),
                      ComboLabelWidget(
                        title: 'Guardian Name :',
                        content: widget.doc.get('parent_name'),
                      ),
                      GestureDetector(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: const [
                                  MyLabelWidget(
                                      labelName: 'Guardian Contact :'),
                                ],
                              ),
                            ),
                            Expanded(
                              child: MyLabelWidget(
                                labelName: widget.doc.get('parent_contact'),
                                labelStyle: kLabelWidgetTextStyle.copyWith(
                                  color: Colors.blueAccent,
                                ),
                              ),
                            ),
                          ],
                        ),
                        onTap: () async {
                          await FlutterPhoneDirectCaller.callNumber(
                              widget.doc.get('parent_contact'));
                        },
                      ),
                      ComboLabelWidget(
                          title: 'Height :',
                          content: widget.doc.get('height')[0].toString() +
                              'cm - ' +
                              widget.doc.get('height')[1].toString() +
                              'cm'),
                      ComboLabelWidget(
                          title: 'Weight :',
                          content: widget.doc.get('weight').toString() + 'kg'),
                      ComboLabelWidget(
                        title: 'Pincode :',
                        content: widget.doc.get('pincode').toString(),
                      ),
                      ComboLabelWidget(
                        title: 'City :',
                        content: widget.doc.get('city'),
                      ),
                      ComboLabelWidget(
                        title: 'District :',
                        content: widget.doc.get('district'),
                      ),
                      ComboLabelWidget(
                        title: 'State :',
                        content: widget.doc.get('state'),
                      ),
                      ComboLabelWidget(
                        title: 'Place of Missing :',
                        content: widget.doc.get('pom'),
                      ),
                      ComboLabelWidget(
                        title: 'Date of Missing :',
                        content: widget.doc.get('dom'),
                      ),
                      ComboLabelWidget(
                        title: 'Last Seen Wearing :',
                        content: widget.doc.get('last_outfit'),
                      ),
                      ComboLabelWidget(title: 'Posted by :', content: postedBy),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
