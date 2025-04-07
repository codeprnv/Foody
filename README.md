# 🍲 Foody

Foody is an AI-powered Flutter application designed to suggest personalized recipes based on ingredients detected from images. It simplifies meal preparation by allowing users to upload or capture an image of ingredients and instantly receive recipe suggestions.

---

![Flutter](https://img.shields.io/badge/Flutter-3.19-blue?logo=flutter) ![License](https://img.shields.io/github/license/codeprnv/foody) ![Stars](https://img.shields.io/github/stars/codeprnv/foody?style=social) ![Open Issues](https://img.shields.io/github/issues/codeprnv/foody)

---

## 📚 Table of Contents

- [About](#about)
- [Features](#features)
- [Screenshots](#screenshots)
- [Built With](#built-with)
- [Getting Started](#getting-started)
- [Usage](#usage)
- [Project Structure](#project-structure)
- [Learning Objectives](#learning-objectives)
- [Contributing](#contributing)
- [Authors](#authors)
- [License](#license)

---

## 📟 About

Foody revolutionizes the cooking experience by eliminating the need for manual ingredient entry. It utilizes Google Gemini AI to detect ingredients from images and provides curated recipe suggestions. Integration with Firebase enables secure user authentication and the ability to save favorite recipes for later access.

---

## ✨ Features

- 🧠 Real-time ingredient detection using Google Gemini AI
- 🍽️ Smart, curated recipe suggestions
- 💡 Intuitive and modern UI inspired by Dribbble
- 📸 Upload from gallery or take photos for ingredient detection
- 🔐 Firebase integration for authentication and favorites
- 📋 Detailed recipe view with ingredients and cooking steps
- 🎧 Voice integration (coming soon)

---
## 🖼️ Screenshots

| Onboarding | Login | Home |
|:----------:|:-----:|:----:|
| <img src="assets/images/onboarding.png" width="250"/> | <img src="assets/images/login.png" width="250"/> | <img src="assets/images/home.png" width="250"/> |

| Ingredient Detection | Recipe Suggestions | Recipe Details |
|:--------------------:|:------------------:|:--------------:|
| <img src="assets/images/detection.png" width="250"/> | <img src="assets/images/suggestions.png" width="250"/> | <img src="assets/images/details.png" width="250"/> |

| Favorites | Share Recipe |
|:---------:|:------------:|
| <img src="assets/images/favorites.png" width="250"/> | <img src="assets/images/share.png" width="250"/> |


---

## 🛠️ Built With

- ![Flutter](https://img.shields.io/badge/Flutter-blue?logo=flutter) **Flutter**
- ![Firebase](https://img.shields.io/badge/Firebase-yellow?logo=firebase) **Firebase** (Authentication, Firestore)
- ![Google](https://img.shields.io/badge/Gemini_AI-4285F4?logo=google) **Google Gemini AI**
- ![Riverpod](https://img.shields.io/badge/Riverpod-3EAF7C?logo=dart) **Riverpod** (state management)
- 🎨 Dribbble-inspired UI designs

---

## 🚀 Getting Started

### ✅ Prerequisites

Ensure the following are installed:

- Flutter SDK
- Dart SDK
- Android Studio or VS Code
- A Firebase project
- A Google Gemini API key
- Stable internet connection

### 📅 Setup & Installation

1. **Clone the repository**

```bash
git clone https://github.com/codeprnv/Foody.git
cd Foody
```

2. **Install dependencies**

```bash
flutter pub get
```

3. **Set up Firebase**

- Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com/)
- Enable **Email/Password** and/or **Google Sign-In** under Authentication
- Enable **Cloud Firestore** (start in test mode for dev)
- Download `google-services.json` from Firebase Console and place it at:

```
android/app/google-services.json
```

4. **Get Gemini API Key**

- Visit [Google AI Studio](https://makersuite.google.com/app)
- Sign in with your Google account
- Click your profile icon > **API Keys** > **Create API Key**
- Copy the key

Create a `.env` file at the root of the project:

```env
GEMINI_API_KEY=your_google_gemini_api_key
```

> ⚠️ **Important**: Never share or commit your `.env` file to source control.

5. **Run the app**

```bash
flutter run
```

---

## 📲 Usage

1. Sign in using Email or Google
2. Upload or take a picture of ingredients
3. Gemini AI detects the ingredients automatically
4. View recipe suggestions based on detection
5. Tap any recipe to see details
6. Save your favorites to revisit later

---

## 🗂️ Project Structure

```
Foody/
├── lib/
│   ├── main.dart
│   ├── src/
│   │   ├── auth/
│   │   │   └── presentation/
│   │   │       └── screens/
│   │   │           └── auth_screen.dart
│   │   ├── core/
│   │   │   ├── animation/
│   │   │   ├── constants/
│   │   │   ├── theme/
│   │   │   └── widgets/
│   │   ├── onboarding/
│   │   │   └── onboarding_screen.dart
│   │   ├── recipes/
│   │       ├── domain/
│   │       │   └── recipe.dart
│   │       ├── data/
│   │       │   └── recipe_repository.dart
│   │       └── presentation/
│   │           ├── screens/
│   │           │   ├── home_screen.dart
│   │           │   ├── recipe_details_screen.dart
│   │           │   └── object_detection_screen.dart
│   │           └── widget/
│   │               └── home_screen/
│   │                   ├── animated_appbar_widget.dart
│   │                   ├── animated_recipes_widget.dart
│   │                   ├── loaded_recipes_widget.dart
│   │                   └── recipe_card_widget.dart
├── assets/
│   ├── images/
│   │   └── dish.png
│   └── recipe.json
├── pubspec.yaml
├── .env
└── README.md
```

---

## 🎯 Learning Objectives

This project was created to help the developer get familiar with the following key concepts:

- **Theming:** Learn how to define and apply different themes to customize the app's look and feel.
- **State Management (Riverpod):** Understand how to manage state across different widgets and pages using Riverpod.
- **Navigation:** Learn how to implement navigation between different screens using Flutter’s Navigator.
- **Layout Builder:** Explore how to build adaptive and flexible layouts with Flutter’s layout widgets (e.g., Column, Row, GridView).

---

## 🤝 Contributing

Contributions are what make the open-source community such an amazing place to learn and grow. Any contributions you make are **greatly appreciated**.

1. Fork the repository
2. Create a new branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 👨‍💻 Authors

- [Pranav Pradhan](https://github.com/codeprnv)

---

## 📝 License

Distributed under the MIT License. See `LICENSE` for more information.

---

Made with ❤️ by [@codeprnv](https://github.com/codeprnv) and contributors.
