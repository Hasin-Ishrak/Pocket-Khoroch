import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../pages/splash/splash_page.dart';
import '../pages/home/home_page.dart';
import '../pages/auth/login_page.dart';
import '../pages/auth/signup_page.dart';
import '../pages/auth/forgot_password_page.dart';

class AppRouter {
  static GoRouter buildRouter(AuthProvider authProvider) {
    return GoRouter(
      initialLocation: '/',
      refreshListenable: authProvider,
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const SplashPage(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: '/signup',
          builder: (context, state) => const SignupPage(),
        ),
        GoRoute(
          path: '/forgot-password',
          builder: (context, state) => const ForgotPasswordPage(),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomePage(),
        ),
      ],
      redirect: (context, state) {
        final status = authProvider.status;
        final currentPath = state.matchedLocation;

        // Still checking auth status — stay on splash
        if (status == AuthStatus.unknown) {
          return currentPath == '/' ? null : '/';
        }

        final isAuthPage = currentPath == '/login' ||
            currentPath == '/signup' ||
            currentPath == '/forgot-password';

        if (status == AuthStatus.unauthenticated) {
          // Not logged in — force to login unless already on an auth page
          return isAuthPage ? null : '/login';
        }

        if (status == AuthStatus.authenticated) {
          // Logged in — send away from splash/auth pages to home
          if (currentPath == '/' || isAuthPage) {
            return '/home';
          }
        }

        return null; // no redirect needed
      },
    );
  }
}