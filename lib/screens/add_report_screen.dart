import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
// استيراد ملف الألوان الموحد الخاص بمشروعك لحل مشكلة التكرار في home_screen
import 'package:testapp/widgets/app_colors.dart';

// --- المرشحات الأمنية لمدخلات الحقول (Input Formatters) ---
class LettersOnlyFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final filtered =
        newValue.text.replaceAll(RegExp(r"[^a-zA-Z\u0600-\u06FF\s]"), "");
    return newValue.copyWith(
      text: filtered,
      selection: TextSelection.collapsed(offset: filtered.length),
    );
  }
}

class NumbersOnlyFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final filtered = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    return newValue.copyWith(
      text: filtered,
      selection: TextSelection.collapsed(offset: filtered.length),
    );
  }
}

class NoQuotesFormatter extends TextInputFormatter {
  static final _blocked =
      RegExp(r"""[",\.;: !? /\\|@#\\$٪\^&\*\(\)\[\]{}<>~'\+=\-_«»...]""");
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final filtered = newValue.text.replaceAll(_blocked, "");
    return newValue.copyWith(
      text: filtered,
      selection: TextSelection.collapsed(offset: filtered.length),
    );
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
      selection: TextSelection.collapsed(offset: filtered.length),
    );
  }
}

// --- الشاشة الرئيسية: إضافة بلاغ إلكتروني ---
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

  // وحدات التحكم بالحقول
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

  // دالة جلب الصور والوسائط
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? file =
          await _picker.pickImage(source: source, imageQuality: 85);
      if (file != null) {
        setState(() => _attachedFiles.add(file));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('خطأ أثناء اختيار الملف: $e'),
            backgroundColor: AppColors.danger),
      );
    }
  }

  // شيت اختيار مصدر المرفقات
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
                      label: const Text('الكاميرا',
                          style: TextStyle(color: Colors.white)),
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
                      label: const Text('المعرض',
                          style: TextStyle(color: Colors.white)),
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

  // عند الضغط على زر الإرسال الرئيسي
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

    // فحص ذكي للمرفقات: إذا كانت فارغة يعرض نافذة الأولوية تحذيرياً
    if (_attachedFiles.isEmpty) {
      _showPriorityWarningDialog();
    } else {
      _executeFirebaseUpload();
    }
  }

  // نافذة تنبيه تفاعلية للأولوية الأمنية (تم تصحيح الأخطاء بالكامل هنا)
  void _showPriorityWarningDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            backgroundColor: AppColors.bNavy,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
              side: const BorderSide(
                  color: AppColors.bGold,
                  width: 1), // تم تصحيح الـ BorderSide هنا
            ),
            title: const Row(
              children: [
                Icon(Icons.warning_amber_rounded,
                    color: AppColors.bGold, size: 26),
                SizedBox(width: 10),
                Text(
                  "تنبيه الأولوية الرقمية",
                  style: TextStyle(
                      color: AppColors.bGold,
                      fontWeight: FontWeight.bold,
                      fontSize: 18),
                ),
              ],
            ),
            content: Text(
              "نظام بلاغك يمنح أولوية التحقق والمتابعة الفورية للبلاغات التي تحتوي على وسائط وأدلة رقمية معززة (صور/مستندات).\n\nهل ترغب في إرفاق دليل الآن لرفع أولوية بلاغك، أم الاستمرار في الإرسال بدون وسائط؟",
              style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                  height: 1.5), // تم تصحيح اللون هنا
            ),
            actions: [
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.bGold),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  _showMediaPickerSheet();
                },
                child: const Text("إرفاق الآن",
                    style: TextStyle(
                        color: AppColors.bGold, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 5),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white10,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  _executeFirebaseUpload();
                },
                child: const Text("إرسال على أي حال",
                    style: TextStyle(color: Colors.white70)),
              ),
            ],
          ),
        );
      },
    );
  }

  // دالة الرفع الفعلي لـ Firebase
  void _executeFirebaseUpload() async {
    setState(() => _isLoading = true);

    try {
      final int randomNum = math.Random().nextInt(90000) + 10000;
      final String reportId = 'REF-$randomNum';

      await FirebaseFirestore.instance.collection('reports').add({
        'userId': isAnonymous ? 'anonymous_user' : _phoneCtrl.text.trim(),
        'reportId': reportId,
        'isAnonymous': isAnonymous,
        'name': isAnonymous ? 'مجهول' : _nameCtrl.text.trim(),
        'phone': isAnonymous ? '' : _phoneCtrl.text.trim(),
        'email': isAnonymous ? '' : _emailCtrl.text.trim(),
        'city': isAnonymous ? '' : _cityCtrl.text.trim(),
        'nationalId': (isAnonymous || nationality != 'ليبي')
            ? ''
            : _nationalIdCtrl.text.trim(),
        'passportNum': (isAnonymous || nationality == 'ليبي')
            ? ''
            : _passportCtrl.text.trim(),
        'type': reportType,
        'desc': _descCtrl.text.trim(),
        'status': 'في الانتظار',
        'hasMedia': _attachedFiles.isNotEmpty,
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
                  _field(
                    hint: "الاسم رباعي كما في الإثبات الرسمي",
                    helper:
                        "مسموح بالحروف الأبجدية فقط (العربية أو الإنجليزية)",
                    icon: Icons.person_outline,
                    controller: _nameCtrl,
                    formatters: [LettersOnlyFormatter()],
                    validator: (val) {
                      if (val == null || val.trim().isEmpty)
                        return 'يرجى إدخال الاسم بالكامل';
                      if (val.trim().split(' ').length < 3)
                        return 'يرجى كتابة الاسم ثلاثي على الأقل';
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  _field(
                    hint: "مثال: 091XXXXXXX",
                    helper: "يجب أن يتكون رقم الهاتف من 10 أرقام دقيقة",
                    icon: Icons.phone_outlined,
                    controller: _phoneCtrl,
                    keyboardType: TextInputType.number,
                    formatters: [NumbersOnlyFormatter()],
                    validator: (val) {
                      if (val == null || val.isEmpty)
                        return 'يرجى إدخال رقم الهاتف';
                      if (val.length != 10)
                        return 'رقم الهاتف يجب أن يكون 10 أرقام تماماً';
                      if (!val.startsWith('09'))
                        return 'يجب أن يبدأ الرقم بـ 09 (مدار أو ليبيانا)';
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  _field(
                    hint: "example@email.com",
                    helper:
                        "أدخل بريد إلكتروني صالح لاستقبال إشعارات المتابعة والتحديثات",
                    icon: Icons.email_outlined,
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    formatters: [EmailFormatter()],
                    validator: (val) {
                      if (val == null || val.isEmpty)
                        return 'يرجى إدخال البريد الإلكتروني';
                      final emailRegex =
                          RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                      if (!emailRegex.hasMatch(val))
                        return 'صيغة البريد الإلكتروني غير صحيحة';
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  _field(
                    hint: "مثال: طرابلس، بنغازي، سبها...",
                    helper: "اكتب اسم المدينة أو المنطقة السكنية الحالية",
                    icon: Icons.location_city_outlined,
                    controller: _cityCtrl,
                    formatters: [LettersOnlyFormatter()],
                    validator: (val) => (val == null || val.isEmpty)
                        ? 'يرجى تحديد المدينة'
                        : null,
                  ),
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
                          hint: "مكون من 12 رقم يبدأ بـ 1 أو 2",
                          helper:
                              "أدخل الرقم الوطني الرسمي المعتمد والمكون من 12 رقمًا",
                          icon: Icons.badge_outlined,
                          controller: _nationalIdCtrl,
                          keyboardType: TextInputType.number,
                          formatters: [NumbersOnlyFormatter()],
                          validator: (val) {
                            if (val == null || val.isEmpty)
                              return 'يرجى إدخال الرقم الوطني';
                            if (val.length != 12)
                              return 'الرقم الوطني يجب أن يكون 12 رقماً تماماً';
                            if (!val.startsWith('1') && !val.startsWith('2'))
                              return 'الرقم الوطني يجب أن يبدأ بـ 1 أو 2';
                            return null;
                          },
                        )
                      : _field(
                          hint: "أدخل رقم جواز السفر الحالي",
                          helper:
                              "أدخل رقم وثيقة جواز السفر السارية للوافدين والأجانب",
                          icon: Icons.airplanemode_active_outlined,
                          controller: _passportCtrl,
                          formatters: [NoQuotesFormatter()],
                          validator: (val) => (val == null || val.isEmpty)
                              ? 'يرجى إدخال رقم جواز السفر'
                              : null,
                        ),
                  const SizedBox(height: 25),
                ],
                const Divider(color: Colors.white12),
                const SizedBox(height: 10),
                _dropdownField(),
                const SizedBox(height: 15),
                _field(
                  hint:
                      "اكتب هنا تفاصيل ووقائع الجريمة بالتفصيل والشرح المبسط...",
                  helper:
                      "يرجى كتابة الأحداث بوضوح (ممنوع استخدام الرموز وعلامات الاقتباس لتأمين قواعد البيانات)",
                  icon: Icons.description_outlined,
                  controller: _descCtrl,
                  maxLines: 4,
                  formatters: [NoQuotesFormatter()],
                  validator: (val) {
                    if (val == null || val.isEmpty)
                      return 'يرجى كتابة وصف للبلاغ';
                    if (val.length < 15)
                      return 'الوصف قصير جداً، يرجى شرح تفاصيل الواقعة بوضوح أكثر';
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${_attachedFiles.length} ملفات مرفقة',
                        style: const TextStyle(
                            color: AppColors.bGold, fontSize: 13)),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white10),
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

  Widget _field({
    required String hint,
    required String helper,
    required IconData icon,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    List<TextInputFormatter>? formatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      textAlign: TextAlign.right,
      textDirection: TextDirection.rtl,
      keyboardType: keyboardType,
      inputFormatters: formatters,
      validator: validator,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: AppColors.bGold),
        hintText: hint,
        hintStyle:
            TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 14),
        helperText: helper,
        helperStyle:
            TextStyle(color: AppColors.bGold.withOpacity(0.6), fontSize: 11),
        errorStyle: const TextStyle(
            color: AppColors.danger, fontSize: 12, fontWeight: FontWeight.w500),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.bGold, width: 1.5)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.danger, width: 1)),
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.danger, width: 1.5)),
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
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.category_outlined, color: AppColors.bGold),
        hintText: 'نوع الجريمة الإلكترونية',
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
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

// --- شاشة تم الإرسال بنجاح وتلقي رقم المرجع السري ---
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
                "تم تشفير البيانات وإرسالها مباشرة إلى قسم مكافحة الجرائم الإلكترونية لضمان سريتك التامة.",
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
