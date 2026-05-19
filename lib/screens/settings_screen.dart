import 'package:flutter/material.dart';
import '../widgets/app_colors.dart'; // Adjust path if AppColors is defined in a different folder

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Screen Toggles / Variables
  bool _notifyUpdates = true;
  bool _notifyNews = false;
  bool _hideIdentity = true;
  bool _twoFactor = false;
  String _selectedLang = 'العربية';
  double _fontSize = 14.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFF050D1F), // Match your dark-navy 900 background
      appBar: AppBar(
        title: const Text(
          'الإعدادات',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- Section: Notifications ---
            _sectionHeader(
                title: 'التنبيهات والإشعارات',
                icon: Icons.notifications_none_rounded),
            _switchTile(
              title: 'تحديثات التطبيق والميزات الجديدة',
              subtitle: 'ابق على اطلاع بآخر الميزات المضافة للتطبيق',
              icon: Icons.system_update_rounded,
              value: _notifyUpdates,
              onChanged: (v) {
                setState(() => _notifyUpdates = v);
              },
            ),
            _switchTile(
              title: 'الأخبار والتنبيهات',
              subtitle: 'تنبيهات أمنية وإرشادات الحماية العامة',
              icon: Icons.campaign_rounded,
              value: _notifyNews,
              onChanged: (v) {
                setState(() => _notifyNews = v);
              },
            ),

            const SizedBox(height: 10),

            // --- Section: Security & Privacy ---
            _sectionHeader(
                title: 'الخصوصية والأمان', icon: Icons.security_rounded),
            _switchTile(
              title: 'إخفاء الهوية تلقائياً',
              subtitle: 'يُخفي بياناتك الشخصية الحساسة عند إرسال البلاغات',
              icon: Icons.person_off_rounded,
              value: _hideIdentity,
              onChanged: (v) {
                setState(() => _hideIdentity = v);
              },
            ),
            _switchTile(
              title: 'التحقق بخطوتين',
              subtitle: 'أمان إضافي وحماية لحسابك عند تسجيل الدخول',
              icon: Icons.lock_outlined,
              value: _twoFactor,
              onChanged: (v) {
                setState(() => _twoFactor = v);
              },
            ),
            _actionTile(
              title: 'مسح البيانات المحلية',
              subtitle: 'حذف جميع البيانات المؤقتة المخزنة على هذا الجهاز',
              icon: Icons.delete_sweep_rounded,
              iconColor: AppColors.danger,
              onTap: () {
                // Perform clear cache action here
              },
            ),

            const SizedBox(height: 10),

            // --- Section: Language & Display ---
            _sectionHeader(title: 'اللغة والعرض', icon: Icons.language_rounded),

            // Custom Dropdown Box Wrapper for Language
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.bGold.withOpacity(0.15)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  textDirection: TextDirection.rtl,
                  children: [
                    Row(
                      textDirection: TextDirection.rtl,
                      children: [
                        Icon(Icons.translate, color: AppColors.bGold, size: 20),
                        const SizedBox(width: 12),
                        const Text(
                          'لغة التطبيق',
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ],
                    ),
                    DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedLang,
                        dropdownColor: const Color(0xFF050D1F),
                        style:
                            const TextStyle(color: Colors.white, fontSize: 14),
                        items:
                            <String>['العربية', 'English'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (v) {
                          if (v != null) {
                            setState(() => _selectedLang = v);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Font Sizing Slider Block
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.bGold.withOpacity(0.15)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      textDirection: TextDirection.rtl,
                      children: [
                        Row(
                          textDirection: TextDirection.rtl,
                          children: [
                            Icon(Icons.text_fields_rounded,
                                color: AppColors.bGold, size: 20),
                            const SizedBox(width: 12),
                            const Text(
                              'حجم الخط',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 14),
                            ),
                          ],
                        ),
                        Text(
                          _fontSize <= 12.0
                              ? 'صغير'
                              : _fontSize <= 16.0
                                  ? 'متوسط'
                                  : 'كبير',
                          style:
                              TextStyle(color: AppColors.bGold, fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: AppColors.bGold,
                        inactiveTrackColor: AppColors.bGold.withOpacity(0.2),
                        thumbColor: AppColors.bGold,
                        overlayColor: AppColors.bGold.withOpacity(0.15),
                      ),
                      child: Slider(
                        value: _fontSize,
                        min: 10.0,
                        max: 22.0,
                        divisions: 4,
                        onChanged: (v) {
                          setState(() => _fontSize = v);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            // --- Section: Support ---
            _sectionHeader(
                title: 'الدعم والمعلومات', icon: Icons.info_outline_rounded),
            _actionTile(
              title: 'سياسة الخصوصية',
              subtitle: 'اطلع على بنود حماية خصوصية بياناتك المشفرة',
              icon: Icons.privacy_tip_outlined,
              onTap: () {
                // Open Privacy Policy Link/Screen
              },
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // --- Reusable Layout Helper Widgets ---

  Widget _sectionHeader({required String title, required IconData icon}) {
    return Padding(
      padding: const EdgeInsets.only(right: 16, left: 16, top: 16, bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            title,
            style: TextStyle(
              color: AppColors.bGold,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Icon(icon, color: AppColors.bGold, size: 18),
        ],
      ),
    );
  }

  Widget _switchTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.bGold,
        title: Text(
          title,
          textAlign: TextAlign.right,
          style: const TextStyle(
              color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          subtitle,
          textAlign: TextAlign.right,
          style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11),
        ),
        secondary: Icon(icon, color: Colors.white54, size: 22),
      ),
    );
  }

  Widget _actionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    Color? iconColor,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: ListTile(
        onTap: onTap,
        trailing: Icon(icon, color: iconColor ?? Colors.white54, size: 22),
        leading: const Icon(Icons.arrow_back_ios_new_rounded,
            color: Colors.white24, size: 14),
        title: Text(
          title,
          textAlign: TextAlign.right,
          style: const TextStyle(
              color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          subtitle,
          textAlign: TextAlign.right,
          style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11),
        ),
      ),
    );
  }
}
