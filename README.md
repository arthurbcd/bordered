# Bordered Widget for Flutter

## Overview

The `Bordered` widget is a specialized Flutter widget designed for rendering advanced borders. It supports complex features like non-uniform border radius, adjustable border depth, variable border widths, and gradient colors.

## Features

- **Non-Uniform Border Radius**: Utilizes `UiRadius` for handling different border radii.
- **Adjustable Border Depth**: Control the depth of the border using `UiRadius.depth`.
- **Variable Border Width & Color**: `UiBorder` allows for non-uniform border widths and colors.
- **Gradient Borders**: Implement gradient colors in borders with `UiBorder.gradient`.
- **Shape and Shadow Control**: Customize the widget's shape, clip behavior, shadow elevation, and shadow color.
- **Animation Support**: Use `AnimatedBordered` for animating borders.

## Usage Example

```dart
Bordered(
  border: UiBorder.all(
    gradient: SweepGradient(...)
  ),
  borderRadius: BorderRadius.circular(20).withDepth(-1),
  child: ...
)
```
