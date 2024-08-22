import 'package:flutter/material.dart';

class ElevateButtonCustom extends StatelessWidget {
  final String text; // 버튼 텍스트
  final Color backgroundColor; // 버튼 배경 색상
  final Color textColor; // 버튼 텍스트 색상
  final Function onPressed; // 버튼 클릭 신호

  const ElevateButtonCustom(
      {super.key,
      required this.text,
      required this.backgroundColor,
      required this.textColor,
      required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    );
  }
}
