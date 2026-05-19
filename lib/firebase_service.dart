import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ===================== نموذج البلاغ =====================
class ReportModel {
  final String id;
  final String refNumber;
  final String accountNumber;
  final String type;
  final String description;
  final String status;
  final bool isAnonymous;
  final List<String> mediaUrls;
  final DateTime createdAt;
  final Map<String, dynamic>? identity;

  const ReportModel({
    required this.id,
    required this.refNumber,
    required this.accountNumber,
    required this.type,
    required this.description,
    required this.status,
    required this.isAnonymous,
    required this.mediaUrls,
    required this.createdAt,
    this.identity,
  });

  factory ReportModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return ReportModel(
      id:            doc.id,
      refNumber:     d['refNumber']     ?? '',
      accountNumber: d['accountNumber'] ?? '',
      type:          d['type']          ?? '',
      description:   d['description']   ?? '',
      status:        d['status']        ?? 'في الانتظار',
      isAnonymous:   d['isAnonymous']   ?? true,
      mediaUrls:     List<String>.from(d['mediaUrls'] ?? []),
      createdAt:     (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      identity:      d['identity'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toMap() => {
    'refNumber':     refNumber,
    'accountNumber': accountNumber,
    'type':          type,
    'description':   description,
    'status':        status,
    'isAnonymous':   isAnonymous,
    'mediaUrls':     mediaUrls,
    'createdAt':     FieldValue.serverTimestamp(),
    if (identity != null) 'identity': identity,
  };
}

// ===================== خدمة Firebase =====================
class FirebaseService {
  static final _db   = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  // ── المصادقة ──────────────────────────────────────────

  static Future<UserCredential?> signIn(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
          email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw _authError(e.code);
    }
  }

  static Future<void> signOut() => _auth.signOut();

  static User? get currentUser => _auth.currentUser;

  static Stream<User?> get authStream => _auth.authStateChanges();

  static String _authError(String code) => switch (code) {
    'user-not-found'   => 'البريد الإلكتروني غير مسجّل',
    'wrong-password'   => 'كلمة المرور غير صحيحة',
    'invalid-email'    => 'البريد الإلكتروني غير صالح',
    'user-disabled'    => 'هذا الحساب معطّل',
    'too-many-requests'=> 'محاولات كثيرة، حاول لاحقاً',
    _                  => 'حدث خطأ، حاول مجدداً',
  };

  // ── البلاغات ─────────────────────────────────────────

  /// إضافة بلاغ جديد وإرجاع رقم المرجع
  static Future<Map<String, String>> submitReport(ReportModel report) async {
    final ref = _db.collection('reports').doc();
    await ref.set(report.toMap());
    return {
      'refNumber':     report.refNumber,
      'accountNumber': report.accountNumber,
    };
  }

  /// توليد رقم مرجع فريد
  static String generateRefNumber() {
    final now = DateTime.now();
    final rand = (1000 + DateTime.now().microsecond % 9000).toString();
    return 'REF-${now.year}-$rand';
  }

  static String generateAccountNumber() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand = List.generate(9, (i) => chars[(DateTime.now().microsecond + i * 7) % chars.length]).join();
    return 'USR-${rand.substring(0,5)}-${rand.substring(5)}';
  }

  /// جلب كل البلاغات (للوحة التحكم)
  static Stream<List<ReportModel>> watchAllReports() =>
      _db.collection('reports')
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((s) => s.docs.map(ReportModel.fromFirestore).toList());

  /// جلب بلاغات المستخدم برقم الحساب
  static Future<List<ReportModel>> getUserReports(
      String accountNumber, String refNumber) async {
    final snap = await _db.collection('reports')
        .where('accountNumber', isEqualTo: accountNumber)
        .where('refNumber', isEqualTo: refNumber)
        .get();
    return snap.docs.map(ReportModel.fromFirestore).toList();
  }

  /// تحديث حالة بلاغ
  static Future<void> updateStatus(String reportId, String newStatus) =>
      _db.collection('reports').doc(reportId).update({'status': newStatus});

  /// حذف بلاغ
  static Future<void> deleteReport(String reportId) =>
      _db.collection('reports').doc(reportId).delete();

  // ── إحصائيات ─────────────────────────────────────────

  static Future<Map<String, int>> getStats() async {
    final snap = await _db.collection('reports').get();
    final docs = snap.docs.map((d) => d.data()).toList();
    return {
      'total':      docs.length,
      'pending':    docs.where((d) => d['status'] == 'في الانتظار').length,
      'inProgress': docs.where((d) => d['status'] == 'جاري التحقيق').length,
      'resolved':   docs.where((d) => d['status'] == 'تم الحل').length,
    };
  }
}