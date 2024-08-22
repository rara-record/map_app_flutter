import 'package:flutter/material.dart';
import 'package:map_app/screen/login_screen.dart';
import 'package:map_app/screen/register_screen.dart';
import 'package:map_app/screen/splash_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  // main 메소드에서 비동기로 데이터를 다루는 상황이 있을 때 반드시 최초에 호출해줘야 함
  WidgetsFlutterBinding.ensureInitialized();

  // init supabase
  await Supabase.initialize(
    url: 'https://fnpeucnejzwsbcczaohr.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZucGV1Y25lanp3c2JjY3phb2hyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjI0ODg1NTgsImV4cCI6MjAzODA2NDU1OH0.R0Cb8hYmpAwLzeB-F43qpfdTPaNZSTRlD_VxNVmPxHs',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override // 부모 클래스의 메서드를 덮어쓴다
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen()
      },
    );
  }
}
