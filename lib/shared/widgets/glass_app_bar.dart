import 'package:flutter/material.dart';

class GlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBackButton;
  final double height;

  const GlassAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.showBackButton = false,
    this.height = kToolbarHeight + 10,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 1,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.95),
      leading: showBackButton
          ? IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded,
                  color: Theme.of(context).colorScheme.primary),
              onPressed: () => Navigator.of(context).pop(),
            )
          : leading ??
              (Navigator.canPop(context)
                  ? IconButton(
                      icon: Icon(Icons.arrow_back_ios_new,
                          color: Theme.of(context).colorScheme.primary),
                      onPressed: () => Navigator.pop(context),
                    )
                  : null),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}
