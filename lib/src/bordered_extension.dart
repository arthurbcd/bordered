import 'dart:math';

import 'package:flutter/rendering.dart';

import 'ui_radius.dart';

extension UiBorderRadiusExtension on BorderRadius {
  /// Returns the same as [BorderRadius] but with [depth] set to `1.0`.
  ///
  /// This essentialy converts each internal [Radius] to a [UiRadius].
  BorderRadius withDepth(double depth) {
    return BorderRadius.only(
      topLeft: topLeft.withDepth(depth),
      topRight: topRight.withDepth(depth),
      bottomLeft: bottomLeft.withDepth(depth),
      bottomRight: bottomRight.withDepth(depth),
    );
  }

  /// The angle of the [BorderRadius.topLeft].
  double get topLeftAngle => atan2(topLeft.y, topLeft.x);

  /// The angle of the [BorderRadius.topRight].
  double get topRightAngle => atan2(topRight.y, topRight.x);

  /// The angle of the [BorderRadius.bottomRight].
  double get bottomRightAngle => atan2(bottomRight.y, bottomRight.x);

  /// The angle of the [BorderRadius.bottomLeft].
  double get bottomLeftAngle => atan2(bottomLeft.y, bottomLeft.x);

  /// Creates a [Path] from the given [rect] and this [BorderRadius].
  ///
  /// The is compatible with [UiRadius]. Which enables it to use the
  /// [UiRadius.depth] property to control the depth of the border.
  ///
  Path getBorderedPath(
    Rect rect, {
    EdgeInsets edgeInsets = EdgeInsets.zero,
  }) {
    final path = Path();

    var edge = edgeInsets;

    // Top Left
    final tld = topLeft.depth.abs().clamp(0, 1).toDouble();

    edge = topLeft.depth.isNegative ? edgeInsets : EdgeInsets.zero;
    edge = edge * tld;
    var tlLeft = edgeInsets.left * tan(topLeftAngle) / 2;
    var tlTop = edgeInsets.top * tan(topLeftAngle) / 2;
    tlLeft = tlLeft - tld * tlLeft;
    tlTop = tlTop - tld * tlTop;

    final topLeftIn = rect.topLeft + Offset(-0, topLeft.y + edge.top + tlTop);
    final topLeftBegin = topLeftIn + Offset(-edge.left, -0);
    final topLeftEnd =
        rect.topLeft + Offset(topLeft.x + edge.left + tlLeft, -edge.top);
    final topLeftOut = topLeftEnd + Offset(0, edge.top);

    // Top Right
    final trd = topRight.depth.abs().clamp(0, 1).toDouble();
    edge = topRight.depth.isNegative ? edgeInsets : EdgeInsets.zero;
    edge = edge * trd;
    var trRight = edgeInsets.right * tan(topRightAngle) / 2;
    var trTop = edgeInsets.top * tan(topRightAngle) / 2;
    trRight = trRight - trd * trRight;
    trTop = trTop - trd * trTop;

    final topRightIn =
        rect.topRight + Offset(-topRight.x - edge.right - trRight, 0);
    final topRightBegin = topRightIn + Offset(0, -edge.top);
    final topRightEnd =
        rect.topRight + Offset(edge.right, topRight.y + edge.top + trTop);
    final topRightOut = topRightEnd + Offset(-edge.right, 0);

    // Bottom Right
    final brd = bottomRight.depth.abs().clamp(0, 1).toDouble();
    edge = bottomRight.depth.isNegative ? edgeInsets : EdgeInsets.zero;
    edge = edge * brd;
    var brRight = edgeInsets.right * tan(bottomRightAngle) / 2;
    var brBottom = edgeInsets.bottom * tan(bottomRightAngle) / 2;
    brRight = brRight - brd * brRight;
    brBottom = brBottom - brd * brBottom;

    final bottomRightIn =
        rect.bottomRight + Offset(0, -bottomRight.y - edge.bottom - brBottom);
    final bottomRightBegin = bottomRightIn + Offset(edge.right, 0);
    final bottomRightEnd = rect.bottomRight +
        Offset(-bottomRight.x - edge.right - brRight, edge.bottom);
    final bottomRightOut = bottomRightEnd + Offset(0, -edge.bottom);

    // Bottom Left
    final bld = bottomLeft.depth.abs().clamp(0, 1).toDouble();
    edge = bottomLeft.depth.isNegative ? edgeInsets : EdgeInsets.zero;
    edge = edge * bld;
    var blLeft = edgeInsets.left * tan(bottomLeftAngle) / 2;
    var blBottom = edgeInsets.bottom * tan(bottomLeftAngle) / 2;
    blLeft = blLeft - bld * blLeft;
    blBottom = blBottom - bld * blBottom;

    final bottomLeftIn =
        rect.bottomLeft + Offset(bottomLeft.x + edge.left + blLeft, 0);
    final bottomLeftBegin = bottomLeftIn + Offset(0, edge.bottom);
    final bottomLeftEnd = rect.bottomLeft +
        Offset(-edge.left, -bottomLeft.y - edge.bottom - blBottom);
    final bottomLeftOut = bottomLeftEnd + Offset(edge.left, 0);

    /// If [radius] is a [BoxRadius], then it will use it's [depth] value,
    /// otherwise `radius.depth` will use the default value of `1.0`.
    void drawBezierCurve(Offset start, Offset end, Radius radius) {
      final depth = radius is UiRadius ? radius.depth : 1.0;

      // final p = measureBezierDepth(start, end, depth);
      // path.cubicToPoint(end, p1: p.first, p2: p.last);

      final factor = (end - start) * depth.abs() * 0.552;

      // Filters negative and inverted values
      var sameSignal = factor.dx.isNegative == factor.dy.isNegative;
      if (depth < 0) sameSignal = !sameSignal;

      path.cubicToPoint(
        end,
        p1: sameSignal
            ? Offset(start.dx + factor.dx, start.dy)
            : Offset(start.dx, start.dy + factor.dy),
        p2: sameSignal
            ? Offset(end.dx, end.dy - factor.dy)
            : Offset(end.dx - factor.dx, end.dy),
      );
    }

    path.moveToPoint(topLeftIn);
    path.lineToPoint(topLeftBegin);
    drawBezierCurve(topLeftBegin, topLeftEnd, topLeft);
    path.lineToPoint(topLeftOut);

    path.lineToPoint(topRightIn);
    path.lineToPoint(topRightBegin);
    drawBezierCurve(topRightBegin, topRightEnd, topRight);
    path.lineToPoint(topRightOut);

    path.lineToPoint(bottomRightIn);
    path.lineToPoint(bottomRightBegin);
    drawBezierCurve(bottomRightBegin, bottomRightEnd, bottomRight);
    path.lineToPoint(bottomRightOut);

    path.lineToPoint(bottomLeftIn);
    path.lineToPoint(bottomLeftBegin);
    drawBezierCurve(bottomLeftBegin, bottomLeftEnd, bottomLeft);
    path.lineToPoint(bottomLeftOut);

    path.close();
    return Path.combine(PathOperation.intersect, Path()..addRect(rect), path);
  }
}

/// ? consider suggesting this to Flutter
extension UiBorderExtension on Border {
  /// Gets the insets of all [BorderSide.strokeInset] inside this.
  EdgeInsets get insets => EdgeInsets.fromLTRB(
        left.strokeInset,
        top.strokeInset,
        right.strokeInset,
        bottom.strokeInset,
      );

  /// Gets the outsets of all [BorderSide.strokeOutset] inside this.
  EdgeInsets get outsets => EdgeInsets.fromLTRB(
        left.strokeOutset,
        top.strokeOutset,
        right.strokeOutset,
        bottom.strokeOutset,
      );
}

/// ? consider suggesting this to Flutter
extension on Path {
  /// Same as [Path.cubicTo] but with [Offset] instead of [double] values.
  void cubicToPoint(Offset end, {required Offset p1, required Offset p2}) {
    cubicTo(p1.dx, p1.dy, p2.dx, p2.dy, end.dx, end.dy);
  }

  /// Same as [Path.moveTo] but with [Offset] instead of [double] values.
  void moveToPoint(Offset point) {
    moveTo(point.dx, point.dy);
  }

  /// Same as [Path.lineTo] but with [Offset] instead of [double] values.
  void lineToPoint(Offset point) {
    lineTo(point.dx, point.dy);
  }
}
