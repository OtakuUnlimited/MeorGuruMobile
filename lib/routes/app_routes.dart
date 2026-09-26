  import 'package:flutter/material.dart';

  import '../frontend/pages/home_screen.dart';
  import '../frontend/pages/login_screen.dart';
  import '../frontend/pages/register_screen.dart';
  import '../frontend/pages/profile_screen.dart';
  import '../frontend/pages/setting_screen.dart';
  import '../frontend/pages/support_help_screen.dart';
  // import '../frontend/pages/decoration_services_screen.dart';
  import '../frontend/pages/find_gurus_screen.dart';
  import '../frontend/pages/services_details_screen.dart';
  import '../frontend/pages/services_page_screen.dart';
  import '../frontend/pages/otp_verification_screen.dart';
  import '../frontend/pages/basic_details_screen.dart';
  import '../frontend/pages/blogs_screen.dart';
  import '../frontend/pages/blog_details.dart';

  import '../frontend/pages/patro_screen.dart';

  import '../frontend/pages/event_packages_screen.dart';
  import '../frontend/pages/event_packages_detail_screen.dart';
  import '../frontend/pages/event_packages_order_screen.dart';

  import '../frontend/pages/auspicious_calender.dart';


  // New E-Commerce Page Imports
  import '../frontend/pages/shop_screen.dart';
  import '../frontend/pages/item_detail_screen.dart';
  import '../frontend/pages/cart_screen.dart';
  import '../frontend/pages/checkout_screen.dart';
  import '../frontend/pages/puja_materials_screen.dart';

  import '../frontend/pages/booking_screen.dart';

  import '../frontend/pages/online_puja_screen.dart';
  import '../frontend/pages/online_puja_detail_screen.dart';
  import '../frontend/pages/online_puja_order_screen.dart';

  import '../frontend/pages/astrology_screen.dart';
  import '../frontend/pages/astrology_detail_screen.dart';
  import '../frontend/pages/astrology_order_screen.dart'; 

  import '../frontend/pages/forgot_password_screen.dart';

  class AppRoutes {
    static const home = '/';
    static const login = '/login';
    static const register = '/register';
    static const profile = '/profile';
    static const settings = '/settings';
    static const supportHelp = '/support-help';
    static const forgotPassword = '/forgot-password';
    // static const decorationServices = '/decoration-services';
    static const guru = '/guru';
    static const otpVerification = '/otp-verification';
    static const basicDetails = '/basic-details';
    static const blogs = '/blogs';
    static const blogDetails = '/blog-details';

    static const patro = '/patro';
    static const auspiciousCalender = '/auspicious-calender';

    static const String eventPackages = '/event-packages';
    static const String eventPackagesDetail = '/event-packages-detail';
    static const String eventPackagesOrder = '/event-packages-order';
    static const String astrology = '/astrology';
    static const String astrologyDetail = '/astrology-detail';
    static const String astrologyOrder = '/astrology-order';
    // New E-Commerce Named Route Strings
    static const shop = '/shop';
    static const itemDetail = '/item-detail';
    static const cart = '/cart';
    static const checkout = '/checkout';
    static const pujaMaterials = '/puja-materials';

    static const serviceDetails = '/service-details';
    static const services = '/services';
    static const String bookings = '/bookings';
    
    static const String onlinePuja = '/online-puja';
    static const String onlinePujaDetail = '/online-puja-detail';
    static const String onlinePujaOrder = '/online-puja-order';
    static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case blogDetails:
        final slug = settings.arguments as String;

        return MaterialPageRoute(
          builder: (_) => BlogDetailScreen(slug: slug),
        );
      case eventPackagesDetail:
        final slug = settings.arguments as String;

        return MaterialPageRoute(
          builder: (_) => EventPackagesDetailScreen(slug: slug),
        );
      case itemDetail:
        final slug = settings.arguments as String;

        return MaterialPageRoute(
          builder: (_) => ItemDetailScreen(slug: slug),
        );
      case astrologyDetail:
        final slug = settings.arguments as String;

        return MaterialPageRoute(
          builder: (_) => AstrologyDetailScreen(slug: slug),
        );

      case onlinePujaDetail:
        final slug = settings.arguments as String;

        return MaterialPageRoute(
          builder: (_) => OnlinePujaDetailScreen(slug: slug),
        );

      case eventPackagesOrder:
        final args = settings.arguments as Map<String, dynamic>;

        return MaterialPageRoute(
          builder: (_) => EventPackagesOrderScreen(
            eventPackageData: args,
          ),
        );

      case onlinePujaOrder:
        final args = settings.arguments as Map<String, dynamic>;

        return MaterialPageRoute(
          builder: (_) => OnlinePujaOrderScreen(
            pujaData: args,
          ),
        );

      case astrologyOrder:
      final args = settings.arguments as Map<String, dynamic>;

        return MaterialPageRoute(
          builder: (_) => AstrologyOrderScreen(
            astrologyData: args,
          ),
        );

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

        case otpVerification:
        final args =
            settings.arguments as Map<String, dynamic>;

        return MaterialPageRoute(
          builder: (_) => OtpVerificationScreen(
            userId: args['userId'],
            email: args['email'],
          ),
        );

      case basicDetails:
        final userId = settings.arguments as int;

        return MaterialPageRoute(
          builder: (_) => BasicDetailsScreen(
            userId: userId,
          ),
        );

        case forgotPassword:
    return MaterialPageRoute(
      builder: (_) =>
          const ForgotPasswordScreen(),
      settings: settings,
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
      settings: (_) => const SettingsScreen(),
      supportHelp: (_) => const SupportHelpScreen(),
      blogs: (_) => const BlogsScreen(),
      patro: (_) => const PatroScreen(),
      auspiciousCalender: (_) => const AuspiciousCalender(),
      // decorationServices: (_) => const DecorationServicesScreen(),
      guru: (_) => const FindGurusScreen(),
      astrology: (_) => const AstrologyScreen(),
      eventPackages: (_) => const EventPackagesScreen(),
      // Services Detail Route
      bookings: (_) => const BookingsScreen(),
      onlinePuja: (_) => const OnlinePujaScreen(),

      // New E-Commerce View Mapping
      shop: (_) => const ShopScreen(),
      cart: (_) => const CartScreen(),
      checkout: (_) => const CheckOutScreen(),
      pujaMaterials: (_) => const PujaMaterialsScreen(),
    };
  }