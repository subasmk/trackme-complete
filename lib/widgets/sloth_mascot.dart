import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum SlothMood { idle, happy, celebrating }

/// The TrackMe sloth mascot, hand-painted with [CustomPainter] so it renders
/// crisply at any size without shipping an image asset.
///
/// Redesigned for more Duolingo-caliber charm: big cartoon eyes (white
/// sclera + dark pupil + highlight, not just a dark oval), a rounder
/// upper-body silhouette instead of a floating face, and posable arms that
/// change with [mood] — relaxed and hugging its branch when idle, one paw
/// raised when happy, both arms thrown up in a "hooray" when celebrating.
/// The branch is the sloth's own signature prop (sloths hang from
/// branches), used instead of borrowing any other mascot's specific pose.
class SlothMascot extends StatelessWidget {
  final double size;
  final SlothMood mood;
  final bool showGlow;

  const SlothMascot({
    super.key,
    this.size = 120,
    this.mood = SlothMood.idle,
    this.showGlow = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (showGlow)
            Container(
              width: size * 0.95,
              height: size * 0.95,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.mascotGlow(
                  opacity: mood == SlothMood.celebrating ? 0.5 : 0.3,
                ),
              ),
            ),
          CustomPaint(
            size: Size(size, size),
            painter: _SlothPainter(mood: mood),
          ),
        ],
      ),
    );
  }
}

class _SlothPainter extends CustomPainter {
  final SlothMood mood;
  _SlothPainter({required this.mood});

  static const _darkLine = Color(0xFF3A2618);
  static const _noseMouth = Color(0xFF4A2F1C);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final furPaint = Paint()..color = AppColors.slothFur;
    final outlinePaint = Paint()
      ..color = _darkLine
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.026
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final facePaint = Paint()..color = AppColors.slothFace;
    final patchPaint = Paint()..color = AppColors.slothEyePatch;

    // --- Branch: the sloth's signature prop, drawn first (background). ---
    final branchRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(w * 0.5, h * 0.90),
        width: w * 0.92,
        height: h * 0.075,
      ),
      Radius.circular(h * 0.04),
    );
    canvas.drawRRect(branchRect, Paint()..color = const Color(0xFF8B6F4E));
    canvas.drawRRect(
      branchRect,
      Paint()
        ..color = const Color(0xFF6B5236)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.012,
    );

    // --- Arms: simple thick rounded strokes, posed per mood. ---
    _drawArm(
      canvas,
      shoulder: Offset(w * 0.16, h * 0.52),
      hand: _leftHand(w, h),
      width: w * 0.15,
      strokeColor: _darkLine,
      strokeWidth: w * 0.02,
    );
    _drawArm(
      canvas,
      shoulder: Offset(w * 0.84, h * 0.52),
      hand: _rightHand(w, h),
      width: w * 0.15,
      strokeColor: _darkLine,
      strokeWidth: w * 0.02,
    );

    // --- Body: one rounded silhouette (chunkier than a plain face-circle,
    // suggesting shoulders/upper body like Duolingo-style mascots). ---
    final bodyRect = Rect.fromCenter(
      center: Offset(w * 0.5, h * 0.48),
      width: w * 0.80,
      height: h * 0.76,
    );
    canvas.drawOval(bodyRect, furPaint);
    canvas.drawOval(bodyRect, outlinePaint);

    // Ears
    final earY = h * 0.20;
    for (final dx in [w * 0.20, w * 0.80]) {
      canvas.drawCircle(Offset(dx, earY), w * 0.115, furPaint);
      canvas.drawCircle(Offset(dx, earY), w * 0.115, outlinePaint);
      canvas.drawCircle(
          Offset(dx, earY), w * 0.06, Paint()..color = AppColors.slothEyePatch.withOpacity(0.7));
    }

    // Cream face patch
    final faceRect = Rect.fromCenter(
      center: Offset(w * 0.5, h * 0.53),
      width: w * 0.58,
      height: h * 0.44,
    );
    canvas.drawOval(faceRect, facePaint);

    // Dark eye "mask" patches — a real sloth trait, and TrackMe's own
    // visual signature (distinct from any other app's mascot).
    final leftPatchCenter = Offset(w * 0.365, h * 0.475);
    final rightPatchCenter = Offset(w * 0.635, h * 0.475);
    canvas.drawOval(
      Rect.fromCenter(center: leftPatchCenter, width: w * 0.23, height: h * 0.27),
      patchPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: rightPatchCenter, width: w * 0.23, height: h * 0.27),
      patchPaint,
    );

    // Big cartoon eyes: white sclera + dark pupil + highlight, the single
    // biggest change from the old design — this is where personality lives.
    final eyeOpenness = switch (mood) {
      SlothMood.idle => 0.55,
      SlothMood.happy => 0.95,
      SlothMood.celebrating => 1.0,
    };
    _drawEye(canvas, leftPatchCenter, w * 0.078, eyeOpenness);
    _drawEye(canvas, rightPatchCenter, w * 0.078, eyeOpenness);

    // Nose
    final nosePath = Path()
      ..moveTo(w * 0.465, h * 0.575)
      ..quadraticBezierTo(w * 0.50, h * 0.615, w * 0.535, h * 0.575)
      ..quadraticBezierTo(w * 0.50, h * 0.60, w * 0.465, h * 0.575)
      ..close();
    canvas.drawPath(nosePath, Paint()..color = _noseMouth);

    // Mouth — a confident, bigger grin by default (idle already smiles;
    // happy/celebrating widen it further), matching Duolingo-style
    // exaggerated warmth rather than a subtle, realistic expression.
    final mouthPaint = Paint()
      ..color = _noseMouth
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.022
      ..strokeCap = StrokeCap.round;
    final mouthWidth = mood == SlothMood.idle ? w * 0.12 : w * 0.17;
    final mouthDrop = mood == SlothMood.idle ? h * 0.055 : h * 0.075;
    final mouthPath = Path()
      ..moveTo(w * 0.5, h * 0.615)
      ..quadraticBezierTo(
          w * 0.5 - mouthWidth, h * 0.615 + mouthDrop, w * 0.5 - mouthWidth * 0.25, h * 0.65)
      ..moveTo(w * 0.5, h * 0.615)
      ..quadraticBezierTo(
          w * 0.5 + mouthWidth, h * 0.615 + mouthDrop, w * 0.5 + mouthWidth * 0.25, h * 0.65);
    canvas.drawPath(mouthPath, mouthPaint);

    // Rosy cheeks
    final cheekPaint = Paint()..color = const Color(0x33FF8A65);
    canvas.drawCircle(Offset(w * 0.29, h * 0.585), w * 0.045, cheekPaint);
    canvas.drawCircle(Offset(w * 0.71, h * 0.585), w * 0.045, cheekPaint);

    // Little feet peeking out at the bottom, in front of the branch.
    final footPaint = Paint()..color = AppColors.slothFur;
    for (final dx in [w * 0.38, w * 0.62]) {
      canvas.drawCircle(Offset(dx, h * 0.885), w * 0.075, footPaint);
      canvas.drawCircle(Offset(dx, h * 0.885), w * 0.075, outlinePaint);
    }
  }

  /// Left-hand target position, per mood — idle rests near the branch,
  /// celebrating throws the arm straight up into the "hooray" pose.
  Offset _leftHand(double w, double h) => switch (mood) {
        SlothMood.idle => Offset(w * 0.30, h * 0.74),
        SlothMood.happy => Offset(w * 0.26, h * 0.70),
        SlothMood.celebrating => Offset(w * 0.10, h * 0.16),
      };

  /// Right-hand target — happy raises just this one paw (a friendly wave);
  /// celebrating mirrors the left arm up into "hooray".
  Offset _rightHand(double w, double h) => switch (mood) {
        SlothMood.idle => Offset(w * 0.70, h * 0.74),
        SlothMood.happy => Offset(w * 0.88, h * 0.20),
        SlothMood.celebrating => Offset(w * 0.90, h * 0.16),
      };

  void _drawArm(
    Canvas canvas, {
    required Offset shoulder,
    required Offset hand,
    required double width,
    required Color strokeColor,
    required double strokeWidth,
  }) {
    // Dark outline pass first (slightly thicker), then the fur color on
    // top — the same layering trick used for the body silhouette, so the
    // limb reads as a clean flat shape with a crisp edge.
    canvas.drawLine(
      shoulder,
      hand,
      Paint()
        ..color = strokeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = width + strokeWidth
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawLine(
      shoulder,
      hand,
      Paint()
        ..color = AppColors.slothFur
        ..style = PaintingStyle.stroke
        ..strokeWidth = width
        ..strokeCap = StrokeCap.round,
    );
    // Paw at the hand end.
    canvas.drawCircle(hand, width * 0.62, Paint()..color = AppColors.slothFur);
    canvas.drawCircle(
      hand,
      width * 0.62,
      Paint()
        ..color = strokeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth * 0.8,
    );
  }

  void _drawEye(Canvas canvas, Offset patchCenter, double scleraRadius, double openness) {
    final clampedOpen = openness.clamp(0.3, 1.0);
    final scleraRect = Rect.fromCenter(
      center: patchCenter,
      width: scleraRadius * 2,
      height: scleraRadius * 2 * clampedOpen,
    );
    canvas.drawOval(scleraRect, Paint()..color = Colors.white);

    final pupilRadius = scleraRadius * 0.52 * clampedOpen.clamp(0.55, 1.0);
    final pupilCenter = Offset(patchCenter.dx, patchCenter.dy + scleraRadius * 0.08);
    canvas.drawCircle(pupilCenter, pupilRadius, Paint()..color = const Color(0xFF2B1B10));

    final highlightRadius = pupilRadius * 0.32;
    canvas.drawCircle(
      Offset(pupilCenter.dx - pupilRadius * 0.35, pupilCenter.dy - pupilRadius * 0.35),
      highlightRadius,
      Paint()..color = Colors.white.withOpacity(0.9),
    );
  }

  @override
  bool shouldRepaint(covariant _SlothPainter oldDelegate) =>
      oldDelegate.mood != mood;
}
