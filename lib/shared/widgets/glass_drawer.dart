import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'glass_container.dart';
import '../../core/theme/app_colors.dart';
import '../../presentation/providers/auth_provider.dart';

class DrawerMenuItem {
  final String title;
  final IconData icon;
  final String route;

  const DrawerMenuItem({
    required this.title,
    required this.icon,
    required this.route,
  });
}

class GlassDrawer extends ConsumerWidget {
  final String role;
  final String userName;
  final List<DrawerMenuItem> menuItems;

  const GlassDrawer({
    super.key,
    required this.role,
    required this.userName,
    required this.menuItems,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Drawer(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: GlassContainer(
        borderRadius: 0,
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 24,
          left: 16,
          right: 16,
          bottom: 24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                  child: Icon(Icons.person, size: 30, color: Theme.of(context).colorScheme.primary),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          role,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            const Divider(color: Colors.white24),
            const SizedBox(height: 16),
            
            // Menu Items
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.zero,
                itemCount: menuItems.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final item = menuItems[index];
                  return ListTile(
                    leading: Icon(item.icon, color: Theme.of(context).textTheme.bodyLarge?.color),
                    title: Text(item.title, style: Theme.of(context).textTheme.bodyLarge),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    hoverColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    onTap: () {
                      Navigator.pop(context); // Close drawer
                      context.push(item.route); // Navigate
                    },
                  );
                },
              ),
            ),
            
            const Divider(color: Colors.white24),
            const SizedBox(height: 16),
            
            // Logout Button
            ListTile(
              leading: const Icon(Icons.logout, color: AppColors.error),
              title: const Text('Logout', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              onTap: () async {
                Navigator.pop(context);
                await ref.read(authStateProvider.notifier).logout();
                if (context.mounted) context.go('/login');
              },
            ),
          ],
        ),
      ),
    );
  }
}
