import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:Foody/src/recipes/domain/recipe.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// ✅ Get current user ID
  String? get userId => _auth.currentUser?.uid;

  /// ✅ Ensure user is logged in (Shows a modern pop-up if not)
Future<bool> _ensureUserLoggedIn(BuildContext context) async {
    if (userId == null) {
      bool shouldLogin = await showDialog<bool>(
            context: context,
            barrierDismissible: false,
            builder: (context) => Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              backgroundColor: Colors.black54,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.lock_outline_rounded,
                        size: 60, color: Colors.white),
                    const SizedBox(height: 18),
                    const Text(
                      "Sign In Required",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "You need to be logged in to use this feature.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text("Cancel",
                              style: TextStyle(
                                  color: Colors.redAccent,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500)),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop(true); // Close dialog
                          },
                          child: const Text("Sign In",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ) ??
          false;

      if (shouldLogin) {
        // Check if the widget is still mounted before calling Navigator
        if (context.mounted) {
          Navigator.pushNamed(context, '/auth');
        }
      }

      return shouldLogin;
    }
    return true;
  }


  /// ✅ Ensure user document exists in Firestore
  Future<void> _ensureUserDocExists() async {
    if (userId == null) return;
    final userDoc = _db.collection('users').doc(userId);
    final docSnapshot = await userDoc.get();

    if (!docSnapshot.exists) {
      await userDoc.set({"created_at": FieldValue.serverTimestamp()});
    }
  }

  // ------------------ FAVORITES ------------------

  /// ✅ Add Recipe to Favorites
  Future<void> addToFavorites(BuildContext context, Recipe recipe) async {
    if (!await _ensureUserLoggedIn(context)) return;
    await _ensureUserDocExists();
    await _db
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(recipe.id)
        .set(recipe.toJson());
     if (userId != null) {
      // Ensure the user is actually logged in before showing snackbar
      _showSnackBar(context, "Added to Favorites! ❤️", Colors.greenAccent);
    }
  }

  /// ✅ Remove Recipe from Favorites
  Future<void> removeFromFavorites(
      BuildContext context, String recipeId) async {
    if (!await _ensureUserLoggedIn(context)) return;
    await _db
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(recipeId)
        .delete();
   if(userId != null) {
      // Ensure the user is actually logged in before showing snackbar
      _showSnackBar(context, "Removed from Favorites.", Colors.redAccent);
    }
  }

  /// ✅ Check if a Recipe is a Favorite
  Stream<bool> isFavorite(String recipeId) {
    if (userId == null) return const Stream.empty();
    return _db
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(recipeId)
        .snapshots()
        .map((doc) => doc.exists);
  }

  // ------------------ BOOKMARKS ------------------

  /// ✅ Add Recipe to Bookmarks
  Future<void> addBookmark(BuildContext context, Recipe recipe) async {
    if (!await _ensureUserLoggedIn(context)) return;
    await _ensureUserDocExists();
    await _db
        .collection('users')
        .doc(userId)
        .collection('bookmarks')
        .doc(recipe.id)
        .set(recipe.toJson());
    if(userId != null) {
      // Ensure the user is actually logged in before showing snackbar
      _showSnackBar(context, "Bookmark added! 📌", Colors.blueAccent);
    }
  }

  /// ✅ Remove Recipe from Bookmarks
  Future<void> removeFromBookmarks(
      BuildContext context, String recipeId) async {
    if (!await _ensureUserLoggedIn(context)) return;
    await _db
        .collection('users')
        .doc(userId)
        .collection('bookmarks')
        .doc(recipeId)
        .delete();
    if(userId != null) {
      // Ensure the user is actually logged in before showing snackbar
      _showSnackBar(context, "Bookmark removed.", Colors.redAccent);
    }
  }

  /// ✅ Check if a Recipe is Bookmarked
  Stream<bool> isBookmarked(String recipeId) {
    if (userId == null) return const Stream.empty();
    return _db
        .collection('users')
        .doc(userId)
        .collection('bookmarks')
        .doc(recipeId)
        .snapshots()
        .map((doc) => doc.exists);
  }

  // ------------------ RECIPES MADE ------------------

  /// ✅ Add Recipe to "Made Recipes"
  Future<void> addMadeRecipe(BuildContext context, Recipe recipe) async {
    if (!await _ensureUserLoggedIn(context)) return;
    await _ensureUserDocExists();
    await _db
        .collection('users')
        .doc(userId)
        .collection('recipes_made')
        .doc(recipe.id)
        .set(recipe.toJson());
    if(userId != null) {
      // Ensure the user is actually logged in before showing snackbar
      _showSnackBar(context, "Added to Made Recipes! 🍽️", Colors.greenAccent);
    }
  }

  /// ✅ Remove Recipe from "Made Recipes"
  Future<void> removeMadeRecipe(BuildContext context, String recipeId) async {
    if (!await _ensureUserLoggedIn(context)) return;
    await _db
        .collection('users')
        .doc(userId)
        .collection('recipes_made')
        .doc(recipeId)
        .delete();
    if(userId != null) {
      // Ensure the user is actually logged in before showing snackbar
      _showSnackBar(context, "Removed from Made Recipes.", Colors.redAccent);
    }
  }

  /// ✅ Check if a Recipe is Marked as Made
  Stream<bool> isRecipeMade(String recipeId) {
    if (userId == null) return const Stream.empty();
    return _db
        .collection('users')
        .doc(userId)
        .collection('recipes_made')
        .doc(recipeId)
        .snapshots()
        .map((doc) => doc.exists);
  }

  // ------------------ HELPER METHODS ------------------

  /// ✅ Show SnackBar Message
  void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded,
                color: Colors.white, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: color.withOpacity(0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        elevation: 6,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
