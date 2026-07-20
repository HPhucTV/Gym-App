import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/colors.dart';

class GymCheckbox extends StatefulWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final double size;

  const GymCheckbox({
    super.key,
    required this.value,
    this.onChanged,
    this.size = 28.0,
  });

  @override
  State<GymCheckbox> createState() => _GymCheckboxState();
}

class _GymCheckboxState extends State<GymCheckbox> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 1.2), weight: 50),
      TweenSequenceItem(tween: Tween<double>(begin: 1.2, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant GymCheckbox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value && widget.value) {
      _animationController.forward(from: 0.0);
    }
  }

  void _onTap() {
    if (widget.onChanged != null) {
      HapticFeedback.lightImpact();
      widget.onChanged!(!widget.value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color bg;
    Border border;

    if (widget.value) {
      bg = AppColors.successGreen;
      border = Border.all(color: AppColors.successGreen, width: 2.0);
    } else {
      bg = Colors.transparent;
      border = Border.all(
        color: isDark ? AppColors.darkBorder : AppColors.borderGray,
        width: 2.0,
      );
    }

    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTap: _onTap,
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: bg,
            shape: BoxShape.circle,
            border: border,
          ),
          child: widget.value
              ? Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: widget.size * 0.65,
                )
              : null,
        ),
      ),
    );
  }
}
