import 'package:flutter/material.dart';

class GlassSearchBar extends StatelessWidget {
  final String hintText;
  final ValueChanged<String>? onChanged;

  const GlassSearchBar({
    super.key,
    this.hintText = 'Search...',
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SearchBar(
      onChanged: onChanged,
      hintText: hintText,
      leading: Icon(Icons.search, color: Theme.of(context).colorScheme.primary),
      elevation: WidgetStateProperty.all(0),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.15),
          ),
        ),
      ),
      backgroundColor: WidgetStateProperty.all(
        Theme.of(context).brightness == Brightness.dark
            ? Theme.of(context).colorScheme.surfaceContainerHighest
            : Theme.of(context).colorScheme.surfaceContainerLowest,
      ),
      padding: WidgetStateProperty.all(
        const EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }
}
