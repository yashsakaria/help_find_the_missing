import 'package:flutter/material.dart';
import 'package:help_find_the_missing/constants/constants.dart';

class LoadingWidget extends StatelessWidget {
  final String newText;
  final Color progressColor;
  const LoadingWidget(
      {required this.newText, this.progressColor = Colors.white});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            color: progressColor,
          ),
        ),
        const SizedBox(width: 16),
        Text(
          newText,
          style: kButtonTextStyle.copyWith(color: progressColor),
        ),
      ],
    );
  }
}
