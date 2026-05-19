import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:testapp/widgets/app_colors.dart';

// المرشحات الآمنة للحقول
class LettersOnlyFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final filtered =
        newValue.text.replaceAll(RegExp(r"[^a-zA-Z\u0600-\u06FF\s]"), "");
    return newValue.copyWith(
        text: filtered,
        selection: TextSelection.collapsed(offset: filtered.length));
  }
}

class NumbersOnlyFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final filtered = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    return newValue.copyWith(
        text: filtered,
        selection: TextSelection.collapsed(offset: filtered.length));
  }
}

class NoQuotesFormatter extends TextInputFormatter {
  static final _blocked =
      RegExp(r"""[",\.;: !?/\\|@#\\$%\^&\*\(\)\[\]{}<>~'\+=\-_«»...]""");
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final filtered = newValue.text.replaceAll(_blocked, "");
    return newValue.copyWith(
        text: filtered,
        selection: TextSelection.collapsed(offset: filtered.length));
  }
}

class EmailFormatter extends TextInputFormatter {
  static final _allowed = RegExp(r'[a-zA-Z0-9@._+\-]');
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final filtered =
        newValue.text.split("").where((c) => _allowed.hasMatch(c)).join();
    return newValue.copyWith(
        text: filtered,
        selection: TextSelection.collapsed(offset: filtered.length));
  }
}

class AddReportScreen extends StatefulWidget {
  const AddReportScreen({super.key});
  @override
  State<AddReportScreen> createState() => _AddReportScreenState();
}

class _AddReportScreenState extends State<AddReportScreen> {
  final _formKey = GlobalKey<FormState>();
  bool isAnonymous = false;
  String nationality = 'ليبي';
  String? reportType;
  bool _isLoading = false;

  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _nationalIdCtrl = TextEditingController();
  final _passportCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  final List<XFile> _attachedFiles = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _cityCtrl.dispose();
    _nationalIdCtrl.dispose();
    _passportCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? file =
        await _picker.pickImage(source: source, imageQuality: 85);
    if (file != null) {
      setState(() => _attachedFiles.add(file));
    }
  }

  void _showMediaPickerSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bNavy,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('إرفاق دليل أو وسائط للبلاغ',
                  style: TextStyle(
                      color: AppColors.bGold,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white10,
                          padding: const EdgeInsets.symmetric(vertical: 15)),
                      icon:
                          const Icon(Icons.camera_alt, color: AppColors.bGold),
                      label: const Text('الكاميرا'),
                      onPressed: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.camera);
                      },
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white10,
                          padding: const EdgeInsets.symmetric(vertical: 15)),
                      icon: const Icon(Icons.photo_library,
                          color: AppColors.bGold),
                      label: const Text('المعرض'),
                      onPressed: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.gallery);
                      },
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  void _submitReport() async {
    if (reportType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('يرجى اختيار نوع الجريمة الإلكترونية'),
            backgroundColor: AppColors.danger),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final int randomNum = math.Random().nextInt(90000) + 10000;
      final String reportId = 'REF-$randomNum';

      await FirebaseFirestore.instance.collection('reports').add({
        'userId': 'test_user_123',
        'reportId': reportId,
        'isAnonymous': isAnonymous,
        'name': isAnonymous ? 'مجهول' : _nameCtrl.text.trim(),
        'phone': isAnonymous ? '' : _phoneCtrl.text.trim(),
        'email': isAnonymous ? '' : _emailCtrl.text.trim(),
        'city': isAnonymous ? '' : _cityCtrl.text.trim(),
        'type': reportType,
        'desc': _descCtrl.text.trim(),
        'status': 'في الانتظار',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (_) => ReportReceivedScreen(refNum: reportId)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('خطأ في الإرسال: $e'),
              backgroundColor: AppColors.danger),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("بلاغ إلكتروني جديد",
            style:
                TextStyle(color: AppColors.bGold, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.bNavy,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.bGold),
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
              colors: [AppColors.bNavy, AppColors.bNavyDark],
              begin: Alignment.topCenter),
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Expanded(
                        child: _tabBtn("بلاغ سري (مجهول)", isAnonymous,
                            () => setState(() => isAnonymous = true))),
                    const SizedBox(width: 10),
                    Expanded(
                        child: _tabBtn("تقديم بالهوية", !isAnonymous,
                            () => setState(() => isAnonymous = false))),
                  ],
                ),
                const SizedBox(height: 25),
                if (!isAnonymous) ...[
                  _field("الاسم بالكامل", Icons.person_outline, _nameCtrl,
                      formatters: [LettersOnlyFormatter()]),
                  const SizedBox(height: 15),
                  _field("رقم الهاتف", Icons.phone_outlined, _phoneCtrl,
                      keyboardType: TextInputType.number,
                      formatters: [NumbersOnlyFormatter()]),
                  const SizedBox(height: 15),
                  _field("البريد الإلكتروني", Icons.email_outlined, _emailCtrl,
                      formatters: [EmailFormatter()]),
                  const SizedBox(height: 15),
                  _field("المدينة / المنطقة", Icons.location_city_outlined,
                      _cityCtrl,
                      formatters: [LettersOnlyFormatter()]),
                  const SizedBox(height: 25),
                  Row(
                    children: [
                      Expanded(
                          child: _tabBtn("غير ليبي", nationality == 'غير ليبي',
                              () => setState(() => nationality = 'غير ليبي'))),
                      const SizedBox(width: 10),
                      Expanded(
                          child: _tabBtn("ليبي", nationality == 'ليبي',
                              () => setState(() => nationality = 'ليبي'))),
                    ],
                  ),
                  const SizedBox(height: 15),
                  nationality == 'ليبي'
                      ? _field(
                          "الرقم الوطني", Icons.badge_outlined, _nationalIdCtrl,
                          keyboardType: TextInputType.number,
                          formatters: [NumbersOnlyFormatter()])
                      : _field("رقم جواز السفر",
                          Icons.airplanemode_active_outlined, _passportCtrl,
                          formatters: [NoQuotesFormatter()]),
                  const SizedBox(height: 25),
                ],
                const Divider(color: Colors.white12),
                const SizedBox(height: 10),
                _dropdownField(),
                const SizedBox(height: 15),
                _field("وصف تفاصيل البلاغ الإلكتروني",
                    Icons.description_outlined, _descCtrl,
                    maxLines: 4, formatters: [NoQuotesFormatter()]),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${_attachedFiles.length} ملفات مرفقة',
                        style: const TextStyle(
                            color: AppColors.bGold, fontSize: 13)),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white),
                      onPressed: _showMediaPickerSheet,
                      icon: const Icon(Icons.attach_file,
                          color: AppColors.bGold, size: 18),
                      label: const Text('إرفاق دليل رقمي',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.white24),
                            minimumSize: const Size(double.infinity, 55)),
                        onPressed: () => Navigator.pop(context),
                        child: const Text("إلغاء",
                            style: TextStyle(color: Colors.white70)),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.bGold,
                            minimumSize: const Size(double.infinity, 55)),
                        onPressed: _isLoading ? null : _submitReport,
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: AppColors.bNavy)
                            : const Text("إرسال البلاغ الآن",
                                style: TextStyle(
                                    color: AppColors.bNavy,
                                    fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(String hint, IconData icon, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text,
      int maxLines = 1,
      List<TextInputFormatter>? formatters}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      textAlign: TextAlign.right,
      textDirection: TextDirection.rtl,
      keyboardType: keyboardType,
      inputFormatters: formatters,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: AppColors.bGold),
        hintText: hint,
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.bGold)),
      ),
    );
  }

  Widget _tabBtn(String title, bool selected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.bGold : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.bGold),
        ),
        child: Center(
          child: Text(title,
              style: TextStyle(
                  color: selected ? Colors.black : Colors.white,
                  fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _dropdownField() {
    return DropdownButtonFormField<String>(
      value: reportType,
      dropdownColor: AppColors.bNavy,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.category_outlined, color: AppColors.bGold),
        hintText: 'نوع الجريمة الإلكترونية',
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
      ),
      items: const [
        DropdownMenuItem(
            value: 'اختراق إلكتروني',
            child: Align(
                alignment: Alignment.centerRight,
                child: Text('اختراق إلكتروني'))),
        DropdownMenuItem(
            value: 'ابتزاز إلكتروني',
            child: Align(
                alignment: Alignment.centerRight,
                child: Text('ابتزاز إلكتروني'))),
        DropdownMenuItem(
            value: 'احتيال مالي إلكتروني',
            child: Align(
                alignment: Alignment.centerRight,
                child: Text('احتيال مالي إلكتروني'))),
        DropdownMenuItem(
            value: 'جرائم النشر والتشهير',
            child: Align(
                alignment: Alignment.centerRight,
                child: Text('جرائم النشر والتشهير'))),
      ],
      onChanged: (val) => setState(() => reportType = val),
    );
  }
}

// شاشة تم الإرسال بنجاح (مضافة في نفس الملف للتوجيه التلقائي المباشر)
class ReportReceivedScreen extends StatelessWidget {
  final String refNum;
  const ReportReceivedScreen({super.key, required this.refNum});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
              colors: [AppColors.bNavy, AppColors.bNavyDark],
              begin: Alignment.topCenter),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_outline_rounded,
                color: AppColors.bGold, size: 100),
            const SizedBox(height: 25),
            const Text("تم إرسال بلاغك الإلكتروني بنجاح",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center),
            const SizedBox(height: 15),
            const Text(
                "تم تشفير البيانات وإرسالها مباشرة إلى قسم مكافحة الجرائم الإلكترونية والمعلوماتية لضمان سريتك التامة.",
                style:
                    TextStyle(color: Colors.white54, fontSize: 14, height: 1.5),
                textAlign: TextAlign.center),
            const SizedBox(height: 35),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: AppColors.bGold.withOpacity(0.3))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.copy,
                        color: AppColors.bGold, size: 20),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: refNum));
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('تم نسخ رقم المرجع')));
                    },
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text("رقم مرجع البلاغ السري",
                          style:
                              TextStyle(color: Colors.white38, fontSize: 12)),
                      const SizedBox(height: 5),
                      Text(refNum,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 50),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.bGold,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: const Text("العودة للرئيسية",
                  style: TextStyle(
                      color: AppColors.bNavy,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
