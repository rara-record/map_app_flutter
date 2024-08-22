import 'package:flutter/material.dart';

class TextFormFieldCustom extends StatefulWidget {
  final String? defaultText; // 기본적으로 미리 쓰여지는 텍스트 값
  final String? hintText; // 입력에 힌트가 되는 텍스트 설정 값
  final bool isPasswordField; // 비밀번호 입력필드 인지 여부
  final bool? isEnabled; // 텍스트 필드 활성화 여부
  final int? maxLines; // 최대 텍스트 줄 길이
  final bool isReadOnly; // 읽기 전용 입력필드인지 여부
  final TextInputType keyboardType; // 입력 키보드 타입
  final TextInputAction textInputAction; // 키보드 액션 타입
  final FormFieldValidator<String> validator; // 유효성 검사
  final TextEditingController controller; // 텍스트 필드 컨트롤러
  final Function(String value)? onFieldSubmitted; // 입력 완료 시 콜백 함수
  final Function()? onTap;

  const TextFormFieldCustom({
    this.defaultText,
    this.hintText,
    required this.isPasswordField,
    this.isEnabled,
    this.maxLines,
    required this.isReadOnly,
    required this.keyboardType,
    required this.textInputAction,
    required this.validator,
    required this.controller,
    this.onFieldSubmitted,
    this.onTap,
    super.key,
  });

  @override
  State<TextFormFieldCustom> createState() => _TextFormFieldCustomState();
}

class _TextFormFieldCustomState extends State<TextFormFieldCustom> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: widget.defaultText,
      validator: (value) => widget.validator(value),
      controller: widget.controller,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      enabled: widget.isEnabled,
      readOnly: widget.isReadOnly,
      onTap: widget.isReadOnly ? widget.onTap : null,
      maxLines: widget.maxLines,
      onFieldSubmitted: widget.onFieldSubmitted,
      decoration: InputDecoration(
          // 기본 border
          border: OutlineInputBorder(
            borderSide: const BorderSide(
              width: 2,
              color: Colors.black,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          // 활성화 border
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              width: 2,
              color: Colors.black,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          // 에러 border
          errorBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              width: 2,
              color: Colors.redAccent,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          // focused border
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              width: 2,
              color: Colors.blueAccent,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          hintText: widget.hintText),
      obscureText: widget.isPasswordField,
    );
  }
}
