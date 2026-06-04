import 'package:flutter/material.dart';

import '../../constants.dart';
import '../../backend/services/auth_service.dart';

import '../pages/login_screen.dart';
import '../pages/profile_screen.dart';
import 'hamburger_overlay.dart';

enum NavBarStyle {
  BrandedLight,
  DarkAuth,
  MinimalAccent,
  TransAuth,
}

class CustomTopNavBar extends StatelessWidget
    implements PreferredSizeWidget {
  final String title;
  final NavBarStyle style;
  final bool showMenu;
  final bool showBack;
  final bool showProfile;
  final List<Widget>? actions;

  const CustomTopNavBar({
    Key? key,
    required this.title,
    this.style = NavBarStyle.BrandedLight,
    this.showMenu = false,
    this.showBack = false,
    this.showProfile = false,
    this.actions,
  }) : super(key: key);

  void _openHamburgerMenu(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        barrierColor: Colors.black.withOpacity(0.4),
        pageBuilder: (context, _, __) => const HamburgerOverlay(),
        transitionsBuilder:
            (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  Future<void> _handleProfileTap(BuildContext context) async {
    final loggedIn = await AuthService.isLoggedIn();

    if (!context.mounted) return;

    if (loggedIn) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const ProfileScreen(),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Color appBarBgColor;
    Color iconAndTextColor;
    double elevationValue;

    switch (style) {
      case NavBarStyle.DarkAuth:
        appBarBgColor = Colors.black;
        iconAndTextColor = Colors.white;
        elevationValue = 0.0;
        break;

      case NavBarStyle.MinimalAccent:
        appBarBgColor = AppColors.orangeMain;
        iconAndTextColor = Colors.white;
        elevationValue = 2.0;
        break;

      case NavBarStyle.BrandedLight:
        appBarBgColor = Colors.white;
        iconAndTextColor = AppColors.textDark;
        elevationValue = 0.0;
        break;

      case NavBarStyle.TransAuth:
      default:
        appBarBgColor = Colors.transparent;
        iconAndTextColor = Colors.black;
        elevationValue = 0.0;
        break;
    }

    return AppBar(
      backgroundColor: appBarBgColor,
      elevation: elevationValue,
      centerTitle: true,
      iconTheme: IconThemeData(
        color: iconAndTextColor,
      ),
      leading: showBack
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            )
          : (showMenu
              ? IconButton(
                  icon: Icon(
                    Icons.menu,
                    color: iconAndTextColor,
                  ),
                  onPressed: () => _openHamburgerMenu(context),
                )
              : null),
      title: Text(
        title,
        style: TextStyle(
          color: style == NavBarStyle.BrandedLight
              ? AppColors.orangeMain
              : iconAndTextColor,
          fontWeight: FontWeight.bold,
          fontSize: 22,
        ),
      ),
      actions: [
        ...(actions ?? []),

        if (showProfile)
          IconButton(
            icon: Icon(
              Icons.account_circle,
              color: iconAndTextColor,
            ),
            onPressed: () => _handleProfileTap(context),
          ),
      ],
    );
  }

  @override
  Size get preferredSize =>
      const Size.fromHeight(kToolbarHeight);
}