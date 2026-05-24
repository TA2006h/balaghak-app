import 'package:flutter/material.dart';
import 'package:testapp/widgets/app_colors.dart';
import 'package:testapp/screens/add_report_screen.dart';
import 'package:testapp/screens/login_screen.dart';

// 1. تأكد من تعديل هذا السطر ليتوافق مع المسار الصحيح لملف الإعدادات الحالي عندك:
import 'package:testapp/screens/settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.bNavy, AppColors.bNavyDark],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // --- 2. هذا هو الصف العلوي الجديد الذي يحتوي على زر الإعدادات جهة اليسار ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.settings_rounded,
                          color: AppColors.bGold, size: 28),
                      onPressed: () {
                        // الانتقال إلى شاشة الإعدادات الموجودة عندك عند الضغط على الزر
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SettingsScreen()),
                        );
                      },
                    ),
                    const SizedBox(), // للحفاظ على التوازن وتوزيع المحاذاة في الصف
                  ],
                ),

                const Spacer(), // توزيع مسافة مرنة لتوسيط الشعار

                // الشعار العلوي لنظام البلاغات
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.bGold.withOpacity(0.05),
                    border: Border.all(
                        color: AppColors.bGold.withOpacity(0.15), width: 1.5),
                  ),
                  child: const Icon(
                    Icons.gavel_rounded,
                    size: 80,
                    color: AppColors.bGold,
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  "نظام بلاغك الأمني",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "منصة رسمية مشفرة لتقديم ومتابعة بلاغات الجرائم الإلكترونية بكل سرية وأمان تام",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 14,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),

                const Spacer(), // مسافة مرنة ثانية قبل الأزرار الكبيرة

                // الزر الأول: تسجيل بلاغ جديد
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.bGold,
                    foregroundColor: AppColors.bNavy,
                    minimumSize: const Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 2,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AddReportScreen()),
                    );
                  },
                  icon: const Icon(Icons.add_moderator_rounded, size: 22),
                  label: const Text(
                    "تسجيل بلاغ جديد",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 20),

                // الزر الثاني: بلاغاتي ومتابعتها
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.bGold,
                    side: const BorderSide(color: AppColors.bGold, width: 1.5),
                    minimumSize: const Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginScreen()),
                    );
                  },
                  icon: const Icon(Icons.folder_shared_rounded, size: 22),
                  label: const Text(
                    "بلاغاتي ومتابعتها",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),

                const Spacer(),

                // نص الحماية السفلية
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "جميع البيانات مشفرة وفقاً لمعايير الأمن الرقمي",
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.3), fontSize: 11),
                    ),
                    const SizedBox(width: 6),
                    Icon(Icons.lock_outline_rounded,
                        size: 14, color: Colors.white.withOpacity(0.3)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
