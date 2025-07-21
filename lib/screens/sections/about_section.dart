import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/app_colors.dart';

class AboutSection extends StatelessWidget {
  final double fontScale;

  const AboutSection({super.key, this.fontScale = 1.0});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('About Bean Classifier', style: GoogleFonts.poppins(fontSize: 22 * fontScale, fontWeight: FontWeight.bold)),
          const SizedBox(height: 18),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('App Version', style: TextStyle(fontSize: 18 * fontScale, fontWeight: FontWeight.bold)),
                  Text('1.0.0', style: TextStyle(fontSize: 16 * fontScale)),
                  const SizedBox(height: 16),
                  Text('Description', style: TextStyle(fontSize: 18 * fontScale, fontWeight: FontWeight.bold)),
                  Text(
                    'Bean Classifier is an AI-powered application that helps identify healthy beans and detect bean rust disease using advanced machine learning models.',
                    style: TextStyle(fontSize: 16 * fontScale),
                  ),
                  const SizedBox(height: 16),
                  Text('Available Models', style: TextStyle(fontSize: 18 * fontScale, fontWeight: FontWeight.bold)),
                  Text(
                    '• Distilled CNN - Lightweight and efficient\n• ResNet - Deep residual network\n• MobileNetV2 - Optimized for mobile devices',
                    style: TextStyle(fontSize: 16 * fontScale),
                  ),
                  const SizedBox(height: 16),
                  Text('Features', style: TextStyle(fontSize: 18 * fontScale, fontWeight: FontWeight.bold)),
                  Text(
                    '• Real-time bean classification\n• Multiple AI models\n• Prediction history\n• Dark mode support\n• Accessibility features',
                    style: TextStyle(fontSize: 16 * fontScale),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Contact & Support', style: TextStyle(fontSize: 18 * fontScale, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () async {
                      final Uri emailUri = Uri(
                        scheme: 'mailto',
                        path: 'support@beanclassifier.com',
                        query: 'subject=Bean Classifier Support',
                      );
                      if (await canLaunchUrl(emailUri)) {
                        await launchUrl(emailUri);
                      }
                    },
                    child: Row(
                      children: [
                        Icon(Icons.email, color: AppColors.primary),
                        const SizedBox(width: 12),
                        Text('support@beanclassifier.com', style: TextStyle(fontSize: 16 * fontScale, color: AppColors.primary)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Privacy Policy', style: TextStyle(fontSize: 16 * fontScale, fontWeight: FontWeight.w500)),
                  Text(
                    'This app processes images locally on your device. No data is transmitted to external servers.',
                    style: TextStyle(fontSize: 14 * fontScale, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
