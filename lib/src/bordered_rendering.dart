import 'package:flutter/rendering.dart';

import 'bordered_extension.dart';

class RenderBordered extends RenderBorderedBase {
  RenderBordered({
    super.border,
    super.borderRadius,
    super.shape,
    super.clipBehavior,
    super.elevation,
    super.shadowColor,
    super.textDirection,
    super.child,
  });

  @override
  void paint(PaintingContext context, Offset offset) {
    final Canvas canvas = context.canvas;
    final Rect rect = offset & size;
    var borderRadius = this.borderRadius?.resolve(textDirection);

    // limit border radius
    const min = Radius.zero;
    final max = Radius.elliptical(size.width, size.height) / 2;

    borderRadius = borderRadius?.copyWith(
      topLeft: borderRadius.topLeft.clamp(minimum: min, maximum: max),
      topRight: borderRadius.topRight.clamp(minimum: min, maximum: max),
      bottomLeft: borderRadius.bottomLeft.clamp(minimum: min, maximum: max),
      bottomRight: borderRadius.bottomRight.clamp(minimum: min, maximum: max),
    );

    // add background shadow
    if (elevation > 0) {
      canvas.drawShadow(
        shape == BoxShape.circle
            ? (Path()..addOval(rect))
            : borderRadius?.getBorderedPath(rect) ?? (Path()..addRect(rect)),
        shadowColor,
        elevation,
        true,
      );
    }

    // clip widget
    super.paint(context, offset);

    // add foreground border
    border?.paint(
      canvas,
      rect,
      shape: shape,
      borderRadius: borderRadius,
      textDirection: textDirection,
    );
  }
}

abstract class RenderBorderedBase extends RenderClipPath {
  RenderBorderedBase({
    BoxBorder? border,
    BorderRadiusGeometry? borderRadius,
    BoxShape shape = BoxShape.rectangle,
    double elevation = 0.0,
    Color shadowColor = const Color(0xFF000000),
    TextDirection? textDirection,
    super.clipBehavior,
    super.child,
  })  : _border = border,
        _borderRadius = borderRadius,
        _elevation = elevation,
        _shadowColor = shadowColor,
        _shape = shape,
        _textDirection = textDirection,
        super(clipper: borderRadius.clipper(textDirection, shape));

  /// The [clipper] property depends on [borderRadius] and [shape].
  void markNeedsClip() {
    super.clipper = borderRadius.clipper(textDirection, shape);
  }

  BoxBorder? get border => _border;
  BoxBorder? _border;
  set border(BoxBorder? value) {
    if (_border == value) return;
    _border = value;
    markNeedsPaint();
  }

  BorderRadiusGeometry? get borderRadius => _borderRadius;
  BorderRadiusGeometry? _borderRadius;
  set borderRadius(BorderRadiusGeometry? value) {
    if (_borderRadius == value) return;
    _borderRadius = value;
    markNeedsClip();
    markNeedsPaint();
  }

  BoxShape get shape => _shape;
  BoxShape _shape;
  set shape(BoxShape value) {
    if (_shape == value) return;
    _shape = value;
    markNeedsClip();
    markNeedsPaint();
  }

  double get elevation => _elevation;
  double _elevation;
  set elevation(double value) {
    if (_elevation == value) return;
    _elevation = value;
    markNeedsPaint();
  }

  Color get shadowColor => _shadowColor;
  Color _shadowColor;
  set shadowColor(Color value) {
    if (_shadowColor == value) return;
    _shadowColor = value;
    markNeedsPaint();
  }

  TextDirection? get textDirection => _textDirection;
  TextDirection? _textDirection;
  set textDirection(TextDirection? value) {
    if (_textDirection == value) return;
    _textDirection = value;
    markNeedsPaint();
  }
}

class _BorderedClipper extends CustomClipper<Path> {
  const _BorderedClipper({required this.borderRadius});
  final BorderRadius borderRadius;

  @override
  Path getClip(Size size) => borderRadius.getBorderedPath(Offset.zero & size);

  @override
  bool shouldReclip(_BorderedClipper oldClipper) {
    return borderRadius != oldClipper.borderRadius;
  }
}

class _CircleClipper extends CustomClipper<Path> {
  const _CircleClipper();
  @override
  Path getClip(Size size) => Path()..addOval(Offset.zero & size);

  @override
  bool shouldReclip(_CircleClipper oldClipper) => false;
}

extension on BorderRadiusGeometry? {
  CustomClipper<Path>? clipper(TextDirection? textDirection, BoxShape shape) {
    if (shape == BoxShape.circle) return const _CircleClipper();
    if (this == null) return null;
    return _BorderedClipper(borderRadius: this!.resolve(textDirection));
  }
}
