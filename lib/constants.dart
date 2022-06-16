import 'package:flutter/material.dart';

const themeColor = Color(0xFF32B768);
Color greenAccent = Colors.greenAccent.shade100;

InputDecoration kTextFieldDecoration = InputDecoration(
  contentPadding: const EdgeInsets.all(8.0),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(10.0),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(10.0),
    borderSide: const BorderSide(
      width: 2.0,
    ),
  ),
  hintStyle: const TextStyle(
    fontSize: 12.0,
  ),
);
