import 'package:Foody/src/core/theme/app_colors.dart';
import 'package:Foody/src/recipes/presentation/screens/camera_screen.dart';
import 'package:Foody/src/recipes/presentation/screens/favorites_screen.dart';
import 'package:Foody/src/recipes/presentation/widget/home_screen/animated_appbar_widget.dart'
    as home;
import 'package:Foody/src/recipes/presentation/widget/home_screen/home_screen_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _showRecipeList = false;
  int _selectedIndex = 0;

  void changeListVisibility() {
    setState(() {
      _showRecipeList = true;
    });
  }

  @override
  void initState() {
    Future.delayed(2550.ms, () => changeListVisibility());
    super.initState();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<bool> _onWillPop() async {
    if (_selectedIndex != 0) {
      setState(() {
        _selectedIndex = 0;
      });
      return false;
    }
    return true;
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final avatarPlayDuration = 500.ms;
    final avatarWaitingDuration = 400.ms;
    final nameDelayDuration =
        avatarWaitingDuration + avatarWaitingDuration + 200.ms;
    final namePlayDuration = 800.ms;
    final categoryListPlayDuration = 750.ms;
    final categoryListDelayDuration =
        nameDelayDuration + namePlayDuration - 400.ms;
    final selectedCategoryPlayDuration = 400.ms;
    final selectedCategoryDelayDuration =
        categoryListDelayDuration + categoryListPlayDuration;

    final List<Widget> _pages = [
      // Your existing HomeScreen content
      SafeArea(
        child: CustomScrollView(
          physics: const ClampingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    height: 30,
                  ),
                  home.AnimatedAppBarWidget(
                      avatarWaitingDuration: avatarWaitingDuration,
                      avatarPlayDuration: avatarPlayDuration,
                      nameDelayDuration: nameDelayDuration,
                      namePlayDuration: namePlayDuration),
                  const SizedBox(
                    height: 30,
                  ),
                  // AnimatedCategoryList(
                  //   categoryListPlayDuration: categoryListPlayDuration,
                  //   categoryListDelayDuration: categoryListDelayDuration,
                  // ),
                  const SizedBox(
                    height: 30,
                  ),
                  AnimatedSelectedCategoryWidget(
                    selectedCategoryPlayDuration: selectedCategoryPlayDuration,
                    selectedCategoryDelayDuration:
                        selectedCategoryDelayDuration,
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                ],
              ),
            ),
            _showRecipeList
                ? const AnimatedRecipesWidget()
                : const SliverToBoxAdapter(
                    child: SizedBox(),
                  )
          ],
        ),
      ),
      const CameraScreen(),
      const FavoritesScreen(),
    ];

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBackgroundColor,
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          backgroundColor: AppColors.scaffoldBackgroundColor,
          elevation: 0,
          iconSize: 28,
          onTap: _onItemTapped,
          selectedItemColor: AppColors
              .onBoardingButtonColor, // Replace with your kprimaryColor
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: const TextStyle(
              color: AppColors.cardColor,
              fontWeight: FontWeight.w700), // Replace with your kprimaryColor
          unselectedLabelStyle:
              const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(
                icon: _selectedIndex == 0
                    ? const Icon(Iconsax.home5)
                    : const Icon(Iconsax.home_1),
                label: "Home"),
            BottomNavigationBarItem(
                icon: _selectedIndex == 1
                    ? const Icon(Iconsax.camera5)
                    : const Icon(Iconsax.camera4),
                label: "Camera"),
            BottomNavigationBarItem(
                icon: _selectedIndex == 2
                    ? const Icon(Iconsax.heart5)
                    : const Icon(Iconsax.heart),
                label: "Favorites"),
          ],
        ),
        body: IndexedStack(
          index: _selectedIndex,
          children: _pages,
        ),
      ),
    );
  }
}
