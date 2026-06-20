import 'package:flutter/material.dart';
import 'glass_container.dart';

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
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: GlassContainer(
          height: height,
          borderRadius: 20,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (showBackButton)
                IconButton(
                  icon: Icon(Icons.arrow_back_ios_new_rounded, color: Theme.of(context).colorScheme.primary),
                  onPressed: () => Navigator.of(context).pop(),
                )
              else if (leading != null)
                leading!
              else if (Navigator.canPop(context))
                IconButton(
                  icon: Icon(Icons.arrow_back_ios_new, color: Theme.of(context).colorScheme.primary),
                  onPressed: () => Navigator.pop(context),
                )
              else
                const SizedBox(width: 48), // Balance spacing
                
              Expanded(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              
              if (actions != null)
                Row(mainAxisSize: MainAxisSize.min, children: actions!)
              else
                const SizedBox(width: 48), // Balance spacing
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height + 16);
}
