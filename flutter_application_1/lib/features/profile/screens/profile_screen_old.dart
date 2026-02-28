import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../auth/providers/auth_provider.dart';

/// User profile screen
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = fb.FirebaseAuth.instance.currentUser;
    final email = user?.email ?? authProvider.currentUser ?? 'No email';
    final displayName =
        (user?.displayName != null && user!.displayName!.trim().isNotEmpty)
        ? user.displayName!
        : (email.contains('@') ? email.split('@').first : 'User');
    final phoneNumber =
        (user?.phoneNumber != null && user!.phoneNumber!.trim().isNotEmpty)
        ? user.phoneNumber!
        : 'No phone number';

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.myProfile)),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.screenPadding),
          child: Column(
            children: [
              /// Profile Header
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.paddingXLarge),
                  child: Column(
                    children: [
                      /// Avatar
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: AppColors.primary.withOpacity(0.2),
                        child: const Icon(
                          Icons.person,
                          size: 60,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: AppSizes.paddingLarge),

                      /// Name
                      Text(
                        displayName,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: AppSizes.paddingSmall),

                      /// Email
                      Text(
                        email,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSizes.paddingLarge),

                      /// Phone
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.phone,
                            size: 18,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: AppSizes.paddingSmall),
                          Text(
                            phoneNumber,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSizes.paddingLarge),

                      /// Edit Profile Button
                      ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Edit profile feature coming soon'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        child: const Text(AppStrings.editProfile),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.paddingXLarge),

              /// Menu Options
              _buildMenuSection(
                context,
                title: 'Account',
                items: [
                  _MenuItem(
                    icon: Icons.shopping_cart_outlined,
                    label: AppStrings.myBookings,
                    onTap: () => _showComingSoon(context),
                  ),
                  _MenuItem(
                    icon: Icons.favorite_outline,
                    label: AppStrings.savedEquipment,
                    onTap: () => _showComingSoon(context),
                  ),
                  _MenuItem(
                    icon: Icons.notifications_outlined,
                    label: AppStrings.notifications,
                    onTap: () => _showComingSoon(context),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.paddingXLarge),

              _buildMenuSection(
                context,
                title: 'More',
                items: [
                  _MenuItem(
                    icon: Icons.settings_outlined,
                    label: AppStrings.settings,
                    onTap: () => _showComingSoon(context),
                  ),
                  _MenuItem(
                    icon: Icons.logout,
                    label: AppStrings.logout,
                    onTap: () => _showLogoutDialog(context),
                    isDestructive: true,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuSection(
    BuildContext context, {
    required String title,
    required List<_MenuItem> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppSizes.paddingMedium),
        Card(
          child: Column(
            children: List.generate(items.length, (index) {
              final item = items[index];
              return Column(
                children: [
                  ListTile(
                    leading: Icon(
                      item.icon,
                      color: item.isDestructive
                          ? AppColors.error
                          : AppColors.primary,
                    ),
                    title: Text(
                      item.label,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: item.isDestructive
                            ? AppColors.error
                            : AppColors.textPrimary,
                      ),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: item.isDestructive
                          ? AppColors.error
                          : AppColors.textSecondary,
                    ),
                    onTap: item.onTap,
                  ),
                  if (index < items.length - 1)
                    const Divider(
                      height: 0,
                      indent: 56,
                      color: AppColors.divider,
                    ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Feature coming soon'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceLight,
        title: const Text('Logout', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: Colors.white.withOpacity(0.9)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await context.read<AuthProvider>().signOut();
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });
}
