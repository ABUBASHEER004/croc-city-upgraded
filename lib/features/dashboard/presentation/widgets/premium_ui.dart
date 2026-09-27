
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../constants/app_colors.dart';

class PremiumDashboardBackground extends StatelessWidget {
  const PremiumDashboardBackground({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Stack(
      children: [
        Positioned.fill(child: Container(color: dark ? const Color(0xFF0B1220) : AppColors.background)),
        Positioned(
          top: -120, right: -90,
          child: Opacity(
            opacity: dark ? .08 : .055,
            child: Image.asset('assets/images/logo.jpg', width: 300, height: 300, fit: BoxFit.contain),
          ),
        ),
        Positioned(
          bottom: -100, left: -100,
          child: Opacity(
            opacity: dark ? .05 : .035,
            child: Image.asset('assets/images/logo.jpg', width: 260, height: 260, fit: BoxFit.contain),
          ),
        ),
        SafeArea(child: child),
      ],
    );
  }
}

class PremiumHero extends StatelessWidget {
  const PremiumHero({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    this.image = 'assets/images/stadium.jpg',
    this.icon = Icons.sports_soccer,
  });

  final String eyebrow;
  final String title;
  final String subtitle;
  final String image;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 28,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          Image.asset(
            image,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: AppColors.primary,
                child: const Center(
                  child: Icon(
                    Icons.sports_soccer_rounded,
                    color: Colors.white24,
                    size: 90,
                  ),
                ),
              );
            },
          ),

          // Dark branded overlay
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary.withValues(alpha: 0.94),
                  AppColors.primary.withValues(alpha: 0.62),
                  Colors.black.withValues(alpha: 0.72),
                ],
              ),
            ),
          ),

          // Croc City pattern
          Positioned.fill(
            child: IgnorePointer(
              child: Opacity(
                opacity: 0.18,
                child: SvgPicture.asset(
                  'assets/icons/croc_city_pattern.svg',
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                ),
              ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      icon,
                      color: AppColors.secondary,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        eyebrow.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 27,
                    height: 1.05,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  subtitle,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PremiumStat extends StatelessWidget {
  const PremiumStat({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
  });

  final String value;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF111827) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.border,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 18,
            offset: Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.muted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PremiumSection extends StatelessWidget {
  const PremiumSection({
    super.key,
    required this.title,
    required this.child,
    this.action,
  });

  final String title;
  final Widget child;
  final VoidCallback? action;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
            ),
            if (action != null)
              TextButton.icon(
                onPressed: action,
                icon: const Icon(
                  Icons.arrow_forward_rounded,
                  size: 16,
                ),
                label: const Text('View all'),
              ),
          ],
        ),
        const SizedBox(height: 10),
        child,
      ],
    );
  }
}

class PremiumFeatureScreen extends StatelessWidget {
  const PremiumFeatureScreen({
    super.key,
    required this.title,
    required this.eyebrow,
    required this.description,
    required this.icon,
    this.actions = const [],
  });

  final String title;
  final String eyebrow;
  final String description;
  final IconData icon;
  final List<PremiumFeatureAction> actions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 32),
        children: [
          PremiumHero(
            eyebrow: eyebrow,
            title: title,
            subtitle: description,
            icon: icon,
          ),

          const SizedBox(height: 20),

          ...actions.map(
            (action) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Card(
                elevation: 0,
                clipBehavior: Clip.antiAlias,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(17),
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.09),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(
                      action.icon,
                      color: AppColors.primary,
                    ),
                  ),
                  title: Text(
                    action.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(action.subtitle),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                  ),
                  onTap: action.onTap,
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Premium academy information panel
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.10),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.auto_awesome_rounded,
                  color: AppColors.secondary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Designed for a professional academy workflow — '
                    'clean, focused and ready for live data.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PremiumFeatureAction {
  const PremiumFeatureAction({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onTap;
}

