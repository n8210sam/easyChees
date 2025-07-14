import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sudoku_app/providers/game_provider.dart';
import 'package:sudoku_app/providers/settings_provider.dart';
import 'package:sudoku_app/screens/home_screen.dart';
import 'package:sudoku_app/utils/theme.dart';

void main() async {
  // 確保 Flutter 綁定初始化
  WidgetsFlutterBinding.ensureInitialized();

  // 強制直式顯示 (手機和平板)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // 開發環境版本號 Log (開發規範要求)
  // ignore: avoid_print
  print('🚀 === 數獨遊戲啟動 - 版本 v1.2.15+24 (醒目所選數字統一) === 🚀');

  // Additional debug info (only in debug mode)
  if (kDebugMode) {
    debugPrint('🔧 Debug Mode: 數獨遊戲開發環境');
    debugPrint('📱 Platform: ${defaultTargetPlatform.name}');
    debugPrint('🔒 強制直式顯示已啟用');
    debugPrint('🚀 Context7 MCP: 已集成最新代碼文檔支持');
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







