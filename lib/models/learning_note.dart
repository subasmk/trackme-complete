import 'package:hive/hive.dart';

part 'learning_note.g.dart';

@HiveType(typeId: 1)
class LearningNote extends HiveObject {
  @HiveField(0)
  String text;

  @HiveField(1)
  DateTime date;

  @HiveField(2)
  String id;

  /// Path to a photo attached to this note, copied into the app's own
  /// documents directory (so it survives even if the original gallery
  /// item is deleted) by GoalService.completeToday. Null if no photo.
  @HiveField(3)
  String? imagePath;

  /// A link the user attached to this note (e.g. a doc, article, or repo
  /// they were learning from). Null if none. Always normalized to include
  /// a scheme (https:// prepended if missing) before saving.
  @HiveField(4)
  String? linkUrl;

  LearningNote({
    required this.text,
    required this.date,
    required this.id,
    this.imagePath,
    this.linkUrl,
  });
}
