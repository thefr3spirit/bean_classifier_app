import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pytorch_lite/pytorch_lite.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const BeanClassifierApp());
}

class AppColors {
  static const primary = Color(0xFF388E3C); // Deep Green (accent)
  static const secondary = Color(0xFFFF9800); // Soft Orange
  static const background = Color(0xFFF5F5F5); // Light Gray
  static const surface = Color(0xFFFFFFFF); // White
  static const textLight = Color(0xFF212121); // Dark Gray
  static const textDark = Color(0xFFFAFAFA); // White
  static const error = Color(0xFFD32F2F);
  static const cardShadow = Color(0x1A000000); // Subtle shadow
  // Dark mode
  static const backgroundDark = Color(0xFF181A20);
  static const surfaceDark = Color(0xFF23272F);
}

enum AuthState { loggedOut, login, signup, loggedIn }

class BeanClassifierApp extends StatefulWidget {
  const BeanClassifierApp({super.key});
  @override
  State<BeanClassifierApp> createState() => _BeanClassifierAppState();
}

class _BeanClassifierAppState extends State<BeanClassifierApp> {
  AuthState _authState = AuthState.login;
  String? _userEmail;

  @override
  void initState() {
    super.initState();
    // Automatically sign in if user is already authenticated
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
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
    await FirebaseAuth.instance.signOut();
    setState(() {
      _authState = AuthState.login;
      _userEmail = null;
    });
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
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.light(
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
            borderSide: BorderSide(color: AppColors.primary, width: 2),
          ),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.backgroundDark,
        colorScheme: ColorScheme.dark(
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
            borderSide: BorderSide(color: AppColors.primary, width: 2),
          ),
        ),
      ),
      themeMode: ThemeMode.system,
      home: Builder(
        builder: (context) {
          switch (_authState) {
            case AuthState.login:
              return AuthScreen(
                isLogin: true,
                onLogin: _onLogin,
                goToSignup: _goToSignup,
              );
            case AuthState.signup:
              return AuthScreen(
                isLogin: false,
                onSignup: _onSignup,
                goToLogin: _goToLogin,
              );
            case AuthState.loggedIn:
              return BeanClassifierHome(
                onLogout: _onLogout,
                userEmail: _userEmail,
              );
            default:
              return const SizedBox.shrink();
          }
        },
      ),
    );
  }
}


class AuthScreen extends StatefulWidget {
  final bool isLogin;
  final void Function(String email)? onLogin;
  final void Function(String email)? onSignup;
  final VoidCallback? goToSignup;
  final VoidCallback? goToLogin;
  const AuthScreen({
    super.key,
    required this.isLogin,
    this.onLogin,
    this.onSignup,
    this.goToSignup,
    this.goToLogin,
  });
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscure = true;
  String? _error;
  bool _isLoading = false;

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (!widget.isLogin && _passwordController.text != _confirmController.text) {
        setState(() => _error = 'Passwords do not match');
        return;
      }
      
      setState(() {
        _error = null;
        _isLoading = true;
      });

      try {
        if (widget.isLogin) {
          // Login
          await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
          widget.onLogin?.call(_emailController.text.trim());
        } else {
          // Sign up
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
          widget.onSignup?.call(_emailController.text.trim());
        }
      } on FirebaseAuthException catch (e) {
        setState(() {
          _error = _getErrorMessage(e.code);
        });
      } catch (e) {
        setState(() {
          _error = 'An unexpected error occurred. Please try again.';
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _getErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'email-already-in-use':
        return 'The account already exists for that email.';
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'invalid-email':
        return 'The email address is not valid.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          AnimatedGradientBackground(child: const SizedBox.expand()),
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: GlassCard(
                  borderRadius: 28,
                  blur: 24,
                  opacity: 0.22,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 28),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.spa, color: AppColors.primary, size: 48),
                          const SizedBox(height: 12),
                          Text(widget.isLogin ? 'Login' : 'Sign Up', style: GoogleFonts.poppins(fontSize: 26, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 24),
                          TextFormField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              prefixIcon: Icon(Icons.email_outlined),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) => v == null || v.isEmpty ? 'Enter your email' : null,
                          ),
                          const SizedBox(height: 18),
                          TextFormField(
                            controller: _passwordController,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                                onPressed: () => setState(() => _obscure = !_obscure),
                              ),
                            ),
                            obscureText: _obscure,
                            validator: (v) => v == null || v.length < 6 ? 'Password must be at least 6 characters' : null,
                          ),
                          if (!widget.isLogin) ...[
                            const SizedBox(height: 18),
                            TextFormField(
                              controller: _confirmController,
                              decoration: const InputDecoration(
                                labelText: 'Confirm Password',
                                prefixIcon: Icon(Icons.lock_outline),
                              ),
                              obscureText: true,
                              validator: (v) => v == null || v.length < 6 ? 'Password must be at least 6 characters' : null,
                            ),
                          ],
                          if (_error != null) ...[
                            const SizedBox(height: 12),
                            Text(_error!, style: const TextStyle(color: Colors.red)),
                          ],
                          const SizedBox(height: 28),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 22, height: 22,
                                      child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                                    )
                                  : Text(widget.isLogin ? 'Login' : 'Sign Up'),
                            ),
                          ),
                          const SizedBox(height: 18),
                          TextButton(
                            onPressed: widget.isLogin ? widget.goToSignup : widget.goToLogin,
                            child: Text(widget.isLogin ? "Don't have an account? Sign Up" : "Already have an account? Login"),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BeanClassifierHome extends StatefulWidget {
  final VoidCallback? onLogout;
  final String? userEmail;
  const BeanClassifierHome({super.key, this.onLogout, this.userEmail});
  @override
  _BeanClassifierHomeState createState() => _BeanClassifierHomeState();
}

enum HomeSection { main, history, about, settings }

class _BeanClassifierHomeState extends State<BeanClassifierHome> {
  final List<Map<String, String>> models = [
    {'name': 'Distilled CNN', 'path': 'assets/models/distilled_cnn_mobile.pt'},
    {'name': 'ResNet', 'path': 'assets/models/resnet_mobile.pt'},
    {'name': 'MobileNetV2', 'path': 'assets/models/mobilenet_mobile.pt'},
  ];

  String? selectedModelPath;
  ClassificationModel? model;
  File? _image;
  String? _prediction;
  double? _confidence;
  bool _isPredicting = false;
  List<String> _classNames = [];
  double _imageOpacity = 0.0;
  final List<Map<String, dynamic>> _predictionHistory = [];
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  bool _showHealthyCheck = false;
  HomeSection _section = HomeSection.main;
  double _fontScale = 1.0;
  bool _isDarkMode = false;
  String _language = 'English';

  @override
  void initState() {
    super.initState();
    selectedModelPath = models[0]['path'];
    _loadModel();
  }

  @override
  void didUpdateWidget(covariant BeanClassifierHome oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_image != null) {
      setState(() {
        _imageOpacity = 1.0;
      });
    }
  }

  String _getLabelPathForModel(String? modelPath) {
    if (modelPath == 'assets/models/resnet_mobile.pt') {
      return 'assets/models/labels_resnet.txt';
    } else {
      return 'assets/models/labels_mobilenet_distilledcnn.txt';
    }
  }

  Future<List<String>> _loadLabels(String labelPath) async {
    final labelFile = File(labelPath);
    if (await labelFile.exists()) {
      final lines = await labelFile.readAsLines();
      return lines.map((l) => l.trim()).where((l) => l.isNotEmpty).toList();
    } else {
      // For asset bundle (mobile/web)
      final labelData = await DefaultAssetBundle.of(context).loadString(labelPath);
      return labelData.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();
    }
  }

  Future<void> _loadModel() async {
    if (selectedModelPath == null) return;
    final labelPath = _getLabelPathForModel(selectedModelPath);
    final loadedLabels = await _loadLabels(labelPath);
    final loadedModel = await PytorchLite.loadClassificationModel(
      selectedModelPath!,
      224, // width
      224, // height
      3,   // channels (RGB)
      labelPath: labelPath,
    );
    setState(() {
      model = loadedModel;
      _classNames = loadedLabels;
      _prediction = null;
      _confidence = null;
      _image = null;
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile == null) return;
    setState(() {
      _image = File(pickedFile.path);
      _prediction = null;
      _confidence = null;
      _imageOpacity = 0.0;
    });
    // Animate image fade-in
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _imageOpacity = 1.0;
        });
      }
    });
  }

  Future<void> _runInference() async {
    if (_image == null || model == null || _classNames.isEmpty) {
      print("No image, model not loaded, or labels missing");
      _showSnackbar('Please select an image and ensure the model is loaded.', isError: true);
      return;
    }
    setState(() { _isPredicting = true; });
    // Show progress bar
    final bytes = await _image!.readAsBytes();

    List<double>? logits;
    if (selectedModelPath == 'assets/models/resnet_mobile.pt' ||
        selectedModelPath == 'assets/models/mobilenet_mobile.pt') {
      logits = await model!.getImagePredictionList(
        bytes,
        mean: [0.485, 0.456, 0.406],
        std: [0.229, 0.224, 0.225],
      );
    } else {
      // For DistilledCNN: NO normalization, pass bytes directly
      logits = await model!.getImagePredictionList(bytes);
    }
    double maxLogit = logits.reduce((a, b) => a > b ? a : b);
    List<double> exps = logits.map((l) => math.exp(l - maxLogit)).toList();
    double sumExps = exps.reduce((a, b) => a + b);
    List<double> softmax = exps.map((e) => e / sumExps).toList();
    int maxIdx = 0;
    double maxVal = softmax[0];
    for (int i = 1; i < softmax.length; i++) {
      if (softmax[i] > maxVal) {
        maxVal = softmax[i];
        maxIdx = i;
      }
    }
    print("Prediction: ${_classNames[maxIdx]}, Confidence: ${softmax[maxIdx]}");
    setState(() {
      _prediction = _classNames[maxIdx];
      _confidence = softmax[maxIdx];
      _isPredicting = false;
      _predictionHistory.insert(0, {
        'label': _prediction,
        'confidence': _confidence,
        'image': _image,
        'timestamp': DateTime.now(),
      });
      if (_prediction == 'healthy') {
        _showHealthyCheck = true;
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) setState(() { _showHealthyCheck = false; });
        });
      }
    });
    _showSnackbar('Prediction: ${_prediction!.replaceAll('_', ' ')} (${(_confidence! * 100).toStringAsFixed(1)}%)', isError: false);
  }

  void _showSnackbar(String message, {bool isError = false}) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red[700] : AppColors.primary,
          duration: const Duration(seconds: 2),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Bean Classifier'),
          centerTitle: true,
          actions: [
            if (widget.onLogout != null)
              IconButton(
                icon: const Icon(Icons.logout),
                tooltip: 'Logout',
                onPressed: widget.onLogout,
              ),
          ],
        ),
        body: _buildSection(context),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _section.index,
          onTap: (index) {
            setState(() {
              _section = HomeSection.values[index];
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: 'History',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.info_outline),
              label: 'About',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
          selectedItemColor: AppColors.primary,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context) {
    switch (_section) {
      case HomeSection.history:
        return _buildHistory(context);
      case HomeSection.about:
        return _buildAbout(context);
      case HomeSection.settings:
        return _buildSettings(context);
      case HomeSection.main:
      default:
        return _buildMain(context);
    }
  }

  Widget _buildMain(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Model selector
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Model:', style: Theme.of(context).textTheme.titleMedium),
                      DropdownButton<String>(
                        value: selectedModelPath,
                        items: models.map((m) {
                          return DropdownMenuItem(
                            value: m['path'],
                            child: Text(m['name']!, style: const TextStyle(fontWeight: FontWeight.w500)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedModelPath = value;
                            _loadModel();
                          });
                        },
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  // Image preview
                  Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.grey[100],
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: _image == null
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.image_outlined, size: 64, color: Colors.grey[400]),
                                const SizedBox(height: 12),
                                const Text('No image selected.', style: TextStyle(fontSize: 16, color: Colors.grey)),
                              ],
                            ),
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.file(_image!, height: 220, width: 220, fit: BoxFit.cover),
                          ),
                  ),
                  const SizedBox(height: 18),
                  // Image picker buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Take Photo'),
                        onPressed: () => _pickImage(ImageSource.camera),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.photo),
                        label: const Text('Gallery'),
                        onPressed: () => _pickImage(ImageSource.gallery),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  // Predict button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isPredicting ? null : _runInference,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isPredicting
                          ? const SizedBox(
                              width: 22, height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                            )
                          : const Text('Predict', style: TextStyle(fontSize: 18)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Prediction result card
          if (_prediction != null)
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 22.0, horizontal: 28.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _prediction == 'healthy'
                              ? Icons.check_circle
                              : (_prediction == 'bean_rust'
                                  ? Icons.warning_amber_rounded
                                  : Icons.error_outline),
                          color: _prediction == 'healthy'
                              ? Colors.green
                              : (_prediction == 'bean_rust'
                                  ? AppColors.secondary
                                  : AppColors.error),
                          size: 32,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          _prediction!.replaceAll('_', ' ').toUpperCase(),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: _prediction == 'healthy'
                                ? Colors.green
                                : (_prediction == 'bean_rust'
                                    ? AppColors.secondary
                                    : AppColors.error),
                          ),
                        ),
                      ],
                    ),
                    if (_confidence != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Text(
                          'Confidence: ${(_confidence! * 100).toStringAsFixed(2)}%',
                          style: const TextStyle(fontSize: 17),
                        ),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHistory(BuildContext context) {
    if (_predictionHistory.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text('No predictions yet.', style: TextStyle(fontSize: 18 * _fontScale, color: Colors.grey[600])),
        ),
      );
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Prediction History', style: GoogleFonts.poppins(fontSize: 22 * _fontScale, fontWeight: FontWeight.bold)),
          const SizedBox(height: 18),
          ..._predictionHistory.take(10).map((entry) => Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              leading: entry['image'] != null ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(entry['image'], width: 48, height: 48, fit: BoxFit.cover),
              ) : Icon(Icons.image, size: 40),
              title: Text(entry['label'].toString().replaceAll('_', ' ').toUpperCase(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18 * _fontScale)),
              subtitle: Text('Confidence: ${(entry['confidence'] * 100).toStringAsFixed(2)}%\n${DateFormat('yyyy-MM-dd HH:mm').format(entry['timestamp'])}', style: TextStyle(fontSize: 14 * _fontScale)),
              trailing: Icon(
                entry['label'] == 'healthy' ? Icons
                .check_circle : Icons.warning_amber_rounded,
                color: entry['label'] == 'healthy' ? Colors.green : AppColors.secondary,
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildAbout(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('About Bean Classifier', style: GoogleFonts.poppins(fontSize: 22 * _fontScale, fontWeight: FontWeight.bold)),
          const SizedBox(height: 18),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('App Version', style: TextStyle(fontSize: 18 * _fontScale, fontWeight: FontWeight.bold)),
                  Text('1.0.0', style: TextStyle(fontSize: 16 * _fontScale)),
                  const SizedBox(height: 16),
                  Text('Description', style: TextStyle(fontSize: 18 * _fontScale, fontWeight: FontWeight.bold)),
                  Text('Bean Classifier is an AI-powered application that helps identify healthy beans and detect bean rust disease using advanced machine learning models.', style: TextStyle(fontSize: 16 * _fontScale)),
                  const SizedBox(height: 16),
                  Text('Available Models', style: TextStyle(fontSize: 18 * _fontScale, fontWeight: FontWeight.bold)),
                  Text('• Distilled CNN - Lightweight and efficient\n• ResNet - Deep residual network\n• MobileNetV2 - Optimized for mobile devices', style: TextStyle(fontSize: 16 * _fontScale)),
                  const SizedBox(height: 16),
                  Text('Features', style: TextStyle(fontSize: 18 * _fontScale, fontWeight: FontWeight.bold)),
                  Text('• Real-time bean classification\n• Multiple AI models\n• Prediction history\n• Dark mode support\n• Accessibility features', style: TextStyle(fontSize: 16 * _fontScale)),
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
                  Text('Contact & Support', style: TextStyle(fontSize: 18 * _fontScale, fontWeight: FontWeight.bold)),
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
                        Text('support@beanclassifier.com', style: TextStyle(fontSize: 16 * _fontScale, color: AppColors.primary)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Privacy Policy', style: TextStyle(fontSize: 16 * _fontScale, fontWeight: FontWeight.w500)),
                  Text('This app processes images locally on your device. No data is transmitted to external servers.', style: TextStyle(fontSize: 14 * _fontScale, color: Colors.grey[600])),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettings(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Settings', style: GoogleFonts.poppins(fontSize: 22 * _fontScale, fontWeight: FontWeight.bold)),
          const SizedBox(height: 18),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.account_circle, color: AppColors.primary),
                    title: Text('Account', style: TextStyle(fontSize: 16 * _fontScale)),
                    subtitle: Text(widget.userEmail ?? 'Not logged in', style: TextStyle(fontSize: 14 * _fontScale)),
                  ),
                  const Divider(),
                  ListTile(
                    leading: Icon(Icons.text_fields, color: AppColors.primary),
                    title: Text('Font Size', style: TextStyle(fontSize: 16 * _fontScale)),
                    subtitle: Slider(
                      value: _fontScale,
                      min: 0.8,
                      max: 1.4,
                      divisions: 6,
                      label: '${(_fontScale * 100).round()}%',
                      onChanged: (value) {
                        setState(() {
                          _fontScale = value;
                        });
                      },
                    ),
                  ),
                  const Divider(),
                  SwitchListTile(
                    secondary: Icon(Icons.dark_mode, color: AppColors.primary),
                    title: Text('Dark Mode', style: TextStyle(fontSize: 16 * _fontScale)),
                    subtitle: Text('Toggle dark theme', style: TextStyle(fontSize: 14 * _fontScale)),
                    value: _isDarkMode,
                    onChanged: (value) {
                      setState(() {
                        _isDarkMode = value;
                      });
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: Icon(Icons.language, color: AppColors.primary),
                    title: Text('Language', style: TextStyle(fontSize: 16 * _fontScale)),
                    subtitle: Text(_language, style: TextStyle(fontSize: 14 * _fontScale)),
                    trailing: Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Select Language'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                title: Text('English'),
                                onTap: () {
                                  setState(() {
                                    _language = 'English';
                                  });
                                  Navigator.pop(context);
                                },
                              ),
                              ListTile(
                                title: Text('Spanish'),
                                onTap: () {
                                  setState(() {
                                    _language = 'Spanish';
                                  });
                                  Navigator.pop(context);
                                },
                              ),
                              ListTile(
                                title: Text('French'),
                                onTap: () {
                                  setState(() {
                                    _language = 'French';
                                  });
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: Icon(Icons.storage, color: AppColors.primary),
                    title: Text('Clear History', style: TextStyle(fontSize: 16 * _fontScale)),
                    subtitle: Text('Remove all prediction history', style: TextStyle(fontSize: 14 * _fontScale)),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Clear History'),
                          content: Text('Are you sure you want to clear all prediction history?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _predictionHistory.clear();
                                });
                                Navigator.pop(context);
                                _showSnackbar('History cleared');
                              },
                              child: Text('Clear'),
                            ),
                          ],
                        ),
                      );
                    },
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

class AnimatedGradientBackground extends StatefulWidget {
  final Widget child;
  const AnimatedGradientBackground({super.key, required this.child});
  @override
  _AnimatedGradientBackgroundState createState() => _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState extends State<AnimatedGradientBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.lerp(AppColors.primary.withOpacity(0.7), AppColors.secondary.withOpacity(0.7), _animation.value)!,
                Color.lerp(AppColors.secondary.withOpacity(0.7), AppColors.primary.withOpacity(0.7), _animation.value)!,
              ],
            ),
          ),
          child: widget.child,
        );
      },
    );
  }
}

class GlassCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final double blur;
  final double opacity;
  final Color? color;

  const GlassCard({
    super.key,
    required this.child,
    this.borderRadius = 16.0,
    this.blur = 10.0,
    this.opacity = 0.2,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          decoration: BoxDecoration(
            color: (color ?? Colors.white).withOpacity(opacity),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}