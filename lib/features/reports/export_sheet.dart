import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/network/api_error_text.dart';
import '../../core/network/api_exception.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/widgets/widgets.dart';
import '../auth/state/auth_providers.dart';
import '../billing/pro_upsell.dart';
import '../extras/state/extras_providers.dart';
import 'state/reports_providers.dart';

/// Hisobotlarni Excel/PDF ga eksport qilish (Pro). Tanlangan davr (`Bugun/7 kun/30 kun/Custom`)
/// ishlatiladi; fayl yuklab olinib, ulashish oynasi ochiladi (saqlash, Telegram, email...).
Future<void> openExportSheet(BuildContext context, WidgetRef ref) async {
  final AppStrings s = context.s;

  if (!(ref.read(authControllerProvider).user?.isPro ?? false)) {
    await showProUpsell(
      context,
      ref,
      title: s.voiceProTitle,
      body: s.exportProBody,
      icon: Icons.file_download_rounded,
    );
    return;
  }

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (BuildContext _) => const _ExportSheet(),
  );
}

class _ExportSheet extends ConsumerStatefulWidget {
  const _ExportSheet();

  @override
  ConsumerState<_ExportSheet> createState() => _ExportSheetState();
}

class _ExportSheetState extends ConsumerState<_ExportSheet> {
  static const List<String> _types = <String>[
    'report',
    'sales',
    'expenses',
    'debts',
    'inventory',
  ];

  String _type = 'report';
  String _format = 'xlsx';
  bool _busy = false;
  String? _error;

  String _label(AppStrings s, String type) => switch (type) {
        'sales' => s.exportTypeSales,
        'expenses' => s.exportTypeExpenses,
        'debts' => s.exportTypeDebts,
        'inventory' => s.exportTypeInventory,
        _ => s.exportTypeReport,
      };

  String _ymd(DateTime date) {
    String two(int value) => value.toString().padLeft(2, '0');
    return '${date.year}-${two(date.month)}-${two(date.day)}';
  }

  Future<void> _export() async {
    final AppStrings s = context.s;
    final (DateTime from, DateTime to) =
        ref.read(reportsControllerProvider.notifier).range();

    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      final bytes = await ref.read(extrasRepositoryProvider).exportFile(
            type: _type,
            format: _format,
            from: _ymd(from),
            to: _ymd(to),
          );

      final Directory dir = await getTemporaryDirectory();
      final String path =
          '${dir.path}/bozorpro-$_type-${_ymd(from)}_${_ymd(to)}.$_format';
      await File(path).writeAsBytes(bytes, flush: true);

      if (!mounted) {
        return;
      }
      await Share.shareXFiles(
        <XFile>[
          XFile(
            path,
            mimeType: _format == 'pdf'
                ? 'application/pdf'
                : 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
          ),
        ],
      );
      if (mounted) {
        Navigator.of(context).pop();
      }
    } on ApiException catch (error) {
      if (mounted) {
        setState(() => _error = apiErrorText(s, error));
      }
    } catch (_) {
      if (mounted) {
        setState(() => _error = s.errorUnknown);
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppStrings s = context.s;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.screen),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(s.exportTitle, style: textTheme.titleMedium),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: <Widget>[
                for (final String type in _types)
                  ChoiceChip(
                    label: Text(_label(s, type)),
                    selected: _type == type,
                    onSelected: _busy ? null : (_) => setState(() => _type = type),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(s.exportFormat, style: textTheme.titleSmall),
            const SizedBox(height: AppSpacing.sm),
            SegmentedButton<String>(
              segments: const <ButtonSegment<String>>[
                ButtonSegment<String>(
                  value: 'xlsx',
                  label: Text('Excel'),
                  icon: Icon(Icons.table_chart_rounded),
                ),
                ButtonSegment<String>(
                  value: 'pdf',
                  label: Text('PDF'),
                  icon: Icon(Icons.picture_as_pdf_rounded),
                ),
              ],
              selected: <String>{_format},
              onSelectionChanged: (Set<String> value) =>
                  setState(() => _format = value.first),
            ),
            if (_error != null) ...<Widget>[
              const SizedBox(height: AppSpacing.md),
              Text(_error!, style: textTheme.bodySmall?.copyWith(color: Colors.red)),
            ],
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              label: _busy ? s.exportBusy : s.exportAction,
              icon: Icons.file_download_rounded,
              isLoading: _busy,
              onPressed: _export,
            ),
          ],
        ),
      ),
    );
  }
}
