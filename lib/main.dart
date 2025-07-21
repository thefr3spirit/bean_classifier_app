import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

// Import your custom files (you'll need to create these)
import 'models/app_colors.dart';
import 'models/auth_state.dart';
import 'services/auth_service.dart';
import 'screens/auth_screen.dart';
import 'screens/bean_classifier_home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const BeanClassifierApp());
}

class BeanClassifierApp extends StatefulWidget {
  const BeanClassifierApp({super.key});
  
  @override
  State<BeanClassifierApp> createState() => _BeanClassifierAppState();
}

class _BeanClassifierAppState extends State<BeanClassifierApp> {
  final AuthService _authService = AuthService();
  AuthState _authState = AuthState.login;
  String? _userEmail;

  @override
  void initState() {
    super.initState();
    _setupAuthListener();
  }

  void _setupAuthListener() {
    _authService.authStateChanges.listen((User? user) {
      if (user != null) {
        setState(() {
          _authState = AuthState.loggedIn;
          _userEmail = user.email;
        });
      } else {
        setState(() {
          _authState = AuthState.login;
          _userEmail = null;
        });
      }
    });
  }

  void _onLogin(String email) {
    setState(() {
      _authState = AuthState.loggedIn;
      _userEmail = email;
    });
  }

  Future<void> _onLogout() async {
    try {
      await _authService.signOut();
      setState(() {
        _authState = AuthState.login;
        _userEmail = null;
      });
    } catch (e) {
      // Handle logout error if needed
      print('Logout error: $e');
    }
  }

  void _onSignup(String email) {
    setState(() {
      _authState = AuthState.loggedIn;
      _userEmail = email;
    });
  }

  void _goToSignup() {
    setState(() {
      _authState = AuthState.signup;
    });
  }

  void _goToLogin() {
    setState(() {
      _authState = AuthState.login;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bean Classifier',
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      themeMode: ThemeMode.system,
      home: _buildCurrentScreen(),
    );
  }

  Widget _buildCurrentScreen() {
    switch (_authState) {
      case AuthState.login:
        return AuthScreen(
          isLogin: true,
          onLogin: _onLogin,
          goToSignup: _goToSignup,
          // Removed authService parameter
        );
      case AuthState.signup:
        return AuthScreen(
          isLogin: false,
          onSignup: _onSignup,
          goToLogin: _goToLogin,
          // Removed authService parameter
        );
      case AuthState.loggedIn:
        return BeanClassifierHome(
          onLogout: _onLogout,
          userEmail: _userEmail,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
        error: AppColors.error,
      ),
      cardColor: AppColors.surface,
      textTheme: GoogleFonts.poppinsTextTheme(
        ThemeData(brightness: Brightness.light).textTheme.apply(
          bodyColor: AppColors.textLight,
          displayColor: AppColors.textLight,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        elevation: 2,
        iconTheme: IconThemeData(color: AppColors.primary),
        titleTextStyle: TextStyle(
          color: AppColors.primary,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          elevation: 2,
          shadowColor: AppColors.cardShadow,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 2,
        shadowColor: AppColors.cardShadow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surfaceDark,
        error: AppColors.error,
      ),
      cardColor: AppColors.surfaceDark,
      textTheme: GoogleFonts.poppinsTextTheme(
        ThemeData(brightness: Brightness.dark).textTheme.apply(
          bodyColor: AppColors.textDark,
          displayColor: AppColors.textDark,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surfaceDark,
        elevation: 2,
        iconTheme: IconThemeData(color: AppColors.primary),
        titleTextStyle: TextStyle(
          color: AppColors.primary,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          elevation: 2,
          shadowColor: AppColors.cardShadow,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceDark,
        elevation: 2,
        shadowColor: AppColors.cardShadow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }
}