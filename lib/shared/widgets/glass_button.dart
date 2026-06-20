import 'package:flutter/material.dart';
import 'glass_container.dart';

class GlassButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final IconData? icon;
  final Color? color;
  final bool isLoading;

  const GlassButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.color,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: isLoading ? null : onPressed,
      child: GlassContainer(
        height: 56,
        borderRadius: 16,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, color: color ?? Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      text,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: color ?? Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
