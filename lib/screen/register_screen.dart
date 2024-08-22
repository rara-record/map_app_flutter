import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:map_app/widget/appbar.dart';
import 'package:map_app/widget/buttons.dart';
import 'package:map_app/widget/text.dart';
import 'package:map_app/widget/text_fields.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final formKey = GlobalKey<FormState>();
  final supabase = Supabase.instance.client;
  File? profileImg;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordReController = TextEditingController();
  final TextEditingController _introduceController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(
        title: 'Food PICK 가입하기',
        isLeading: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(16),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 프로필 사진
                GestureDetector(
                    child: _buildProfile(),
                    // 프로필 이미지 변경 및 삭체 팝업 띄우기
                    onTap: () {
                      showBottomSheetAboutProfile();
                    }),

                const SizedBox(height: 16),

                // 닉네임
                const SectionText(text: '닉네임', textColor: Color(0xff979797)),
                const SizedBox(height: 8),
                TextFormFieldCustom(
                  hintText: '닉네임을 입력해주세요',
                  isPasswordField: false,
                  isReadOnly: false,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: (value) => inputNameValidator(value),
                  controller: _nameController,
                ),

                const SizedBox(height: 16),

                // 이메일
                const SectionText(text: '이메일', textColor: Color(0xff979797)),
                const SizedBox(height: 16),
                TextFormFieldCustom(
                  hintText: '이메일 입력해주세요',
                  isPasswordField: false,
                  isReadOnly: false,
                  keyboardType: TextInputType.name,
                  textInputAction: TextInputAction.next,
                  validator: (value) => inputEmailValidator(value),
                  controller: _emailController,
                ),

                const SizedBox(height: 16),

                // 비밀번호
                const SectionText(text: '비밀번호', textColor: Color(0xff979797)),
                const SizedBox(height: 8),
                TextFormFieldCustom(
                  hintText: '비밀번호를 입력해주세요',
                  isPasswordField: true,
                  maxLines: 1,
                  isReadOnly: false,
                  keyboardType: TextInputType.visiblePassword,
                  textInputAction: TextInputAction.next,
                  validator: (value) => inputPasswordValidator(value),
                  controller: _passwordController,
                ),

                const SizedBox(height: 16),

                // 비밀번호 확인
                const SectionText(
                    text: '비밀번호 확인', textColor: Color(0xff979797)),
                const SizedBox(height: 8),
                TextFormFieldCustom(
                  hintText: '비밀번호 확인을 입력해주세요',
                  isPasswordField: true,
                  maxLines: 1,
                  isReadOnly: false,
                  keyboardType: TextInputType.visiblePassword,
                  textInputAction: TextInputAction.next,
                  validator: (value) => inputPasswordReValidator(value),
                  controller: _passwordReController,
                ),

                const SizedBox(height: 16),

                // 자기소개
                const SectionText(text: '자기소개', textColor: Color(0xff979797)),
                const SizedBox(height: 8),
                TextFormFieldCustom(
                  hintText: '자기소개를 입력해주세요',
                  isPasswordField: false,
                  maxLines: 10,
                  isReadOnly: false,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  validator: (value) => inputIntroduceValidator(value),
                  controller: _introduceController,
                ),

                const SizedBox(height: 16),

                // 가입 완료 버튼
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 16),
                  width: double.infinity,
                  height: 64,
                  child: ElevatedButtonCustom(
                    text: '가입 완료',
                    backgroundColor: Colors.black,
                    textColor: Colors.white,
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        String emialValue = _emailController.text;
                        String passwordValue = _passwordController.text;

                        // supabase 계정 등록
                        registerAccount(emialValue, passwordValue);
                        // Navigator.pushNamed(context, '/login');
                      }
                    },
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfile() {
    if (profileImg == null) {
      // 이미지가 없을 경우
      return const Center(
        child: CircleAvatar(
          radius: 48,
          backgroundColor: Colors.grey,
          child: Icon(
            Icons.add_a_photo,
            size: 48,
            color: Colors.white,
          ),
        ),
      );
    } else {
      // 이미지가 존재할 경우
      return Center(
        child: CircleAvatar(
          radius: 48,
          backgroundColor: Colors.grey,
          backgroundImage: FileImage(profileImg!),
        ),
      );
    }
  }

  void showBottomSheetAboutProfile() {
    showModalBottomSheet(
      context: context,
      // 위젯 뱉어주기
      builder: (context) {
        return SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 사진 촬영 버튼
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  getCameraImage();
                },
                child: const Text('사진 촬영',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                    )),
              ),
              // 앨범에서 사진 선택
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  getGalleryImage();
                },
                child: const Text('앨범에서 사진 선택',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                    )),
              ),
              // 프로필 사진 삭제
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  deleteProfileImage();
                },
                child: const Text('프로필 사진 삭제',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                    )),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> getCameraImage() async {
    // 카메라로 사진 촬영하여 이미지 파일을 가져오는 함수
    var image = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 10,
    );
    if (image != null) {
      setState(() {
        profileImg = File(image.path);
      });
    }
  }

  Future<void> getGalleryImage() async {
    // 앨범에서 사진 선택하는 함수
    var image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 10,
    );
    if (image != null) {
      setState(() {
        profileImg = File(image.path);
      });
    }
  }

  void deleteProfileImage() {
    // 프로필 사진 삭제
    setState(() {
      profileImg = null;
    });
  }

  inputNameValidator(value) {
    // 닉네임 필드 검증 함수
    if (value.isEmpty) {
      return '닉네임을 입력해주세요';
    }
    return null;
  }

  inputEmailValidator(value) {
    // 이메일 필드 검증 함수
    if (value.isEmpty) {
      return '이메일을 입력해주세요';
    }
    return null;
  }

  inputPasswordValidator(value) {
    // 비밀번호 필드 검증 함수
    if (value.isEmpty) {
      return '비밀번호를 입력해주세요';
    }
    return null;
  }

  inputPasswordReValidator(value) {
    // 비밀번호 필드 재검증 함수
    if (value.isEmpty) {
      return '비밀번호를 입력해주세요';
    }
    return null;
  }

  inputIntroduceValidator(value) {
    // 자기소개 필드 검증 함수
    if (value.isEmpty) {
      return '자기소개를 입력해주세요';
    }
    return null;
  }
}
