import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Pure Flutter animated shimmer effect container (0 third-party packages)
class LoadingShimmer extends StatefulWidget {
  final Widget child;
  final Color baseColor;
  final Color highlightColor;
  final Duration duration;

  const LoadingShimmer({
    super.key,
    required this.child,
    this.baseColor = AppTheme.surfaceCard,
    this.highlightColor = AppTheme.surfaceElevated,
    this.duration = const Duration(milliseconds: 1400),
  });

  @override
  State<LoadingShimmer> createState() => _LoadingShimmerState();
}

class _LoadingShimmerState extends State<LoadingShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            final progress = _controller.value;
            final gradient = LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                widget.baseColor,
                widget.highlightColor,
                widget.baseColor,
              ],
              stops: [
                (progress - 0.3).clamp(0.0, 1.0),
                progress.clamp(0.0, 1.0),
                (progress + 0.3).clamp(0.0, 1.0),
              ],
            );
            return gradient.createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// Generic skeleton placeholder box
class ShimmerBox extends StatelessWidget {
  final double? width;
  final double height;
  final BorderRadius? borderRadius;
  final Color? color;

  const ShimmerBox({
    super.key,
    this.width,
    required this.height,
    this.borderRadius,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color ?? AppTheme.surfaceElevated,
        borderRadius: borderRadius ?? AppTheme.roundedSm,
      ),
    );
  }
}

/// Skeleton placeholder matching the ShopEase Product Card layout
class ProductCardSkeleton extends StatelessWidget {
  const ProductCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: LoadingShimmer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image frame
            Expanded(
              child: Container(
                color: AppTheme.surfaceElevated,
              ),
            ),
            // Details frame
            Padding(
              padding: const EdgeInsets.all(AppTheme.space12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const ShimmerBox(width: 60, height: 10),
                  const SizedBox(height: AppTheme.space8),
                  const ShimmerBox(width: double.infinity, height: 12),
                  const SizedBox(height: AppTheme.space6),
                  const ShimmerBox(width: 100, height: 12),
                  const SizedBox(height: AppTheme.space12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const ShimmerBox(width: 70, height: 16),
                      ShimmerBox(
                        width: 28,
                        height: 28,
                        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
