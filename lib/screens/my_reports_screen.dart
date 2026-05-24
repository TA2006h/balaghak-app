import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:testapp/widgets/app_colors.dart';
import 'package:testapp/widgets/report_card.dart';

class MyReportsScreen extends StatelessWidget {
  // استقبال رقم الحساب الممرر من شاشة تسجيل الدخول
  final String accountNumber;

  const MyReportsScreen({super.key, required this.accountNumber});

  // دالة مساعدة لبناء القائمة بشكل نظيف
  Widget _buildReportsList(List<QueryDocumentSnapshot> docs) {
    return ListView.builder(
      padding: const EdgeInsets.all(15),
      itemCount: docs.length,
      itemBuilder: (context, index) {
        var doc = docs[index];
        var data = doc.data() as Map<String, dynamic>;
        return ReportCard(reportData: data);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'بلاغات الحساب: $accountNumber',
          style: const TextStyle(
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
        decoration: const BoxDecoration(
          gradient: LinearGradient(
              colors: [AppColors.bNavy, AppColors.bNavyDark],
              begin: Alignment.topCenter),
        ),
        child: StreamBuilder<QuerySnapshot>(
          // استعلام مرن: يبحث أولاً برقم الحساب (userId)
          stream: FirebaseFirestore.instance
              .collection('reports')
              .where('userId', isEqualTo: accountNumber.trim())
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                  child: CircularProgressIndicator(color: AppColors.bGold));
            }

            if (snapshot.hasError) {
              return Center(
                child: Text('حدث خطأ: ${snapshot.error}',
                    style: const TextStyle(color: AppColors.danger)),
              );
            }

            // إذا لم يجد تطابق في الـ userId، نقوم بالبحث فوراً برقم مرجع البلاغ السري (reportId)
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('reports')
                    .where('reportId',
                        isEqualTo: accountNumber
                            .trim()) // البحث برقم المرجع مثل REF-53575
                    .snapshots(),
                builder: (context, refSnapshot) {
                  if (refSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child:
                            CircularProgressIndicator(color: AppColors.bGold));
                  }
                  if (!refSnapshot.hasData || refSnapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.folder_open_rounded,
                              size: 60, color: Colors.white.withOpacity(0.1)),
                          const SizedBox(height: 15),
                          Text(
                            'لم نجد أي بيانات مطابقة للمدخل: ($accountNumber)\nتأكد من كتابة رقم الهاتف أو رقم المرجع السري للبلاغ بشكل صحيح.',
                            style: const TextStyle(
                                color: Colors.white38, fontSize: 13),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  return _buildReportsList(refSnapshot.data!.docs);
                },
              );
            }

            return _buildReportsList(snapshot.data!.docs);
          },
        ),
      ),
    );
  }
}
