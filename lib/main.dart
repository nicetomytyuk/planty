import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'bootstrap/supabase_initializer.dart';
import 'providers/vase_provider.dart';
import 'screens/home_screen.dart';
import 'utils/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: '.env');
  } catch (error, stackTrace) {
    debugPrint('Failed to load environment variables: $error\n$stackTrace');
  }
  try {
    await initializeSupabase();
  } catch (error, stackTrace) {
    debugPrint('Supabase initialization failed: $error\n$stackTrace');
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => VaseProvider())],
      child: MaterialApp(
        title: 'Planty',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode:
            ThemeMode.system, // Automatically switch based on system settings
        home: const HomeScreen(),
      ),
    );
  }
}
