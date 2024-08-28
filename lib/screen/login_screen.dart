import 'package:flutter/material.dart';
import 'package:map_app/common/snackbar_uril.dart';
import 'package:map_app/widget/buttons.dart';
import 'package:map_app/widget/text.dart';
import 'package:map_app/widget/text_fields.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// 로그인 화면
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final formKey = GlobalKey<FormState>();
  final supabase = Supabase.instance.client;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 169),
                const Center(
                  child: Text(
                    'Food PICK',
                    style: TextStyle(
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 53),

                // 이메일
                const SectionText(text: '이메일', textColor: Color(0xff979797)),
                const SizedBox(height: 8),
                TextFormFieldCustom(
                  hintText: '이메일을 입력해주세요',
                  isPasswordField: false,
                  isReadOnly: false,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: (value) => inputEmailValidator(value),
                  controller: _emailController,
                ),

                const SizedBox(height: 24),

                // 비밀번호
                const SectionText(text: '비밀번호', textColor: Color(0xff979797)),
                const SizedBox(height: 8),
                TextFormFieldCustom(
                  hintText: '비밀번호를 입력해주세요',
                  maxLines: 1,
                  isPasswordField: true,
                  isReadOnly: false,
                  keyboardType: TextInputType.visiblePassword,
                  textInputAction: TextInputAction.next,
                  validator: (value) => inputPasswordValidator(value),
                  controller: _passwordController,
                ),

                const SizedBox(height: 48),

                // 로그인 버튼
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButtonCustom(
                      text: '로그인',
                      backgroundColor: Colors.black,
                      textColor: Colors.white,
                      onPressed: () async {
                        String emailValue = _emailController.text;
                        String passwordValue = _passwordController.text;

                        // 유효성 검사 체크
                        if (!formKey.currentState!.validate()) {
                          return;
                        }

                        bool isLoginSuccess =
                            await loginWithEmail(emailValue, passwordValue);

                        if (!context.mounted) return;

                        if (!isLoginSuccess) {
                          showSnackBar(context, '로그인을 실패하였습니다.');
                          return;
                        }

                        // 로그인을 성공하여 메인으로 이동
                        Navigator.popAndPushNamed(context, '/main');
                      }),
                ),

                const SizedBox(height: 16),

                // 회원가입 버튼
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButtonCustom(
                      text: '회원가입',
                      backgroundColor: const Color(0xff979797),
                      textColor: Colors.white,
                      onPressed: () {
                        Navigator.pushNamed(context, '/register');
                      }),
                )
              ],
            ),
          ),
        ),
      ),
    );
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

  Future<bool> loginWithEmail(String emailValue, String passwordValue) async {
    bool isLoginSuccess = false;

    try {
      await supabase.auth
          .signInWithPassword(email: emailValue, password: passwordValue);
      isLoginSuccess = true;
    } catch (error) {
      isLoginSuccess = false;
    }

    return isLoginSuccess;
  }
}
