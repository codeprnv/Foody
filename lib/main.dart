import 'package:device_preview/device_preview.dart';
import 'package:Foody/src/core/animation/page_transition.dart';
import 'package:Foody/src/core/theme/app_theme.dart';
import 'package:Foody/src/onboarding/onboarding_screen.dart';
import 'package:Foody/src/recipes/domain/recipe.dart';
import 'package:Foody/src/recipes/presentation/screens/home_screen.dart';
import 'package:Foody/src/recipes/presentation/screens/recipe_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  try {
    await dotenv.load(fileName: ".env");
    debugPrint('Environment variables loaded successfully.');
  } catch (e) {
    debugPrint('Error loading environment variables: $e');
  }

  runApp(const ProviderScope(child: DribbleChallenge()));
  // runApp(DevicePreview(
  //     enabled: true,
  //     builder: (context) {
  //       return const ProviderScope(child: DribbleChallenge());
  //     }));
}

class DribbleChallenge extends StatelessWidget {
  const DribbleChallenge({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: DevicePreview.locale(context),
      home: const OnBoardingScreen(),
      onGenerateRoute: (settings) {
        return switch (settings.name) {
          'home' => NoAnimationTransition(
              builder: (context) => const HomeScreen(),
            ),
          'recipe_details' => NoAnimationTransition(
              builder: (context) =>
                  RecipeDetailsScreen(recipe: settings.arguments as Recipe),
            ),
          _ => NoAnimationTransition(builder: (context) => const HomeScreen())
        };
      },
      theme: mainTheme,
      darkTheme: mainTheme,
      themeMode: ThemeMode.dark,
      debugShowCheckedModeBanner: false,
    );
  }
}
