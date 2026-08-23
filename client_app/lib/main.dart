import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'providers/theme_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/transaction_provider.dart';
import 'services/auth_service.dart';
import 'services/local_storage_service.dart';
import 'services/transaction_cloud_service.dart';
import 'repository/user_repository.dart';
import 'repository/transaction_repository.dart';
import 'utils/app_router.dart';
import 'providers/savings_provider.dart';
import 'services/savings_cloud_service.dart';
import 'repository/savings_repository.dart';
import 'providers/subscription_provider.dart';
import 'services/subscription_api_service.dart';
import 'repository/subscription_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await LocalStorageService.init();
  runApp(const PocketKhorochApp());
}

class PocketKhorochApp extends StatelessWidget {
  const PocketKhorochApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ---- Dependency Injection: services → repositories → providers ----
    final authService = AuthService();
    final userRepository = UserRepository();

    final localStorageService = LocalStorageService();
    final transactionCloudService = TransactionCloudService();
    final subscriptionApiService =
        MockSubscriptionApiService(); // swap to BdAppsSubscriptionApiService later
    final subscriptionRepository = SubscriptionRepository(
      apiService: subscriptionApiService,
    );

    final transactionRepository = TransactionRepository(
      localService: localStorageService,
      cloudService: transactionCloudService,
    );
    final savingsCloudService = SavingsCloudService();
    final savingsRepository = SavingsRepository(
      localService: localStorageService,
      cloudService: savingsCloudService,
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            authService: authService,
            userRepository: userRepository,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => TransactionProvider(repository: transactionRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => SavingsProvider(repository: savingsRepository),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              SubscriptionProvider(repository: subscriptionRepository),
        ),
      ],
      child: Consumer2<ThemeProvider, AuthProvider>(
        builder: (context, themeProvider, authProvider, _) {
          return MaterialApp.router(
            title: 'Pocket Khoroch',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            routerConfig: AppRouter.buildRouter(authProvider),
          );
        },
      ),
    );
  }
}
