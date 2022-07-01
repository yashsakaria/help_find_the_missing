import 'package:flutter/material.dart';

import 'package:help_find_the_missing/constants/constants.dart';
import 'package:help_find_the_missing/my_widgets/missing_person_card.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class SearchResults extends StatefulWidget {
  final Map<QueryDocumentSnapshot, List> documentAccuracyMap;
  const SearchResults({required this.documentAccuracyMap});

  @override
  State<SearchResults> createState() => _SearchResultsState();
}

class _SearchResultsState extends State<SearchResults> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: themeColor,
        title: const Text('Search Results'),
      ),
      body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView.builder(
              itemCount: widget.documentAccuracyMap.length,
              itemBuilder: (context, index) {
                return MissingPersonCard(
                  doc: widget.documentAccuracyMap.keys.elementAt(index),
                  info: widget.documentAccuracyMap.values.elementAt(index),
                );
              })),
    );
  }
}
