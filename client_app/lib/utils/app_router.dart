import 'package:go_router/go_router.dart';
import '../pages/splash/splash_page.dart';
import '../pages/home/home_page.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomePage(),
      ),
      // Auth routes (login/signup) will be added in Module 3
    ],
  );
}