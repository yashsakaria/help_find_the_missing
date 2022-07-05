// ignore_for_file: avoid_print

import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:help_find_the_missing/constants/constants.dart';
import 'package:help_find_the_missing/screens/add_report_screen.dart';
import 'package:help_find_the_missing/screens/search_person_screen.dart';
import 'package:help_find_the_missing/my_widgets/missing_person_card.dart';

final _auth = FirebaseAuth.instance;
final _firestore = FirebaseFirestore.instance;
late User loggedInUser;

class HomeScreen extends StatefulWidget {
  static const String id = 'homeScreen';

  const HomeScreen({this.name = 'NA'});

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
          title: const Text('Reports'),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SearchPerson()));
              },
              icon: const Icon(Icons.search),
            ),
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
        body: const Padding(
          padding: EdgeInsets.all(8.0),
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
  const MissingPersonStream({Key? key}) : super(key: key);

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
