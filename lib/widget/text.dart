import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class SectionText extends StatelessWidget {
  final String text;
  final Color textColor;

  const SectionText({super.key, required this.text, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
          color: textColor, fontSize: 20, fontWeight: FontWeight.bold),
    );
  }
}
