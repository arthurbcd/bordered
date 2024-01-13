import 'dart:ui';

/// A [Radius] with a depth.
class UiRadius extends Radius {
  /// Same as [Radius.circular] but with [depth].
  const UiRadius.circular(super.radius, {this.depth = 1.0}) : super.circular();

  /// Same as [Radius.elliptical] but with [depth].
  const UiRadius.elliptical(super.x, super.y, {this.depth = 1.0})
      : super.elliptical();

  /// Same as [Radius.zero] but with [depth] set to `1.0`.
  static const UiRadius zero = UiRadius.circular(0.0);

  /// The depth of the radius.
  ///
  /// - `1.0`: Default rounded circle.
  /// - `0.0`: Chamfer line.
  /// - `-1.0`: Inverted rounded circle.
  final double depth;

  @override
  UiRadius clamp({Radius? minimum, Radius? maximum}) {
    return super.clamp(minimum: minimum, maximum: maximum).withDepth(depth);
  }

  @override
  Radius clampValues(
      {double? minimumX,
      double? minimumY,
      double? maximumX,
      double? maximumY}) {
    return super
        .clampValues(
            minimumX: minimumX,
            minimumY: minimumY,
            maximumX: maximumX,
            maximumY: maximumY)
        .withDepth(depth);
  }

  @override
  Radius operator -() => Radius.elliptical(-x, -y).withDepth(depth);

  @override
  Radius operator -(Radius other) =>
      Radius.elliptical(x - other.x, y - other.y).withDepth(depth);

  @override
  Radius operator +(Radius other) =>
      Radius.elliptical(x + other.x, y + other.y).withDepth(depth);

  @override
  Radius operator *(double operand) =>
      Radius.elliptical(x * operand, y * operand).withDepth(depth);

  @override
  Radius operator /(double operand) =>
      Radius.elliptical(x / operand, y / operand).withDepth(depth);

  @override
  Radius operator ~/(double operand) =>
      Radius.elliptical((x ~/ operand).toDouble(), (y ~/ operand).toDouble())
          .withDepth(depth);

  @override
  Radius operator %(double operand) =>
      Radius.elliptical(x % operand, y % operand).withDepth(depth);

  @override
  operator ==(Object other) {
    if (other is Radius) {
      return super == other && depth == other.depth;
    }
    return false;
  }

  @override
  int get hashCode => super.hashCode ^ depth.hashCode;

  /// Same as [Radius.lerp] but also interpolates the [depth] value.
  static UiRadius? lerp(Radius? a, Radius? b, double t) {
    return Radius.lerp(a, b, t)?.withDepth(lerpDouble(a?.depth, b?.depth, t)!);
  }

  @override
  String toString() {
    return x == y
        ? 'Radius.circular(${x.toStringAsFixed(1)}, depth: $depth)'
        : 'Radius.elliptical(${x.toStringAsFixed(1)}, '
            '${y.toStringAsFixed(1)}, depth: $depth)';
  }
}

extension on Radius {}

extension UiRadiusExtension on Radius {
  /// Creates a [UiRadius] with the same [x] and [y] values as this radius.
  UiRadius withDepth(double depth) {
    return UiRadius.elliptical(x, y, depth: depth);
  }

  /// The depth of the radius.
  ///
  /// - `1.0`: Default rounded circle.
  /// - `0.0`: Chamfer line.
  /// - `-1.0`: Inverted rounded circle.
  double get depth {
    if (this is UiRadius) {
      return (this as UiRadius).depth;
    }
    return 1.0;
  }
}
