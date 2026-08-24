import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
import 'providers/chat_provider.dart';
import 'services/ai_service.dart';
import 'repository/chat_repository.dart';
import 'providers/reminder_provider.dart';
import 'services/notification_service.dart';
import 'services/reminder_cloud_service.dart';
import 'repository/reminder_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  if (kIsWeb) {
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: false,
    );
  }

  await LocalStorageService.init();
  await NotificationService.init();
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
    final aiService = AiService();
    final chatRepository = ChatRepository();
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

    final reminderCloudService = ReminderCloudService();
    final reminderRepository = ReminderRepository(
      localService: localStorageService,
      cloudService: reminderCloudService,
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
        ChangeNotifierProvider(
          create: (_) => ChatProvider(
            aiService: aiService,
            chatRepository: chatRepository,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => ReminderProvider(repository: reminderRepository),
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