//bean_classifier_home.dart
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/scheduler.dart';

import 'package:pytorch_lite/pytorch_lite.dart'; // If using pytorch_lite plugin

import '../models/app_colors.dart';
import '../models/home_section.dart';
import '../widgets/animated_gradient_background.dart';
import '../widgets/glass_card.dart';

import 'sections/main_section.dart';
import 'sections/history_section.dart';
import 'sections/about_section.dart';
import 'sections/settings_section.dart';

class BeanClassifierHome extends StatefulWidget {
  final VoidCallback? onLogout;
  final String? userEmail;
  const BeanClassifierHome({super.key, this.onLogout, this.userEmail});
  
  @override
  State<BeanClassifierHome> createState() => _BeanClassifierHomeState();
}

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
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
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
    try {
      final labelFile = File(labelPath);
      if (await labelFile.exists()) {
        final lines = await labelFile.readAsLines();
        return lines.map((l) => l.trim()).where((l) => l.isNotEmpty).toList();
      } else {
        // For asset bundle (mobile/web)
        final labelData = await DefaultAssetBundle.of(context).loadString(labelPath);
        return labelData
            .split('\n')
            .map((l) => l.trim())
            .where((l) => l.isNotEmpty)
            .toList();
      }
    } catch (e) {
      debugPrint('Error loading labels: $e');
      return [];
    }
  }

  Future<void> _loadModel() async {
    if (selectedModelPath == null) return;
    
    try {
      final labelPath = _getLabelPathForModel(selectedModelPath);
      final loadedLabels = await _loadLabels(labelPath);
      final loadedModel = await PytorchLite.loadClassificationModel(
        selectedModelPath!,
        224, // width
        224, // height
        3, // channels (RGB)
        labelPath: labelPath,
      );
      
      if (mounted) {
        setState(() {
          model = loadedModel;
          _classNames = loadedLabels;
          _prediction = null;
          _confidence = null;
          _image = null;
        });
      }
    } catch (e) {
      debugPrint('Error loading model: $e');
      _showSnackbar('Failed to load model. Please try again.', isError: true);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 90,
      );
      
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
    } catch (e) {
      debugPrint('Error picking image: $e');
      _showSnackbar('Failed to pick image. Please try again.', isError: true);
    }
  }

  Future<void> _runInference() async {
    if (_image == null || model == null || _classNames.isEmpty) {
      debugPrint("No image, model not loaded, or labels missing");
      _showSnackbar(
        'Please select an image and ensure the model is loaded.',
        isError: true,
      );
      return;
    }
    
    setState(() {
      _isPredicting = true;
    });

    try {
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

      // Apply softmax to get probabilities
      final maxLogit = logits.reduce((a, b) => a > b ? a : b);
      final exps = logits.map((l) => math.exp(l - maxLogit)).toList();
      final sumExps = exps.reduce((a, b) => a + b);
      final softmax = exps.map((e) => e / sumExps).toList();
      
      // Find max probability and index
      int maxIdx = 0;
      double maxVal = softmax[0];
      for (int i = 1; i < softmax.length; i++) {
        if (softmax[i] > maxVal) {
          maxVal = softmax[i];
          maxIdx = i;
        }
      }

      debugPrint("Prediction: ${_classNames[maxIdx]}, Confidence: ${softmax[maxIdx]}");
      
      if (mounted) {
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
              if (mounted) {
                setState(() {
                  _showHealthyCheck = false;
                });
              }
            });
          }
        });
        
        _showSnackbar(
          'Prediction: ${_prediction!.replaceAll('_', ' ')} (${(_confidence! * 100).toStringAsFixed(1)}%)',
          isError: false,
        );
      }
    } catch (e) {
      debugPrint('Error during inference: $e');
      if (mounted) {
        setState(() {
          _isPredicting = false;
        });
        _showSnackbar('Prediction failed. Please try again.', isError: true);
      }
    }
  }

  void _showSnackbar(String message, {bool isError = false}) {
    if (!mounted) return;
    
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red[700] : AppColors.primary,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    });
  }

  void _handleClearHistory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _isDarkMode ? Colors.grey[800] : Colors.white,
        title: Text(
          'Clear History',
          style: TextStyle(
            color: _isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        content: Text(
          'Are you sure you want to clear all prediction history?',
          style: TextStyle(
            color: _isDarkMode ? Colors.white70 : Colors.black54,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: _isDarkMode ? Colors.white70 : Colors.black54,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _predictionHistory.clear();
              });
              Navigator.pop(context);
              _showSnackbar('History cleared successfully');
            },
            child: Text(
              'Clear',
              style: TextStyle(color: Colors.red[400]),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _isDarkMode 
          ? ThemeData.dark().copyWith(
              appBarTheme: AppBarTheme(
                backgroundColor: Colors.grey[900],
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              colorScheme: ColorScheme.dark(
                primary: AppColors.primary,
                secondary: AppColors.primary,
              ),
            )
          : ThemeData.light().copyWith(
              appBarTheme: AppBarTheme(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              colorScheme: ColorScheme.light(
                primary: AppColors.primary,
                secondary: AppColors.primary,
              ),
            ),
      child: ScaffoldMessenger(
        key: _scaffoldMessengerKey,
        child: Scaffold(
          appBar: AppBar(
            title: const Text(
              'Bean Classifier',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            centerTitle: true,
          ),
          body: Stack(
            children: [
              AnimatedGradientBackground(child: const SizedBox.expand()),
              _buildSection(context),
            ],
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: BottomNavigationBar(
              currentIndex: _section.index,
              onTap: (index) {
                setState(() {
                  _section = HomeSection.values[index];
                });
              },
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_rounded),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.history_rounded),
                  label: 'History',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.info_outline_rounded),
                  label: 'About',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings_rounded),
                  label: 'Settings',
                ),
              ],
              selectedItemColor: AppColors.primary,
              unselectedItemColor: _isDarkMode ? Colors.white54 : Colors.grey[600],
              showUnselectedLabels: true,
              type: BottomNavigationBarType.fixed,
              backgroundColor: _isDarkMode ? Colors.grey[900] : Colors.white,
              elevation: 0,
              selectedFontSize: 12,
              unselectedFontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context) {
    switch (_section) {
      case HomeSection.history:
        return HistorySection(
          fontScale: _fontScale,
          predictionHistory: _predictionHistory,
        );
      case HomeSection.about:
        return AboutSection(fontScale: _fontScale);
      case HomeSection.settings:
        return SettingsSection(
          userEmail: widget.userEmail,
          fontScale: _fontScale,
          isDarkMode: _isDarkMode,
          language: _language,
          onToggleDarkMode: (value) {
            setState(() {
              _isDarkMode = value;
            });
          },
          onFontScaleChanged: (value) {
            setState(() {
              _fontScale = value;
            });
          },
          onLanguageChanged: (lang) {
            setState(() {
              _language = lang;
            });
          },
          onClearHistory: _handleClearHistory,
          onLogout: widget.onLogout,
        );
      case HomeSection.main:
      default:
        return MainSection(
          image: _image,
          isPredicting: _isPredicting,
          prediction: _prediction,
          confidence: _confidence,
          models: models,
          selectedModelPath: selectedModelPath!,
          onModelChanged: (value) {
            setState(() {
              selectedModelPath = value!;
              _loadModel();
            });
          },
          onImagePick: _pickImage,
          onPredict: _runInference,
        );
    }
  }
}