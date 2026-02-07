import 'package:get/get.dart';

import '../screens/auth/dashboard_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/otp_screen.dart';

/// Central route names. Use these instead of raw strings.
abstract class AppRoutes {
  AppRoutes._();

  static const String login = '/login';
  static const String otp = '/otp';
  static const String dashboard = '/dashboard';
}

/// All app routes. Used by [GetMaterialApp] in [main.dart].
final List<GetPage<dynamic>> appPages = [
  GetPage(
    name: AppRoutes.login,
    page: () => LoginScreen(),
  ),
  GetPage(
    name: AppRoutes.otp,
    page: () => const OtpScreen(),
  ),
  GetPage(
    name: AppRoutes.dashboard,
    page: () => const DashboardScreen(),
  ),
];
