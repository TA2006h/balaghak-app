import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'app_colors.dart';

class ReportCard extends StatelessWidget {
  final Map<String, dynamic> reportData;

  const ReportCard({super.key, required this.reportData});

  @override
  Widget build(BuildContext context) {
    // Safely extract data fields with fallbacks
    final String title = reportData['title'] ?? 'بدون عنوان';
    final String category = reportData['category'] ?? 'عام';
    final String status = reportData['status'] ?? 'قيد المراجعة';
    final String description = reportData['description'] ?? '';
    final String? imageUrl = reportData['imageUrl'];

    // Safely parse Firestore Timestamp or String date
    String displayDate = 'غير محدد';
    final dynamic dateField = reportData['timestamp'] ?? reportData['date'];
    if (dateField is Timestamp) {
      final DateTime dt = dateField.toDate();
      displayDate = "${dt.year}/${dt.month}/${dt.day}";
    } else if (dateField is String) {
      displayDate = dateField;
    }

    // Determine status badge color dynamically
    Color statusColor;
    switch (status) {
      case 'مقبول':
      case 'تم الحل':
      case 'Approved':
        statusColor = Colors.greenAccent;
        break;
      case 'مرفوض':
      case 'Rejected':
        statusColor = AppColors.danger;
        break;
      default:
        statusColor = AppColors.bGold; // Pending / قيد المراجعة
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: AppColors.bGold.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end, // RTL support for Arabic
          children: [
            // Top Bar: Category & Status Badge
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Status Badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: statusColor.withOpacity(0.4), width: 1),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // Category Indicator
                  Row(
                    children: [
                      Text(
                        category,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        Icons.bookmark_outline,
                        color: AppColors.bGold.withOpacity(0.7),
                        size: 16,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Content Area (Image if present + Text)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              textDirection: TextDirection.rtl, // Forces RTL layout for content
              children: [
                // Optional attached report image thumbnail
                if (imageUrl != null && imageUrl.isNotEmpty)
                  Padding(
                    padding:
                        const EdgeInsets.only(right: 12, bottom: 12, left: 12),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        imageUrl,
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 70,
                            height: 70,
                            color: Colors.white10,
                            child: const Icon(Icons.broken_image,
                                color: Colors.white24),
                          );
                        },
                      ),
                    ),
                  ),

                // Text Details
                Expanded(
                  child: Padding(
                    padding:
                        const EdgeInsets.only(right: 12, left: 12, bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      textDirection: TextDirection.rtl,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (description.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            description,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.45),
                              fontSize: 13,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Footer Divider & Date stamp
            Divider(color: Colors.white.withOpacity(0.05), height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(Icons.access_time, color: Colors.white38, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    displayDate,
                    style: const TextStyle(
                      color: Colors.white38,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
