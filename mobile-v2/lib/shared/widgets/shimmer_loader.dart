import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/theme/colors.dart';

class ShimmerLoader extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerLoader({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.backgroundTertiary,
      highlightColor: AppColors.backgroundSecondary.withOpacity(0.5),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.backgroundTertiary,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class ShimmerCard extends StatelessWidget {
  const ShimmerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ShimmerLoader(width: double.infinity, height: 100, borderRadius: 8),
          const SizedBox(height: 12),
          ShimmerLoader(width: MediaQuery.of(context).size.width * 0.6, height: 16, borderRadius: 4),
          const SizedBox(height: 8),
          ShimmerLoader(width: MediaQuery.of(context).size.width * 0.4, height: 14, borderRadius: 4),
        ],
      ),
    );
  }
}

class ShimmerTrackTile extends StatelessWidget {
  const ShimmerTrackTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        children: [
          const ShimmerLoader(width: 56, height: 56, borderRadius: 8),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerLoader(width: MediaQuery.of(context).size.width * 0.5, height: 16, borderRadius: 4),
                const SizedBox(height: 8),
                ShimmerLoader(width: MediaQuery.of(context).size.width * 0.3, height: 14, borderRadius: 4),
              ],
            ),
          ),
          const ShimmerLoader(width: 40, height: 40, borderRadius: 20),
        ],
      ),
    );
  }
}
