import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';

class GlowingSlider extends StatelessWidget {
  final double value;
  final double min;
  final double max;
  final ValueChanged<double>? onChanged;
  final Color? activeColor;

  const GlowingSlider({
    super.key,
    required this.value,
    this.min = 0.0,
    this.max = 1.0,
    this.onChanged,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = activeColor ?? AppColors.accentPrimary;
    
    return SliderTheme(
      data: SliderThemeData(
        trackHeight: 4,
        activeTrackColor: color,
        inactiveTrackColor: AppColors.backgroundTertiary,
        thumbColor: color,
        overlayColor: color.withOpacity(0.2),
        thumbShape: _GlowingThumbShape(enabledThumbRadius: 8.0, color: color),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
      ),
      child: Slider(
        value: value,
        min: min,
        max: max,
        onChanged: onChanged,
      ),
    );
  }
}

class _GlowingThumbShape extends SliderComponentShape {
  final double enabledThumbRadius;
  final Color color;

  const _GlowingThumbShape({
    this.enabledThumbRadius = 8.0,
    required this.color,
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(enabledThumbRadius);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;

    // Glow effect
    final Paint glowPaint = Paint()
      ..color = color.withOpacity(0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    
    canvas.drawCircle(center, enabledThumbRadius + 4, glowPaint);

    // Thumb
    final Paint thumbPaint = Paint()..color = color;
    canvas.drawCircle(center, enabledThumbRadius, thumbPaint);
    
    // Inner white dot
    final Paint innerPaint = Paint()..color = Colors.white;
    canvas.drawCircle(center, enabledThumbRadius / 3, innerPaint);
  }
}
