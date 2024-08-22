import 'package:flutter/material.dart';

void showSnackBar(BuildContext context, String text, [int duration = 2]) {
  // [] 는 선택적 매개변수로, optional position parameters를 나타낸다.
  // 스낵바 유틸 함수
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(text),
      duration: Duration(seconds: duration),
    ),
  );
}
