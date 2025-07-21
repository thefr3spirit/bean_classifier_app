# BeanLeaf AI Classifier 🌱

BeanLeaf is a mobile AI-powered diagnostic tool designed to help farmers and agricultural extension workers detect diseases in bean leaves using image classification. The app leverages machine learning to analyze uploaded images and return predictions with confidence scores, enabling quick, on-the-spot crop assessments.

## 📱 Features

- 📷 **Image-based diagnosis** – Upload an image of a bean leaf for instant disease prediction.
- 🤖 **On-device AI model** – Uses TensorFlow Lite models for fast, offline predictions.
- 📊 **Confidence scoring** – See how confident the model is in each prediction.
- 🕓 **Prediction history** – Keeps a record of all past predictions for easy reference.
- 🌍 **Multi-language support** – Switch between languages in the app settings.
- 🔐 **User authentication** – Secure login system to personalize the experience.
- ⚙️ **Settings customization** – Includes font scaling, dark mode, language preference, and history clearing options.

## 🚀 Roadmap & Improvements

Here are some planned enhancements to increase performance, usability, and scalability:

### 🔧 Technical Improvements
- [ ] **Optimize image caching** to prevent crashes from too many stored images.
- [ ] **Smarter cache management** using LRU (Least Recently Used) or size limits.
- [ ] **Model optimization** for improved accuracy and speed.
- [ ] **Better error handling** during prediction and model loading.

### 🎨 UI/UX Enhancements
- [ ] **Redesigned homepage layout** for a cleaner, more intuitive user interface.
- [ ] **Add loading animations** to improve perceived performance during inference.
- [ ] **Improved accessibility** with dynamic font scaling and color contrast.

### 🌐 Features in Progress
- [ ] **Real-time camera predictions** (live leaf scan via camera).
- [ ] **Integration with cloud services** for model updates and prediction logging.
- [ ] **Multi-model support** for detecting diseases in other crops.

## 🏗️ Tech Stack

- **Flutter** – Cross-platform UI framework
- **Dart** – Main programming language
- **TensorFlow Lite** – On-device ML inference
- **Firebase** – Authentication and cloud functions (optional)

---
