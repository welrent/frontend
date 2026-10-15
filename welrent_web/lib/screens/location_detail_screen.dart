import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/catalog.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

class LocationDetailScreen extends StatelessWidget {
  const LocationDetailScreen({super.key, required this.city});

  final String city;

  @override
  Widget build(BuildContext context) {
    final data = DestinationData.resolve(city);
    final width = MediaQuery.sizeOf(context).width;
    final stacked = width < 900;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: width < 700 ? 460 : 560,
          child: Stack(
            fit: StackFit.expand,
            children: [
              RemoteOrAssetImage(source: data.image, fit: BoxFit.cover),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Color(0xCC1C263A),
                      Color(0x661C263A),
                      Color(0x001C263A),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: CenteredContainer(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TOP DESTINATION',
                          style: AppText.outfit(
                            size: 12.8,
                            weight: FontWeight.w700,
                            color: AppColors.accentBlue,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          data.fullName,
                          style: AppText.playfair(
                            size: stacked ? 48 : 72,
                            color: Colors.white,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Fleet starting ${data.price}',
                          style: AppText.outfit(
                            size: 20,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                        const SizedBox(height: 35),
                        Wrap(
                          spacing: 15,
                          runSpacing: 12,
                          children: [
                            HoverButton(
                              onPressed: () => context.go(
                                '/offerlist?location=${Uri.encodeQueryComponent(data.name)}',
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 28,
                              ),
                              radius: 8,
                              child: const SizedBox(
                                height: 48,
                                child: Center(child: Text('Explore Fleet')),
                              ),
                            ),
                            HoverButton(
                              onPressed: () => showAppMessage(
                                context,
                                title: 'Concierge',
                                message:
                                    'A concierge for ${data.fullName} can be requested from the yacht assistance form on the home page. No concierge endpoint is published by the current API.',
                              ),
                              background: Colors.white.withValues(alpha: 0.08),
                              hoverBackground: Colors.white.withValues(
                                alpha: 0.16,
                              ),
                              borderColor: Colors.white.withValues(alpha: 0.35),
                              radius: 8,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 28,
                              ),
                              child: const SizedBox(
                                height: 48,
                                child: Center(child: Text('Request Concierge')),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 100),
          child: CenteredContainer(
            child: stacked
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _about(data.about),
                      const SizedBox(height: 40),
                      const _StatsColumn(),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 3, child: _about(data.about)),
                      const SizedBox(width: 80),
                      const Expanded(flex: 2, child: _StatsColumn()),
                    ],
                  ),
          ),
        ),
        _FleetSection(
          title: 'Curated Car Fleet',
          link: 'View All Cars',
          items: data.cars,
          horizontal: false,
        ),
        ColoredBox(
          color: AppColors.bgPage,
          child: _FleetSection(
            title: 'Luxury Vessel Collection',
            link: 'View All Boats',
            items: data.boats,
            horizontal: true,
          ),
        ),
      ],
    );
  }
}

Widget _about(String about) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'About the City',
        style: AppText.outfit(size: 32, weight: FontWeight.w700),
      ),
      const SizedBox(height: 25),
      Text(
        about,
        style: AppText.outfit(
          size: 17.6,
          color: AppColors.bodyGrey,
          height: 1.7,
        ),
      ),
    ],
  );
}

class _StatsColumn extends StatelessWidget {
  const _StatsColumn();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _Stat('250+', 'Vehicles Available'),
        SizedBox(height: 20),
        _Stat('24/7', 'On-site Support'),
        SizedBox(height: 20),
        _Stat('100%', 'Digital Access'),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.value, this.label);

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.bgPage,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: AppText.outfit(
              size: 24,
              weight: FontWeight.w700,
              color: AppColors.accentBlue,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: AppText.outfit(size: 13.6, color: AppColors.fieldText),
          ),
        ],
      ),
    );
  }
}

class _FleetSection extends StatelessWidget {
  const _FleetSection({
    required this.title,
    required this.link,
    required this.items,
    required this.horizontal,
  });

  final String title;
  final String link;
  final List<FleetItem> items;
  final bool horizontal;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 80),
      child: CenteredContainer(
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: AppText.outfit(size: 24, weight: FontWeight.w700),
                  ),
                ),
                GestureDetector(
                  onTap: () => context.go('/offerlist'),
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Text(
                      link,
                      style: AppText.outfit(
                        size: 14.4,
                        weight: FontWeight.w600,
                        color: AppColors.accentBlue,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            if (horizontal)
              SizedBox(
                height: 430,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 20),
                  itemBuilder: (context, index) => SizedBox(
                    width: 320,
                    child: _FleetCard(item: items[index]),
                  ),
                ),
              )
            else
              LayoutBuilder(
                builder: (context, constraints) {
                  final columns = constraints.maxWidth < 800 ? 1 : 2;
                  const gap = 30.0;
                  final width =
                      (constraints.maxWidth - gap * (columns - 1)) / columns;
                  return Wrap(
                    spacing: gap,
                    runSpacing: gap,
                    children: [
                      for (final item in items)
                        SizedBox(
                          width: width,
                          child: _FleetCard(item: item),
                        ),
                    ],
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _FleetCard extends StatefulWidget {
  const _FleetCard({required this.item});

  final FleetItem item;

  @override
  State<_FleetCard> createState() => _FleetCardState();
}

class _FleetCardState extends State<_FleetCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final parts = widget.item.price.split('/');
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        transform: Matrix4.translationValues(0, _hover ? -5 : 0, 0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 40,
              offset: Offset(0, 10),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 240,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  RemoteOrAssetImage(
                    source: widget.item.image,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    top: 15,
                    right: 15,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Available',
                        style: AppText.outfit(
                          size: 12,
                          weight: FontWeight.w700,
                          color: AppColors.trustGreen,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          widget.item.name,
                          style: AppText.outfit(
                            size: 20,
                            weight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Text.rich(
                        TextSpan(
                          style: AppText.outfit(
                            size: 18.4,
                            weight: FontWeight.w700,
                          ),
                          children: [
                            TextSpan(text: parts.first),
                            TextSpan(
                              text: '/${parts.length > 1 ? parts[1] : 'day'}',
                              style: AppText.outfit(
                                size: 13.6,
                                weight: FontWeight.w400,
                                color: AppColors.fieldText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.item.specs,
                    style: AppText.outfit(
                      size: 14.4,
                      color: AppColors.bodyGrey,
                    ),
                  ),
                  const SizedBox(height: 25),
                  HoverButton(
                    onPressed: () => context.go('/offerlist'),
                    radius: 8,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shadow: const [
                      BoxShadow(
                        color: Color(0x335CAAF6),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                    child: const SizedBox(
                      width: double.infinity,
                      child: Center(child: Text('Reserve now')),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
