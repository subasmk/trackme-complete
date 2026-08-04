import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../models/goal.dart';
import '../models/learning_note.dart';
import '../services/goal_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_theme.dart';
import '../theme/widget_themes.dart';

/// Opens a modal bottom sheet for editing [note]'s text, photo, and link.
/// Mirrors the "what did you learn today" flow's capabilities, just
/// pre-filled with what's already there. Editing never touches
/// streak/XP — see GoalService.editNote for why.
Future<void> showEditNoteSheet(
  BuildContext context, {
  required Goal goal,
  required LearningNote note,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
    ),
    builder: (context) => _EditNoteSheet(goal: goal, note: note),
  );
}

class _EditNoteSheet extends StatefulWidget {
  final Goal goal;
  final LearningNote note;
  const _EditNoteSheet({required this.goal, required this.note});

  @override
  State<_EditNoteSheet> createState() => _EditNoteSheetState();
}

class _EditNoteSheetState extends State<_EditNoteSheet> {
  late final TextEditingController _textController;
  late final TextEditingController _linkController;
  XFile? _newPickedImage;
  bool _imageRemoved = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.note.text);
    _linkController = TextEditingController(text: widget.note.linkUrl ?? '');
  }

  @override
  void dispose() {
    _textController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  bool get _hasImage => !_imageRemoved && (_newPickedImage != null || widget.note.imagePath != null);

  Future<void> _pickImage() async {
    try {
      final image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
        imageQuality: 85,
      );
      if (image != null) {
        setState(() {
          _newPickedImage = image;
          _imageRemoved = false;
        });
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open the photo picker')),
        );
      }
    }
  }

  Future<void> _save() async {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Note can\'t be empty')),
      );
      return;
    }

    setState(() => _saving = true);
    final linkText = _linkController.text.trim();
    await context.read<GoalService>().editNote(
          widget.goal,
          widget.note.id,
          text: text,
          newPickedImagePath: _newPickedImage?.path,
          removeImage: _imageRemoved,
          linkUrl: linkText.isEmpty ? null : linkText,
          removeLink: linkText.isEmpty,
        );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = WidgetThemes.byId(widget.goal.themeId);

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Edit Note', style: AppTextStyles.title),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: _textController,
                maxLines: 6,
                minLines: 3,
                autofocus: true,
                style: AppTextStyles.body,
                decoration: const InputDecoration(hintText: 'What did you learn?'),
              ),
              const SizedBox(height: AppSpacing.sm),

              if (_hasImage) ...[
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      child: _newPickedImage != null
                          ? Image.file(File(_newPickedImage!.path),
                              height: 140, width: double.infinity, fit: BoxFit.cover)
                          : Image.file(File(widget.note.imagePath!),
                              height: 140, width: double.infinity, fit: BoxFit.cover),
                    ),
                    Positioned(
                      top: 6,
                      right: 6,
                      child: InkWell(
                        onTap: () => setState(() {
                          _newPickedImage = null;
                          _imageRemoved = true;
                        }),
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                              color: Colors.black54, shape: BoxShape.circle),
                          child: const Icon(Icons.close, color: Colors.white, size: 16),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
              ],

              TextField(
                controller: _linkController,
                style: AppTextStyles.body,
                keyboardType: TextInputType.url,
                decoration: const InputDecoration(
                  hintText: 'Link (optional)',
                  prefixIcon: Icon(Icons.link, color: AppColors.textMuted, size: 20),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),

              TextButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.photo_outlined, size: 18),
                label: Text(_hasImage ? 'Change Photo' : 'Add Photo'),
                style: TextButton.styleFrom(foregroundColor: theme.mid),
              ),
              const SizedBox(height: AppSpacing.sm),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _saving ? null : () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saving ? null : _save,
                      style: ElevatedButton.styleFrom(backgroundColor: theme.mid),
                      child: _saving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2.2, color: Colors.white),
                            )
                          : const Text('Save'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
