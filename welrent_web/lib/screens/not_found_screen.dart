import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_theme.dart';
import '../widgets/common.dart';

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 100),
      child: CenteredContainer(
        child: Column(
          children: [
            Text('Page not found', style: AppText.playfair(size: 56)),
            const SizedBox(height: 16),
            Text(
              'That address is not part of the Welrent marketplace.',
              style: AppText.outfit(size: 16, color: AppColors.fieldText),
            ),
            const SizedBox(height: 28),
            HoverButton(
              onPressed: () => context.go('/'),
              background: AppColors.textPrimary,
              hoverBackground: const Color(0xFF2D3A54),
              radius: 10,
              child: const Text('Back home'),
            ),
          ],
        ),
      ),
    );
  }
}
