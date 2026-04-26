import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/apod_provider.dart';
import 'screens/main_shell.dart';
import 'theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const SpaceExplorerApp());
}

class SpaceExplorerApp extends StatelessWidget {
  const SpaceExplorerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ApodProvider()),
      ],
      child: MaterialApp(
        title: 'Explorador Espacial',
        debugShowCheckedModeBanner: false,
        locale: const Locale('pt', 'BR'),
        theme: AppTheme.darkTheme,
        home: const MainShell(),
      ),
    );
  }
}
