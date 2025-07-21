import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../models/app_colors.dart';

class HistorySection extends StatelessWidget {
  final double fontScale;
  final List<Map<String, dynamic>> predictionHistory;

  const HistorySection({
    super.key,
    required this.fontScale,
    required this.predictionHistory,
  });

  @override
  Widget build(BuildContext context) {
    if (predictionHistory.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            'No predictions yet.',
            style: TextStyle(fontSize: 18 * fontScale, color: Colors.grey[600]),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Prediction History',
            style: GoogleFonts.poppins(
              fontSize: 22 * fontScale,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 18),
          ...predictionHistory.take(10).map(
            (entry) => Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: ListTile(
                leading: entry['image'] != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          entry['image'] as File,
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                        ),
                      )
                    : const Icon(Icons.image, size: 40),
                title: Text(
                  entry['label']
                      .toString()
                      .replaceAll('_', ' ')
                      .toUpperCase(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18 * fontScale,
                  ),
                ),
                subtitle: Text(
                  'Confidence: ${(entry['confidence'] * 100).toStringAsFixed(2)}%\n${DateFormat('yyyy-MM-dd HH:mm').format(entry['timestamp'])}',
                  style: TextStyle(fontSize: 14 * fontScale),
                ),
                trailing: Icon(
                  entry['label'] == 'healthy'
                      ? Icons.check_circle
                      : Icons.warning_amber_rounded,
                  color: entry['label'] == 'healthy'
                      ? Colors.green
                      : AppColors.secondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
