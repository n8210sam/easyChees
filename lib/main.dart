import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sudoku_app/providers/game_provider.dart';
import 'package:sudoku_app/providers/settings_provider.dart';
import 'package:sudoku_app/screens/home_screen.dart';
import 'package:sudoku_app/utils/theme.dart';

void main() {
  // Only print in debug mode
  if (kDebugMode) {
    debugPrint('=== 數獨遊戲啟動 - 版本 v1.2.1 ===');
  }
  runApp(const SudokuApp());
}

class SudokuApp extends StatelessWidget {
  const SudokuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => SettingsProvider()..loadSettings()),
        ChangeNotifierProxyProvider<SettingsProvider, GameProvider>(
          create: (context) => GameProvider(),
          update: (context, settingsProvider, gameProvider) {
            gameProvider?.setSettingsProvider(settingsProvider);
            gameProvider?.updateHighlightSettings(); // 更新醒目設置
            return gameProvider ?? GameProvider();
          },
        ),
      ],
      child: MaterialApp(
        title: 'Sudoku App',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const HomeScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}







