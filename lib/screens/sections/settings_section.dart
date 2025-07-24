//settings_section.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/app_colors.dart';
import '../../widgets/animated_gradient_background.dart';
import '../../widgets/glass_card.dart';

class SettingsSection extends StatelessWidget {
  final String? userEmail;
  final double fontScale;
  final bool isDarkMode;
  final String language;
  final VoidCallback onClearHistory;
  final void Function(bool) onToggleDarkMode;
  final void Function(double) onFontScaleChanged;
  final void Function(String) onLanguageChanged;
  final VoidCallback? onLogout;

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
    this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedGradientBackground(child: const SizedBox.expand()),
        SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Settings',
                style: GoogleFonts.poppins(
                  fontSize: 22 * fontScale,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 18),
              GlassCard(
                borderRadius: 16,
                blur: 20,
                opacity: isDarkMode ? 0.15 : 0.25,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(
                          Icons.account_circle,
                          color: AppColors.primary,
                        ),
                        title: Text(
                          'Account',
                          style: TextStyle(
                            fontSize: 16 * fontScale,
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                        ),
                        subtitle: Text(
                          userEmail ?? 'Not logged in',
                          style: TextStyle(
                            fontSize: 14 * fontScale,
                            color: isDarkMode ? Colors.white70 : Colors.black54,
                          ),
                        ),
                      ),
                      Divider(color: isDarkMode ? Colors.white24 : Colors.black12),
                      ListTile(
                        leading: Icon(
                          Icons.text_fields,
                          color: AppColors.primary,
                        ),
                        title: Text(
                          'Font Size',
                          style: TextStyle(
                            fontSize: 16 * fontScale,
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                        ),
                        subtitle: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: AppColors.primary,
                            inactiveTrackColor: isDarkMode ? Colors.white24 : Colors.black12,
                            thumbColor: AppColors.primary,
                            overlayColor: AppColors.primary.withOpacity(0.2),
                          ),
                          child: Slider(
                            value: fontScale,
                            min: 0.8,
                            max: 1.4,
                            divisions: 6,
                            label: '${(fontScale * 100).round()}%',
                            onChanged: onFontScaleChanged,
                          ),
                        ),
                      ),
                      Divider(color: isDarkMode ? Colors.white24 : Colors.black12),
                      SwitchListTile(
                        secondary: Icon(
                          Icons.dark_mode,
                          color: AppColors.primary,
                        ),
                        title: Text(
                          'Dark Mode',
                          style: TextStyle(
                            fontSize: 16 * fontScale,
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                        ),
                        subtitle: Text(
                          'Toggle dark theme',
                          style: TextStyle(
                            fontSize: 14 * fontScale,
                            color: isDarkMode ? Colors.white70 : Colors.black54,
                          ),
                        ),
                        value: isDarkMode,
                        onChanged: onToggleDarkMode,
                        activeColor: AppColors.primary,
                      ),
                      Divider(color: isDarkMode ? Colors.white24 : Colors.black12),
                      ListTile(
                        leading: Icon(
                          Icons.language,
                          color: AppColors.primary,
                        ),
                        title: Text(
                          'Language',
                          style: TextStyle(
                            fontSize: 16 * fontScale,
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                        ),
                        subtitle: Text(
                          language,
                          style: TextStyle(
                            fontSize: 14 * fontScale,
                            color: isDarkMode ? Colors.white70 : Colors.black54,
                          ),
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: isDarkMode ? Colors.white54 : Colors.black54,
                        ),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              backgroundColor: isDarkMode ? Colors.grey[800] : Colors.white,
                              title: Text(
                                'Select Language',
                                style: TextStyle(
                                  color: isDarkMode ? Colors.white : Colors.black87,
                                ),
                              ),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  for (final lang in ['English', 'Spanish', 'French'])
                                    ListTile(
                                      title: Text(
                                        lang,
                                        style: TextStyle(
                                          color: isDarkMode ? Colors.white : Colors.black87,
                                        ),
                                      ),
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
                      Divider(color: isDarkMode ? Colors.white24 : Colors.black12),
                      ListTile(
                        leading: Icon(
                          Icons.storage,
                          color: AppColors.primary,
                        ),
                        title: Text(
                          'Clear History',
                          style: TextStyle(
                            fontSize: 16 * fontScale,
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                        ),
                        subtitle: Text(
                          'Remove all prediction history',
                          style: TextStyle(
                            fontSize: 14 * fontScale,
                            color: isDarkMode ? Colors.white70 : Colors.black54,
                          ),
                        ),
                        onTap: onClearHistory,
                      ),
                      if (onLogout != null) ...[
                        Divider(color: isDarkMode ? Colors.white24 : Colors.black12),
                        ListTile(
                          leading: Icon(
                            Icons.logout,
                            color: Colors.red[400],
                          ),
                          title: Text(
                            'Logout',
                            style: TextStyle(
                              fontSize: 16 * fontScale,
                              color: Colors.red[400],
                            ),
                          ),
                          subtitle: Text(
                            'Sign out of your account',
                            style: TextStyle(
                              fontSize: 14 * fontScale,
                              color: isDarkMode ? Colors.white70 : Colors.black54,
                            ),
                          ),
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                backgroundColor: isDarkMode ? Colors.grey[800] : Colors.white,
                                title: Text(
                                  'Logout',
                                  style: TextStyle(
                                    color: isDarkMode ? Colors.white : Colors.black87,
                                  ),
                                ),
                                content: Text(
                                  'Are you sure you want to logout?',
                                  style: TextStyle(
                                    color: isDarkMode ? Colors.white70 : Colors.black54,
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text(
                                      'Cancel',
                                      style: TextStyle(
                                        color: isDarkMode ? Colors.white70 : Colors.black54,
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      onLogout!();
                                    },
                                    child: Text(
                                      'Logout',
                                      style: TextStyle(color: Colors.red[400]),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}