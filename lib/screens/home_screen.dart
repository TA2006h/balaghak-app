import 'package:flutter/material.dart';
import 'package:testapp/widgets/app_colors.dart';
import 'package:testapp/widgets/custom_button.dart';
import 'add_report_screen.dart';
import 'my_reports_screen.dart';
import 'settings_screen.dart';

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
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.bNavy, AppColors.bNavyDark],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 70),
              Container(
                height: 140,
                width: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.bGold, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.bGold.withOpacity(0.2),
                      blurRadius: 30,
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(Icons.shield_rounded,
                      size: 80, color: AppColors.bGold),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                textDirection: TextDirection.rtl,
                children: [
                  const Text("بلاغ",
                      style: TextStyle(
                          color: AppColors.bGold,
                          fontSize: 50,
                          fontWeight: FontWeight.bold)),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                        color: AppColors.bGold,
                        borderRadius: BorderRadius.circular(8)),
                    child: const Text("ك",
                        style: TextStyle(
                            color: AppColors.bNavy,
                            fontSize: 35,
                            fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text("منصتك الآمنة للبلاغات الإلكترونية",
                  style: TextStyle(color: Colors.white54, fontSize: 16)),
              const SizedBox(height: 60),
              CustomMenuButton(
                title: "تقديم بلاغ إلكتروني جديد",
                icon: Icons.edit_note_rounded,
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AddReportScreen()));
                },
              ),
              CustomMenuButton(
                title: "بلاغاتي ومتابعتها",
                icon: Icons.fact_check_outlined,
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const MyReportsScreen()));
                },
              ),
              CustomMenuButton(
                title: "الإعدادات والحساب",
                icon: Icons.settings_suggest_outlined,
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SettingsScreen()));
                },
              ),
              const SizedBox(height: 80),
              const Text("جميع الحقوق محفوظة © 2026",
                  style: TextStyle(color: Colors.white24, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}
