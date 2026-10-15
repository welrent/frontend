import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/models.dart';
import '../state/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/icons.dart';

class BookingsScreen extends ConsumerStatefulWidget {
  const BookingsScreen({super.key});

  @override
  ConsumerState<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends ConsumerState<BookingsScreen> {
  String _tab = 'active';

  @override
  Widget build(BuildContext context) {
    final bookings = ref.watch(bookingControllerProvider);
    final filtered = bookings
        .where((item) => _tab == 'active' ? item.active : !item.active)
        .toList();
    final width = MediaQuery.sizeOf(context).width;
    final stacked = width < 900;

    return ColoredBox(
      color: AppColors.bgPage,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 36, 0, 60),
        child: CenteredContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'My Bookings',
                style: AppText.playfair(size: width < 700 ? 40 : 48),
              ),
              const SizedBox(height: 12),
              Text(
                'Manage your active rentals and view your transaction history.',
                style: AppText.outfit(
                  size: 18.4,
                  color: AppColors.bodyGrey,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  _tabButton('Upcoming & Active', 'active'),
                  const SizedBox(width: 40),
                  _tabButton('History', 'history'),
                ],
              ),
              const Divider(height: 1, color: Color(0xFFE5E7EB)),
              const SizedBox(height: 40),
              if (filtered.isEmpty)
                Column(
                  children: [
                    const SizedBox(height: 40),
                    const AppIcon(
                      'calendar',
                      size: 60,
                      color: AppColors.fieldText,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'No $_tab bookings found.',
                      style: AppText.outfit(
                        size: 16,
                        color: AppColors.fieldText,
                      ),
                    ),
                    const SizedBox(height: 15),
                    HoverButton(
                      onPressed: () => context.go('/offerlist'),
                      child: const Text('Rent something new'),
                    ),
                  ],
                )
              else
                for (final booking in filtered) ...[
                  _BookingCard(booking: booking, stacked: stacked),
                  const SizedBox(height: 30),
                ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _tabButton(String label, String value) {
    final active = _tab == value;
    return GestureDetector(
      onTap: () => setState(() => _tab = value),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: active ? AppColors.accentBlue : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Text(
            label.toUpperCase(),
            style: AppText.outfit(
              size: 13.6,
              weight: FontWeight.w700,
              letterSpacing: 1,
              color: active ? AppColors.accentBlue : AppColors.fieldText,
            ),
          ),
        ),
      ),
    );
  }
}

class _BookingCard extends ConsumerWidget {
  const _BookingCard({required this.booking, required this.stacked});

  final Booking booking;
  final bool stacked;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final confirmed = booking.status.toLowerCase() == 'confirmed';
    final details = Padding(
      padding: const EdgeInsets.all(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ID: ${booking.id}',
                      style: AppText.outfit(
                        size: 12,
                        weight: FontWeight.w700,
                        color: AppColors.fieldText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      booking.name,
                      style: AppText.outfit(size: 24, weight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              Text(
                booking.total,
                style: AppText.outfit(size: 24, weight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 25),
          Wrap(
            spacing: 30,
            runSpacing: 16,
            children: [
              _data('Dates', booking.dates),
              _data('Location', booking.location),
            ],
          ),
          const SizedBox(height: 25),
          const Divider(height: 1, color: AppColors.gridLine),
          const SizedBox(height: 25),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              HoverButton(
                onPressed: () => showAppMessage(
                  context,
                  title: booking.name,
                  message:
                      '${booking.id}\n${booking.dates}\n${booking.location}\n${booking.total}\nStatus: ${booking.status}',
                ),
                background: AppColors.textPrimary,
                hoverBackground: const Color(0xFF2D3A54),
                radius: 6,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: const Text('Manage Booking'),
              ),
              HoverButton(
                onPressed: () => context.go('/chat'),
                background: AppColors.searchBg,
                hoverBackground: const Color(0xFFE5E7EB),
                foreground: AppColors.textPrimary,
                radius: 6,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: const Text('Contact Owner'),
              ),
              if (booking.active)
                HoverButton(
                  onPressed: () async {
                    final ok = await showConfirmDialog(
                      context,
                      title: 'Cancel booking',
                      message: 'Cancel ${booking.id} for ${booking.name}?',
                      confirmLabel: 'Cancel booking',
                      danger: true,
                    );
                    if (ok) {
                      await ref
                          .read(bookingControllerProvider.notifier)
                          .cancel(booking.id);
                    }
                  },
                  background: Colors.transparent,
                  hoverBackground: AppColors.errorBg,
                  foreground: AppColors.error,
                  borderColor: AppColors.cancelBorder,
                  radius: 6,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: const Text('Cancel'),
                ),
            ],
          ),
        ],
      ),
    );

    final image = SizedBox(
      height: stacked ? 200 : 240,
      width: stacked ? double.infinity : 320,
      child: Stack(
        fit: StackFit.expand,
        children: [
          RemoteOrAssetImage(source: booking.image, fit: BoxFit.cover),
          Positioned(
            top: 15,
            left: 15,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                booking.status.toUpperCase(),
                style: AppText.outfit(
                  size: 12,
                  weight: FontWeight.w800,
                  color: confirmed ? AppColors.trustGreen : AppColors.fieldText,
                ),
              ),
            ),
          ),
        ],
      ),
    );

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.gridLine),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 40,
            offset: Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: stacked
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [image, details],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                image,
                Expanded(child: details),
              ],
            ),
    );
  }

  Widget _data(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: AppText.outfit(
            size: 12,
            weight: FontWeight.w700,
            color: AppColors.fieldText,
          ),
        ),
        const SizedBox(height: 6),
        Text(value, style: AppText.outfit(size: 16, weight: FontWeight.w600)),
      ],
    );
  }
}
