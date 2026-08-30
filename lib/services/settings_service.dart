import 'package:flutter/foundation.dart';
import 'hive_service.dart';

/// Small persisted settings that aren't goal-specific: the user's display
/// name (used in "Keep going, {name}!") and whether onboarding has been
/// shown yet. Backed by a plain untyped Hive box, so no adapter is needed.
class SettingsService extends ChangeNotifier {
  static const String _keyUserName = 'user_name';
  static const String _keyOnboardingSeen = 'onboarding_seen';

  String _userName = 'Learner';
  bool _onboardingSeen = false;

  String get userName => _userName;
  bool get onboardingSeen => _onboardingSeen;

  SettingsService() {
    _load();
  }

  void _load() {
    final box = HiveService.settingsBox;
    _userName = (box.get(_keyUserName) as String?) ?? 'Learner';
    _onboardingSeen = (box.get(_keyOnboardingSeen) as bool?) ?? false;
  }

  Future<void> setUserName(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    _userName = trimmed;
    await HiveService.settingsBox.put(_keyUserName, trimmed);
    notifyListeners();
  }

  Future<void> markOnboardingSeen() async {
    _onboardingSeen = true;
    await HiveService.settingsBox.put(_keyOnboardingSeen, true);
    notifyListeners();
  }

  /// Called by BackupService after an import writes directly into the
  /// settings box (bypassing setUserName) — re-reads from disk and
  /// notifies listeners so the UI (and GoalService's widget-sync copy of
  /// the name, via main.dart's listener) picks up the restored name.
  void reloadFromDisk() {
    _load();
    notifyListeners();
  }
}
