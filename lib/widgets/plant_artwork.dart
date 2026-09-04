import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Animated plant artwork whose posture and color are controlled by [health].
class PlantArtwork extends StatelessWidget {
  const PlantArtwork({
    super.key,
    required this.health,
    this.potColorIndex = 0,
    this.size = 52,
    this.semanticLabel = 'Plant health illustration',
    this.animationDuration = const Duration(milliseconds: 600),
  });

  final double health;
  final int potColorIndex;
  final double size;
  final String semanticLabel;
  final Duration animationDuration;

  @override
  Widget build(BuildContext context) {
    final target = health.clamp(0.0, 1.0);
    return Semantics(
      image: true,
      label: semanticLabel,
      child: SizedBox.square(
        dimension: size,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 1, end: target),
          duration: animationDuration,
          curve: Curves.easeOutCubic,
          builder: (context, value, _) => CustomPaint(
            key: const ValueKey('plant-custom-paint'),
            painter: PlantPainter(health: value, potColorIndex: potColorIndex),
          ),
        ),
      ),
    );
  }
}

/// Draws a scalable potted plant in a 100-by-120 logical view box.
class PlantPainter extends CustomPainter {
  PlantPainter({required double health, this.potColorIndex = 0})
    : health = health.clamp(0.0, 1.0);

  final double health;
  final int potColorIndex;

  static const _leafPositions = <double>[.25, .38, .52, .66, .80, .92];
  static const _shedThreshold = .34;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    const designSize = Size(100, 120);
    final scale = math.min(
      size.width / designSize.width,
      size.height / designSize.height,
    );
    final offset = Offset(
      (size.width - designSize.width * scale) / 2,
      (size.height - designSize.height * scale) / 2,
    );

    canvas
      ..save()
      ..translate(offset.dx, offset.dy)
      ..scale(scale);

    final stem = _stemForHealth(health);
    _drawStem(canvas, stem);
    _drawLeaves(canvas, stem);
    _drawPot(canvas);
    if (health < _shedThreshold) _drawShedLeaf(canvas);

    canvas.restore();
  }

  _StemCurve _stemForHealth(double value) {
    final inverseHealth = 1 - value;
    return _StemCurve(
      base: const Offset(50, 88),
      control: Offset(
        _lerp(48, 65, inverseHealth),
        _lerp(50, 65, inverseHealth),
      ),
      tip: Offset(_lerp(50, 66, inverseHealth), _lerp(14, 45, inverseHealth)),
    );
  }

  void _drawStem(Canvas canvas, _StemCurve stem) {
    final path = Path()
      ..moveTo(stem.base.dx, stem.base.dy)
      ..quadraticBezierTo(
        stem.control.dx,
        stem.control.dy,
        stem.tip.dx,
        stem.tip.dy,
      );
    canvas.drawPath(
      path,
      Paint()
        ..color = Color.lerp(
          const Color(0xff795548),
          const Color(0xff397a45),
          health,
        )!
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.6
        ..strokeCap = StrokeCap.round,
    );
  }

  void _drawLeaves(Canvas canvas, _StemCurve stem) {
    for (var index = 0; index < _leafPositions.length; index++) {
      if (health < _shedThreshold && index.isOdd) continue;

      final side = index.isEven ? -1.0 : 1.0;
      final base = quadraticBezierPoint(
        stem.base,
        stem.control,
        stem.tip,
        _leafPositions[index],
      );
      final healthyAngle = side < 0 ? math.pi + .38 : -.38;
      final wiltedAngle = side < 0 ? math.pi - .88 : .88;
      final angle = _lerp(healthyAngle, wiltedAngle, 1 - health);
      final direction = Offset(math.cos(angle), math.sin(angle));
      final length = _lerp(12, 18, health);
      final width = _lerp(4.5, 7, health);
      final color = _leafColor(index);
      _drawLeaf(canvas, base, direction, length, width, color);
    }
  }

  void _drawLeaf(
    Canvas canvas,
    Offset base,
    Offset direction,
    double length,
    double width,
    Color color,
  ) {
    final tip = base + direction * length;
    final normal = Offset(-direction.dy, direction.dx);
    final middle = base + direction * (length * .48);
    final path = Path()
      ..moveTo(base.dx, base.dy)
      ..quadraticBezierTo(
        (middle + normal * width).dx,
        (middle + normal * width).dy,
        tip.dx,
        tip.dy,
      )
      ..quadraticBezierTo(
        (middle - normal * width).dx,
        (middle - normal * width).dy,
        base.dx,
        base.dy,
      )
      ..close();
    canvas.drawPath(path, Paint()..color = color);

    canvas.drawLine(
      base,
      tip - direction * 1.5,
      Paint()
        ..color = Color.lerp(color, const Color(0xff315c36), .35)!
        ..strokeWidth = 1
        ..strokeCap = StrokeCap.round,
    );
  }

  Color _leafColor(int index) {
    final base = health >= .5
        ? Color.lerp(
            const Color(0xffd5a52c),
            const Color(0xff429653),
            (health - .5) * 2,
          )!
        : Color.lerp(
            const Color(0xff81502f),
            const Color(0xffd5a52c),
            health * 2,
          )!;
    final shade = index.isEven ? .06 : -.06;
    return _shiftLightness(base, shade);
  }

  void _drawPot(Canvas canvas) {
    final potColor = potColorForIndex(potColorIndex);
    final body = Path()
      ..moveTo(31, 91)
      ..lineTo(69, 91)
      ..lineTo(63, 116)
      ..quadraticBezierTo(50, 120, 37, 116)
      ..close();
    canvas.drawPath(body, Paint()..color = potColor);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(27, 85, 46, 10),
        const Radius.circular(4),
      ),
      Paint()..color = _shiftLightness(potColor, .09),
    );
    canvas.drawOval(
      const Rect.fromLTWH(30, 84, 40, 7),
      Paint()..color = const Color(0xff553b2e),
    );
    canvas.drawArc(
      const Rect.fromLTWH(38, 101, 24, 12),
      0,
      math.pi,
      false,
      Paint()
        ..color = const Color(0x2bffffff)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  void _drawShedLeaf(Canvas canvas) {
    final wilted = _leafColor(1);
    _drawLeaf(
      canvas,
      const Offset(24, 114),
      const Offset(-.92, -.38),
      14,
      5,
      wilted,
    );
  }

  @override
  bool shouldRepaint(covariant PlantPainter oldDelegate) =>
      oldDelegate.health != health ||
      oldDelegate.potColorIndex != potColorIndex;
}

const plantPotColors = <Color>[
  Color(0xffb86f52),
  Color(0xff607d8b),
  Color(0xff718b69),
  Color(0xff85677b),
  Color(0xffb18a4b),
];

const plantPotColorNames = <String>[
  'Terracotta',
  'Slate blue',
  'Sage',
  'Plum',
  'Ochre',
];

Color potColorForIndex(int index) =>
    plantPotColors[index >= 0 && index < plantPotColors.length ? index : 0];

/// A point on a quadratic Bezier curve, sampled with De Casteljau's method.
@visibleForTesting
Offset quadraticBezierPoint(
  Offset start,
  Offset control,
  Offset end,
  double t,
) {
  final progress = t.clamp(0.0, 1.0);
  final first = Offset.lerp(start, control, progress)!;
  final second = Offset.lerp(control, end, progress)!;
  return Offset.lerp(first, second, progress)!;
}

class _StemCurve {
  const _StemCurve({
    required this.base,
    required this.control,
    required this.tip,
  });

  final Offset base;
  final Offset control;
  final Offset tip;
}

double _lerp(double start, double end, double progress) =>
    start + (end - start) * progress;

Color _shiftLightness(Color color, double amount) {
  final hsl = HSLColor.fromColor(color);
  return hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0)).toColor();
}
