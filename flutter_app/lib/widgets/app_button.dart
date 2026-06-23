import 'package:flutter/material.dart';

/// Full-width teal gradient pill button with optional icon.
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
          foregroundColor: const Color(0xFF0B6E6E),
          side: const BorderSide(color: Color(0xFF0B6E6E), width: 2),
          minimumSize: const Size(double.infinity, 54),
          shape: const StadiumBorder(),
        ),
        icon: loading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Color(0xFF0B6E6E)))
            : Icon(icon ?? Icons.arrow_forward),
        label: Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.w600, fontSize: 15)),
      );
    }

    return Container(
      decoration: BoxDecoration(
        gradient: onPressed == null
            ? null
            : const LinearGradient(
                colors: [Color(0xFF0B6E6E), Color(0xFF1A9E9E)]),
        color: onPressed == null ? const Color(0xFFCCCCCC) : null,
        borderRadius: BorderRadius.circular(30),
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
