import 'package:flutter/material.dart';
import '../styles/colors.dart';
import '../styles/text_styles.dart';
import '../constants/sizes.dart';

class PermissionDialog extends StatelessWidget {
  final String title;
  final String message;
  final String iconPath;
  final VoidCallback onGrant;
  final VoidCallback onDeny;

  const PermissionDialog({
    required this.title,
    required this.message,
    required this.iconPath,
    required this.onGrant,
    required this.onDeny,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(AppSizes.lg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 아이콘
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                iconPath == 'camera' ? Icons.camera_alt : Icons.photo_library,
                size: 40,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSizes.lg),
            
            // 제목
            Text(
              title,
              style: AppTextStyles.h3.copyWith(
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.md),
            
            // 메시지
            Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.xl),
            
            // 버튼들
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onDeny,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSizes.md,
                      ),
                    ),
                    child: const Text('나중에'),
                  ),
                ),
                const SizedBox(width: AppSizes.md),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onGrant,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSizes.md,
                      ),
                    ),
                    child: const Text('허용'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 