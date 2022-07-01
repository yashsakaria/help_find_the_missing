import 'package:flutter/material.dart';
import 'package:help_find_the_missing/my_widgets/my_label_widget.dart';

class ComboLabelWidget extends StatelessWidget {
  final String title;
  final String content;

  const ComboLabelWidget({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              MyLabelWidget(labelName: title),
            ],
          ),
        ),
        Expanded(
          child: MyLabelWidget(
            labelName: content,
          ),
        ),
      ],
    );
  }
}
