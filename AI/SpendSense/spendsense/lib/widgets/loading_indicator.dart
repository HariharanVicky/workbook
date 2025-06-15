import 'package:flutter/material.dart';

enum LoadingIndicatorStyle {
  circular,
  linear,
  shimmer,
}

class LoadingIndicator extends StatelessWidget {
  final LoadingIndicatorStyle style;
  final double? size;
  final Color? color;
  final String? message;

  const LoadingIndicator({
    super.key,
    this.style = LoadingIndicatorStyle.circular,
    this.size,
    this.color,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = color ?? theme.colorScheme.primary;

    switch (style) {
      case LoadingIndicatorStyle.circular:
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: size ?? 40,
                height: size ?? 40,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(effectiveColor),
                  strokeWidth: 3,
                ),
              ),
              if (message != null) ...[
                const SizedBox(height: 16),
                Text(
                  message!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onBackground.withOpacity(0.7),
                  ),
                ),
              ],
            ],
          ),
        );

      case LoadingIndicatorStyle.linear:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LinearProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(effectiveColor),
              backgroundColor: effectiveColor.withOpacity(0.2),
            ),
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(
                message!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onBackground.withOpacity(0.7),
                ),
              ),
            ],
          ],
        );

      case LoadingIndicatorStyle.shimmer:
        return ShimmerLoading(
          child: Container(
            width: size ?? double.infinity,
            height: size ?? 40,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
    }
  }
}

class ShimmerLoading extends StatefulWidget {
  final Widget child;

  const ShimmerLoading({
    super.key,
    required this.child,
  });

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
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
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.surface,
                Theme.of(context).colorScheme.surface.withOpacity(0.5),
                Theme.of(context).colorScheme.surface,
              ],
              stops: const [0.0, 0.5, 1.0],
              transform: _SlidingGradientTransform(
                slidePercent: _animation.value,
              ),
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  final double slidePercent;

  const _SlidingGradientTransform({
    required this.slidePercent,
  });

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * slidePercent, 0.0, 0.0);
  }
} 