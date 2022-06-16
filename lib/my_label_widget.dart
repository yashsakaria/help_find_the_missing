import 'package:flutter/material.dart';

class myLabelWidget extends StatelessWidget {
  const myLabelWidget({required this.labelName});

  final String labelName;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
      child: Text(
        labelName,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Color(0xFF374151),
        ),
      ),
    );
  }
}
