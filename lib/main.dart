import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/home_screen.dart';
import 'package:testapp/widgets/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const BalaghApp());
}

class BalaghApp extends StatelessWidget {
  const BalaghApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'بلاغك',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.navy900,
        useMaterial3: true,
      ),
      home: const HomeScreen(), // يفتح الشاشة الرئيسية المقسمة
    );
  }
}
