import 'package:flutter/material.dart';

const themeColor = Color(0xFF32B768);
Color secondaryColor = Colors.greenAccent.shade100;

InputDecoration kTextFieldDecoration = InputDecoration(
  contentPadding: const EdgeInsets.all(8.0),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(10.0),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(10.0),
    borderSide: const BorderSide(
      width: 1.0,
    ),
  ),
  hintStyle: const TextStyle(
    fontSize: 12.0,
  ),
);

const kDefaultBorderRadius = BorderRadius.all(Radius.circular(8.0));

const kButtonTextStyle = TextStyle(
  fontSize: 16.0,
  // color: textColor, // here
  fontWeight: FontWeight.w900,
);
