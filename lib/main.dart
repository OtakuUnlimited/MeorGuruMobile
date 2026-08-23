import 'package:flutter/material.dart';

import 'constants.dart';
import 'routes/app_routes.dart';
import 'backend/services/auth_service.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as stripe;
import 'backend/services/cart_notifier.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

   stripe.Stripe.publishableKey = "pk_test_51S00QKJlpluk7DSJU4VqhUGOrlt0hznAS3atQjUhPkjllkvvWEIBOYRV8dWoM9N8YW1lo4jqYZqNexCtIdMjeQOY00LA99ZWHJ";
  // Replace with your Stripe publishable key

  await stripe.Stripe.instance.applySettings();
  await cartNotifier.refresh();

  // Restore saved login token
  await AuthService.initializeAuth();

  runApp(const MeroGuruApp());
}

class MeroGuruApp extends StatelessWidget {
  const MeroGuruApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mero Guru',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        primaryColor: AppColors.orangeMain,
        scaffoldBackgroundColor: AppColors.bg,
        fontFamily: 'Roboto',
      ),

      initialRoute: AppRoutes.home,
      routes: AppRoutes.routes,
      onGenerateRoute: AppRoutes.onGenerateRoute,
    );
  }
}