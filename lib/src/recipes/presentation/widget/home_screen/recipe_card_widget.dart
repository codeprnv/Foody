// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';
import 'package:Foody/src/core/constants/assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:Foody/src/recipes/domain/recipe.dart';

class RecipeCardWidget extends StatelessWidget {
  final Recipe recipe;
  final File? fallbackImageFile; // Nullable fallback image

  const RecipeCardWidget({
    Key? key,
    required this.recipe,
    this.fallbackImageFile, // Nullable
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final playDuration = 600.ms;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 200),
      child: Card(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _AnimatedImageWidget(
              imageUrl: recipe.imageUrl,
              fallbackImageFile: fallbackImageFile,
              playDuration: playDuration,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _AnimatedNutritionText(
                  playDuration: playDuration,
                  nutrition: recipe.nutrition,
                ),
                _AnimatedNameWidget(
                    playDuration: playDuration, name: recipe.name),
                _AnimatedDescriptionWidget(
                    playDuration: playDuration, description: recipe.description)
              ],
            )
          ],
        ),
      ),
    );
  }
}

class _AnimatedNutritionText extends StatelessWidget {
  final Duration playDuration;
  final Map<String, dynamic> nutrition;
  const _AnimatedNutritionText({
    Key? key,
    required this.playDuration,
    required this.nutrition,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Text(
        "${nutrition["calories"]} cal \t\t ${nutrition["protein"]}g protein",
        style: Theme.of(context).textTheme.labelMedium,
      ).animate().scaleXY(
          begin: 0,
          end: 1,
          delay: 300.ms,
          duration: playDuration - 100.ms,
          curve: Curves.decelerate),
    );
  }
}

class _AnimatedImageWidget extends StatelessWidget {
  final Duration playDuration;
  final String imageUrl;
  final File? fallbackImageFile; // Used for fallback

  const _AnimatedImageWidget({
    Key? key,
    required this.playDuration,
    required this.imageUrl,
    this.fallbackImageFile,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isNetworkImage =
        imageUrl.startsWith('http') || imageUrl.startsWith('https');
    bool isLocalAsset = imageUrl.startsWith('assets/');

    return Container(
      constraints: const BoxConstraints(maxHeight: 150, maxWidth: 150),
      child: isNetworkImage
          ? Image.network(
              imageUrl,
              fit: BoxFit.contain,
              alignment: Alignment.center,
              errorBuilder: (context, error, stackTrace) =>
                  _getFallbackImage(), // Use fallback if network fails
            )
          : isLocalAsset
              ? Image.asset(
                  imageUrl, // Use local asset
                  fit: BoxFit.contain,
                  alignment: Alignment.center,
                  errorBuilder: (context, error, stackTrace) =>
                      _getFallbackImage(),
                )
              : _getFallbackImage(), // Directly show fallback for unknown cases
    ).animate(delay: 400.ms).shimmer(duration: playDuration - 200.ms).flip();
  }

  /// Returns the fallback image
  Widget _getFallbackImage() {
    if (fallbackImageFile != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12), // Smooth rounded corners
        child: Image.file(
          fallbackImageFile!,
          fit: BoxFit.cover, // Modern fit
          width: double.infinity, // Full width
          height: 200, // Consistent height
        ),
      );
    } else {
      return Image.asset(Assets.dish, fit: BoxFit.cover); // Default dish image
    }
  }
}

class _AnimatedNameWidget extends StatelessWidget {
  final Duration playDuration;
  final String name;
  const _AnimatedNameWidget({
    Key? key,
    required this.playDuration,
    required this.name,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 150),
      alignment: Alignment.centerLeft,
      child: Text(name,
              overflow: TextOverflow.ellipsis,
              maxLines: 3,
              softWrap: true,
              style: Theme.of(context).textTheme.titleLarge)
          .animate()
          .fadeIn(
              duration: 300.ms, delay: playDuration, curve: Curves.decelerate)
          .slideX(begin: 0.2, end: 0),
    );
  }
}

class _AnimatedDescriptionWidget extends StatelessWidget {
  final Duration playDuration;
  final String description;
  const _AnimatedDescriptionWidget({
    Key? key,
    required this.playDuration,
    required this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 150),
      child: Text(description,
              overflow: TextOverflow.ellipsis,
              maxLines: 4,
              softWrap: true,
              style: Theme.of(context).textTheme.labelLarge)
          .animate()
          .scaleXY(
              begin: 0,
              end: 1,
              delay: 300.ms,
              duration: playDuration - 100.ms,
              curve: Curves.decelerate),
    );
  }
}
