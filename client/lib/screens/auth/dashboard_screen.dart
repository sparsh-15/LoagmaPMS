import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/auth_controller.dart';
import '../../router/app_router.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  static const _backgroundColor = Color(0xFFFFFBF0);
  static const _textDark = Color(0xFF2C2416);
  static const _textMuted = Color(0xFF6B5D4A);

  Future<void> _showLogoutConfirm(BuildContext context) async {
    final logout = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Do you really want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('No'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );
    if (context.mounted && logout == true) {
      await AuthController.setLoggedIn(false);
      try {
        Get.find<AuthController>().reset();
      } catch (_) {}
      Get.offAllNamed(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) return;
        await _showLogoutConfirm(context);
      },
      child: Scaffold(
        backgroundColor: _backgroundColor,
        appBar: AppBar(
          title: const Text('Loagma PMS'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => _showLogoutConfirm(context),
          ),
        ),
        body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              Text(
                'Home',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: _textDark,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Choose a module to continue',
                style: TextStyle(
                  fontSize: 15,
                  color: _textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 32),
              _ModuleCard(
                title: 'Issue to production',
                subtitle: 'Issue materials or items to production',
                icon: Icons.outbox_rounded,
                onTap: () {
                  // TODO: Navigate to Issue to production module
                },
              ),
              const SizedBox(height: 16),
              _ModuleCard(
                title: 'Receive from production',
                subtitle: 'Receive items or materials from production',
                icon: Icons.inbox_rounded,
                onTap: () {
                  // TODO: Navigate to Receive from production module
                },
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }
}

class _ModuleCard extends StatelessWidget {
  const _ModuleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  static const _accentColor = Color(0xFFB8860B);
  static const _accentLight = Color(0xFFFFF8E7);
  static const _textDark = Color(0xFF2C2416);
  static const _textMuted = Color(0xFF6B5D4A);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _accentLight,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: _accentColor, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: _textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: _textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: _accentColor, size: 28),
            ],
          ),
        ),
      ),
    );
  }
}
