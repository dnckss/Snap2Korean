import 'package:flutter/material.dart';
import '../styles/colors.dart';
import '../styles/text_styles.dart';
import '../constants/sizes.dart';

class InfoCard extends StatelessWidget {
  final String title;
  final String content;
  final IconData? icon;
  final Color? iconColor;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  final bool isExpandable;
  final bool isExpanded;

  const InfoCard({
    required this.title,
    required this.content,
    this.icon,
    this.iconColor,
    this.backgroundColor,
    this.onTap,
    this.isExpandable = false,
    this.isExpanded = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: backgroundColor ?? AppColors.cardBackground,
      elevation: AppSizes.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.cardPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (icon != null) ...[
                    Icon(
                      icon,
                      color: iconColor ?? AppColors.primary,
                      size: AppSizes.iconSize,
                    ),
                    const SizedBox(width: AppSizes.sm),
                  ],
                  Expanded(
                    child: Text(
                      title,
                      style: AppTextStyles.labelLarge.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  if (isExpandable) ...[
                    Icon(
                      isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: AppColors.textSecondary,
                      size: AppSizes.iconSizeSmall,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: AppSizes.md),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSizes.md),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  content,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ExpandableInfoCard extends StatefulWidget {
  final String title;
  final String content;
  final IconData? icon;
  final Color? iconColor;
  final Color? backgroundColor;

  const ExpandableInfoCard({
    required this.title,
    required this.content,
    this.icon,
    this.iconColor,
    this.backgroundColor,
    super.key,
  });

  @override
  State<ExpandableInfoCard> createState() => _ExpandableInfoCardState();
}

class _ExpandableInfoCardState extends State<ExpandableInfoCard>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      title: widget.title,
      content: widget.content,
      icon: widget.icon,
      iconColor: widget.iconColor,
      backgroundColor: widget.backgroundColor,
      onTap: _toggleExpanded,
      isExpandable: true,
      isExpanded: _isExpanded,
    );
  }
} 