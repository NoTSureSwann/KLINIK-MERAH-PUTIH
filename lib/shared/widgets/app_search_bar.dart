import 'package:flutter/material.dart';

class AppSearchBar extends StatelessWidget {
  final String hintText;
  final ValueChanged<String>? onChanged;

  const AppSearchBar({
    super.key,
    this.hintText = 'Search...',
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SearchBar(
      onChanged: onChanged,
      hintText: hintText,
      leading: Icon(Icons.search, color: theme.colorScheme.primary),
      elevation: WidgetStateProperty.all(0),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: theme.dividerColor.withValues(alpha: 0.6),
          ),
        ),
      ),
      backgroundColor: WidgetStateProperty.all(theme.colorScheme.surface),
      padding: WidgetStateProperty.all(
        const EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }
}
