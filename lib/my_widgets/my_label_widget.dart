import 'package:flutter/material.dart';
import 'package:help_find_the_missing/constants/constants.dart';

class MyLabelWidget extends StatelessWidget {
  const MyLabelWidget(
      {required this.labelName, this.labelStyle = kLabelWidgetTextStyle});

  final String labelName;
  final TextStyle labelStyle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
      child: Text(
        labelName,
        style: labelStyle,
      ),
    );
  }
}
