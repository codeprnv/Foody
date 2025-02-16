import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:Foody/src/core/services/firestore_service.dart';
import 'package:Foody/src/recipes/domain/recipe.dart';
import 'package:share_plus/share_plus.dart';

class AnimatedAppBarWidget extends StatefulWidget {
  final String name;
  final Recipe recipe;
  final Duration appBarPlayTime;
  final Duration appBarDelayTime;

  const AnimatedAppBarWidget({
    Key? key,
    required this.name,
    required this.recipe,
    required this.appBarPlayTime,
    required this.appBarDelayTime,
  }) : super(key: key);

  @override
  _AnimatedAppBarWidgetState createState() => _AnimatedAppBarWidgetState();
}

class _AnimatedAppBarWidgetState extends State<AnimatedAppBarWidget> {
  final FirestoreService _firestoreService = FirestoreService();
  bool isFavorite = false;
  bool isMade = false;
  bool isBookmarked = false;

  StreamSubscription<bool>? _favoriteSubscription;
  StreamSubscription<bool>? _madeSubscription;
  StreamSubscription<bool>? _bookmarkSubscription;

  @override
  void initState() {
    super.initState();

    _favoriteSubscription =
        _firestoreService.isFavorite(widget.recipe.id).listen((fav) {
      if (mounted) {
        setState(() {
          isFavorite = fav;
        });
      }
    });

    _madeSubscription =
        _firestoreService.isRecipeMade(widget.recipe.id).listen((made) {
      if (mounted) {
        setState(() {
          isMade = made;
        });
      }
    });

    _bookmarkSubscription =
        _firestoreService.isBookmarked(widget.recipe.id).listen((bookmark) {
      if (mounted) {
        setState(() {
          isBookmarked = bookmark;
        });
      }
    });
  }

  @override
  void dispose() {
    _favoriteSubscription?.cancel();
    _madeSubscription?.cancel();
    _bookmarkSubscription?.cancel();
    super.dispose();
  }

  void toggleFavorite() {
    if (isFavorite) {
      _firestoreService.removeFromFavorites(context, widget.recipe.id);
    } else {
      _firestoreService.addToFavorites(context, widget.recipe);
    }
  }

  void toggleMadeRecipe() {
    if (isMade) {
      _firestoreService.removeMadeRecipe(context, widget.recipe.id);
    } else {
      _firestoreService.addMadeRecipe(context, widget.recipe);
    }
  }

  void toggleBookmark() {
    if (isBookmarked) {
      _firestoreService.removeFromBookmarks(context, widget.recipe.id);
    } else {
      _firestoreService.addBookmark(context, widget.recipe);
    }
  }

  void _shareRecipe() {
    // Format the steps list
    String stepsFormatted = widget.recipe.steps.asMap().entries.map((entry) {
      return "${entry.key + 1}. ${entry.value}";
    }).join("\n");

    // Recipe text content
    String shareText = "🍽️ *${widget.recipe.name}*\n\n"
        "📖 *Description:*\n${widget.recipe.description}\n\n"
        "📝 *Steps to make it:*\n$stepsFormatted";

    Share.share(shareText);
  }


  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Back Button
        IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back_ios_new, size: 25),
        ),

        // Recipe Name
        Expanded(
          child: Text(
            widget.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .bodyLarge!
                .copyWith(color: Colors.white),
          ),
        ),

        // "Made" Icon (Chef Badge)
        IconButton(
          onPressed: toggleMadeRecipe,
          icon: Icon(
            isMade ? Icons.restaurant_menu : Icons.restaurant_menu_outlined,
            size: 28,
            color: isMade ? Colors.orangeAccent : Colors.white,
          ),
          tooltip: isMade ? "You made this!" : "Mark as made",
        ),

        // Favorite Button
        IconButton(
          onPressed: toggleFavorite,
          icon: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_outline,
            size: 25,
            color: isFavorite ? Colors.red : Colors.white,
          ),
          tooltip: isFavorite ? "Remove from favorites" : "Add to favorites",
        ),

        // More Options (Bookmark & Share)
        PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'Bookmark') {
              toggleBookmark();
            } else if (value == 'Share') {
              _shareRecipe();
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'Bookmark',
              child: Row(
                children: [
                  Icon(
                    isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
                    color: isBookmarked ? Colors.blueAccent : Colors.black,
                  ),
                  const SizedBox(width: 10),
                  Text(isBookmarked ? 'Remove Bookmark' : 'Bookmark'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'Share',
              child: Row(
                children: [
                  Icon(Icons.ios_share_rounded,
                      color: Theme.of(context).colorScheme.primary, size: 22),
                  const SizedBox(width: 12),
                  Text(
                    'Share Recipe',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    ).animate().then(delay: widget.appBarDelayTime).scaleXY(
          begin: 0,
          end: 1,
          duration: widget.appBarPlayTime,
          curve: Curves.decelerate,
        );
  }
}
