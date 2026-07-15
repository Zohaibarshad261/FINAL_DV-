import 'package:flutter/material.dart';
import '../app_theme.dart';
import 'app_logo.dart';

/// Top bar with logo anchored top-left and optional trailing actions.
class AppHeaderBar extends StatelessWidget {
  final List<Widget>? actions;
  final Widget? trailing;

  const AppHeaderBar({super.key, this.actions, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          const AppLogo(size: 44),
          const Spacer(),
          if (trailing != null)
            trailing!
          else if (actions != null)
            ...actions!,
        ],
      ),
    );
  }
}

/// Branded app bar for inner screens — back button + small logo.
class BrandedAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final List<Widget>? actions;
  final bool showLogo;

  const BrandedAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
    this.showLogo = true,
  });

  @override
  Size get preferredSize => Size.fromHeight(subtitle != null ? 64 : 56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      toolbarHeight: subtitle != null ? 64 : 56,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            color: AppTheme.textPrimary, size: 20),
        onPressed: () => Navigator.maybePop(context),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showLogo) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/app_logo.png',
                width: 28,
                height: 28,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    gradient: AppTheme.gradient,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.health_and_safety_rounded,
                      size: 16, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          subtitle != null
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        color: AppTheme.primary.withValues(alpha: 0.9),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                )
              : Text(
                  title,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 17,
                  ),
                ),
        ],
      ),
      centerTitle: true,
      actions: actions,
    );
  }
}
