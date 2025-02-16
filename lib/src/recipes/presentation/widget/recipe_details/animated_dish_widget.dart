import 'dart:io';
import 'package:Foody/src/core/constants/assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AnimatedDishWidget extends StatelessWidget {
  final BoxConstraints constraints;
  final String imageUrl;
  final File? userImage;
  final Duration dishPlayTime;

  const AnimatedDishWidget({
    Key? key,
    required this.constraints,
    required this.imageUrl,
    this.userImage,
    required this.dishPlayTime,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isNetworkImage =
        imageUrl.startsWith('http') || imageUrl.startsWith('https');
    bool isLocalAsset = imageUrl.startsWith('assets/');

    return Container(
      height: constraints.maxHeight * 0.31,
      width: constraints.maxWidth * 0.8,
      alignment: Alignment.center,
      child: isNetworkImage
          ? Image.network(
              imageUrl,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => userImage != null
                  ? Image.file(
                      userImage!,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) =>
                          _fallbackImage(),
                    )
                  : _fallbackImage(),
            )
          : isLocalAsset
              ? Image.asset(
                  imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) =>
                      _fallbackImage(),
                )
              : userImage != null
                  ? Image.file(
                      userImage!,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) =>
                          _fallbackImage(),
                    )
                  : _fallbackImage(),
    )
        .animate()
        .scaleXY(
            begin: 0.0,
            end: 1.0,
            duration: dishPlayTime,
            curve: Curves.decelerate)
        .fadeIn()
        .blurXY(begin: 10, end: 0);
  }

  Widget _fallbackImage() {
    return Image.asset(
      Assets.dish,
      width: 200, // Adjust size as needed
      height: 200,
      fit: BoxFit.cover,
    );
  }
}
