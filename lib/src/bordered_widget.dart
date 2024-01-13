import 'package:flutter/widgets.dart';

import 'animated_bordered.dart';
import 'bordered_rendering.dart';
import 'ui_border.dart';
import 'ui_radius.dart';

class Bordered extends SingleChildRenderObjectWidget {
  /// A widget specialized in rendering a border.
  ///
  /// It's additionaly compatible with [UiRadius] and [UiBorder]. Features that
  /// enable the creation of complex borders, such as:
  ///
  /// - [UiRadius] to handle non-uniform border radius.
  /// - [UiRadius.depth] to control the depth of the border.
  /// - [UiBorder] to handle non-uniform border width and color.
  /// - [UiBorder.gradient] to control the border color with a gradient.
  ///
  /// ```dart
  /// BorderedBox(
  ///  border: UiBorder.all(
  ///   gradient: SweepGradient(...)
  /// ),
  /// borderRadius: BorderRadius.circular(20).withDepth(-1),
  /// child: ...
  /// )
  /// ```
  ///
  /// Use [AnimatedBordered] to animate the border.
  ///
  const Bordered({
    super.key,
    this.border,
    this.borderRadius,
    this.shape = BoxShape.rectangle,
    this.clipBehavior = Clip.antiAlias,
    this.elevation = 0.0,
    this.shadowColor = const Color(0xFF000000),
    super.child,
  })  : assert(elevation >= 0.0),
        assert(shape != BoxShape.circle || borderRadius == null);

  /// The border to paint on foreground.
  ///
  /// Compatible with [UiBorder].
  final BoxBorder? border;

  /// The border radius to clip the [child], border and shadow.
  ///
  /// Compatible with [UiRadius].
  final BorderRadiusGeometry? borderRadius;

  /// The shape to be used. Ignored if [borderRadius] is non-null.
  final BoxShape shape;

  /// The clip behavior applied on [child].
  final Clip clipBehavior;

  /// The elevation of the shadow on background.
  final double elevation;

  /// The color of the shadow on background.
  final Color shadowColor;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderBordered(
      border: border,
      borderRadius: borderRadius,
      shape: shape,
      clipBehavior: clipBehavior,
      elevation: elevation,
      shadowColor: shadowColor,
      textDirection: Directionality.maybeOf(context),
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderBordered renderObject) {
    renderObject
      ..border = border
      ..borderRadius = borderRadius
      ..shape = shape
      ..clipBehavior = clipBehavior
      ..elevation = elevation
      ..shadowColor = shadowColor
      ..textDirection = Directionality.maybeOf(context);
  }
}
