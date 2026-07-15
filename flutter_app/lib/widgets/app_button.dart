import 'package:flutter/material.dart';
import '../app_theme.dart';

/// Full-width gradient pill button with optional icon.
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;
  final bool outlined;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.loading = false,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    if (outlined) {
      return OutlinedButton.icon(
        onPressed: loading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppTheme.primary,
          side: const BorderSide(color: AppTheme.primary, width: 2),
          minimumSize: const Size(double.infinity, 54),
          shape: const StadiumBorder(),
        ),
        icon: loading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: AppTheme.primary))
            : Icon(icon ?? Icons.arrow_forward),
        label: Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.w600, fontSize: 15)),
      );
    }

    return Container(
      decoration: BoxDecoration(
        gradient: onPressed == null ? null : AppTheme.gradient,
        color: onPressed == null ? const Color(0xFFCCCCCC) : null,
        borderRadius: BorderRadius.circular(30),
        boxShadow: onPressed == null
            ? null
            : [
                BoxShadow(
                  color: AppTheme.primary.withValues(alpha: 0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: ElevatedButton.icon(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          minimumSize: const Size(double.infinity, 54),
          shape: const StadiumBorder(),
        ),
        icon: loading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white))
            : Icon(icon ?? Icons.arrow_forward, color: Colors.white),
        label: Text(label,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 15)),
      ),
    );
  }
}
