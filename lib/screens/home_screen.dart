import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sudoku_app/models/sudoku_board.dart';
import 'package:sudoku_app/providers/game_provider.dart';
import 'package:sudoku_app/screens/game_screen.dart';
import 'package:sudoku_app/screens/game_records_screen.dart';
import 'package:sudoku_app/screens/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800), // 縮短動畫時間
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1), // 減少滑動距離
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
    ));

    // 延遲啟動動畫，避免與導航衝突
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('數獨遊戲'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo/Title with animation
            FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 1000),
                    tween: Tween(begin: 0.0, end: 1.0),
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Icon(
                          Icons.grid_3x3,
                          size: 100,
                          color: Theme.of(context).primaryColor,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '數獨',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '挑戰你的邏輯思維',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),

            // New Game Buttons with animation
            SlideTransition(
              position: _slideAnimation,
              child: Column(
                children: [
                  _buildDifficultyButton(
                    context,
                    '簡單',
                    Difficulty.easy,
                    Colors.green,
                    Icons.sentiment_satisfied,
                  ),
                  const SizedBox(height: 16),
                  _buildDifficultyButton(
                    context,
                    '中等',
                    Difficulty.medium,
                    Colors.orange,
                    Icons.sentiment_neutral,
                  ),
                  const SizedBox(height: 16),
                  _buildDifficultyButton(
                    context,
                    '困難',
                    Difficulty.hard,
                    Colors.red,
                    Icons.sentiment_dissatisfied,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // Continue Game Button
            Consumer<GameProvider>(
              builder: (context, gameProvider, child) {
                return FutureBuilder<bool>(
                  future: _hasSavedGame(),
                  builder: (context, snapshot) {
                    if (snapshot.data == true) {
                      return SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => _continueGame(context),
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('繼續遊戲'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                );
              },
            ),

            const SizedBox(height: 16),

            // Game Records Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _openGameRecords(context),
                icon: const Icon(Icons.history),
                label: const Text('遊戲記錄'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Settings Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _openSettings(context),
                icon: const Icon(Icons.settings),
                label: const Text('設定'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultyButton(
    BuildContext context,
    String title,
    Difficulty difficulty,
    Color color,
    IconData icon,
  ) {
    return SizedBox(
      width: double.infinity,
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 200),
        tween: Tween(begin: 1.0, end: 1.0),
        builder: (context, scale, child) {
          return Transform.scale(
            scale: scale,
            child: ElevatedButton.icon(
              onPressed: () => _startNewGame(context, difficulty),
              icon: Icon(icon),
              label: Text(title),
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
                elevation: 4,
                shadowColor: color.withValues(alpha: 0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _startNewGame(BuildContext context, Difficulty difficulty) {
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    final navigator = Navigator.of(context);

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    gameProvider.startNewGame(difficulty).then((_) {
      if (mounted) {
        navigator.pop(); // Close loading dialog
        navigator.push(
          MaterialPageRoute(
            builder: (context) => const GameScreen(),
          ),
        );
      }
    });
  }

  void _continueGame(BuildContext context) {
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    final navigator = Navigator.of(context);

    gameProvider.loadSavedGame().then((_) {
      if (mounted && gameProvider.currentBoard != null) {
        navigator.push(
          MaterialPageRoute(
            builder: (context) => const GameScreen(),
          ),
        );
      }
    });
  }

  Future<bool> _hasSavedGame() async {
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    return await gameProvider.storage.hasSavedGame();
  }

  void _openGameRecords(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const GameRecordsScreen(),
      ),
    );
  }

  void _openSettings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SettingsScreen(),
      ),
    );
  }
}
