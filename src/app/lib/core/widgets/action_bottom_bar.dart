import 'package:app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class ActionBottomBar extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isDisabled;
  final Color backgroundColor;

  const ActionBottomBar({
    super.key,
    required this.child,
    this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.backgroundColor = AppColors.green,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: const Border(
          top: BorderSide(color: AppColors.lightGrey),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            backgroundColor: backgroundColor,
            disabledBackgroundColor: Colors.grey[300],
          ),
          onPressed: (isDisabled || isLoading) ? null : onPressed,
          child: isLoading
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : child,
        ),
      ),
    );
  }
}
