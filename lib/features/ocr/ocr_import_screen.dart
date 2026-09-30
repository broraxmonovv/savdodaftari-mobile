import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/network/api_error_text.dart';
import '../../core/network/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/utils/money.dart';
import '../../core/widgets/widgets.dart';
import '../auth/data/auth_models.dart';
import '../auth/state/auth_providers.dart';
import '../billing/pro_upsell.dart';
import '../extras/data/extras_models.dart';
import '../extras/state/extras_providers.dart';

/// Sozlamalardan: Pro bo'lsa OCR ekrani ochiladi, aks holda Pro taklifi.
Future<void> openOcrImport(BuildContext context, WidgetRef ref) async {
  final AppStrings s = context.s;
  final AuthUser? user = ref.read(authControllerProvider).user;

  if (user == null || !user.isPro) {
    await showProUpsell(
      context,
      ref,
      title: s.voiceProTitle,
      body: s.ocrProBody,
      icon: Icons.document_scanner_rounded,
    );
    return;
  }

  await Navigator.of(context).push<void>(
    MaterialPageRoute<void>(builder: (BuildContext _) => const OcrImportScreen()),
  );
}

class _Row {
  _Row(OcrItem item)
      : name = TextEditingController(text: item.name),
        amount = TextEditingController(text: Money.group(item.amount)),
        phone = item.phone,
        note = item.note,
        uncertain = item.uncertain,
        existing = item.existingCustomerName;

  final TextEditingController name;
  final TextEditingController amount;
  final String? phone;
  final String? note;
  final bool uncertain;
  final String? existing;
  bool selected = true;

  int get value => Money.parse(amount.text);

  bool get valid => name.text.trim().isNotEmpty && value > 0;

  OcrItem toItem() => OcrItem(
        name: name.text.trim(),
        amount: value.toDouble(),
        phone: phone,
        note: note,
      );

  void dispose() {
    name.dispose();
    amount.dispose();
  }
}

/// TZ 15: eski qog'oz daftarni ko'chirish (Pro). Rasm -> AI tahlili -> TEKSHIRISH ->
/// import. Tasdiqlamasdan hech narsa yozilmaydi; noaniq qatorlar "Tekshirish kerak"
/// belgisi bilan ko'rsatiladi.
class OcrImportScreen extends ConsumerStatefulWidget {
  const OcrImportScreen({super.key});

  @override
  ConsumerState<OcrImportScreen> createState() => _OcrImportScreenState();
}

class _OcrImportScreenState extends ConsumerState<OcrImportScreen> {
  final ImagePicker _picker = ImagePicker();
  final List<_Row> _rows = <_Row>[];

  bool _analyzing = false;
  bool _importing = false;
  bool _analyzed = false;
  String? _error;

  @override
  void dispose() {
    for (final _Row row in _rows) {
      row.dispose();
    }
    super.dispose();
  }

  Future<void> _pick(ImageSource source) async {
    final AppStrings s = context.s;
    final XFile? file = await _picker.pickImage(
      source: source,
      maxWidth: 2200,
      imageQuality: 85,
    );
    if (file == null || !mounted) {
      return;
    }

    setState(() {
      _analyzing = true;
      _error = null;
    });

    try {
      final List<OcrItem> items =
          await ref.read(extrasRepositoryProvider).ocrExtract(file.path);
      if (!mounted) {
        return;
      }
      for (final _Row row in _rows) {
        row.dispose();
      }
      setState(() {
        _rows
          ..clear()
          ..addAll(items.map(_Row.new));
        _analyzed = true;
      });
    } on ApiException catch (error) {
      if (mounted) {
        setState(() => _error = apiErrorText(s, error));
      }
    } finally {
      if (mounted) {
        setState(() => _analyzing = false);
      }
    }
  }

  List<_Row> get _selected =>
      _rows.where((_Row r) => r.selected && r.valid).toList();

  int get _total => _selected.fold(0, (int sum, _Row r) => sum + r.value);

  Future<void> _import() async {
    final AppStrings s = context.s;
    final List<_Row> chosen = _selected;
    if (chosen.isEmpty) {
      return;
    }

    setState(() {
      _importing = true;
      _error = null;
    });
    try {
      final OcrImportSummary summary = await ref
          .read(extrasRepositoryProvider)
          .ocrConfirm(chosen.map((_Row r) => r.toItem()).toList());
      if (!mounted) {
        return;
      }
      await showDialog<void>(
        context: context,
        builder: (BuildContext dialogContext) => AlertDialog(
          icon: const Icon(Icons.check_circle_rounded,
              color: AppColors.primary, size: 44),
          title: Text(s.voiceDone, textAlign: TextAlign.center),
          content: Text(
            '${s.ocrImportedText(summary.customersCreated, summary.debtsCreated)}\n'
            '${Money.format(summary.total)}',
            textAlign: TextAlign.center,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(s.close),
            ),
          ],
        ),
      );
      if (mounted) {
        Navigator.of(context).pop();
      }
    } on ApiException catch (error) {
      if (mounted) {
        setState(() => _error = apiErrorText(s, error));
      }
    } finally {
      if (mounted) {
        setState(() => _importing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppStrings s = context.s;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(s.ocrTitle)),
      body: _analyzing
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const CircularProgressIndicator(),
                  const SizedBox(height: AppSpacing.lg),
                  Text(s.ocrAnalyzing, style: textTheme.titleSmall),
                ],
              ),
            )
          : (_analyzed && _rows.isNotEmpty ? _buildReview(s, textTheme) : _buildPicker(s, textTheme)),
    );
  }

  Widget _buildPicker(AppStrings s, TextTheme textTheme) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screen),
      children: <Widget>[
        const SizedBox(height: AppSpacing.xl),
        Center(
          child: Container(
            height: 96,
            width: 96,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.lightGreen,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.document_scanner_rounded,
                size: 44, color: AppColors.primary),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(s.ocrIntro, textAlign: TextAlign.center, style: textTheme.bodyMedium),
        if (_analyzed && _rows.isEmpty) ...<Widget>[
          const SizedBox(height: AppSpacing.lg),
          Text(
            s.ocrNothingFound,
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(color: AppColors.warning),
          ),
        ],
        if (_error != null) ...<Widget>[
          const SizedBox(height: AppSpacing.lg),
          Text(
            _error!,
            textAlign: TextAlign.center,
            style: textTheme.bodySmall?.copyWith(color: AppColors.danger),
          ),
        ],
        const SizedBox(height: AppSpacing.xxl),
        AppButton(
          label: s.ocrCamera,
          icon: Icons.photo_camera_rounded,
          onPressed: () => _pick(ImageSource.camera),
        ),
        const SizedBox(height: AppSpacing.md),
        AppButton(
          label: s.ocrGallery,
          icon: Icons.photo_library_rounded,
          variant: AppButtonVariant.secondary,
          onPressed: () => _pick(ImageSource.gallery),
        ),
      ],
    );
  }

  Widget _buildReview(AppStrings s, TextTheme textTheme) {
    final int count = _selected.length;

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.screen, 0, AppSpacing.screen, AppSpacing.sm),
          child: Text(s.ocrReviewHint, style: textTheme.bodySmall),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.screen),
            itemCount: _rows.length,
            separatorBuilder: (BuildContext _, int __) =>
                const SizedBox(height: AppSpacing.md),
            itemBuilder: (BuildContext context, int index) {
              final _Row row = _rows[index];
              return AppCard(
                padding: const EdgeInsets.all(AppSpacing.md),
                borderColor: row.uncertain ? AppColors.warning : null,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Checkbox(
                          value: row.selected,
                          onChanged: (bool? value) =>
                              setState(() => row.selected = value ?? false),
                        ),
                        Expanded(
                          child: TextField(
                            controller: row.name,
                            onChanged: (_) => setState(() {}),
                            decoration: const InputDecoration(isDense: true),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: TextField(
                        controller: row.amount,
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          MoneyTextInputFormatter(),
                        ],
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          isDense: true,
                          suffixText: Money.currency,
                        ),
                      ),
                    ),
                    if (row.uncertain || row.existing != null)
                      Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.sm, left: 12),
                        child: Wrap(
                          spacing: AppSpacing.sm,
                          runSpacing: AppSpacing.xs,
                          children: <Widget>[
                            if (row.uncertain)
                              _Tag(
                                text: s.ocrUncertain,
                                color: AppColors.warning,
                                icon: Icons.warning_amber_rounded,
                              ),
                            if (row.existing != null)
                              _Tag(
                                text: '${s.ocrExisting}: ${row.existing}',
                                color: AppColors.info,
                                icon: Icons.person_rounded,
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.screen),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Text(
                      _error!,
                      style: textTheme.bodySmall?.copyWith(color: AppColors.danger),
                    ),
                  ),
                Text(
                  s.ocrSelectedText(count, Money.format(_total)),
                  style: textTheme.titleSmall,
                ),
                const SizedBox(height: AppSpacing.sm),
                AppButton(
                  label: s.ocrImportAction,
                  icon: Icons.download_done_rounded,
                  isLoading: _importing,
                  onPressed: count == 0 ? null : _import,
                ),
                const SizedBox(height: AppSpacing.sm),
                AppButton(
                  label: s.ocrTryAgain,
                  variant: AppButtonVariant.outline,
                  size: AppButtonSize.medium,
                  onPressed: () => setState(() {
                    _analyzed = false;
                    _error = null;
                  }),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.text, required this.color, required this.icon});

  final String text;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
