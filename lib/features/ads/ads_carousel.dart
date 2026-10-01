import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/widgets/widgets.dart';
import '../extras/data/extras_models.dart';
import '../extras/state/extras_providers.dart';

/// Bosh sahifa sarlavhasi ostidagi reklama karuseli. Rasmga bosilganda
/// banner havolasi tashqi brauzerda ochiladi. Bannerlar bo'lmasa — ko'rinmaydi.
class AdsCarousel extends ConsumerWidget {
  const AdsCarousel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<AdBanner>> banners = ref.watch(bannersProvider);

    return banners.when(
      loading: () => const _AdsPlaceholder(),
      error: (Object _, StackTrace __) => const SizedBox.shrink(),
      data: (List<AdBanner> items) => items.isEmpty
          ? const SizedBox.shrink()
          : Padding(
              padding: const EdgeInsets.only(top: AppSpacing.lg),
              child: AdsCarouselView(banners: items),
            ),
    );
  }
}

class _AdsPlaceholder extends StatelessWidget {
  const _AdsPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screen,
        AppSpacing.lg,
        AppSpacing.screen,
        0,
      ),
      child: SkeletonShimmer(
        child: AspectRatio(
          aspectRatio: AdsCarouselView.aspectRatio,
          child: SkeletonBox(height: double.infinity, radius: 18),
        ),
      ),
    );
  }
}

class AdsCarouselView extends ConsumerStatefulWidget {
  const AdsCarouselView({super.key, required this.banners});

  /// Banner rasmi nisbati (tavsiya: 1200×500).
  static const double aspectRatio = 2.75;

  final List<AdBanner> banners;

  @override
  ConsumerState<AdsCarouselView> createState() => _AdsCarouselViewState();
}

class _AdsCarouselViewState extends ConsumerState<AdsCarouselView> {
  final PageController _controller = PageController(viewportFraction: 0.92);
  Timer? _timer;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _restartTimer();
  }

  @override
  void didUpdateWidget(covariant AdsCarouselView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.banners.length != widget.banners.length) {
      _index = 0;
      _restartTimer();
    }
  }

  void _restartTimer() {
    _timer?.cancel();
    if (widget.banners.length < 2) {
      return;
    }
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || !_controller.hasClients) {
        return;
      }
      final int next = (_index + 1) % widget.banners.length;
      _controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _open(AdBanner banner) async {
    final AppStrings s = context.s;
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final Uri? uri = Uri.tryParse(banner.url);
    unawaited(ref.read(extrasRepositoryProvider).bannerClicked(banner.id));

    bool opened = false;
    if (uri != null && (uri.scheme == 'http' || uri.scheme == 'https')) {
      try {
        opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (_) {}
    }
    if (!opened) {
      messenger.showSnackBar(SnackBar(content: Text(s.openLinkFailed)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<AdBanner> banners = widget.banners;

    return Column(
      children: <Widget>[
        AspectRatio(
          // Sahifa kengligi = ekran, karta kengligi = 92% - chetlar: karta nisbati banner rasmiga teng bo'lsin
          aspectRatio: AdsCarouselView.aspectRatio / 0.93,
          child: PageView.builder(
            controller: _controller,
            itemCount: banners.length,
            onPageChanged: (int value) => setState(() => _index = value),
            itemBuilder: (BuildContext context, int i) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: _BannerCard(banner: banners[i], onTap: () => _open(banners[i])),
            ),
          ),
        ),
        if (banners.length > 1) ...<Widget>[
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              for (int i = 0; i < banners.length; i++)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  height: 6,
                  width: i == _index ? 18 : 6,
                  decoration: BoxDecoration(
                    color: i == _index ? AppColors.primary : AppColors.border,
                    borderRadius: AppRadius.pill,
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _BannerCard extends StatelessWidget {
  const _BannerCard({required this.banner, required this.onTap});

  final AdBanner banner;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: banner.title,
      child: Material(
        color: AppColors.card,
        elevation: 0,
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              boxShadow: AppShadows.soft,
            ),
            child: Image.network(
              banner.imageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              loadingBuilder: (
                BuildContext context,
                Widget child,
                ImageChunkEvent? progress,
              ) =>
                  progress == null
                      ? child
                      : const SkeletonShimmer(
                          child: SkeletonBox(
                            height: double.infinity,
                            radius: 18,
                          ),
                        ),
              errorBuilder: (BuildContext _, Object __, StackTrace? ___) =>
                  Container(
                color: AppColors.lightGreen,
                alignment: Alignment.center,
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Text(
                  banner.title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.darkGreen,
                      ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
