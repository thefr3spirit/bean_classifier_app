import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/app_colors.dart';

class MainSection extends StatelessWidget {
  final File? image;
  final bool isPredicting;
  final String? prediction;
  final double? confidence;
  final List<Map<String, String>> models;
  final String selectedModelPath;
  final void Function(String?) onModelChanged;
  final void Function(ImageSource source) onImagePick;
  final VoidCallback onPredict;

  const MainSection({
    super.key,
    required this.image,
    required this.isPredicting,
    required this.prediction,
    required this.confidence,
    required this.models,
    required this.selectedModelPath,
    required this.onModelChanged,
    required this.onImagePick,
    required this.onPredict,
  });

  @override
  Widget build(BuildContext context) {
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
                            child: Text(
                              m['name']!,
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                          );
                        }).toList(),
                        onChanged: onModelChanged,
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
                    child: image == null
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.image_outlined, size: 64, color: Colors.grey[400]),
                                const SizedBox(height: 12),
                                const Text(
                                  'No image selected.',
                                  style: TextStyle(fontSize: 16, color: Colors.grey),
                                ),
                              ],
                            ),
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.file(
                              image!,
                              height: 220,
                              width: 220,
                              fit: BoxFit.cover,
                            ),
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
                        onPressed: () => onImagePick(ImageSource.camera),
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
                        onPressed: () => onImagePick(ImageSource.gallery),
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
                      onPressed: isPredicting ? null : onPredict,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: isPredicting
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
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
          if (prediction != null)
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
                          prediction == 'healthy'
                              ? Icons.check_circle
                              : (prediction == 'bean_rust'
                                  ? Icons.warning_amber_rounded
                                  : Icons.error_outline),
                          color: prediction == 'healthy'
                              ? Colors.green
                              : (prediction == 'bean_rust'
                                  ? AppColors.secondary
                                  : AppColors.error),
                          size: 32,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          prediction!.replaceAll('_', ' ').toUpperCase(),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: prediction == 'healthy'
                                ? Colors.green
                                : (prediction == 'bean_rust'
                                    ? AppColors.secondary
                                    : AppColors.error),
                          ),
                        ),
                      ],
                    ),
                    if (confidence != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Text(
                          'Confidence: ${(confidence! * 100).toStringAsFixed(2)}%',
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
}
