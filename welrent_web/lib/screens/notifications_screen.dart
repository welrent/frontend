import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/icons.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(notificationControllerProvider);
    final width = MediaQuery.sizeOf(context).width;
    return ColoredBox(
      color: AppColors.bgPage,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 36, 0, 80),
        child: CenteredContainer(
          maxWidth: 800,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 12,
                runSpacing: 8,
                children: [
                  Text(
                    'Notifications',
                    style: AppText.playfair(size: width < 700 ? 40 : 48),
                  ),
                  TextButton(
                    onPressed: () => ref
                        .read(notificationControllerProvider.notifier)
                        .markAllRead(),
                    child: Text(
                      'MARK ALL AS READ',
                      style: AppText.outfit(
                        size: 12.8,
                        weight: FontWeight.w700,
                        letterSpacing: 1,
                        color: AppColors.accentBlue,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Stay updated with your latest bookings and system alerts.',
                style: AppText.outfit(size: 18.4, color: AppColors.bodyGrey),
              ),
              const SizedBox(height: 32),
              for (final item in items) ...[
                _NotificationCard(
                  type: item.type,
                  title: item.title,
                  description: item.description,
                  time: item.time,
                  unread: item.unread,
                  onTap: () => ref
                      .read(notificationControllerProvider.notifier)
                      .markRead(item.id),
                ),
                const SizedBox(height: 20),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationCard extends StatefulWidget {
  const _NotificationCard({
    required this.type,
    required this.title,
    required this.description,
    required this.time,
    required this.unread,
    required this.onTap,
  });

  final String type;
  final String title;
  final String description;
  final String time;
  final bool unread;
  final VoidCallback onTap;

  @override
  State<_NotificationCard> createState() => _NotificationCardState();
}

class _NotificationCardState extends State<_NotificationCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final palette = switch (widget.type) {
      'booking' => (AppColors.greenBg, AppColors.trustGreen, 'check'),
      'system' => (AppColors.alertAmberBg, AppColors.alertAmber, 'tag'),
      _ => (const Color(0xFFE6F4FF), AppColors.accentBlue, 'shield'),
    };
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          transform: Matrix4.translationValues(0, _hover ? -3 : 0, 0),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: widget.unread ? const Color(0xFFF0F7FF) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _hover
                  ? AppColors.accentBlue
                  : (widget.unread
                        ? const Color(0xFFD6E9FF)
                        : AppColors.gridLine),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: palette.$1,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: AppIcon(palette.$3, size: 22, color: palette.$2),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      spacing: 12,
                      runSpacing: 4,
                      children: [
                        Text(
                          widget.title,
                          style: AppText.outfit(
                            size: 16,
                            weight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          widget.time,
                          style: AppText.outfit(
                            size: 12.8,
                            weight: FontWeight.w500,
                            color: AppColors.fieldText,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.description,
                      style: AppText.outfit(
                        size: 14.4,
                        color: AppColors.bodyGrey,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.unread)
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(left: 12, top: 4),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF4D4F),
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
