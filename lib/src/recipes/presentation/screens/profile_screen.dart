import 'package:Foody/src/recipes/presentation/screens/recipe_details_screen.dart';
import 'package:Foody/src/recipes/presentation/widget/home_screen/recipe_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Foody/src/recipes/domain/recipe.dart';
import 'package:Foody/src/core/constants/assets.dart';
import 'package:Foody/src/recipes/presentation/screens/home_screen.dart'; // Import your HomeScreen

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    bool isLoggedIn = user != null;
    String profilePic = user?.photoURL ?? Assets.profileImage;
    String userName = user?.displayName ?? "Guest User";

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: const Text(
          "My Profile",
          style: TextStyle(color: Colors.white, fontSize: 22),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey.shade800,
                backgroundImage: user?.photoURL != null
                    ? NetworkImage(profilePic)
                    : const AssetImage(Assets.profileImage) as ImageProvider,
              ).animate().scaleXY(
                  begin: 0, end: 1, duration: 500.ms, curve: Curves.easeOut),
            ),
            const SizedBox(height: 10),
            Text(
              userName,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall!
                  .copyWith(color: Colors.white, fontWeight: FontWeight.bold),
            ).animate().fade(duration: 600.ms).moveY(begin: 10, end: 0),
            const SizedBox(height: 20),
            isLoggedIn
                ? _buildLogoutButton(context)
                : _buildLoginButton(context),
            const SizedBox(height: 20),
            if (isLoggedIn) _buildTabBar(),
            if (isLoggedIn) Expanded(child: _buildTabBarView()),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return TabBar(
      controller: _tabController,
      labelColor: Colors.white,
      indicatorColor: Colors.white,
      tabs: const [
        Tab(icon: Icon(Iconsax.heart5), text: "Favorites"),
        Tab(icon: Icon(Icons.dinner_dining_rounded), text: "Recipes Made"),
        Tab(icon: Icon(Iconsax.bookmark), text: "Bookmarks"),
      ],
    );
  }

  Widget _buildTabBarView() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildRecipeList("favorites"),
        _buildRecipeList("recipes_made"),
        _buildRecipeList("bookmarks"),
      ],
    );
  }

  Widget _buildRecipeList(String collectionName) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return _buildLoginPrompt();
    }

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection(collectionName)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              "No $collectionName yet!",
              style: const TextStyle(color: Colors.white),
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.only(top: 10),
          children: snapshot.data!.docs.map((doc) {
            final recipe = Recipe.fromJson(doc.data() as Map<String, dynamic>);

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RecipeDetailsScreen(recipe: recipe),
                  ),
                );
              },
              child: RecipeCardWidget(recipe: recipe),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildLoginPrompt() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Login to use this feature",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 10),
          _buildLoginButton(context),
        ],
      ),
    );
  }

  Widget _buildLoginButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        Navigator.pushNamed(context, "/auth"); // Navigate to login screen
      },
      icon: const Icon(Iconsax.login, color: Colors.white),
      label: const Text("Login",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueAccent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 30),
      ),
    ).animate().fade(duration: 500.ms).moveY(begin: 10, end: 0);
  }

  Widget _buildLogoutButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () async {
        await FirebaseAuth.instance.signOut();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => const HomeScreen()), // Redirect to Home
        );
      },
      icon: const Icon(Iconsax.logout, color: Colors.white),
      label: const Text("Logout",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.redAccent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 30),
      ),
    ).animate().fade(duration: 500.ms).moveY(begin: 10, end: 0);
  }
}
