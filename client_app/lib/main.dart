import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const PocketKhorochApp());
}

class PocketKhorochApp extends StatelessWidget {
  const PocketKhorochApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pocket Khoroch',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.teal,
      ),
      home: const Scaffold(
        body: Center(
          child: Text('Pocket Khoroch 🚀 Firebase Connected'),
        ),
      ),
    );
  }
}