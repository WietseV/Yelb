import 'dart:math';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class TriangleActionButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Color fillColor;
  final Color borderColor;
  final double size;
  final double borderWidth;
  final double cornerCut;

  const TriangleActionButton({
    super.key,
    required this.child,
    this.onPressed,
    this.fillColor = AppColors.transparent,
    this.borderColor = AppColors.white24,
    this.size = 64,
    this.borderWidth = 1.5,
    this.cornerCut = 12,
  });

  @override
  Widget build(BuildContext context) {
    final shape = _TrapezoidTriangleBorder(
      side: BorderSide(color: borderColor, width: borderWidth),
      cornerCut: cornerCut,
    );
    final centroidShift = _centroidVerticalShift(size);

    return SizedBox(
      width: size,
      height: size,
      child: Material(
        color: fillColor,
        shape: shape,
        child: InkWell(
          customBorder: shape,
          onTap: onPressed,
          child: Center(
            child: Transform.translate(
              offset: Offset(0, centroidShift),
              child: child,
            ),
          ),
        ),
      ),
    );
  }

  double _centroidVerticalShift(double containerSize) {
    final triangleHeight = containerSize * sqrt(3) / 2;
    final verticalOffset = (containerSize - triangleHeight) / 2;
    final centroidY = verticalOffset + (2 * triangleHeight / 3);
    final centerY = containerSize / 2;
    return centroidY - centerY;
  }
}

class _TrapezoidTriangleBorder extends OutlinedBorder {
  final double cornerCut;

  const _TrapezoidTriangleBorder({
    required super.side,
    this.cornerCut = 12,
  });

  @override
  OutlinedBorder copyWith({BorderSide? side}) {
    return _TrapezoidTriangleBorder(
      side: side ?? this.side,
      cornerCut: cornerCut,
    );
  }

  @override
  ShapeBorder scale(double t) {
    return _TrapezoidTriangleBorder(
      side: side.scale(t),
      cornerCut: cornerCut * t,
    );
  }

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(side.width);

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final size = min(rect.width, rect.height);
    final triangleHeight = size * sqrt(3) / 2;
    final verticalOffset = (rect.height - triangleHeight) / 2;
    final topY = rect.top + verticalOffset;
    final baseY = topY + triangleHeight;
    final halfBase = size / 2;
    final centerX = rect.center.dx;

    final top = Offset(centerX, topY);
    final right = Offset(centerX + halfBase, baseY);
    final left = Offset(centerX - halfBase, baseY);

    final trimmed = _trimCorners([top, right, left]);
    final path = Path()..moveTo(trimmed.first.dx, trimmed.first.dy);
    for (var i = 1; i < trimmed.length; i++) {
      path.lineTo(trimmed[i].dx, trimmed[i].dy);
    }
    path.close();
    return path;
  }

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    final inset = side.width;
    return getOuterPath(rect.deflate(inset), textDirection: textDirection);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    if (side == BorderSide.none) return;
    final paint = side.toPaint();
    canvas.drawPath(getOuterPath(rect, textDirection: textDirection), paint);
  }

  List<Offset> _trimCorners(List<Offset> vertices) {
    final trimmed = <Offset>[];
    for (var i = 0; i < vertices.length; i++) {
      final prev = vertices[(i - 1 + vertices.length) % vertices.length];
      final corner = vertices[i];
      final next = vertices[(i + 1) % vertices.length];

      final toPrev = prev - corner;
      final toNext = next - corner;
      final cutPrev = min(cornerCut, toPrev.distance / 3);
      final cutNext = min(cornerCut, toNext.distance / 3);

      trimmed.add(_moveAlong(corner, prev, cutPrev));
      trimmed.add(_moveAlong(corner, next, cutNext));
    }
    return trimmed;
  }

  Offset _moveAlong(Offset from, Offset to, double distance) {
    final vector = to - from;
    final length = vector.distance;
    if (length == 0) return from;
    final t = distance / length;
    return Offset(from.dx + vector.dx * t, from.dy + vector.dy * t);
  }
}
