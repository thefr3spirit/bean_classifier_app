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
  _BeanClassifierHomeState createState() => _BeanClassifierHomeState();
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
    final labelFile = File(labelPath);
    if (await labelFile.exists()) {
      final lines = await labelFile.readAsLines();
      return lines.map((l) => l.trim()).where((l) => l.isNotEmpty).toList();
    } else {
      // For asset bundle (mobile/web)
      final labelData = await DefaultAssetBundle.of(
        context,
      ).loadString(labelPath);
      return labelData
          .split('\n')
          .map((l) => l.trim())
          .where((l) => l.isNotEmpty)
          .toList();
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
      3, // channels (RGB)
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
      _showSnackbar(
        'Please select an image and ensure the model is loaded.',
        isError: true,
      );
      return;
    }
    setState(() {
      _isPredicting = true;
    });
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
          if (mounted)
            setState(() {
              _showHealthyCheck = false;
            });
        });
      }
    });
    _showSnackbar(
      'Prediction: ${_prediction!.replaceAll('_', ' ')} (${(_confidence! * 100).toStringAsFixed(1)}%)',
      isError: false,
    );
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
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
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
  onClearHistory: () {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear History'),
        content: const Text('Are you sure you want to clear all prediction history?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              setState(() {
                _predictionHistory.clear();
              });
              Navigator.pop(context);
              _showSnackbar('History cleared');
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  },
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
