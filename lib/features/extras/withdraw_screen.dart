import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/network/api_error_text.dart';
import '../../core/network/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/utils/money.dart';
import '../../core/widgets/widgets.dart';
import '../auth/state/auth_providers.dart';
import 'state/extras_providers.dart';

/// Bonusni plastik kartaga yechib olish so'rovi. So'rov adminga yuboriladi,
/// summa balansdan darhol ushlab qolinadi; admin pulni o'tkazgach holat
/// "To'landi" bo'ladi (rad etilsa summa balansga qaytadi).
class WithdrawScreen extends ConsumerStatefulWidget {
  const WithdrawScreen({
    super.key,
    required this.balance,
    required this.minWithdrawal,
  });

  final double balance;
  final double minWithdrawal;

  @override
  ConsumerState<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends ConsumerState<WithdrawScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _cardController = TextEditingController();
  final TextEditingController _holderController = TextEditingController();

  int _amount = 0;
  String? _amountError;
  String? _cardError;
  bool _busy = false;

  @override
  void dispose() {
    _amountController.dispose();
    _cardController.dispose();
    _holderController.dispose();
    super.dispose();
  }

  void _fillAll() {
    final int all = widget.balance.floor();
    _amountController.text = Money.group(all);
    setState(() {
      _amount = all;
      _amountError = null;
    });
  }

  Future<void> _submit() async {
    final AppStrings s = context.s;
    final String card = _cardController.text.replaceAll(RegExp(r'\D'), '');

    String? amountError;
    if (_amount <= 0) {
      amountError = s.validationAmountRequired;
    } else if (_amount < widget.minWithdrawal) {
      amountError = s.withdrawMinText(Money.format(widget.minWithdrawal));
    } else if (_amount > widget.balance) {
      amountError = s.amountExceedsText(Money.format(widget.balance));
    }
    final String? cardError = card.length == 16 ? null : s.validationCardInvalid;

    setState(() {
      _amountError = amountError;
      _cardError = cardError;
    });
    if (amountError != null || cardError != null) {
      return;
    }

    setState(() => _busy = true);
    try {
      await ref.read(extrasRepositoryProvider).requestWithdrawal(
            amount: _amount,
            cardNumber: card,
            cardHolder: _holderController.text,
          );
      ref.invalidate(bonusesProvider);
      ref.invalidate(withdrawalsProvider);
      ref.invalidate(referralProvider);
      await ref.read(authControllerProvider.notifier).refreshUser();

      if (!mounted) {
        return;
      }
      await showDialog<void>(
        context: context,
        builder: (BuildContext dialogContext) => AlertDialog(
          icon: const Icon(
            Icons.check_circle_rounded,
            color: AppColors.primary,
            size: 44,
          ),
          title: Text(s.withdrawSentTitle, textAlign: TextAlign.center),
          content: Text(s.withdrawSentBody, textAlign: TextAlign.center),
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
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(apiErrorText(s, error))));
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

    return Scaffold(
      appBar: AppBar(title: Text(s.withdrawTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.screen),
          children: <Widget>[
            AppCard(
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(s.bonusBalanceLabel, style: textTheme.bodySmall),
                        Text(
                          Money.format(widget.balance),
                          style: textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: widget.balance > 0 ? _fillAll : null,
                    child: Text(s.withdrawAllAction),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            MoneyInput(
              label: s.withdrawAmountLabel,
              controller: _amountController,
              errorText: _amountError,
              helperText: s.withdrawMinText(Money.format(widget.minWithdrawal)),
              onChanged: (int value) => setState(() {
                _amount = value;
                _amountError = null;
              }),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              label: s.withdrawCardLabel,
              hint: '8600 0000 0000 0000',
              controller: _cardController,
              errorText: _cardError,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              prefixIcon: Icons.credit_card_rounded,
              inputFormatters: <TextInputFormatter>[_CardNumberFormatter()],
              onChanged: (String _) {
                if (_cardError != null) {
                  setState(() => _cardError = null);
                }
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              label: s.withdrawHolderLabel,
              controller: _holderController,
              textInputAction: TextInputAction.done,
              prefixIcon: Icons.person_outline_rounded,
            ),
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              label: s.withdrawSubmit,
              icon: Icons.send_rounded,
              isLoading: _busy,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}

/// Karta raqamini 4 tadan guruhlaydi: `8600 1234 5678 9012` (max 16 raqam).
class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.length > 16) {
      digits = digits.substring(0, 16);
    }
    final StringBuffer buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(digits[i]);
    }
    final String text = buffer.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
