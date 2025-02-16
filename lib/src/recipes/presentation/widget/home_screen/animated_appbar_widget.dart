import 'package:Foody/src/core/constants/assets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:Foody/src/recipes/presentation/widget/home_screen/animated_name_widget.dart';
import 'package:Foody/src/recipes/presentation/screens/profile_screen.dart';

class AnimatedAppBarWidget extends StatelessWidget {
  final Duration avatarWaitingDuration;
  final Duration avatarPlayDuration;
  final Duration nameDelayDuration;
  final Duration namePlayDuration;

  const AnimatedAppBarWidget({
    Key? key,
    required this.avatarWaitingDuration,
    required this.avatarPlayDuration,
    required this.nameDelayDuration,
    required this.namePlayDuration,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 20),
        AnimatedNameWidget(
          namePlayDuration: namePlayDuration,
          nameDelayDuration: nameDelayDuration,
        ),
        Expanded(child: Container()),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            );
          },
          child: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                debugPrint("Error fetching user data: ${snapshot.error}");
              }

              User? user = snapshot.data;
              String? profilePic = user?.photoURL;

              return CircleAvatar(
                radius: 18,
                backgroundColor: Colors.grey.shade800,
                child: ClipOval(
                  child: profilePic != null && profilePic.isNotEmpty
                      ? Image.network(
                          profilePic,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            debugPrint("Error loading profile image: $error");
                            return Image.asset(Assets.profileImage,
                                fit: BoxFit.cover);
                          },
                        )
                      : Image.asset(Assets.profileImage,
                          fit: BoxFit.cover), // Default image
                ),
              )
                  .animate()
                  .scaleXY(
                    begin: 0,
                    end: 2,
                    duration: avatarPlayDuration,
                    curve: Curves.easeInOutSine,
                  )
                  .then(delay: avatarWaitingDuration)
                  .scaleXY(begin: 3, end: 1)
                  .slide(begin: const Offset(-4, 6), end: Offset.zero);
            },
          ),
        ),
        const SizedBox(width: 25),
      ],
    );
  }
}
