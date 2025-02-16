import 'package:Foody/src/core/constants/assets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AnimatedAvatarWidget extends StatefulWidget {
  final Duration avatarPlayDuration;
  final Duration avatarWaitingDuration;

  const AnimatedAvatarWidget({
    Key? key,
    required this.avatarPlayDuration,
    required this.avatarWaitingDuration,
  }) : super(key: key);

  @override
  _AnimatedAvatarWidgetState createState() => _AnimatedAvatarWidgetState();
}

class _AnimatedAvatarWidgetState extends State<AnimatedAvatarWidget> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          debugPrint("Error fetching user data: ${snapshot.error}");
          return const CircleAvatar(
            radius: 30,
            backgroundColor: Colors.transparent,
            child: Icon(Icons.error, color: Colors.red),
          );
        }

        User? user = snapshot.data;
        String? profilePic = user?.photoURL;

        return CircleAvatar(
          radius: 30,
          backgroundColor: const Color.fromARGB(88, 255, 255, 255),
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
                : Image.asset(Assets.profileImage, fit: BoxFit.cover),
          ),
        )
            .animate()
            .scaleXY(
              begin: 0,
              end: 1.2,
              duration: widget.avatarPlayDuration,
              curve: Curves.easeInOutSine,
            )
            .then(delay: widget.avatarWaitingDuration)
            .scaleXY(begin: 1.5, end: 1)
            .slide(begin: const Offset(-3.5, 8), end: Offset.zero);
      },
    );
  }
}
