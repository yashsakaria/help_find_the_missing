import 'package:flutter/material.dart';
import 'constants.dart';

class MyElevatedButton extends StatelessWidget {
  const MyElevatedButton(
      {required this.onPress,
      required this.buttonLabel,
      required this.w,
      this.buttonColor = themeColor,
      this.textColor = Colors.white});

  final double w;
  final Function() onPress;
  final String buttonLabel;
  final Color textColor, buttonColor;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPress,
      child: Text(
        buttonLabel, //here
        style: TextStyle(
          fontSize: 16.0,
          color: textColor, // here
          fontWeight: FontWeight.w900,
        ),
      ),
      style: ElevatedButton.styleFrom(
        primary: buttonColor, // here
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        minimumSize: Size((w / 4) * 3, 48),
      ),
    );
  }
}
