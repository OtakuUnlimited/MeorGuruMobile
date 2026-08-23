import 'package:flutter/material.dart';

import '../../constants.dart';
import '../../backend/services/auth_service.dart';
import '../../backend/services/cart_notifier.dart';
import '../../routes/app_routes.dart';
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
  final bool showSettings;
  final bool showBookings;
  final bool showCart;

  final List<Widget>? actions;

  const CustomTopNavBar({
    Key? key,
    required this.title,
    this.style = NavBarStyle.BrandedLight,
    this.showMenu = false,
    this.showBack = false,
    this.showProfile = false,
    this.showSettings = false,
    this.showBookings = false,
    this.showCart = false,
    this.actions,
  }) : super(key: key);

  // ============================================================
  // HAMBURGER MENU
  // ============================================================

  void _openHamburgerMenu(
    BuildContext context,
  ) {
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        barrierColor:
            Colors.black.withOpacity(0.4),
        pageBuilder:
            (context, _, __) =>
                const HamburgerOverlay(),
        transitionsBuilder:
            (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  // ============================================================
  // PROFILE
  // ============================================================

  Future<void> _handleProfileTap(
    BuildContext context,
  ) async {
    final loggedIn =
        await AuthService.isLoggedIn();

    if (!context.mounted) return;

    if (loggedIn) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              const ProfileScreen(),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              const LoginScreen(),
        ),
      );
    }
  }

  // ============================================================
  // CART
  // ============================================================

  Widget _buildCartButton(
    BuildContext context,
    Color iconAndTextColor,
  ) {
    return AnimatedBuilder(
    animation: cartNotifier,
    builder: (context, child) {
      final cartCount = cartNotifier.itemCount;
        return Stack(
          clipBehavior: Clip.none,
          children: [

            // ---------------- CART ICON ----------------

            IconButton(
              icon: Icon(
                Icons.shopping_cart_outlined,
                color: iconAndTextColor,
              ),
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.cart,
                );
              },
            ),

            // ---------------- BADGE ----------------

            if (cartCount > 0)
              Positioned(
                top: 6,
                right: 5,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ),
                  constraints:
                      const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  decoration:
                      BoxDecoration(
                    color:
                        AppColors.orangeMain,
                    borderRadius:
                        BorderRadius.circular(
                      10,
                    ),
                    border: Border.all(
                      color: Colors.white,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    cartCount > 9
                        ? '9+'
                        : cartCount.toString(),
                    style:
                        const TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight:
                          FontWeight.bold,
                    ),
                    textAlign:
                        TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    Color appBarBgColor;
    Color iconAndTextColor;
    double elevationValue;

    switch (style) {
      case NavBarStyle.DarkAuth:
        appBarBgColor = Colors.black;
        iconAndTextColor =
            Colors.white;
        elevationValue = 0.0;
        break;

      case NavBarStyle.MinimalAccent:
        appBarBgColor =
            AppColors.orangeMain;
        iconAndTextColor =
            Colors.white;
        elevationValue = 2.0;
        break;

      case NavBarStyle.BrandedLight:
        appBarBgColor = Colors.white;
        iconAndTextColor =
            AppColors.textDark;
        elevationValue = 0.0;
        break;

      case NavBarStyle.TransAuth:
      default:
        appBarBgColor =
            Colors.transparent;
        iconAndTextColor =
            Colors.black;
        elevationValue = 0.0;
        break;
    }

    return AppBar(
      backgroundColor:
          appBarBgColor,
      elevation: elevationValue,
      centerTitle: true,

      iconTheme: IconThemeData(
        color: iconAndTextColor,
      ),

      // ========================================================
      // LEADING
      // ========================================================

      leading: showBack
          ? IconButton(
              icon: const Icon(
                Icons.arrow_back,
              ),
              onPressed: () =>
                  Navigator.pop(
                context,
              ),
            )
          : (showMenu
              ? IconButton(
                  icon: Icon(
                    Icons.menu,
                    color:
                        iconAndTextColor,
                  ),
                  onPressed: () =>
                      _openHamburgerMenu(
                    context,
                  ),
                )
              : null),

      // ========================================================
      // TITLE
      // ========================================================

      title: Text(
        title,
        style: TextStyle(
          color: style ==
                  NavBarStyle.BrandedLight
              ? AppColors.orangeMain
              : iconAndTextColor,
          fontWeight:
              FontWeight.bold,
          fontSize: 22,
        ),
      ),

      // ========================================================
      // ACTIONS
      // ========================================================

      actions: [

        ...(actions ?? []),

        // ------------------------------------------------------
        // SETTINGS
        // ------------------------------------------------------

        if (showSettings)
          IconButton(
            icon: Icon(
              Icons.settings,
              color:
                  iconAndTextColor,
            ),
            onPressed: () {
              Navigator.pushNamed(
                context,
                AppRoutes.settings,
              );
            },
          ),

        // ------------------------------------------------------
        // CART
        // ------------------------------------------------------

        if (showCart)
          _buildCartButton(
            context,
            iconAndTextColor,
          ),

        // ------------------------------------------------------
        // BOOKINGS
        // ------------------------------------------------------

        if (showBookings)
          IconButton(
            icon: Icon(
              Icons
                  .calendar_month_outlined,
              color:
                  iconAndTextColor,
            ),
            onPressed: () {
              Navigator.pushNamed(
                context,
                AppRoutes.bookings,
              );
            },
          ),

        // ------------------------------------------------------
        // PROFILE
        // ------------------------------------------------------

        if (showProfile)
          IconButton(
            icon: Icon(
              Icons.account_circle,
              color:
                  iconAndTextColor,
            ),
            onPressed: () =>
                _handleProfileTap(
              context,
            ),
          ),
      ],
    );
  }

  @override
  Size get preferredSize =>
      const Size.fromHeight(
        kToolbarHeight,
      );
}