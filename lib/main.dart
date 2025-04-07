import 'package:Foody/src/auth/presentation/screens/auth_screen.dart';
import 'package:Foody/src/core/theme/app_theme.dart';
import 'package:Foody/src/onboarding/onboarding_screen.dart';
import 'package:Foody/src/recipes/presentation/screens/home_screen.dart';
import 'package:Foody/src/recipes/presentation/screens/recipe_details_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Foody/src/recipes/domain/recipe.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
    debugPrint('Firebase initialized successfully.');
    await dotenv.load(fileName: ".env");
    debugPrint('.env file loaded successfully.');
  } catch (e) {
    debugPrint('Error initializing : $e');
  }
  runApp(const ProviderScope(child: Foody()));
}

class Foody extends StatelessWidget {
  const Foody({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Foody',
      theme: mainTheme,
      darkTheme: mainTheme,
      themeMode: ThemeMode.dark,
      debugShowCheckedModeBanner: false,
      home:
          const Initializer(), // Decides whether to show Onboarding or Home/Auth
      onGenerateRoute: (settings) {
        if (settings.name == '/recipe_details') {
          final recipe = settings.arguments as Recipe?;
          return MaterialPageRoute(
            builder: (context) => recipe != null
                ? RecipeDetailsScreen(recipe: recipe)
                : const HomeScreen(),
          );
        }
        if (settings.name == '/auth') {
          return MaterialPageRoute(builder: (context) => const AuthPage());
        }
        return null;
      },
    );
  }
}

/// **Decides whether to show Onboarding or Home/Auth**
class Initializer extends StatefulWidget {
  const Initializer({super.key});

  @override
  State<Initializer> createState() => _InitializerState();
}

class _InitializerState extends State<Initializer> {
  bool? _hasSeenOnboarding;

  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    final prefs = await SharedPreferences.getInstance();

    // **Force onboarding screen every restart**
    await prefs.setBool('hasSeenOnboarding', false);

    setState(() {
      _hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_hasSeenOnboarding == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return _hasSeenOnboarding! ? const AuthWrapper() : const OnBoardingScreen();
  }
}

/// **Handles navigation after onboarding**
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomeScreen(); // Always show HomeScreen, login is optional
  }
}
