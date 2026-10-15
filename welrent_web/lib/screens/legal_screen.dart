import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/catalog.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

class LegalScreen extends StatelessWidget {
  const LegalScreen.terms({super.key}) : privacy = false;
  const LegalScreen.privacy({super.key}) : privacy = true;

  final bool privacy;

  @override
  Widget build(BuildContext context) {
    final sections = privacy ? LegalCopy.privacy : LegalCopy.terms;
    final title = privacy ? 'Privacy Policy' : 'Terms of Service';
    final width = MediaQuery.sizeOf(context).width;
    return Padding(
      padding: const EdgeInsets.only(bottom: 80),
      child: CenteredContainer(
        maxWidth: 800,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 40, bottom: 60),
              margin: const EdgeInsets.only(bottom: 40),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.gridLine)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'LEGAL',
                    style: AppText.outfit(
                      size: 12.8,
                      weight: FontWeight.w700,
                      color: AppColors.accentBlue,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    style: AppText.playfair(
                      size: width < 700 ? 40 : 48,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Last updated: April 8, 2025',
                    style: AppText.outfit(
                      size: 15.2,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            for (final section in sections) ...[
              Text(
                section.title,
                style: AppText.outfit(size: 18.4, weight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              Text(
                section.body,
                style: AppText.outfit(
                  size: 15.2,
                  color: AppColors.bodyGrey,
                  height: 1.75,
                ),
              ),
              const SizedBox(height: 36),
            ],
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.infoBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: privacy
                  ? Wrap(
                      children: [
                        Text(
                          'Also read our ',
                          style: AppText.outfit(
                            size: 14.4,
                            color: AppColors.textMuted,
                          ),
                        ),
                        _link(context, 'Terms of Service', '/terms'),
                        Text(
                          ' and ',
                          style: AppText.outfit(
                            size: 14.4,
                            color: AppColors.textMuted,
                          ),
                        ),
                        _link(
                          context,
                          'find a Welrent location near you',
                          '/locations',
                        ),
                        Text(
                          '.',
                          style: AppText.outfit(
                            size: 14.4,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    )
                  : Wrap(
                      children: [
                        Text(
                          'Questions? Contact us at ',
                          style: AppText.outfit(
                            size: 14.4,
                            color: AppColors.textMuted,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => openExternal('mailto:legal@welrent.com'),
                          child: Text(
                            'legal@welrent.com',
                            style: AppText.outfit(
                              size: 14.4,
                              weight: FontWeight.w600,
                              color: AppColors.accentBlue,
                            ),
                          ),
                        ),
                        Text(
                          '. Also read our ',
                          style: AppText.outfit(
                            size: 14.4,
                            color: AppColors.textMuted,
                          ),
                        ),
                        _link(context, 'Privacy Policy', '/privacy'),
                        Text(
                          '.',
                          style: AppText.outfit(
                            size: 14.4,
                            color: AppColors.textMuted,
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

  Widget _link(BuildContext context, String label, String path) {
    return GestureDetector(
      onTap: () => context.go(path),
      child: Text(
        label,
        style: AppText.outfit(
          size: 14.4,
          weight: FontWeight.w600,
          color: AppColors.accentBlue,
        ),
      ),
    );
  }
}
