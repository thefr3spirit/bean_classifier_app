import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:pytorch_lite/pytorch_lite.dart';

class PredictionService {
  static const List<Map<String, String>> availableModels = [
    {'name': 'Distilled CNN', 'path': 'assets/models/distilled_cnn_mobile.pt'},
    {'name': 'ResNet', 'path': 'assets/models/resnet_mobile.pt'},
    {'name': 'MobileNetV2', 'path': 'assets/models/mobilenet_mobile.pt'},
  ];

  ClassificationModel? _currentModel;
  List<String> _classNames = [];
  String? _currentModelPath;

  // Getters
  ClassificationModel? get currentModel => _currentModel;
  List<String> get classNames => _classNames;
  String? get currentModelPath => _currentModelPath;
  bool get isModelLoaded => _currentModel != null && _classNames.isNotEmpty;

  // Get label path for specific model
  String _getLabelPathForModel(String modelPath) {
    if (modelPath == 'assets/models/resnet_mobile.pt') {
      return 'assets/models/labels_resnet.txt';
    } else {
      return 'assets/models/labels_mobilenet_distilledcnn.txt';
    }
  }

  // Load labels from file
  Future<List<String>> _loadLabels(String labelPath, BuildContext context) async {
    try {
      final labelFile = File(labelPath);
      if (await labelFile.exists()) {
        final lines = await labelFile.readAsLines();
        return lines.map((l) => l.trim()).where((l) => l.isNotEmpty).toList();
      } else {
        // For asset bundle (mobile/web)
        final labelData = await DefaultAssetBundle.of(context).loadString(labelPath);
        return labelData.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();
      }
    } catch (e) {
      throw Exception('Failed to load labels: $e');
    }
  }

  // Load model
  Future<void> loadModel(String modelPath, BuildContext context) async {
    try {
      final labelPath = _getLabelPathForModel(modelPath);
      
      // Load labels
      final loadedLabels = await _loadLabels(labelPath, context);
      
      // Load model
      final loadedModel = await PytorchLite.loadClassificationModel(
        modelPath,
        224, // width
        224, // height
        3,   // channels (RGB)
        labelPath: labelPath,
      );

      _currentModel = loadedModel;
      _classNames = loadedLabels;
      _currentModelPath = modelPath;
    } catch (e) {
      throw Exception('Failed to load model: $e');
    }
  }

  // Run prediction
  Future<PredictionResult> predict(File imageFile) async {
    if (_currentModel == null || _classNames.isEmpty) {
      throw Exception('Model not loaded. Please load a model first.');
    }

    try {
      final bytes = await imageFile.readAsBytes();
      
      List<double>? logits;
      
      // Apply different preprocessing based on model
      if (_currentModelPath == 'assets/models/resnet_mobile.pt' ||
          _currentModelPath == 'assets/models/mobilenet_mobile.pt') {
        logits = await _currentModel!.getImagePredictionList(
          bytes,
          mean: [0.485, 0.456, 0.406],
          std: [0.229, 0.224, 0.225],
        );
      } else {
        // For DistilledCNN: NO normalization, pass bytes directly
        logits = await _currentModel!.getImagePredictionList(bytes);
      }

      // Apply softmax to get probabilities
      final probabilities = _applySoftmax(logits);
      
      // Find the class with highest probability
      int maxIndex = 0;
      double maxConfidence = probabilities[0];
      for (int i = 1; i < probabilities.length; i++) {
        if (probabilities[i] > maxConfidence) {
          maxConfidence = probabilities[i];
          maxIndex = i;
        }
      }

      return PredictionResult(
        label: _classNames[maxIndex],
        confidence: maxConfidence,
        allProbabilities: probabilities,
        classNames: _classNames,
      );
    } catch (e) {
      throw Exception('Prediction failed: $e');
    }
  }

  // Apply softmax function to logits
  List<double> _applySoftmax(List<double> logits) {
    // Find max value for numerical stability
    double maxLogit = logits.reduce((a, b) => a > b ? a : b);
    
    // Calculate exponentials
    List<double> exps = logits.map((l) => math.exp(l - maxLogit)).toList();
    
    // Calculate sum of exponentials
    double sumExps = exps.reduce((a, b) => a + b);
    
    // Return normalized probabilities
    return exps.map((e) => e / sumExps).toList();
  }

  // Get model name by path
  String getModelNameByPath(String path) {
    for (final model in availableModels) {
      if (model['path'] == path) {
        return model['name']!;
      }
    }
    return 'Unknown Model';
  }

  // Dispose resources
  void dispose() {
    _currentModel = null;
    _classNames.clear();
    _currentModelPath = null;
  }
}

// Result class for predictions
class PredictionResult {
  final String label;
  final double confidence;
  final List<double> allProbabilities;
  final List<String> classNames;

  PredictionResult({
    required this.label,
    required this.confidence,
    required this.allProbabilities,
    required this.classNames,
  });

  // Get formatted label (replace underscores with spaces)
  String get formattedLabel => label.replaceAll('_', ' ');

  // Get confidence as percentage
  String get confidencePercentage => '${(confidence * 100).toStringAsFixed(1)}%';

  // Check if prediction is healthy
  bool get isHealthy => label.toLowerCase() == 'healthy';

  // Get top N predictions
  List<PredictionItem> getTopPredictions(int n) {
    final items = <PredictionItem>[];
    for (int i = 0; i < classNames.length && i < allProbabilities.length; i++) {
      items.add(PredictionItem(
        label: classNames[i],
        confidence: allProbabilities[i],
      ));
    }
    
    // Sort by confidence descending
    items.sort((a, b) => b.confidence.compareTo(a.confidence));
    
    // Return top N
    return items.take(n).toList();
  }
}

// Individual prediction item
class PredictionItem {
  final String label;
  final double confidence;

  PredictionItem({
    required this.label,
    required this.confidence,
  });

  String get formattedLabel => label.replaceAll('_', ' ');
  String get confidencePercentage => '${(confidence * 100).toStringAsFixed(1)}%';
}