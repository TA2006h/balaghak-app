import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:testapp/widgets/app_colors.dart';
import 'package:testapp/widgets/report_card.dart';

class MyReportsScreen extends StatelessWidget {
  const MyReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('بلاغاتي المرسلة',
            style:
                TextStyle(color: AppColors.bGold, fontWeight: FontWeight.bold)),
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
          stream: FirebaseFirestore.instance
              .collection('reports')
              .where('userId', isEqualTo: 'test_user_123')
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                  child: CircularProgressIndicator(color: AppColors.bGold));
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text('لا يوجد بلاغات مقدمة حالياً.',
                    style: TextStyle(color: Colors.white38, fontSize: 16)),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var doc = snapshot.data!.docs[index];
                var data = doc.data() as Map<String, dynamic>;
                return ReportCard(reportData: data);
              },
            );
          },
        ),
      ),
    );
  }
}
