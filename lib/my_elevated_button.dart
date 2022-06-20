import 'package:flutter/material.dart';
import 'constants.dart';

class MyElevatedButton extends StatelessWidget {
  const MyElevatedButton(
      {required this.onPress,
      required this.buttonLabel,
      required this.w,
      this.buttonColor = themeColor});

  final double w;
  final Function() onPress;
  final Widget buttonLabel;
  final Color buttonColor;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPress,
      child: buttonLabel,
      style: ElevatedButton.styleFrom(
        primary: buttonColor, // here
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        minimumSize: Size((w / 4) * 3, 48),
      ),
    );
  }
}
