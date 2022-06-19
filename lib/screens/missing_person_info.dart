import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:help_find_the_missing/build_image.dart';
import 'package:help_find_the_missing/my_elevated_button.dart';
import 'package:help_find_the_missing/my_label_widget.dart';
import '../constants.dart';

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
    final w = MediaQuery.of(context).size.width;

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
                            myLabelWidget(labelName: 'Name  :'),
                            myLabelWidget(labelName: 'Age  :'),
                            myLabelWidget(labelName: 'Gender  :'),
                            myLabelWidget(labelName: 'Guardian Name  :'),
                            myLabelWidget(labelName: 'Guardian Contact  :'),
                            myLabelWidget(labelName: 'Height  :'),
                            myLabelWidget(labelName: 'Weight  :'),
                            myLabelWidget(labelName: 'Pincode  :'),
                            myLabelWidget(labelName: 'City  :'),
                            myLabelWidget(labelName: 'District  :'),
                            myLabelWidget(labelName: 'State  :'),
                            myLabelWidget(labelName: 'Place of Missing  :'),
                            myLabelWidget(labelName: 'Date of Missing  :'),
                            myLabelWidget(labelName: 'Last seen wearing  :'),
                            myLabelWidget(labelName: 'Posted By :'),
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
                  Column(
                    children: [
                      MyElevatedButton(
                          onPress: () {}, buttonLabel: 'View Comments', w: w),
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
                                          const myLabelWidget(
                                              labelName: 'Last Seen Location'),
                                          TextField(
                                            keyboardType: TextInputType.name,
                                            // controller: _lastSeenController,
                                            decoration:
                                                kTextFieldDecoration.copyWith(
                                              hintText: 'Location',
                                            ),
                                          ),
                                          const myLabelWidget(
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
                                                        onPrimary: greenAccent,
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
                                          const myLabelWidget(
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
                                                        onPrimary: greenAccent,
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
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Center(
                                            child: MyElevatedButton(
                                                onPress: () {},
                                                buttonLabel: 'Post',
                                                w: w),
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
                        buttonLabel: 'Post Comment',
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
