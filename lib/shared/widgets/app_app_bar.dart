import 'package:flutter/material.dart';

class AppAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBackButton;
  final double height;

  const AppAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.showBackButton = false,
    this.height = kToolbarHeight + 10,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasDrawer = Scaffold.maybeOf(context)?.hasDrawer ?? false;

    final effectiveLeading = showBackButton
        ? IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded,
                color: theme.colorScheme.primary),
            onPressed: () => Navigator.of(context).pop(),
          )
        : leading ??
            (Navigator.canPop(context)
                ? IconButton(
                    icon: Icon(Icons.arrow_back_ios_new,
                        color: theme.colorScheme.primary),
                    onPressed: () => Navigator.pop(context),
                  )
                : (hasDrawer
                    ? IconButton(
                        icon: Icon(Icons.menu_rounded,
                            color: theme.colorScheme.primary),
                        onPressed: () => Scaffold.of(context).openDrawer(),
                      )
                    : null));

    return SafeArea(
      bottom: false,
      child: Container(
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        decoration: BoxDecoration(
          color: theme.appBarTheme.backgroundColor ?? theme.colorScheme.surface,
          border: Border(
            bottom: BorderSide(
              color: theme.dividerColor.withValues(alpha: 0.8),
            ),
          ),
        ),
        child: Row(
          children: [
            if (effectiveLeading != null)
              effectiveLeading
            else
              const SizedBox(width: 48),
            Expanded(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (actions != null)
              Row(mainAxisSize: MainAxisSize.min, children: actions!)
            else
              const SizedBox(width: 48),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height + 16);
}
