﻿## [1.2.1] - 2025-07-13 17:10:21

### Change type: patch
Pure frontend responsive UI - no backend changes

## [1.2.0] - 2025-07-13 17:04:50

### Change type: minor
Responsive UI - hide Chinese text on mobile, show on tablet+

## [1.1.4] - 2025-07-13 16:32:20

### Change type: patch
Fix test issues - all tests now pass

## [1.1.3] - 2025-07-13 16:01:27

### Change type: patch
Fix all BuildContext async issues - clean code analysis

## [1.1.2] - 2025-07-13 14:58:23

### Change type: patch
Fix all code analysis issues for GitHub Actions

## [1.1.1] - 2025-07-13 14:51:59

### Change type: patch
Fix GitHub Actions build issues

## [1.1.0] - 2025-07-13 04:57:49

### Change type: minor
Android APK release

## [1.0.2] - 2025-07-13 04:52:15

### Change type: patch
功能描述

## [1.0.1] - 2025-07-13 04:18:50

### Change type: patch
Test version management system

# ??湔甇瑕

## [2.8.0] - 2025-07-13 04:00:00

### 霈憿?: minor
?啣??芸?摰??嚗?‵?亦?Ｖ??渲??帖?悅?澆?芸1?潛?蝛箸嚗迨??銝敺拙?銝????閮?

### ?啣??
- ???芸?摰??嚗?賣炎皜砌蒂憛怠蝣箏???獢?- ? ?閮剛??批??雿?嚗??箏銵＊蝷?- ? ?啣??蝞∠?蝟餌絞???潸極??
### ?銵??- ? 瘛餃??芸??蝞∠??單
- ?? ?蔭 Augment ???隞?- ?? 摰????瑼???

### ?辣霈
- `lib/providers/game_provider.dart` - ?啣??芸?摰??摩
- `lib/widgets/game_controls_widget.dart` - ?啣??芸?摰??????唬?撅
- `scripts/version-manager.ps1` - ?蝞∠??單
- `scripts/bump-version.ps1` - 敹恍??祆?啗??- `.augment/config.json` - Augment ???蝵?- `DEVELOPER_GUIDE.md` - ?????- `CHANGELOG.md` - ?甇瑕閮?

---

## ?蝞∠?隤芣?

### ??撘?- **?澆?**: `major.minor.patch+build`
- **?嗅?**: `2.8.0+1`

### ?憿?
- **patch**: ?航炊靽桀儔???寥?- **minor**: ?啣??賬?敺摰?- **major**: ?之霈??賭??澆捆

### 雿輻?蝞∠?撌亙
```bash
# Augment ?冽敹急?誘
bv "??膩"                    # 敹恍?patch ?湔
vm minor "?啣????"          # 摰?蝞∠?

# ???瑁??單
.\scripts\bump-version.ps1 "??膩"
.\scripts\version-manager.ps1 patch "靽桀儔?航炊"
```

### ?芸??湔??隞?1. `pubspec.yaml` - Flutter ??
2. `lib/main.dart` - ?憿舐內?
3. `CHANGELOG.md` - ?祆?隞塚??甇瑕嚗?
---

*甇斗?隞嗥?蝞∠?撌亙?芸?蝬剛風*









