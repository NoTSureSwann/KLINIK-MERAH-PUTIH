import 'package:flutter/material.dart';
import 'glass_container.dart';

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
    return GlassContainer(
      height: 56,
      borderRadius: 16,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Center(
        child: TextField(
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hintText,
            border: InputBorder.none,
            icon: Icon(Icons.search, color: Theme.of(context).colorScheme.primary),
            hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
          ),
        ),
      ),
    );
  }
}
