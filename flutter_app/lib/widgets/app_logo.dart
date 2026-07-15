import 'package:flutter/material.dart';
import '../app_theme.dart';

/// DermaVision+ brand logo — image asset with optional label.
class AppLogo extends StatelessWidget {
  final double size;
  final bool showLabel;
  final bool compact;

  const AppLogo({
    super.key,
    this.size = 40,
    this.showLabel = true,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(size * 0.24),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withValues(alpha: 0.35),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Image.asset(
            'assets/app_logo.png',
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => Container(
              decoration: const BoxDecoration(gradient: AppTheme.gradient),
              child: Icon(
                Icons.biotech_rounded,
                color: Colors.white,
                size: size * 0.55,
              ),
            ),
          ),
        ),
        if (showLabel) ...[
          SizedBox(width: compact ? 8 : 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'DermaVision+',
                style: TextStyle(
                  fontSize: compact ? 14 : 16,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                  height: 1.1,
                ),
              ),
              if (!compact)
                Text(
                  'AI Dermatology',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.primary.withValues(alpha: 0.85),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}
