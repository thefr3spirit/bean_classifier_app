import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/app_colors.dart';

class SettingsSection extends StatelessWidget {
  final String? userEmail;
  final double fontScale;
  final bool isDarkMode;
  final String language;
  final VoidCallback onClearHistory;
  final void Function(bool) onToggleDarkMode;
  final void Function(double) onFontScaleChanged;
  final void Function(String) onLanguageChanged;

  const SettingsSection({
    super.key,
    required this.userEmail,
    required this.fontScale,
    required this.isDarkMode,
    required this.language,
    required this.onClearHistory,
    required this.onToggleDarkMode,
    required this.onFontScaleChanged,
    required this.onLanguageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Settings', style: GoogleFonts.poppins(fontSize: 22 * fontScale, fontWeight: FontWeight.bold)),
          const SizedBox(height: 18),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.account_circle, color: AppColors.primary),
                    title: Text('Account', style: TextStyle(fontSize: 16 * fontScale)),
                    subtitle: Text(userEmail ?? 'Not logged in', style: TextStyle(fontSize: 14 * fontScale)),
                  ),
                  const Divider(),
                  ListTile(
                    leading: Icon(Icons.text_fields, color: AppColors.primary),
                    title: Text('Font Size', style: TextStyle(fontSize: 16 * fontScale)),
                    subtitle: Slider(
                      value: fontScale,
                      min: 0.8,
                      max: 1.4,
                      divisions: 6,
                      label: '${(fontScale * 100).round()}%',
                      onChanged: onFontScaleChanged,
                    ),
                  ),
                  const Divider(),
                  SwitchListTile(
                    secondary: Icon(Icons.dark_mode, color: AppColors.primary),
                    title: Text('Dark Mode', style: TextStyle(fontSize: 16 * fontScale)),
                    subtitle: Text('Toggle dark theme', style: TextStyle(fontSize: 14 * fontScale)),
                    value: isDarkMode,
                    onChanged: onToggleDarkMode,
                  ),
                  const Divider(),
                  ListTile(
                    leading: Icon(Icons.language, color: AppColors.primary),
                    title: Text('Language', style: TextStyle(fontSize: 16 * fontScale)),
                    subtitle: Text(language, style: TextStyle(fontSize: 14 * fontScale)),
                    trailing: Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Select Language'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              for (final lang in ['English', 'Spanish', 'French'])
                                ListTile(
                                  title: Text(lang),
                                  onTap: () {
                                    onLanguageChanged(lang);
                                    Navigator.pop(context);
                                  },
                                )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: Icon(Icons.storage, color: AppColors.primary),
                    title: Text('Clear History', style: TextStyle(fontSize: 16 * fontScale)),
                    subtitle: Text('Remove all prediction history', style: TextStyle(fontSize: 14 * fontScale)),
                    onTap: onClearHistory,
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
