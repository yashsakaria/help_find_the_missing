// ignore_for_file: avoid_print, use_key_in_widget_constructors

import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:help_find_the_missing/constants.dart';
import 'package:help_find_the_missing/my_elevated_button.dart';
import 'package:help_find_the_missing/my_label_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

final _auth = FirebaseAuth.instance;
final _firestore = FirebaseFirestore.instance;
final _database = FirebaseDatabase.instance.refFromURL(
    'https://find-the-missing-587f9-default-rtdb.asia-southeast1.firebasedatabase.app');
final _storage = FirebaseStorage.instance.ref();
late User loggedInUser;

class AddReportScreen extends StatefulWidget {
  static String id = 'addReportScreen';

  @override
  State<AddReportScreen> createState() => _AddReportScreenState();
}

class _AddReportScreenState extends State<AddReportScreen> {
  final ImagePicker _picker = ImagePicker();
  File? selectedImage;

  late DataSnapshot snapshot;
  var selectedHeightRange = const RangeValues(100, 120);
  var selectedWeight = 50.0;
  DateTime selectedDate = DateTime.now();

  String gender = 'Male';
  List<String> areas = ['Invalid Pincode'];
  String selectedArea = 'Invalid Pincode';

  final _fullNameController = TextEditingController();
  final _ageController = TextEditingController();
  final _parentNameController = TextEditingController();
  final _parentContactController = TextEditingController();
  final _addressController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _cityController = TextEditingController();
  final _districtController = TextEditingController();
  final _stateController = TextEditingController();
  final _complexionController = TextEditingController();
  final _bodyTypeController = TextEditingController();
  final _hairColorController = TextEditingController();
  final _markController = TextEditingController();
  final _lastOutfitController = TextEditingController();
  final _pomController = TextEditingController();
  final _domController = TextEditingController();
  final _lastSeenController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getCurrentUser();
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

  Future updateSnapshot(String key) async {
    print('shere');
    snapshot = await _database.child(key).get();
  }

  Future getImage(source) async {
    try {
      XFile? tempImage = await _picker.pickImage(source: source);
      if (tempImage != null) {
        setState(() {
          selectedImage = File(tempImage.path);
        });
      }
    } catch (e) {
      print(e);
      return;
    }
  }

  void validate() {
    if (selectedImage == null) {
      throw 'Please select an image.';
    }

    if (_fullNameController.text.isEmpty) {
      throw 'Name Field Cannot be empty.';
    }

    if (_ageController.text.isEmpty) {
      throw 'Age Field Cannot be empty.';
    }

    if (_parentNameController.text.isEmpty) {
      throw 'Parent Name Field Cannot be empty.';
    }

    if (_parentContactController.text.length != 10) {
      throw 'Please provide valid Parent/Guardian contact number.';
    }

    if (_addressController.text.isEmpty) {
      throw 'Please provide valid address.';
    }

    if (_pincodeController.text.length != 6) {
      throw 'Please provide valid pincode.';
    }

    if (selectedArea.compareTo('Invalid Pincode') == 0) {
      throw 'Invalid Pincode';
    }

    if (_cityController.text.isEmpty) {
      throw 'Invalid city field.';
    }

    if (_districtController.text.isEmpty) {
      throw 'Invalid district field.';
    }

    if (_stateController.text.isEmpty) {
      throw 'Invalid state field.';
    }

    if (_pomController.text.isEmpty) {
      throw 'Please provide place of missing.';
    }

    if (_domController.text.isEmpty) {
      throw 'Please provide date of missing.';
    }

    addDocument();
  }

  void addDocument() {
    _firestore.collection('missing_person').add({
      'image': null,
      'name': _fullNameController.text,
      'age': int.parse(_ageController.text),
      'gender': gender,
      'parent_name': _parentNameController.text,
      'parent_contact': _parentContactController.text,
      'height': [
        selectedHeightRange.start.round(),
        selectedHeightRange.end.round()
      ],
      'weight': selectedWeight.round(),
      'address': _addressController.text,
      'pincode': int.parse(_pincodeController.text),
      'area': selectedArea,
      'lat': double.parse(snapshot
          .child('Areas/$selectedArea/Lat')
          .value
          .toString()
          .replaceFirst(',', '.')),
      'long': double.parse(snapshot
          .child('Areas/$selectedArea/long')
          .value
          .toString()
          .replaceFirst(',', '.')),
      'city': _cityController.text,
      'district': _districtController.text,
      'state': _stateController.text,
      'complexion': _complexionController.text,
      'body_type': _bodyTypeController.text,
      'hair_color': _hairColorController.text,
      'identification_mark': _markController.text,
      'last_outfit': _lastOutfitController.text,
      'pom': _pomController.text,
      'dom': _domController.text,
      'last_seen': _lastSeenController.text,
      'posted_by': _firestore.doc('/authorised_users/' + loggedInUser.uid),
      'time': FieldValue.serverTimestamp(),
    }).then((DocumentReference documentReference) async {
      String? path = await uploadImage(documentReference.id);
      if (path != null) {
        _firestore
            .collection('missing_person')
            .doc(documentReference.id)
            .update({
          'image': path,
        });
      }
    });
  }

  Future<String?> uploadImage(String id) async {
    var path = '$id.jpg';
    final newRef = _storage.child(path);
    await newRef.putFile(selectedImage!);
    print('Successfully uploaded');
    path = await newRef.getDownloadURL();
    return path;
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: themeColor,
        title: const Center(
          child: Text('Add Report'),
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics()),
        padding: const EdgeInsets.all(8.0),
        // crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            child: SizedBox(
              height: 200,
              width: 200,
              child: ClipRRect(
                borderRadius: kDefaultBorderRadius,
                child: (selectedImage == null)
                    ? Image.asset(
                        'images/no_image.jpg',
                      )
                    : Image.file(
                        selectedImage!,
                        height: 200,
                        width: 200,
                        fit: BoxFit.contain,
                      ),
              ),
            ),
            onTap: () {
              showModalBottomSheet(
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.0),
                    topRight: Radius.circular(20.0),
                  ),
                ),
                context: context,
                builder: (context) {
                  return SizedBox(
                    height: 214,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        GestureDetector(
                          child: const SizedBox(
                            height: 70,
                            child: Center(child: Text('From Gallery')),
                          ),
                          onTap: () async {
                            Navigator.of(context).pop();
                            await getImage(ImageSource.gallery);
                          },
                        ),
                        const Divider(
                          height: 0,
                          thickness: 2,
                          color: themeColor,
                        ),
                        GestureDetector(
                          child: const SizedBox(
                            height: 70,
                            child: Center(child: Text('From Camera')),
                          ),
                          onTap: () async {
                            Navigator.of(context).pop();
                            await getImage(ImageSource.camera);
                          },
                        ),
                        const Divider(
                          height: 0,
                          thickness: 2,
                          color: themeColor,
                        ),
                        GestureDetector(
                          child: const SizedBox(
                            height: 70,
                            child: Center(child: Text('Cancel')),
                          ),
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
          const myLabelWidget(labelName: 'Full Name'),
          TextField(
            keyboardType: TextInputType.name,
            controller: _fullNameController,
            decoration: kTextFieldDecoration.copyWith(
              hintText: 'Full Name',
            ),
          ),
          const myLabelWidget(labelName: 'Age'),
          TextField(
            maxLength: 3,
            controller: _ageController,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
            ],
            decoration: kTextFieldDecoration.copyWith(
              hintText: 'Age',
            ),
          ),
          const myLabelWidget(labelName: 'Gender'),
          Material(
            elevation: 2,
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            child: DropdownButton<String>(
              value: gender,
              isExpanded: true,
              underline: Container(
                color: Colors.white,
              ),
              onChanged: (String? newValue) {
                setState(() {
                  gender = newValue!;
                });
              },
              items: <String>['Male', 'Female', 'Other']
                  .map<DropdownMenuItem<String>>((itemValue) {
                return DropdownMenuItem(
                  value: itemValue,
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 10,
                      ),
                      Text(itemValue)
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const myLabelWidget(labelName: 'Parent Name'),
          TextField(
            keyboardType: TextInputType.name,
            controller: _parentNameController,
            decoration: kTextFieldDecoration.copyWith(
              hintText: 'Parent Name',
            ),
          ),
          const myLabelWidget(labelName: 'Parent Contact Number'),
          TextField(
            maxLength: 10,
            keyboardType: TextInputType.phone,
            controller: _parentContactController,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
            ],
            decoration: kTextFieldDecoration.copyWith(
              hintText: 'Provide Valid Contact Number',
            ),
          ),
          Row(
            children: [
              const myLabelWidget(labelName: 'Height : '),
              const SizedBox(
                width: 10,
              ),
              Text('${selectedHeightRange.start.round()} cm  -  '),
              Text('${selectedHeightRange.end.round()} cm'),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 1.0,
              rangeThumbShape:
                  const RoundRangeSliderThumbShape(enabledThumbRadius: 8),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
            ),
            child: RangeSlider(
              activeColor: themeColor,
              inactiveColor: greenAccent,
              values: selectedHeightRange,
              onChanged: (RangeValues newRange) {
                setState(() {
                  selectedHeightRange = newRange;
                });
              },
              min: 15,
              max: 200,
              divisions: 186,
            ),
          ),
          Row(
            children: [
              const myLabelWidget(labelName: 'Weight : '),
              const SizedBox(
                width: 10,
              ),
              Text('${selectedWeight.round()} kg')
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 1.0,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
            ),
            child: Slider(
              activeColor: themeColor,
              inactiveColor: greenAccent,
              value: selectedWeight,
              onChanged: (double newWeight) {
                setState(() {
                  selectedWeight = newWeight;
                });
              },
              min: 10,
              max: 180,
            ),
          ),
          const myLabelWidget(labelName: 'Address'),
          TextField(
            maxLines: 4,
            keyboardType: TextInputType.name,
            controller: _addressController,
            decoration: kTextFieldDecoration.copyWith(
              hintText: 'Address',
            ),
          ),
          const myLabelWidget(labelName: 'Pincode'),
          TextField(
            maxLength: 6,
            keyboardType: TextInputType.phone,
            controller: _pincodeController,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
            ],
            decoration: kTextFieldDecoration.copyWith(
              hintText: 'Provide Valid Pincode',
            ),
            onChanged: (newValue) async {
              if (_pincodeController.text.length != 6) {
                setState(() {
                  areas = ['Invalid Pincode'];
                  selectedArea = areas[0];
                  _stateController.text = '';
                  _districtController.text = '';
                });
              } else {
                await updateSnapshot(_pincodeController.text);
                if (snapshot.value != null) {
                  areas = [];
                  var state = snapshot.child('State').value.toString();
                  var district = snapshot.child('District').value.toString();
                  var localities = snapshot.child('Areas');
                  for (var x in localities.children) {
                    areas.add(x.key.toString());
                  }
                  setState(() {
                    areas;
                    selectedArea = areas[0];
                    _stateController.text = state;
                    _districtController.text = district;
                  });
                }
              }
            },
          ),
          const myLabelWidget(labelName: 'Area'),
          Material(
            elevation: 2,
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            child: DropdownButton<String>(
              value: selectedArea,
              isExpanded: true,
              underline: Container(
                color: Colors.white,
              ),
              onChanged: (String? newValue) {
                setState(() {
                  selectedArea = newValue!;
                });
              },
              items: areas.map<DropdownMenuItem<String>>((itemValue) {
                return DropdownMenuItem(
                  value: itemValue,
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 10,
                      ),
                      Text(itemValue)
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const myLabelWidget(labelName: 'City/Town'),
          TextField(
            keyboardType: TextInputType.name,
            controller: _cityController,
            decoration: kTextFieldDecoration.copyWith(
              hintText: 'Place',
            ),
          ),
          const myLabelWidget(labelName: 'District'),
          TextField(
            readOnly: true,
            keyboardType: TextInputType.name,
            controller: _districtController,
            decoration: kTextFieldDecoration.copyWith(
              hintText: 'District',
            ),
          ),
          const myLabelWidget(labelName: 'State'),
          TextField(
            readOnly: true,
            keyboardType: TextInputType.name,
            controller: _stateController,
            decoration: kTextFieldDecoration.copyWith(
              hintText: 'State',
            ),
          ),
          const myLabelWidget(labelName: 'Complexion'),
          TextField(
            keyboardType: TextInputType.name,
            controller: _complexionController,
            decoration: kTextFieldDecoration.copyWith(
              hintText: 'Complexion',
            ),
          ),
          const myLabelWidget(labelName: 'Body Type'),
          TextField(
            keyboardType: TextInputType.name,
            controller: _bodyTypeController,
            decoration: kTextFieldDecoration.copyWith(
              hintText: 'Body Type',
            ),
          ),
          const myLabelWidget(labelName: 'Hair Color'),
          TextField(
            keyboardType: TextInputType.name,
            controller: _hairColorController,
            decoration: kTextFieldDecoration.copyWith(
              hintText: 'Hair Color',
            ),
          ),
          const myLabelWidget(labelName: 'Identification Mark'),
          TextField(
            keyboardType: TextInputType.name,
            controller: _markController,
            decoration: kTextFieldDecoration.copyWith(
              hintText: 'Any Identification Mark, like a mole',
            ),
          ),
          const myLabelWidget(labelName: 'Last Outfit'),
          TextField(
            keyboardType: TextInputType.name,
            controller: _lastOutfitController,
            decoration: kTextFieldDecoration.copyWith(
              hintText: 'Last outfit, ex : Blue shirt , Black top',
            ),
          ),
          const myLabelWidget(labelName: 'Place of missing'),
          TextField(
            keyboardType: TextInputType.name,
            controller: _pomController,
            decoration: kTextFieldDecoration.copyWith(
              hintText: 'Place of missing',
            ),
          ),
          const myLabelWidget(labelName: 'Date of missing'),
          TextField(
            readOnly: true,
            keyboardType: TextInputType.datetime,
            controller: _domController,
            decoration: kTextFieldDecoration.copyWith(
              hintText: 'Date of missing',
            ),
            onTap: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime(2000),
                lastDate: DateTime.now(),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: ColorScheme.light(
                        primary: themeColor, // <-- SEE HERE
                        onPrimary: greenAccent, // <-- SEE HERE
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (picked != null) {
                setState(() {
                  selectedDate = picked;
                  _domController.text =
                      '${selectedDate.toLocal()}'.split(' ')[0];
                });
              }
            },
          ),
          const myLabelWidget(labelName: 'Last Seen'),
          TextField(
            keyboardType: TextInputType.name,
            controller: _lastSeenController,
            decoration: kTextFieldDecoration.copyWith(
              hintText: 'Last known Location',
            ),
          ),
          const SizedBox(
            height: 28.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              MyElevatedButton(
                onPress: () {
                  Navigator.of(context).pop();
                },
                buttonLabel: 'Cancel',
                w: w / 2,
                buttonColor: greenAccent,
                textColor: themeColor,
              ),
              MyElevatedButton(
                  onPress: () async {
                    try {
                      validate();
                      await showDialog(
                        context: context,
                        builder: (BuildContext context) => CupertinoAlertDialog(
                          title: const Text(
                            'Success',
                            style: TextStyle(
                              fontSize: 24,
                            ),
                          ),
                          content: const Text(
                            'Report has been generated successfully',
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text(
                                'OK',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    } catch (e) {
                      print(e);
                      showDialog(
                        context: context,
                        builder: (BuildContext context) => CupertinoAlertDialog(
                          title: const Text(
                            'Error',
                            style: TextStyle(
                              fontSize: 24,
                            ),
                          ),
                          content: Text(
                            e.toString(),
                            style: const TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text(
                                'OK',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                  buttonLabel: 'Submit',
                  w: w / 2),
            ],
          ),
          const SizedBox(
            height: 20.0,
          ),
        ],
      ),
    );
  }
}
