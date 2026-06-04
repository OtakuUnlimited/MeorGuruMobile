import 'package:flutter/material.dart';

import '../frontend/pages/home_screen.dart';
import '../frontend/pages/login_screen.dart';
import '../frontend/pages/register_screen.dart';
import '../frontend/pages/profile_screen.dart';
// import '../frontend/pages/decoration_services_screen.dart';
import '../frontend/pages/find_gurus_screen.dart';
import '../frontend/pages/services_details_screen.dart';
import '../frontend/pages/services_page_screen.dart';

// New E-Commerce Page Imports
import '../frontend/pages/shop_screen.dart';
import '../frontend/pages/item_detail_screen.dart';
import '../frontend/pages/cart_screen.dart';
import '../frontend/pages/checkout_screen.dart';

class AppRoutes {
  static const home = '/';
  static const login = '/login';
  static const register = '/register';
  static const profile = '/profile';
  // static const decorationServices = '/decoration-services';
  static const guru = '/guru';

  // New E-Commerce Named Route Strings
  static const shop = '/shop';
  static const itemDetail = '/item-detail';
  static const cart = '/cart';
  static const checkout = '/checkout';
  static const serviceDetails = '/service-details';
  static const services = '/services';
  
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
  switch (settings.name) {

    case serviceDetails:
      final slug = settings.arguments as String;

      return MaterialPageRoute(
        builder: (_) => ServicesDetailsScreen(slug: slug),
      );

    case services:
      final args = settings.arguments as Map;
      final slug = args['slug'];
      final title = args['title'];

      return MaterialPageRoute(
        builder: (_) => ServicesPageScreen(
          slug: slug,
          // optional: title: title,
        ),
      );

    default:
      return null;
  }
}

  static Map<String, WidgetBuilder> routes = {
    home: (_) => const HomeScreen(),
    login: (_) => const LoginScreen(),
    register: (_) => const RegisterScreen(),
    profile: (_) => const ProfileScreen(),
    // decorationServices: (_) => const DecorationServicesScreen(),
    guru: (_) => const FindGurusScreen(),
    // Services Detail Route


    // New E-Commerce View Mapping
    shop: (_) => const ShopScreen(),
    itemDetail: (_) => const ItemDetailScreen(),
    cart: (_) => const CartScreen(),
    checkout: (_) => const CheckOutScreen(),
  };
}