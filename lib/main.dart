import 'package:flutter/material.dart';

import 'constants.dart';
import 'routes/app_routes.dart';
import 'backend/services/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

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