import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sudoku_app/providers/settings_provider.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _version = '載入中...';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _version = '版本 ${packageInfo.version}+${packageInfo.buildNumber}';
      });
    } catch (e) {
      setState(() {
        _version = '版本 1.2.1+10';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('設定'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(context, value),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'reset',
                child: Row(
                  children: [
                    Icon(Icons.restore),
                    SizedBox(width: 8),
                    Text('重置設定'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          if (!settingsProvider.isLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // 遊戲設定區塊
              _buildSectionHeader('遊戲設定'),
              _buildSettingTile(
                context,
                title: '醒目數字',
                subtitle: '開啟後，在選取數字時會強調所選數字',
                icon: Icons.highlight,
                value: settingsProvider.highlightSameNumbers,
                onChanged: settingsProvider.setHighlightSameNumbers,
              ),
              _buildSettingTile(
                context,
                title: '顯示計時器',
                subtitle: '在遊戲中顯示計時器',
                icon: Icons.timer,
                value: settingsProvider.showTimer,
                onChanged: settingsProvider.setShowTimer,
              ),
              _buildSettingTile(
                context,
                title: '自動保存',
                subtitle: '自動保存遊戲進度',
                icon: Icons.save,
                value: settingsProvider.autoSave,
                onChanged: settingsProvider.setAutoSave,
              ),

              const SizedBox(height: 24),

              // 音效與震動設定區塊
              _buildSectionHeader('音效與震動'),
              _buildSettingTile(
                context,
                title: '音效',
                subtitle: '填錯數字時播放警告音',
                icon: Icons.volume_up,
                value: settingsProvider.soundEnabled,
                onChanged: settingsProvider.setSoundEnabled,
              ),
              _buildSettingTile(
                context,
                title: '震動',
                subtitle: '填錯數字時觸發震動回饋',
                icon: Icons.vibration,
                value: settingsProvider.vibrationEnabled,
                onChanged: settingsProvider.setVibrationEnabled,
              ),

              const SizedBox(height: 24),

              // 醒目數字預覽
              if (settingsProvider.highlightSameNumbers) ...[
                _buildSectionHeader('醒目數字預覽'),
                _buildHighlightPreview(context),
                const SizedBox(height: 16),
              ],

              // 關於區塊
              _buildSectionHeader('關於'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '數獨遊戲',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _version,
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '一個簡潔優雅的數獨遊戲，支援三種難度等級和多種輔助功能。',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }

  Widget _buildSettingTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required Future<void> Function(bool) onChanged,
  }) {
    return Card(
      child: SwitchListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        secondary: Icon(icon),
        value: value,
        onChanged: onChanged,
        activeColor: Theme.of(context).primaryColor,
      ),
    );
  }



  Widget _buildHighlightPreview(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '當選擇數字 5 時的效果：',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildPreviewCell('3', false),
                _buildPreviewCell('5', true), // 高亮
                _buildPreviewCell('7', false),
                _buildPreviewCell('5', true), // 高亮
                _buildPreviewCell('1', false),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '相同數字會以背景色高亮顯示',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewCell(String number, bool isHighlighted) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: isHighlighted 
            ? Colors.blue.withValues(alpha: 0.2)
            : Colors.grey.withValues(alpha: 0.1),
        border: Border.all(
          color: isHighlighted 
              ? Colors.blue.withValues(alpha: 0.5)
              : Colors.grey.withValues(alpha: 0.3),
          width: isHighlighted ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: Text(
          number,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
            color: isHighlighted ? Colors.blue[700] : Colors.black87,
          ),
        ),
      ),
    );
  }

  void _handleMenuAction(BuildContext context, String action) {
    switch (action) {
      case 'reset':
        _showResetConfirmDialog(context);
        break;
    }
  }

  void _showResetConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('重置設定'),
        content: const Text('確定要將所有設定重置為預設值嗎？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await context.read<SettingsProvider>().resetAllSettings();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('設定已重置')),
                );
              }
            },
            child: const Text('確定'),
          ),
        ],
      ),
    );
  }
}
