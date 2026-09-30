import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/widgets/widgets.dart';
import '../printing/printer_screen.dart';
import '../printing/receipt_printer.dart';
import 'data/sale_models.dart';

/// TZ 16: elektron chek — savdodan keyin ko'rsatiladi, nusxalash mumkin.
Future<void> showReceiptSheet(BuildContext context, SaleReceipt receipt) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (BuildContext context) => _ReceiptSheet(receipt: receipt),
  );
}

class _ReceiptSheet extends ConsumerStatefulWidget {
  const _ReceiptSheet({required this.receipt});

  final SaleReceipt receipt;

  @override
  ConsumerState<_ReceiptSheet> createState() => _ReceiptSheetState();
}

class _ReceiptSheetState extends ConsumerState<_ReceiptSheet> {
  bool _printing = false;

  SaleReceipt get receipt => widget.receipt;

  /// Bluetooth printerda chop etadi; printer tanlanmagan bo'lsa avval tanlash ekrani ochiladi.
  Future<void> _print() async {
    final AppStrings s = context.s;
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final ReceiptPrinter printer = ref.read(receiptPrinterProvider);

    PrinterConfig? config = await printer.savedPrinter();
    if (config == null) {
      if (!mounted) {
        return;
      }
      await Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (BuildContext _) => const PrinterScreen(),
        ),
      );
      config = await printer.savedPrinter();
      if (config == null) {
        return;
      }
    }

    setState(() => _printing = true);
    final List<String> lines = receipt.lines.isNotEmpty
        ? receipt.lines
        : receipt.text.split('\n');
    final PrintResult result = await printer.printLines(config, lines);
    if (mounted) {
      setState(() => _printing = false);
    }
    messenger.showSnackBar(
      SnackBar(content: Text(printResultText(s, result))),
    );
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                const Icon(
                  Icons.receipt_long_rounded,
                  color: AppColors.primary,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(s.receiptTitle, style: textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Flexible(
              child: SingleChildScrollView(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: AppRadius.card,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    receipt.text,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 13,
                      height: 1.6,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              label: s.printAction,
              icon: Icons.print_rounded,
              isLoading: _printing,
              onPressed: _print,
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: <Widget>[
                Expanded(
                  child: AppButton(
                    label: s.copyLabel,
                    icon: Icons.copy_rounded,
                    variant: AppButtonVariant.outline,
                    size: AppButtonSize.medium,
                    onPressed: () async {
                      await Clipboard.setData(
                        ClipboardData(text: receipt.text),
                      );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(s.receiptCopied)),
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: AppButton(
                    label: s.close,
                    size: AppButtonSize.medium,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
