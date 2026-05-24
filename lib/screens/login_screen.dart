import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // استيراد الفلتر لمنع الرموز الخبيثة
import 'package:testapp/widgets/app_colors.dart';
import 'package:testapp/screens/my_reports_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _accountController = TextEditingController();

  @override
  void dispose() {
    _accountController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      // تنظيف النص النهائي الممرر وحذف أي مسافات زائدة
      String sanitizedInput = _accountController.text.trim();

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MyReportsScreen(
            accountNumber: sanitizedInput,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "متابعة حالة البلاغ",
          style: TextStyle(
              color: AppColors.bGold,
              fontWeight: FontWeight.bold,
              fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: AppColors.bNavy,
        iconTheme: const IconThemeData(color: AppColors.bGold),
      ),
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.bGold.withOpacity(0.05),
                    ),
                    child: const Icon(
                      Icons.admin_panel_settings_rounded, // أيقونة حماية معززة
                      size: 70,
                      color: AppColors.bGold,
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    "الاستعلام الآمن عن بلاغ",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "أدخل رقم الحساب أو كود المرجع (مثل REF-53575) لمتابعة حالة البلاغ",
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 13,
                        height: 1.5),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  // --- حقل الإدخال المحمي والمفلتر ---
                  TextFormField(
                    controller: _accountController,
                    keyboardType: TextInputType
                        .visiblePassword, // يمنع اقتراحات الكلمات التلقائية المزعجة للأكواد
                    style: const TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,

                    // حظر الرموز الخبيثة المستخدمة في الحقن والتخريب (SQLi / Scripting)
                    inputFormatters: [
                      // يسمح فقط بالأحرف الإنجليزية، الأرقام، والشرطة العادية (-) ويمنع الفواصل وعلامات الاقتباس تماماً
                      FilteringTextInputFormatter.allow(
                          RegExp(r'[a-zA-Z0-9\-]')),
                    ],

                    decoration: InputDecoration(
                      labelText: "رقم الحساب أو رمز المرجع",
                      labelStyle: const TextStyle(color: AppColors.bGold),
                      hintText: "مثال: 0912345678 أو REF-53575",
                      hintStyle: TextStyle(
                          color: Colors.white.withOpacity(0.2), fontSize: 13),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: Colors.white.withOpacity(0.2)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: AppColors.bGold, width: 1.5),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.redAccent),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: Colors.redAccent, width: 1.5),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "الرجاء إدخال رقم أو رمز المرجع";
                      }
                      // فحص إضافي أمني لطول النص المكتوب
                      if (value.trim().length > 30) {
                        return "الرمز المدخل طويل جداً وغير منطقي";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.bGold,
                      foregroundColor: AppColors.bNavy,
                      minimumSize: const Size(double.infinity, 52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    onPressed: _submit,
                    child: const Text(
                      "استعلام آمن",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
