import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';

import 'package:help_find_the_missing/constants/constants.dart';
import 'package:help_find_the_missing/my_widgets/build_image.dart';
import 'package:help_find_the_missing/my_widgets/my_label_widget.dart';
import 'package:help_find_the_missing/my_widgets/my_elevated_button.dart';
import 'package:help_find_the_missing/my_widgets/combo_label_widget.dart';

final _firestore = FirebaseFirestore.instance;

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

  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _commentController = TextEditingController();

  @override
  void initState() {
    widget.doc.get('posted_by').get().then((DocumentSnapshot au) {
      setState(() {
        postedBy = au.get('email').toString();
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: themeColor,
        title: Text(widget.doc.get('name') + '\'s Info'),
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
                                      labelName: 'Guardian Contact : '),
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
                      MyElevatedButton(
                        onPress: () {},
                        buttonLabel: const Text(
                          'View Comments',
                          style: kButtonTextStyle,
                        ),
                        w: w,
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      MyElevatedButton(
                        onPress: () {
                          showModalBottomSheet(
                            isScrollControlled: true,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20.0),
                                topRight: Radius.circular(20.0),
                              ),
                            ),
                            context: context,
                            builder: (context) {
                              return SingleChildScrollView(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                      bottom: MediaQuery.of(context)
                                          .viewInsets
                                          .bottom),
                                  child: SizedBox(
                                    height: 335,
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const MyLabelWidget(
                                              labelName: 'Last Seen Location'),
                                          TextField(
                                            keyboardType: TextInputType.name,
                                            controller: _commentController,
                                            decoration:
                                                kTextFieldDecoration.copyWith(
                                              hintText: 'Location',
                                            ),
                                          ),
                                          const MyLabelWidget(
                                              labelName: 'Date'),
                                          TextField(
                                            readOnly: true,
                                            keyboardType:
                                                TextInputType.datetime,
                                            controller: _dateController,
                                            decoration:
                                                kTextFieldDecoration.copyWith(
                                              hintText: 'Date of missing',
                                            ),
                                            onTap: () async {
                                              final DateTime? picked =
                                                  await showDatePicker(
                                                context: context,
                                                initialDate: selectedDate,
                                                firstDate: DateTime(2000),
                                                lastDate: DateTime.now(),
                                                builder: (context, child) {
                                                  return Theme(
                                                    data: Theme.of(context)
                                                        .copyWith(
                                                      colorScheme:
                                                          ColorScheme.light(
                                                        primary: themeColor,
                                                        onPrimary:
                                                            secondaryColor,
                                                      ),
                                                    ),
                                                    child: child!,
                                                  );
                                                },
                                              );
                                              if (picked != null) {
                                                setState(() {
                                                  selectedDate = picked;
                                                  _dateController.text =
                                                      '${selectedDate.toLocal()}'
                                                          .split(' ')[0];
                                                });
                                              }
                                            },
                                          ),
                                          const MyLabelWidget(
                                              labelName: 'Time'),
                                          TextField(
                                            readOnly: true,
                                            keyboardType:
                                                TextInputType.datetime,
                                            controller: _timeController,
                                            decoration:
                                                kTextFieldDecoration.copyWith(
                                              hintText: 'Time',
                                            ),
                                            onTap: () async {
                                              final TimeOfDay? picked =
                                                  await showTimePicker(
                                                context: context,
                                                initialTime: selectedTime,
                                                builder: (context, child) {
                                                  return Theme(
                                                    data: Theme.of(context)
                                                        .copyWith(
                                                      colorScheme:
                                                          ColorScheme.light(
                                                        primary: themeColor,
                                                        onPrimary:
                                                            secondaryColor,
                                                      ),
                                                    ),
                                                    child: child!,
                                                  );
                                                },
                                              );
                                              if (picked != null) {
                                                setState(() {
                                                  _timeController.text =
                                                      '${picked.hour}:${picked.minute}';
                                                  selectedTime = picked;
                                                });
                                              }
                                            },
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          Center(
                                            child: MyElevatedButton(
                                              onPress: () {
                                                var commentRef = _firestore
                                                    .collection('comments')
                                                    .doc(widget.doc.id);

                                                commentRef
                                                    .get()
                                                    .then((document) {
                                                  if (document.exists) {
                                                    print(document
                                                        .get('comments')[0]);

                                                    if (document
                                                            .get('comments')
                                                            .length ==
                                                        4) {
                                                      commentRef.update({
                                                        "comments": FieldValue
                                                            .arrayRemove([
                                                          document.get(
                                                              'comments')[0]
                                                        ])
                                                      });
                                                    }

                                                    commentRef.update({
                                                      "comments": FieldValue
                                                          .arrayUnion([
                                                        {
                                                          "comment":
                                                              _commentController
                                                                  .text,
                                                          "date":
                                                              _dateController
                                                                  .text,
                                                          "time":
                                                              _timeController
                                                                  .text,
                                                        }
                                                      ])
                                                    });
                                                  } else {
                                                    commentRef.set({
                                                      "comments": FieldValue
                                                          .arrayUnion([
                                                        {
                                                          "comment":
                                                              _commentController
                                                                  .text,
                                                          "date":
                                                              _dateController
                                                                  .text,
                                                          "time":
                                                              _timeController
                                                                  .text,
                                                        }
                                                      ])
                                                    });
                                                  }
                                                });
                                              },
                                              buttonLabel: const Text(
                                                'Post',
                                                style: kButtonTextStyle,
                                              ),
                                              w: w,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        buttonLabel: const Text(
                          'Post Comment',
                          style: kButtonTextStyle,
                        ),
                        w: w,
                      ),
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
