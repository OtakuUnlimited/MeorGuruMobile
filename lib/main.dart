import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart'
    as stripe;

import 'constants.dart';
import 'routes/app_routes.dart';
import 'backend/services/auth_service.dart';
import 'backend/services/cart_notifier.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Stripe publishable key.
  // A pk_test key is safe for client-side use.
  stripe.Stripe.publishableKey =
      'pk_test_51S00QKJlpluk7DSJU4VqhUGOrlt0hznAS3atQjUhPkjllkvvWEIBOYRV8dWoM9N8YW1lo4jqYZqNexCtIdMjeQOY00LA99ZWHJ';

  stripe.Stripe.urlScheme = 'meroguru';

  await stripe.Stripe.instance
      .applySettings();

  // Restore the saved token before making
  // any authenticated API request.
  await AuthService.initializeAuth();

  final isLoggedIn =
      await AuthService.isLoggedIn();

  if (isLoggedIn) {
    await cartNotifier.refresh();
  } else {
    cartNotifier.clearAfterLogout();
  }

  runApp(const MeroGuruApp());
}

class MeroGuruApp extends StatelessWidget {
  const MeroGuruApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mero Guru',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        primaryColor:
            AppColors.orangeMain,
        scaffoldBackgroundColor:
            AppColors.bg,
        fontFamily: 'Roboto',
        colorScheme:
            ColorScheme.fromSeed(
          seedColor:
              AppColors.orangeMain,
        ),
        useMaterial3: true,
      ),

      initialRoute: AppRoutes.home,
      routes: AppRoutes.routes,
      onGenerateRoute:
          AppRoutes.onGenerateRoute,
    );
  }
}