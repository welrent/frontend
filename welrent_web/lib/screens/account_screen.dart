import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/models.dart';
import '../services/welrent_api.dart';
import '../state/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/icons.dart';

final accountRentalsProvider = FutureProvider<List<Rental>>((ref) async {
  final user = ref.watch(authControllerProvider).user;
  if (user == null) return const [];
  final api = ref.watch(apiProvider);
  final config = ref.watch(appConfigProvider);
  if (!config.hasApi) return const [];
  return api.fetchRentals(user.id);
});

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    if (auth.status == AuthStatus.loading) {
      return const SizedBox(
        height: 360,
        child: Center(child: AppSpinner(size: 32, color: AppColors.accentBlue)),
      );
    }
    final user = auth.user;
    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) context.go('/login');
      });
      return const SizedBox(
        height: 240,
        child: Center(child: AppSpinner(size: 28, color: AppColors.accentBlue)),
      );
    }
    return _AccountBody(user: user);
  }
}

class _AccountBody extends ConsumerStatefulWidget {
  const _AccountBody({required this.user});

  final SessionUser user;

  @override
  ConsumerState<_AccountBody> createState() => _AccountBodyState();
}

class _AccountBodyState extends ConsumerState<_AccountBody> {
  bool _editName = false;
  bool _editBio = false;
  bool _savingName = false;
  bool _savingBio = false;
  bool _signingOut = false;
  String? _uploadError;
  late final TextEditingController _name;
  late final TextEditingController _bio;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(
      text: widget.user.displayName ?? widget.user.label,
    );
    _bio = TextEditingController(text: widget.user.bio);
  }

  @override
  void didUpdateWidget(covariant _AccountBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_editName && oldWidget.user.displayName != widget.user.displayName) {
      _name.text = widget.user.displayName ?? widget.user.label;
    }
    if (!_editBio && oldWidget.user.bio != widget.user.bio) {
      _bio.text = widget.user.bio;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _bio.dispose();
    super.dispose();
  }

  Future<void> _saveName() async {
    if (_name.text.trim().isEmpty) return;
    setState(() => _savingName = true);
    await ref.read(authControllerProvider.notifier).updateName(_name.text);
    if (mounted) {
      setState(() {
        _savingName = false;
        _editName = false;
      });
    }
  }

  Future<void> _saveBio() async {
    setState(() => _savingBio = true);
    await ref.read(authControllerProvider.notifier).updateBio(_bio.text);
    if (mounted) {
      setState(() {
        _savingBio = false;
        _editBio = false;
      });
    }
  }

  Future<void> _pickPhoto() async {
    setState(() => _uploadError = null);
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final file = result.files.single;
    final bytes = file.bytes;
    if (bytes == null) {
      setState(() => _uploadError = 'Could not read that image.');
      return;
    }
    if (bytes.length > 5 * 1024 * 1024) {
      setState(() => _uploadError = 'Photo must be under 5 MB.');
      return;
    }
    final mime = _mime(file.extension);
    final dataUrl = 'data:$mime;base64,${base64Encode(bytes)}';
    await ref.read(authControllerProvider.notifier).updatePhoto(dataUrl);
  }

  String _mime(String? extension) {
    switch (extension?.toLowerCase()) {
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'gif':
        return 'image/gif';
      default:
        return 'image/jpeg';
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    final width = MediaQuery.sizeOf(context).width;
    final stacked = width < AppBreakpoints.mobile;
    final remote = ref.watch(accountRentalsProvider);
    final local = ref.watch(bookingControllerProvider);
    final rentals = _merge(remote.valueOrNull ?? const [], local);

    return ColoredBox(
      color: AppColors.bgPage,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: CenteredContainer(
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 32),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0A000000),
                      blurRadius: 40,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      height: 140,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(24),
                        ),
                        gradient: LinearGradient(
                          colors: [
                            AppColors.textPrimary,
                            AppColors.navyMid,
                            AppColors.accentBlue,
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        stacked ? 20 : 40,
                        0,
                        stacked ? 20 : 40,
                        40,
                      ),
                      child: stacked
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Transform.translate(
                                  offset: const Offset(0, -50),
                                  child: _Avatar(user: user, onTap: _pickPhoto),
                                ),
                                _profileFields(user),
                                _stats(rentals, true),
                              ],
                            )
                          : Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Transform.translate(
                                  offset: const Offset(0, -50),
                                  child: _Avatar(user: user, onTap: _pickPhoto),
                                ),
                                const SizedBox(width: 28),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 16),
                                    child: _profileFields(user),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                _stats(rentals, false),
                              ],
                            ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 18,
                      ),
                      alignment: Alignment.centerRight,
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                      child: HoverButton(
                        onPressed: _signingOut
                            ? null
                            : () async {
                                setState(() => _signingOut = true);
                                await ref
                                    .read(authControllerProvider.notifier)
                                    .signOut();
                                if (context.mounted) context.go('/');
                              },
                        enabled: !_signingOut,
                        background: Colors.white,
                        hoverBackground: AppColors.errorBg,
                        foreground: AppColors.error,
                        borderColor: AppColors.errorBorder,
                        radius: 10,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 10,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_signingOut)
                              const AppSpinner(size: 16, color: AppColors.error)
                            else
                              const AppIcon(
                                'logout',
                                size: 16,
                                color: AppColors.error,
                              ),
                            const SizedBox(width: 10),
                            const Text('Sign out'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Rental History',
                      style: AppText.outfit(
                        size: 20.8,
                        weight: FontWeight.w800,
                      ),
                    ),
                  ),
                  HoverButton(
                    onPressed: () => context.go('/offerlist'),
                    radius: 8,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 9,
                    ),
                    child: const Text('Browse vehicles'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (remote.isLoading)
                _panel(
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AppSpinner(size: 22, color: AppColors.accentBlue),
                      SizedBox(width: 12),
                      Text('Loading your rentals…'),
                    ],
                  ),
                )
              else if (remote.hasError)
                _panel(
                  child: Text(
                    remote.error is ApiException
                        ? (remote.error! as ApiException).message
                        : 'Rentals could not be loaded from the API.',
                    style: AppText.outfit(color: AppColors.error),
                  ),
                )
              else if (rentals.isEmpty)
                _panel(
                  child: Column(
                    children: [
                      const AppIcon(
                        'car',
                        size: 48,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No rentals yet. Start your first adventure!',
                        style: AppText.outfit(
                          size: 15.2,
                          weight: FontWeight.w500,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 16),
                      HoverButton(
                        onPressed: () => context.go('/offerlist'),
                        radius: 8,
                        child: const Text('Explore vehicles'),
                      ),
                    ],
                  ),
                )
              else
                for (final rental in rentals) ...[
                  _RentalCard(rental: rental, stacked: stacked),
                  const SizedBox(height: 16),
                ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _profileFields(SessionUser user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_uploadError != null)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.errorBg,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.errorBorder),
            ),
            child: Text(
              _uploadError!,
              style: AppText.outfit(size: 12.5, color: AppColors.error),
            ),
          ),
        if (_editName)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: 260,
                child: TextField(
                  controller: _name,
                  autofocus: true,
                  style: AppText.outfit(size: 16, weight: FontWeight.w700),
                  decoration: _editDecoration(),
                  onSubmitted: (_) => _saveName(),
                ),
              ),
              _saveButton('Save', _savingName, _saveName),
              _cancelButton(() => setState(() => _editName = false)),
            ],
          )
        else
          Row(
            children: [
              Flexible(
                child: Text(
                  user.label,
                  style: AppText.outfit(
                    size: 25.6,
                    weight: FontWeight.w800,
                    height: 1.1,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              _editIcon(() {
                _name.text = user.displayName ?? user.label;
                setState(() => _editName = true);
              }),
            ],
          ),
        const SizedBox(height: 4),
        Text(
          user.email,
          style: AppText.outfit(size: 13.6, color: AppColors.textMuted),
        ),
        const SizedBox(height: 14),
        if (_editBio)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _bio,
                maxLines: 3,
                style: AppText.outfit(size: 14.4),
                decoration: _editDecoration().copyWith(
                  hintText: 'Write a short bio...',
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _saveButton('Save bio', _savingBio, _saveBio),
                  const SizedBox(width: 8),
                  _cancelButton(() => setState(() => _editBio = false)),
                ],
              ),
            ],
          )
        else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: Text(
                  user.bio.isEmpty
                      ? 'No bio yet — click the pencil to add one'
                      : user.bio,
                  style: AppText.outfit(
                    size: 14.4,
                    color: user.bio.isEmpty
                        ? AppColors.textMuted
                        : const Color(0xFF5A626E),
                    height: 1.6,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _editIcon(() {
                _bio.text = user.bio;
                setState(() => _editBio = true);
              }),
            ],
          ),
      ],
    );
  }

  Widget _stats(List<Rental> rentals, bool stacked) {
    final spent = rentals.fold<num>(0, (sum, rental) => sum + rental.price);
    final completed = rentals
        .where((rental) => rental.status == 'completed')
        .length;
    return Container(
      margin: EdgeInsets.only(top: stacked ? 20 : 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _stat('${rentals.length}', 'Rentals'),
          _statDivider(),
          _stat('€${formatGrouped(spent)}', 'Total spent'),
          _statDivider(),
          _stat('$completed', 'Completed'),
        ],
      ),
    );
  }

  Widget _stat(String value, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Text(
            value,
            style: AppText.outfit(size: 22.4, weight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            label.toUpperCase(),
            style: AppText.outfit(
              size: 12,
              weight: FontWeight.w600,
              color: AppColors.textMuted,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statDivider() {
    return Container(width: 1, height: 40, color: AppColors.borderLight);
  }

  Widget _editIcon(VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: const AppIcon('edit', size: 14, color: AppColors.textMuted),
      ),
    );
  }

  Widget _saveButton(String label, bool loading, VoidCallback onTap) {
    return HoverButton(
      onPressed: loading ? null : onTap,
      enabled: !loading,
      radius: 7,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      child: loading
          ? const AppSpinner(size: 14)
          : Text(
              label,
              style: AppText.outfit(
                size: 13.6,
                weight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
    );
  }

  Widget _cancelButton(VoidCallback onTap) {
    return HoverButton(
      onPressed: onTap,
      background: Colors.transparent,
      hoverBackground: AppColors.searchBg,
      foreground: AppColors.textMuted,
      borderColor: AppColors.borderLight,
      radius: 7,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: const Text('Cancel'),
    );
  }

  InputDecoration _editDecoration() {
    return const InputDecoration(
      isDense: true,
      filled: true,
      fillColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(color: AppColors.accentBlue, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(color: AppColors.accentBlue, width: 1.5),
      ),
    );
  }

  Widget _panel({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 48),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: child,
    );
  }

  List<Rental> _merge(List<Rental> remote, List<Booking> local) {
    final seen = remote.map((item) => item.bookingRef).toSet();
    final extras = <Rental>[
      for (final booking in local)
        if (booking.local && !seen.contains(booking.id))
          Rental(
            bookingRef: booking.id,
            carName: booking.name,
            carImage: booking.image,
            startDate: booking.dates,
            endDate: '',
            days: 1,
            price: _priceFromTotal(booking.total),
            status: booking.active ? 'upcoming' : booking.status.toLowerCase(),
            location: booking.location,
          ),
    ];
    return [...extras, ...remote];
  }

  num _priceFromTotal(String total) {
    final digits = total.replaceAll(RegExp(r'[^0-9.]'), '');
    return num.tryParse(digits) ?? 0;
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.user, required this.onTap});

  final SessionUser user;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final photo = user.photoUrl;
    return Tooltip(
      message: 'Click to change photo',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 4),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1F000000),
                blurRadius: 20,
                offset: Offset(0, 4),
              ),
            ],
            gradient: photo == null || photo.isEmpty
                ? const LinearGradient(
                    colors: [AppColors.accentBlue, AppColors.navyMid],
                  )
                : null,
          ),
          clipBehavior: Clip.antiAlias,
          alignment: Alignment.center,
          child: photo != null && photo.isNotEmpty
              ? RemoteOrAssetImage(
                  source: photo,
                  fit: BoxFit.cover,
                  width: 100,
                  height: 100,
                )
              : Text(
                  user.initials,
                  style: AppText.outfit(
                    size: 32,
                    weight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }
}

class _RentalCard extends StatelessWidget {
  const _RentalCard({required this.rental, required this.stacked});

  final Rental rental;
  final bool stacked;

  @override
  Widget build(BuildContext context) {
    final badge = _badge(rental.status);
    final image = SizedBox(
      width: stacked ? double.infinity : 200,
      height: stacked ? 160 : 120,
      child: ColoredBox(
        color: AppColors.infoBg,
        child: RemoteOrAssetImage(
          source: rental.carImage.isEmpty
              ? 'assets/brand/WLR_CAR_RS6.png'
              : rental.carImage,
          fit: BoxFit.cover,
        ),
      ),
    );
    final body = Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                rental.bookingRef,
                style: AppText.outfit(
                  size: 11.5,
                  weight: FontWeight.w600,
                  color: AppColors.textMuted,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: badge.$1,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  badge.$2,
                  style: AppText.outfit(
                    size: 11.5,
                    weight: FontWeight.w700,
                    color: badge.$3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            rental.carName,
            style: AppText.outfit(size: 16.8, weight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            rental.endDate.isEmpty
                ? rental.startDate
                : '${rental.startDate} → ${rental.endDate}',
            style: AppText.outfit(
              size: 12.8,
              weight: FontWeight.w500,
              color: AppColors.textMuted,
            ),
          ),
          if (rental.location.isNotEmpty)
            Text(
              rental.location,
              style: AppText.outfit(
                size: 12.8,
                weight: FontWeight.w500,
                color: AppColors.textMuted,
              ),
            ),
        ],
      ),
    );
    final price = Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 28, 20),
      child: Column(
        crossAxisAlignment: stacked
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.end,
        children: [
          Text(
            '€${rental.price.round()}',
            style: AppText.outfit(size: 20.8, weight: FontWeight.w800),
          ),
          Text(
            '${rental.days} ${rental.days == 1 ? 'day' : 'days'}',
            style: AppText.outfit(
              size: 12.5,
              weight: FontWeight.w500,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 8),
          HoverButton(
            onPressed: () => context.go('/offerlist'),
            background: Colors.transparent,
            hoverBackground: AppColors.accentBlue,
            foreground: AppColors.accentBlue,
            borderColor: AppColors.accentBlue,
            radius: 7,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            child: const Text('Rebook'),
          ),
        ],
      ),
    );
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white),
      ),
      clipBehavior: Clip.antiAlias,
      child: stacked
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [image, body, price],
            )
          : Row(
              children: [
                image,
                Expanded(child: body),
                price,
              ],
            ),
    );
  }

  (Color, String, Color) _badge(String status) {
    switch (status) {
      case 'completed':
        return (AppColors.completedBg, 'Completed', AppColors.completed);
      case 'active':
        return (AppColors.activeBg, 'Active', AppColors.accentBlue);
      case 'cancelled':
        return (AppColors.errorBg, 'Cancelled', AppColors.error);
      default:
        return (AppColors.upcomingBg, 'Upcoming', AppColors.upcoming);
    }
  }
}
