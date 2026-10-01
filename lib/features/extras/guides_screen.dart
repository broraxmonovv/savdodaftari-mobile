import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/network/api_error_text.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/utils/link.dart';
import '../../core/widgets/widgets.dart';
import 'data/extras_models.dart';
import 'state/extras_providers.dart';

/// Qo'llanma videolar ro'yxati (backend `/guides`); bosilganda video tashqi
/// ilovada (YouTube/brauzer) ochiladi.
class GuidesScreen extends ConsumerWidget {
  const GuidesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppStrings s = context.s;
    final AsyncValue<List<GuideVideo>> guides = ref.watch(guidesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(s.guidesTitle)),
      body: guides.when(
        loading: () => const SkeletonList(),
        error: (Object error, StackTrace _) => EmptyState(
          icon: Icons.wifi_off_rounded,
          title: s.errorNetwork,
          message: apiErrorText(s, error),
          actionLabel: s.retry,
          onAction: () => ref.invalidate(guidesProvider),
        ),
        data: (List<GuideVideo> items) {
          if (items.isEmpty) {
            return EmptyState(
              icon: Icons.ondemand_video_rounded,
              title: s.guidesEmpty,
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.screen),
            itemCount: items.length,
            separatorBuilder: (BuildContext _, int __) =>
                const SizedBox(height: AppSpacing.md),
            itemBuilder: (BuildContext context, int index) {
              final GuideVideo video = items[index];
              return AppCard(
                padding: const EdgeInsets.all(AppSpacing.md),
                onTap: () => openLink(context, Uri.parse(video.url)),
                child: Row(
                  children: <Widget>[
                    Container(
                      height: 44,
                      width: 44,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.dangerSurface,
                        borderRadius: AppRadius.field,
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        color: AppColors.danger,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        context.s.dyn(video.title),
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                    Icon(Icons.open_in_new_rounded,
                        size: 18, color: AppColors.textSecondary),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
