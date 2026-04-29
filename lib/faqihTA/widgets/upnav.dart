import 'dart:ui';
import 'package:flutter/material.dart';

class UpNav extends StatelessWidget implements PreferredSizeWidget {
  final String profileUrl;
  final VoidCallback onMenuTap;
  final VoidCallback onProfileTap;

  const UpNav({
    super.key,
    required this.profileUrl,
    required this.onMenuTap,
    required this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = Colors.white;

    return Container(
      height: preferredSize.height,
      margin: const EdgeInsets.only(left: 18, right: 18, top: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(
                color: Colors.white.withOpacity(0.28),
                width: 1.4,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),

            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // MENU ICON
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: onMenuTap,
                  child: Icon(
                    Icons.menu_rounded,
                    color: iconColor,
                    size: 32,
                  ),
                ),

                // TITLE
                Text(
                  "Smart Curtain",
                  style: TextStyle(
                    color: iconColor,
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),

                // PROFILE ICON
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: onProfileTap,
                  child: CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.white.withOpacity(0.9),
                    backgroundImage:
                        profileUrl.isNotEmpty ? NetworkImage(profileUrl) : null,
                    child: profileUrl.isEmpty
                        ? Icon(Icons.person, color: Colors.grey.shade700)
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(80);
}
