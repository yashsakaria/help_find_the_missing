// ignore_for_file: avoid_print

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:help_find_the_missing/constants.dart';
import 'package:help_find_the_missing/screens/missing_person_info.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:help_find_the_missing/screens/add_report_screen.dart';

import '../build_image.dart';

final _auth = FirebaseAuth.instance;
final _firestore = FirebaseFirestore.instance;
final _image = FirebaseStorage.instance.ref();
late User loggedInUser;

class HomeScreen extends StatefulWidget {
  static const String id = 'homeScreen';

  HomeScreen({this.name = 'NA'});

  final String name;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        loggedInUser = user;

        if (loggedInUser.email != null) {
          _firestore
              .collection('authorised_users')
              .doc(loggedInUser.uid)
              .set({'email': loggedInUser.email});
        } else {
          _firestore.collection('general_users').doc(loggedInUser.uid).set(
              {'full_name': widget.name, 'number': loggedInUser.phoneNumber});
        }
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: themeColor,
          title: const Text('Hello'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                _auth.signOut();
                Navigator.of(context).pop();
              },
            ),
            const SizedBox(width: 10)
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: MissingPersonStream(),
        ),
        floatingActionButton: Visibility(
          visible: loggedInUser.email != null,
          child: FloatingActionButton(
            onPressed: () {
              Navigator.pushNamed(context, AddReportScreen.id);
            },
            child: const Icon(Icons.add),
            backgroundColor: themeColor,
          ),
        ),
        // body: ,
      ),
    );
  }
}

class MissingPersonStream extends StatelessWidget {
  MissingPersonStream({Key? key}) : super(key: key);

  late String localDirPath;

  Future<void> _getLocalPath() async {
    final appDocDir = await getApplicationDocumentsDirectory();
    localDirPath = appDocDir.path;
  }

  Future<String?> saveImageToLocal(String id) async {
    print('here');

    try {
      final imagePath = '$id/jpg';
      final localImagePath = path.join(localDirPath, imagePath);

      bool exists = await File(localImagePath).exists();

      if (exists) {
        return localImagePath;
      }

      final localImageFile = File(localImagePath);
      final imageRef = _image.child(imagePath);

      imageRef.writeToFile(localImageFile);
      return localImagePath;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Stream<QuerySnapshot<Object?>>? imageStream() async* {
    await _getLocalPath();
    QuerySnapshot snapshot =
        await _firestore.collection('missing_person').get();
    for (QueryDocumentSnapshot doc in snapshot.docs) {
      await saveImageToLocal(doc.id);
    }
    yield* _firestore.collection('missing-person').orderBy('time').snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream:
            _firestore.collection('missing_person').orderBy('time').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final documents = snapshot.data?.docs.reversed;
            List<MissingPersonCard> missingPersons = [];
            for (var doc in documents!) {
              final missingPerson = MissingPersonCard(doc: doc);
              missingPersons.add(missingPerson);
            }
            return ListView.builder(
              itemCount: missingPersons.length,
              itemBuilder: (context, index) {
                return missingPersons[index];
              },
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(
                backgroundColor: Colors.lightBlueAccent,
              ),
            );
          }
        });
  }
}

class MissingPersonCard extends StatelessWidget {
  final QueryDocumentSnapshot<Object?> doc;
  const MissingPersonCard({required this.doc});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        elevation: 4,
        borderRadius: kDefaultBorderRadius,
        child: GestureDetector(
          child: Container(
            height: 110,
            decoration: const BoxDecoration(
              // color: themeColor,
              borderRadius: kDefaultBorderRadius,
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  BuildImage(
                      imageURL: (doc['image'] != null)
                          ? doc['image']
                          : 'no_image.jpg'),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          doc.get('name'),
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
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
                        )
                      ],
                    ),
                  ),
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
