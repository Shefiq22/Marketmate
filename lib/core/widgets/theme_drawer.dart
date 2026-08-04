import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:market_mate/core/providers/theme_provider.dart';
import 'package:market_mate/core/widgets/theme_toggle_button.dart';

class ThemeDrawer extends ConsumerWidget {
  const ThemeDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = ref.watch(isDarkModeProvider);

    return Drawer(
      backgroundColor: theme.colorScheme.surface,
      child: Column(
        children: [
          SizedBox(
            height: kToolbarHeight + MediaQuery.paddingOf(context).top,
          ),
          Divider(height: 1, color: theme.dividerTheme.color),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _DrawerTile(
                  icon: Icons.dark_mode_rounded,
                  label: isDark ? 'Light Mode' : 'Dark Mode',
                  theme: theme,
                  onTap: () => Navigator.of(context).pop(),
                ),
                _DrawerTile(
                  icon: Icons.settings_rounded,
                  label: 'Settings',
                  theme: theme,
                  onTap: () {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Settings coming soon')),
                    );
                  },
                ),
              ],
            ),
          ),
          Divider(height: 1, color: theme.dividerTheme.color),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: ThemeToggleButton(),
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerTile extends StatelessWidget {
  const _DrawerTile({
    required this.icon,
    required this.label,
    required this.theme,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final ThemeData theme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = theme.colorScheme.onSurface;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 48,
          child: Row(
            children: [
              const SizedBox(width: 24),
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 16),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
