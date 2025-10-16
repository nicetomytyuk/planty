import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/vase_provider.dart';
import 'screens/home_screen.dart';
import 'utils/theme.dart';

void main() {
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
