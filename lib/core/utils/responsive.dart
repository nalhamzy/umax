import 'package:flutter/widgets.dart';

extension ResponsiveContext on BuildContext {
  /// Scales a value based on screen size. On tablets (shortest side ≥ 600dp)
  /// values are amplified ~1.4× so layouts don't look tiny.
  double s(double value) {
    final shortest = MediaQuery.sizeOf(this).shortestSide;
    final factor = shortest >= 600 ? 1.4 : 1.0;
    return value * factor;
  }

  double get screenW => MediaQuery.sizeOf(this).width;
  double get screenH => MediaQuery.sizeOf(this).height;
}

class ResponsiveContentBox extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  const ResponsiveContentBox({
    super.key,
    required this.child,
    this.maxWidth = 520,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
