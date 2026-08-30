import 'package:hive_flutter/hive_flutter.dart';
import '../models/goal.dart';
import '../models/learning_note.dart';
import '../models/quest.dart';
import '../models/quest_item.dart';

/// Box names, centralized so every service/screen references the same
/// literal string instead of scattering magic strings around the codebase.
class HiveBoxes {
  HiveBoxes._();
  static const String goals = 'goals_box';
  static const String settings = 'settings_box';
  static const String quests = 'quests_box';
}

/// Handles one-time Hive setup: init, adapter registration, and opening the
/// boxes the rest of the app depends on. Call [HiveService.init] once,
/// before runApp, in main.dart.
class HiveService {
  HiveService._();

  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;

    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(GoalAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(LearningNoteAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(QuestAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(QuestItemAdapter());
    }

    await Hive.openBox<Goal>(HiveBoxes.goals);
    await Hive.openBox(HiveBoxes.settings);
    await Hive.openBox<Quest>(HiveBoxes.quests);

    _initialized = true;
  }

  static Box<Goal> get goalsBox => Hive.box<Goal>(HiveBoxes.goals);
  static Box get settingsBox => Hive.box(HiveBoxes.settings);
  static Box<Quest> get questsBox => Hive.box<Quest>(HiveBoxes.quests);
}
