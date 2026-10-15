import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/catalog.dart';
import '../models/models.dart';
import '../services/geolocation.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/icons.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static final _defaultWhen = DateTime(2026, 12, 16, 22, 30);

  String _type = 'car';
  String _location = DemoData.locations.first;
  DateTime _start = _defaultWhen;
  DateTime _end = _defaultWhen;
  int _hero = 0;
  final _categories = ScrollController();

  static const _heroes = [
    (title: 'an RS6', image: BrandAssets.carRs6),
    (title: 'an EVO', image: BrandAssets.carEvo),
  ];

  @override
  void dispose() {
    _categories.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool start}) async {
    final current = start ? _start : _end;
    final date = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2024),
      lastDate: DateTime(2032),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.textPrimary,
              onPrimary: Colors.white,
              surface: Colors.white,
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(current),
    );
    if (!mounted) return;
    final picked = DateTime(
      date.year,
      date.month,
      date.day,
      time?.hour ?? current.hour,
      time?.minute ?? current.minute,
    );
    setState(() {
      if (start) {
        _start = picked;
      } else {
        _end = picked;
      }
    });
  }

  Future<void> _detectLocation() async {
    final allowed = await detectBrowserLocation();
    if (!mounted) return;
    if (!allowed) {
      await showAppMessage(
        context,
        message: 'Please allow location access to automatically detect.',
      );
      return;
    }
    setState(() => _location = 'Amsterdam Central');
    await showAppMessage(
      context,
      message: 'Location detected: Amsterdam Central',
    );
  }

  void _search() {
    final params = {
      'type': _type,
      'location': _location,
      'start': _start.toIso8601String(),
      'end': _end.toIso8601String(),
    };
    final query = params.entries
        .map((entry) => '${entry.key}=${Uri.encodeQueryComponent(entry.value)}')
        .join('&');
    context.go('/offerlist?$query');
  }

  void _scrollCategories(int direction) {
    if (!_categories.hasClients) return;
    final target = (_categories.offset + direction * 260).clamp(
      0.0,
      _categories.position.maxScrollExtent,
    );
    _categories.animateTo(
      target,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final mobile = width < 900;
    final heroSize = width < 480 ? 40.0 : (width < 768 ? 56.0 : 96.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CenteredContainer(
          child: Padding(
            padding: const EdgeInsets.only(top: 60, bottom: 50),
            child: mobile ? _mobileHero(heroSize) : _desktopHero(heroSize),
          ),
        ),
        _categoriesSection(),
        _yachtSection(width, heroSize),
        _destinations(width),
      ],
    );
  }

  Widget _desktopHero(double heroSize) {
    final hero = _heroes[_hero];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 430,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: 0,
                top: 36,
                child: _heroTitle(hero.title, heroSize),
              ),
              Positioned(
                right: -90,
                top: -10,
                width: 760,
                child: Image.asset(
                  hero.image,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                ),
              ),
              Positioned(right: 80, bottom: 8, child: _arrows()),
            ],
          ),
        ),
        const SizedBox(height: 8),
        _searchCard(wide: true),
      ],
    );
  }

  Widget _mobileHero(double heroSize) {
    final hero = _heroes[_hero];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _heroTitle(hero.title, heroSize),
        const SizedBox(height: 20),
        Stack(
          children: [
            Image.asset(hero.image, fit: BoxFit.contain),
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Align(
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [_arrow(true), _arrow(false)],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),
        _searchCard(wide: false),
      ],
    );
  }

  Widget _heroTitle(String name, double size) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: 'Rent...\n',
            style: AppText.playfair(size: size, color: AppColors.textLightGrey),
          ),
          TextSpan(
            text: name,
            style: AppText.playfair(
              size: size,
              weight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _arrows() {
    return Row(
      children: [_arrow(true), const SizedBox(width: 15), _arrow(false)],
    );
  }

  Widget _arrow(bool previous) {
    final active = previous ? _hero == 0 : _hero == 1;
    return GestureDetector(
      onTap: () => setState(() => _hero = previous ? 0 : 1),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: active ? AppColors.accentBlue : Colors.white,
            shape: BoxShape.circle,
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 15,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: AppIcon(
            previous ? 'chevron-left' : 'chevron-right',
            size: 18,
            color: active ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _searchCard({required bool wide}) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 680),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: const Color(0x05000000)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x08000000),
              blurRadius: 40,
              offset: Offset(0, 15),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [_tab('car', 'Car'), _tab('motorcycle', 'Motorcycle')],
            ),
            const Divider(height: 1, color: AppColors.borderLight),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
              child: wide
                  ? Row(
                      children: [
                        Expanded(child: _locationField()),
                        _divider(),
                        Expanded(child: _dateField('Start', _start, true)),
                        _divider(),
                        Expanded(child: _dateField('End', _end, false)),
                        const SizedBox(width: 20),
                        _searchButton(),
                      ],
                    )
                  : Column(
                      children: [
                        _locationField(),
                        const Divider(height: 24, color: AppColors.borderLight),
                        _dateField('Start', _start, true),
                        const Divider(height: 24, color: AppColors.borderLight),
                        _dateField('End', _end, false),
                        const SizedBox(height: 16),
                        Align(
                          alignment: Alignment.centerRight,
                          child: _searchButton(),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tab(String value, String label) {
    final active = _type == value;
    return GestureDetector(
      onTap: () => setState(() => _type = value),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: active ? AppColors.textPrimary : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Row(
            children: [
              AppIcon(
                value == 'car' ? 'car' : 'moto',
                size: 16,
                color: active ? AppColors.textPrimary : AppColors.textMuted,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: AppText.outfit(
                  size: 14.4,
                  weight: FontWeight.w600,
                  color: active ? AppColors.textPrimary : AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _locationField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Location',
          style: AppText.outfit(size: 12, weight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _location,
                  isDense: true,
                  isExpanded: true,
                  icon: const SizedBox.shrink(),
                  style: AppText.outfit(size: 15.2, color: AppColors.fieldText),
                  items: [
                    for (final city in DemoData.locations)
                      DropdownMenuItem(value: city, child: Text(city)),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => _location = value);
                  },
                ),
              ),
            ),
            IconButton(
              tooltip: 'Detect Location',
              onPressed: _detectLocation,
              icon: const AppIcon(
                'target',
                size: 18,
                color: AppColors.searchButton,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _dateField(String label, DateTime value, bool start) {
    return GestureDetector(
      onTap: () => _pickDate(start: start),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppText.outfit(size: 12, weight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: Text(
                    formatDateTime(value),
                    style: AppText.outfit(
                      size: 15.2,
                      color: AppColors.fieldText,
                    ),
                  ),
                ),
                const AppIcon('calendar', size: 16, color: AppColors.fieldText),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider() {
    return Container(
      width: 1,
      height: 42,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      color: AppColors.borderLight,
    );
  }

  Widget _searchButton() {
    return _Pressable(
      onTap: _search,
      child: const SizedBox(
        width: 44,
        height: 44,
        child: ColoredBox(
          color: AppColors.searchButton,
          child: AppIcon('search', size: 18, color: Colors.white),
        ),
      ),
    );
  }

  Widget _categoriesSection() {
    return ColoredBox(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 80),
        child: CenteredContainer(
          child: Column(
            children: [
              SectionHeading(
                title: 'Explore Our Car Categories',
                trailing: Row(
                  children: [
                    _roundNav(() => _scrollCategories(-1)),
                    const SizedBox(width: 12),
                    _roundNav(() => _scrollCategories(1), next: true),
                  ],
                ),
              ),
              SizedBox(
                height: 180,
                child: ListView.separated(
                  controller: _categories,
                  scrollDirection: Axis.horizontal,
                  itemCount: DemoData.categories.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 20),
                  itemBuilder: (context, index) {
                    final category = DemoData.categories[index];
                    return _CategoryCard(
                      name: category.name,
                      image: category.image,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _roundNav(VoidCallback onTap, {bool next = false}) {
    return _Pressable(
      onTap: onTap,
      border: true,
      child: SizedBox(
        width: 32,
        height: 32,
        child: AppIcon(
          next ? 'chevron-right' : 'chevron-left',
          size: 16,
          color: AppColors.textMuted,
        ),
      ),
    );
  }

  Widget _yachtSection(double width, double heroSize) {
    final stacked = width < 900;
    final text = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'Rent...\n',
                style: AppText.playfair(
                  size: heroSize,
                  color: AppColors.textLightGrey,
                ),
              ),
              TextSpan(
                text: 'a Yacht',
                style: AppText.playfair(
                  size: heroSize,
                  weight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 25),
        HoverButton(
          onPressed: () => _assistance(context),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shadow: const [
            BoxShadow(
              color: Color(0x4D5CAAF6),
              blurRadius: 15,
              offset: Offset(0, 4),
            ),
          ],
          child: const Text('Request assistance'),
        ),
      ],
    );
    if (stacked) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 50),
        child: CenteredContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(BrandAssets.yacht, fit: BoxFit.contain),
              const SizedBox(height: 24),
              text,
            ],
          ),
        ),
      );
    }
    return SizedBox(
      height: 560,
      child: CenteredContainer(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: -120,
              top: 40,
              width: 820,
              child: Image.asset(BrandAssets.yacht, fit: BoxFit.contain),
            ),
            Align(alignment: Alignment.centerRight, child: text),
          ],
        ),
      ),
    );
  }

  Widget _destinations(double width) {
    final columns = width < 600 ? 1 : (width < 1024 ? 2 : 4);
    return ColoredBox(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.only(top: 20, bottom: 80),
        child: CenteredContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeading(title: 'Top Rental Destinations'),
              LayoutBuilder(
                builder: (context, constraints) {
                  const gap = 24.0;
                  final raw = constraints.maxWidth - gap * (columns - 1);
                  final itemWidth = raw <= 0
                      ? constraints.maxWidth
                      : raw / columns;
                  return Wrap(
                    spacing: gap,
                    runSpacing: 24,
                    children: [
                      for (final dest in DemoData.homeDestinations)
                        SizedBox(
                          width: itemWidth,
                          child: _DestinationCard(
                            city: dest.city,
                            price: dest.price,
                            image: dest.image,
                            onTap: () => context.go('/locations/${dest.slug}'),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _assistance(BuildContext context) async {
    final name = TextEditingController();
    final email = TextEditingController();
    final note = TextEditingController();
    final sent = await showDialog<bool>(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Request assistance',
                    style: AppText.outfit(size: 22, weight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tell us what you need for a yacht charter. This request stays on this device — the Welrent API has no assistance endpoint.',
                    style: AppText.outfit(
                      size: 14,
                      color: AppColors.bodyGrey,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 18),
                  _lineField(name, 'Name'),
                  _lineField(email, 'Email'),
                  _lineField(note, 'How can we help?'),
                  const SizedBox(height: 18),
                  HoverButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    background: AppColors.textPrimary,
                    hoverBackground: const Color(0xFF2D3A54),
                    radius: 12,
                    child: const Text('Send request'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
    name.dispose();
    email.dispose();
    note.dispose();
    if (sent == true && context.mounted) {
      await showAppMessage(
        context,
        message: 'Thanks. A concierge request was recorded for this session.',
      );
    }
  }

  Widget _lineField(TextEditingController controller, String hint) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        style: AppText.outfit(size: 16),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppText.outfit(color: AppColors.placeholder),
          border: const UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0x1A1C263A), width: 2),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.accentBlue, width: 2),
          ),
        ),
      ),
    );
  }
}

class _CategoryCard extends StatefulWidget {
  const _CategoryCard({required this.name, required this.image});

  final String name;
  final String image;

  @override
  State<_CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<_CategoryCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        transform: Matrix4.translationValues(0, _hover ? -5 : 0, 0),
        width: 240,
        height: 180,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.searchBg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0D000000),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                widget.name,
                style: AppText.outfit(size: 12, weight: FontWeight.w600),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                height: 100,
                child: RemoteOrAssetImage(
                  source: widget.image,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DestinationCard extends StatefulWidget {
  const _DestinationCard({
    required this.city,
    required this.price,
    required this.image,
    required this.onTap,
  });

  final String city;
  final String price;
  final String image;
  final VoidCallback onTap;

  @override
  State<_DestinationCard> createState() => _DestinationCardState();
}

class _DestinationCardState extends State<_DestinationCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: AnimatedScale(
                  scale: _hover ? 1.04 : 1,
                  duration: const Duration(milliseconds: 400),
                  child: RemoteOrAssetImage(
                    source: widget.image,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.city,
              style: AppText.outfit(size: 16, weight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              'Vehicles ${widget.price}',
              style: AppText.outfit(size: 13.6, color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}

class _Pressable extends StatefulWidget {
  const _Pressable({
    required this.child,
    required this.onTap,
    this.border = false,
  });

  final Widget child;
  final VoidCallback onTap;
  final bool border;

  @override
  State<_Pressable> createState() => _PressableState();
}

class _PressableState extends State<_Pressable> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            border: widget.border
                ? Border.all(
                    color: _hover
                        ? AppColors.textPrimary
                        : AppColors.borderLight,
                  )
                : null,
            color: widget.border ? Colors.white : null,
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
