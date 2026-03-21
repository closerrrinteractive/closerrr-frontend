import 'package:flutter/material.dart';

class SquareShimmer extends StatefulWidget {
  final double size;
  final Color baseColor;
  final Color highlightColor;
  final Duration duration;
  final bool isRectangle;

  const SquareShimmer(
      {super.key,
      this.size = 150,
      this.baseColor = const Color(0xFFE0E0E0),
      this.highlightColor = const Color(0xFFF5F5F5),
      this.duration = const Duration(milliseconds: 1500),
      this.isRectangle = false});

  @override
  State<SquareShimmer> createState() => _SquareShimmerState();
}

class _SquareShimmerState extends State<SquareShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();

    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.size * (widget.isRectangle ? 4 : 1),
          height: widget.size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                widget.baseColor,
                widget.highlightColor,
                widget.baseColor,
              ],
              stops: const [0.0, 0.5, 1.0],
              transform:
                  _SlidingGradientTransform(slidePercent: _animation.value),
            ),
          ),
        );
      },
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  final double slidePercent;

  const _SlidingGradientTransform({required this.slidePercent});

  @override
  Matrix4 transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * slidePercent, 0.0, 0.0);
  }
}
