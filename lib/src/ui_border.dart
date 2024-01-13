import 'package:flutter/rendering.dart';

import 'bordered_extension.dart';
import 'ui_radius.dart';

/// A border that draws a gradient instead of a solid color.
class UiBorder extends Border {
  /// Creates a border that can be dashed, fully non-uniform and/or gradient.
  ///
  /// If [gradient] is present, then [top], [right], [bottom], and [left] colors
  /// are ignored. Otherwise, if the colors are non-uniform a [SweepGradient] is
  /// created from the colors of the sides.
  ///
  const UiBorder({
    this.gradient,
    super.top = BorderSide.none,
    super.right = BorderSide.none,
    super.bottom = BorderSide.none,
    super.left = BorderSide.none,
  });

  /// A uniform gradient border applied to all sides.
  const UiBorder.fromBorderSide(
    super.side, {
    this.gradient,
  }) : super.fromBorderSide();

  /// Creates a gradient border with symmetrical vertical and horizontal sides.
  const UiBorder.symmetric({
    this.gradient,
    super.vertical,
    super.horizontal,
  }) : super.symmetric();

  /// A uniform gradient border applied to all sides.
  UiBorder.all({
    Gradient? gradient,
    Color color = const Color(0xFF000000),
    double width = 1.0,
    BorderStyle style = BorderStyle.solid,
    double strokeAlign = BorderSide.strokeAlignInside,
  }) : this.fromBorderSide(
            gradient: gradient,
            BorderSide(
              color: color,
              width: width,
              style: style,
              strokeAlign: strokeAlign,
            ));

  /// The gradient used to draw the border.
  ///
  /// If [gradient] is present, then all [BorderSide.color] are ignored.
  final Gradient? gradient;

  /// A [BoxBorder.lerp] that also lerps [UiBorder.gradient].
  static BoxBorder? lerp(BoxBorder? a, BoxBorder? b, double t) {
    if (a == null && b == null) return null;

    if (a is Border? && b is Border?) {
      final border = Border.lerp(a, b, t)!;
      return UiBorder(
        gradient: () {
          if (a?.gradient == b?.gradient) return a?.gradient;

          final isLinear = (a?.gradient is LinearGradient) ||
              (b?.gradient is LinearGradient);

          // attempts to lerp an uniform color with a gradient
          Gradient? lerpColor(BoxBorder? border) {
            if (border == null || !border.isColorUniform) return null;
            final colors = [border.top.color, border.top.color];

            return isLinear
                ? LinearGradient(colors: colors)
                : SweepGradient(colors: colors);
          }

          return Gradient.lerp(
            a?.gradient ?? lerpColor(a),
            b?.gradient ?? lerpColor(b),
            t,
          );
        }(),
        top: border.top,
        right: border.right,
        bottom: border.bottom,
        left: border.left,
      );
    }
    return BoxBorder.lerp(a, b, t);
  }

  @override
  void paint(
    Canvas canvas,
    Rect rect, {
    TextDirection? textDirection,
    BoxShape shape = BoxShape.rectangle,
    BorderRadius? borderRadius,
  }) {
    paintNonUniformBordered(
      canvas,
      rect,
      shape: shape,
      borderRadius: borderRadius,
      textDirection: textDirection,
      gradient: gradient,
      top: top,
      right: right,
      bottom: bottom,
      left: left,
    );
  }

  /// Paints a border with a non-uniform colors.
  ///
  /// If [gradient] is present, then [top], [right], [bottom], and [left] colors
  /// are ignored. Otherwise, if the colors are non-uniform a [SweepGradient] is
  /// created from the colors of the sides.
  static void paintNonUniformBordered(
    Canvas canvas,
    Rect rect, {
    Gradient? gradient,
    required BorderRadius? borderRadius,
    required TextDirection? textDirection,
    BoxShape shape = BoxShape.rectangle,
    BorderSide top = BorderSide.none,
    BorderSide right = BorderSide.none,
    BorderSide bottom = BorderSide.none,
    BorderSide left = BorderSide.none,
  }) {
    final RRect borderRect;
    switch (shape) {
      case BoxShape.rectangle:
        borderRect = (borderRadius ?? BorderRadius.zero)
            .resolve(textDirection)
            // ? using custom RRect to avoid losing the UiRadius values
            ._toRRect(rect);
        break;
      case BoxShape.circle:
        assert(borderRadius == null,
            'A borderRadius cannot be given when shape is a BoxShape.circle.');
        borderRect = RRect.fromRectAndRadius(
          Rect.fromCircle(center: rect.center, radius: rect.shortestSide / 2.0),
          Radius.circular(rect.width),
        );
        break;
    }

    final border = Border(top: top, right: right, bottom: bottom, left: left);
    final inner = deflateUiRect(borderRect, border.insets);
    final outer = inflateUiRect(borderRect, border.outsets);

    Path getBorderPath(RRect rect, EdgeInsets edge) {
      return BorderRadius.only(
        topLeft: rect.tlRadius,
        topRight: rect.trRadius,
        bottomLeft: rect.blRadius,
        bottomRight: rect.brRadius,
      ).getBorderedPath(
        rect.outerRect,
        edgeInsets: edge,
      );
    }

    var path = Path.combine(
      PathOperation.difference,
      getBorderPath(outer, -border.outsets),
      getBorderPath(inner, border.insets),
    );

    final paint = Paint();

    if (gradient == null && border.isColorUniform) {
      // no need to use a gradient
      paint.color = top.color;
    } else {
      gradient ??= SweepGradient(
        colors: [right.color, bottom.color, left.color, top.color, right.color],
      );
      paint.shader = gradient.createShader(rect, textDirection: textDirection);
    }

    canvas.drawPath(path, paint);
  }

  /// Inflates the given [rect] by the given [insets].
  static RRect inflateUiRect(RRect rect, EdgeInsets insets) {
    Radius inflateRadius(Radius radius, double x, double y) {
      return (radius + Radius.elliptical(x, y)).clamp(minimum: Radius.zero);
    }

    return _RRect.fromLTRBAndCorners(
      rect.left - insets.left,
      rect.top - insets.top,
      rect.right + insets.right,
      rect.bottom + insets.bottom,
      topLeft: inflateRadius(rect.tlRadius, insets.left, insets.top),
      topRight: inflateRadius(rect.trRadius, insets.right, insets.top),
      bottomRight: inflateRadius(rect.brRadius, insets.right, insets.bottom),
      bottomLeft: inflateRadius(rect.blRadius, insets.left, insets.bottom),
    );
  }

  /// Deflates the given [rect] by the given [insets].
  static RRect deflateUiRect(RRect rect, EdgeInsets insets) {
    Radius deflateRadius(Radius radius, double x, double y) {
      return (radius - Radius.elliptical(x, y)).clamp(minimum: Radius.zero);
    }

    return _RRect.fromLTRBAndCorners(
      rect.left + insets.left,
      rect.top + insets.top,
      rect.right - insets.right,
      rect.bottom - insets.bottom,
      topLeft: deflateRadius(rect.tlRadius, insets.left, insets.top),
      topRight: deflateRadius(rect.trRadius, insets.right, insets.top),
      bottomRight: deflateRadius(rect.brRadius, insets.right, insets.bottom),
      bottomLeft: deflateRadius(rect.blRadius, insets.left, insets.bottom),
    );
  }

  @override
  bool operator ==(Object other) {
    return super == other && other is UiBorder && gradient == other.gradient;
  }

  @override
  int get hashCode => super.hashCode ^ gradient.hashCode;
}

extension on BoxBorder {
  bool get isColorUniform {
    final it = this;

    if (it is Border) {
      return it.top.color == it.left.color &&
          it.top.color == it.bottom.color &&
          it.top.color == it.right.color;
    }
    if (it is BorderDirectional) {
      return it.top.color == it.start.color &&
          it.top.color == it.bottom.color &&
          it.top.color == it.end.color;
    }

    return false;
  }

  Gradient? get gradient {
    if (this is UiBorder) {
      return (this as UiBorder).gradient;
    }
    return null;
  }
}

extension on BorderRadius {
  /// Same as [BorderRadius.toRRect] but doesn't desconstructs [Radius]. So we
  /// won't lose the [UiRadius] values.
  _RRect _toRRect(Rect rect) {
    return _RRect.fromLTRBAndCorners(
      rect.left,
      rect.top,
      rect.right,
      rect.bottom,
      topLeft: topLeft.clamp(minimum: Radius.zero),
      topRight: topRight.clamp(minimum: Radius.zero),
      bottomLeft: bottomLeft.clamp(minimum: Radius.zero),
      bottomRight: bottomRight.clamp(minimum: Radius.zero),
    );
  }
}

/// Custom [RRect] that doesn't desconstructs [Radius] into `x` and `y`.
///
/// Overrides the [Radius] getters so we won't lose the [UiRadius] values.
///
/// ? Consider creating a PR to Flutter so developers don't lose their custom
/// ? [Radius] values.
class _RRect extends RRect {
  _RRect.fromLTRBAndCorners(
    super.left,
    super.top,
    super.right,
    super.bottom, {
    super.topLeft = Radius.zero,
    super.topRight = Radius.zero,
    super.bottomLeft = Radius.zero,
    super.bottomRight = Radius.zero,
  })  : tlRadius = topLeft,
        trRadius = topRight,
        blRadius = bottomLeft,
        brRadius = bottomRight,
        super.fromLTRBAndCorners();

  @override
  final Radius tlRadius;

  @override
  final Radius trRadius;

  @override
  final Radius blRadius;

  @override
  final Radius brRadius;
}
