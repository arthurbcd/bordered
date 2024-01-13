import 'dart:ui';

import 'package:animated_value/animated_value.dart';
import 'package:flutter/widgets.dart';

import 'bordered_widget.dart';
import 'ui_border.dart';
import 'ui_radius.dart';

typedef _BorderedValueBuilder = _BorderedValue Function(BuildContext context);

class AnimatedBordered extends AnimatedValue<_BorderedValueBuilder> {
  /// An animated widget specialized in rendering a border.
  AnimatedBordered({
    BoxBorder? border,
    BorderRadiusGeometry? borderRadius,
    BoxShape shape = BoxShape.rectangle,
    Clip clipBehavior = Clip.antiAlias,
    double elevation = 0.0,
    Color shadowColor = const Color(0xFF000000),
    super.key,
    super.curve,
    super.onEnd,
    required super.duration,
    super.child,
  }) : super(
          value: (ctx) => _BorderedValue(
            border: border,
            borderRadius: borderRadius?.resolve(Directionality.maybeOf(ctx)),
            shape: shape,
            clipBehavior: clipBehavior,
            elevation: elevation,
            shadowColor: shadowColor,
          ),
          lerp: (a, b, t) => (ctx) => _BorderedValue.lerp(a!(ctx), b!(ctx), t),
          builder: (context, valueBuilder, __) {
            final value = valueBuilder(context);
            return Bordered(
              border: value.border,
              borderRadius: value.borderRadius,
              shape: value.shape,
              clipBehavior: value.clipBehavior,
              elevation: value.elevation,
              shadowColor: value.shadowColor,
              child: child,
            );
          },
        );
}

class _BorderedValue {
  final BoxBorder? border;
  final BorderRadius? borderRadius;
  final BoxShape shape;
  final Clip clipBehavior;
  final double elevation;
  final Color shadowColor;

  _BorderedValue({
    required this.border,
    required this.borderRadius,
    required this.shape,
    required this.clipBehavior,
    required this.elevation,
    required this.shadowColor,
  });

  static _BorderedValue lerp(
    _BorderedValue? a,
    _BorderedValue? b,
    double t,
  ) {
    return _BorderedValue(
      border: UiBorder.lerp(a?.border, b?.border, t),
      borderRadius: () {
        final it = a?.borderRadius;
        final other = b?.borderRadius;
        if (it == null && other == null) return null;

        return BorderRadius.only(
          topLeft: UiRadius.lerp(it?.topLeft, other?.topLeft, t)!,
          topRight: UiRadius.lerp(it?.topRight, other?.topRight, t)!,
          bottomLeft: UiRadius.lerp(it?.bottomLeft, other?.bottomLeft, t)!,
          bottomRight: UiRadius.lerp(it?.bottomRight, other?.bottomRight, t)!,
        );
      }(),
      shape: t < 0.5 ? a!.shape : b!.shape,
      clipBehavior: t < 0.5 ? a!.clipBehavior : b!.clipBehavior,
      elevation: lerpDouble(a?.elevation, b?.elevation, t)!,
      shadowColor: Color.lerp(a?.shadowColor, b?.shadowColor, t)!,
    );
  }
}
