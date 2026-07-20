import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/radius.dart';
import '../theme/spacing.dart';
import '../theme/theme.dart';

enum GymCardVariant { flat, elevated, outlined }

class GymCard extends StatefulWidget {
  final Widget child;
  final GymCardVariant variant;
  final VoidCallback? onTap;
  final Color? accentColor;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;

  const GymCard({
    super.key,
    required this.child,
    this.variant = GymCardVariant.flat,
    this.onTap,
    this.accentColor,
    this.padding,
    this.backgroundColor,
  });

  @override
  State<GymCard> createState() => _GymCardState();
}

class _GymCardState extends State<GymCard> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onTap != null) {
      _animationController.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.onTap != null) {
      _animationController.reverse();
    }
  }

  void _onTapCancel() {
    if (widget.onTap != null) {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final customColors = context.customColors;

    Color bg;
    Border? border;
    List<BoxShadow>? shadow;

    if (widget.backgroundColor != null) {
      bg = widget.backgroundColor!;
    } else {
      switch (widget.variant) {
        case GymCardVariant.flat:
          bg = isDark ? AppColors.darkSurface : AppColors.surfaceGray;
          break;
        case GymCardVariant.elevated:
          bg = isDark ? AppColors.darkSurface : AppColors.white;
          shadow = [
            BoxShadow(
              color: customColors.cardShadow,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ];
          break;
        case GymCardVariant.outlined:
          bg = isDark ? AppColors.darkSurface : AppColors.white;
          border = Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.borderGray,
            width: 1.0,
          );
          break;
      }
    }

    Widget content = Padding(
      padding: widget.padding ?? const EdgeInsets.all(GymSpacing.cardPadding),
      child: widget.child,
    );

    if (widget.accentColor != null) {
      content = ClipRRect(
        borderRadius: GymRadius.lgBorder,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 4.0,
                color: widget.accentColor,
              ),
              Expanded(child: content),
            ],
          ),
        ),
      );
    }

    final cardWidget = Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: GymRadius.lgBorder,
        border: border,
        boxShadow: shadow,
      ),
      child: widget.onTap != null
          ? Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onTap,
                borderRadius: GymRadius.lgBorder,
                overlayColor: WidgetStateProperty.all(
                  isDark ? AppColors.darkNavy10 : AppColors.navy10,
                ),
                child: content,
              ),
            )
          : content,
    );

    if (widget.onTap == null) {
      return cardWidget;
    }

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: cardWidget,
      ),
    );
  }
}
