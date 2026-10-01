import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/network/api_error_text.dart';
import '../../core/network/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/utils/money.dart';
import '../../core/widgets/widgets.dart';
import '../auth/data/auth_models.dart';
import '../auth/state/auth_providers.dart';
import '../extras/state/extras_providers.dart';
import 'data/billing_models.dart';
import 'plan_text.dart';
import 'state/billing_providers.dart';

enum _PayMethod { payme, click, bonus }

/// TZ 31, 35, 36: tariflar — Bepul, Standart (savdo + ombor) va Pro.
///
/// Pullik tarif tanlanganda Payme yoki Click checkout sahifasi tashqi
/// brauzerda ochiladi. Asosiy tasdiqlash — backend webhook'i; ilova
/// `order_id` holatini polling qilib, to'lov o'tgach profilni yangilaydi.
class PlansScreen extends ConsumerStatefulWidget {
  const PlansScreen({super.key});

  @override
  ConsumerState<PlansScreen> createState() => _PlansScreenState();
}

class _PlansScreenState extends ConsumerState<PlansScreen>
    with WidgetsBindingObserver {
  static const Duration _pollInterval = Duration(seconds: 4);

  String? _orderId;
  UserPlan? _pendingPlan;
  bool _busy = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  /// Foydalanuvchi to'lov sahifasidan ilovaga qaytganda holat tekshiriladi.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _orderId != null) {
      _check();
    }
  }

  void _snack(String text) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  /// To'lov usuli: Payme, Click yoki (balans yetsa) bonus balansi.
  Future<_PayMethod?> _chooseMethod(
      {required double bonus, required int price}) {
    final AppStrings s = context.s;
    return showModalBottomSheet<_PayMethod>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screen,
              0,
              AppSpacing.screen,
              AppSpacing.lg,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  s.choosePaymentTitle,
                  style: Theme.of(sheetContext).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.lg),
                AppButton(
                  label: s.payWithPayme,
                  icon: Icons.account_balance_wallet_rounded,
                  onPressed: () =>
                      Navigator.of(sheetContext).pop(_PayMethod.payme),
                ),
                const SizedBox(height: AppSpacing.md),
                AppButton(
                  label: s.payWithClick,
                  icon: Icons.touch_app_rounded,
                  variant: AppButtonVariant.secondary,
                  onPressed: () =>
                      Navigator.of(sheetContext).pop(_PayMethod.click),
                ),
                if (bonus >= price) ...<Widget>[
                  const SizedBox(height: AppSpacing.md),
                  AppButton(
                    label: '${s.payWithBonus} (${Money.format(bonus)})',
                    icon: Icons.card_giftcard_rounded,
                    variant: AppButtonVariant.outline,
                    onPressed: () =>
                        Navigator.of(sheetContext).pop(_PayMethod.bonus),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  /// Tarif tanlandi: provayder -> checkout -> brauzerda to'lov sahifasi.
  Future<void> _start(UserPlan plan, int price) async {
    // Bonus balansi (yetsa uchinchi usul sifatida taklif qilinadi).
    double bonus = 0;
    try {
      bonus = (await ref.read(bonusesProvider.future)).balance;
    } on ApiException {
      bonus = 0;
    }
    if (!mounted) {
      return;
    }

    final _PayMethod? method = await _chooseMethod(bonus: bonus, price: price);
    if (method == null || !mounted) {
      return;
    }

    final AppStrings s = context.s;
    setState(() => _busy = true);
    try {
      if (method == _PayMethod.bonus) {
        await ref
            .read(extrasRepositoryProvider)
            .payPlanWithBonus(plan.apiValue);
        await ref.read(authControllerProvider.notifier).refreshUser();
        ref.invalidate(bonusesProvider);
        ref.invalidate(billingPlansProvider);
        _snack(s.planActivatedText(plan.label(s)));
        return;
      }

      final PaymentProvider provider = method == _PayMethod.payme
          ? PaymentProvider.payme
          : PaymentProvider.click;
      final CheckoutResult result = await ref
          .read(billingRepositoryProvider)
          .checkout(plan: plan, provider: provider);

      final String? url = result.checkoutUrl;
      if (url == null || url.isEmpty) {
        _snack(s.checkoutUnavailable);
        return;
      }

      final bool opened = await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );
      if (!opened) {
        _snack(s.checkoutUnavailable);
        return;
      }

      if (mounted) {
        setState(() {
          _orderId = result.orderId;
          _pendingPlan = plan;
        });
        _startPolling();
      }
    } on ApiException catch (error) {
      _snack(apiErrorText(s, error));
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  void _startPolling() {
    _timer?.cancel();
    _timer = Timer.periodic(_pollInterval, (_) => _check());
  }

  void _stopPolling() {
    _timer?.cancel();
    _timer = null;
  }

  /// To'lov holatini so'raydi; to'langan bo'lsa tarifni yangilaydi.
  Future<void> _check({bool manual = false}) async {
    final String? orderId = _orderId;
    final UserPlan? plan = _pendingPlan;
    if (orderId == null) {
      return;
    }

    final AppStrings s = context.s;
    try {
      final PaymentStatus status =
          await ref.read(billingRepositoryProvider).paymentStatus(orderId);
      if (!mounted || _orderId != orderId) {
        return;
      }

      if (status == PaymentStatus.paid) {
        _stopPolling();
        setState(() {
          _orderId = null;
          _pendingPlan = null;
        });
        await ref.read(authControllerProvider.notifier).refreshUser();
        ref.invalidate(billingPlansProvider);
        _snack(s.planActivatedText((plan ?? UserPlan.standard).label(s)));
      } else if (status == PaymentStatus.failed ||
          status == PaymentStatus.canceled) {
        _stopPolling();
        setState(() {
          _orderId = null;
          _pendingPlan = null;
        });
        _snack(s.paymentFailedLabel);
      } else if (manual) {
        _snack(s.paymentPendingBody);
      }
    } on ApiException catch (error) {
      if (manual) {
        _snack(apiErrorText(s, error));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppStrings s = context.s;
    final AsyncValue<BillingPlans> plans = ref.watch(billingPlansProvider);

    return Scaffold(
      appBar: AppBar(title: Text(s.planScreenTitle)),
      body: plans.when(
        loading: () => const SkeletonDetail(),
        error: (Object error, StackTrace _) => EmptyState(
          icon: Icons.wifi_off_rounded,
          title: s.errorNetwork,
          message: apiErrorText(s, error),
          actionLabel: s.retry,
          onAction: () => ref.invalidate(billingPlansProvider),
        ),
        data: (BillingPlans data) => _buildPlans(s, data),
      ),
    );
  }

  Widget _buildPlans(AppStrings s, BillingPlans data) {
    final PlanOffer? standard = data.offerFor(UserPlan.standard);
    final PlanOffer? pro = data.offerFor(UserPlan.pro);
    final UserPlan current = data.current;
    final bool trial = data.isTrial && current == UserPlan.standard;
    final bool trialEnded =
        data.trialUsed && current == UserPlan.free && !data.isTrial;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screen),
      children: <Widget>[
        _CurrentPlanCard(
          plan: current,
          expiresAt: data.expiresAt,
          isTrial: trial,
        ),
        if (trial) ...<Widget>[
          const SizedBox(height: AppSpacing.md),
          _InfoCard(
            icon: Icons.card_giftcard_rounded,
            color: AppColors.info,
            title: s.trialActiveTitle,
            body: s.trialActiveBody(
              data.trialDays,
              data.expiresAt == null
                  ? '—'
                  : s.dyn(DateFormat('d MMMM yyyy', s.localeCode)
                      .format(data.expiresAt!.toLocal())),
            ),
          ),
        ],
        if (trialEnded) ...<Widget>[
          const SizedBox(height: AppSpacing.md),
          _InfoCard(
            icon: Icons.lock_clock_rounded,
            color: AppColors.warning,
            title: s.trialEndedTitle,
            body: s.trialEndedBody,
          ),
        ],
        if (_orderId != null) ...<Widget>[
          const SizedBox(height: AppSpacing.lg),
          _PendingCard(
            onCheck: () => _check(manual: true),
          ),
        ],
        const SizedBox(height: AppSpacing.lg),

        // —— Bepul tarif
        _PlanCard(
          title: s.planFreeName,
          price: '0 ${Money.currency}',
          duration: s.planDurationUnlimited,
          features: <String>[
            s.limitCustomersText(data.freeMaxCustomers),
            ...s.planFreeFeatures,
          ],
          isCurrent: current == UserPlan.free,
          isIncluded: false,
          showAction: false,
          actionLabel: '',
          busy: false,
        ),
        const SizedBox(height: AppSpacing.md),

        // —— Standart (sinovda turganda ham to'lab 30 kunga cho'zish mumkin)
        if (standard != null)
          _PlanCard(
            title: s.planStandardName,
            price: Money.format(standard.price),
            duration: s.planDurationText(standard.days),
            features: <String>[
              s.limitCustomersText(standard.maxCustomers),
              s.limitProductsText(standard.maxProducts),
              ...s.planStandardFeatures,
            ],
            isCurrent: current == UserPlan.standard,
            currentBadge: trial ? s.trialBadge : null,
            isIncluded: current == UserPlan.pro,
            showAction: (current == UserPlan.free || trial) && _orderId == null,
            actionLabel: trial ? s.standardExtendAction : s.planActivateAction,
            busy: _busy,
            onAction: () => _start(UserPlan.standard, standard.price),
          ),
        const SizedBox(height: AppSpacing.md),

        // —— Pro
        if (pro != null)
          _PlanCard(
            title: s.planProName,
            price: Money.format(pro.price),
            duration: s.planDurationText(pro.days),
            features: <String>[
              s.limitCustomersText(pro.maxCustomers),
              s.limitProductsText(pro.maxProducts),
              ...s.planProFeatures,
            ],
            highlighted: true,
            isCurrent: current == UserPlan.pro,
            isIncluded: false,
            showAction: current != UserPlan.pro && _orderId == null,
            actionLabel: current == UserPlan.standard
                ? s.planUpgradeProAction
                : s.planActivateAction,
            busy: _busy,
            onAction: () => _start(UserPlan.pro, pro.price),
          ),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }
}

class _CurrentPlanCard extends StatelessWidget {
  const _CurrentPlanCard({
    required this.plan,
    required this.expiresAt,
    this.isTrial = false,
  });

  final UserPlan plan;
  final DateTime? expiresAt;
  final bool isTrial;

  @override
  Widget build(BuildContext context) {
    final AppStrings s = context.s;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return AppCard(
      child: Row(
        children: <Widget>[
          Container(
            height: 44,
            width: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.lightGreen,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.workspace_premium_rounded,
              color: AppColors.darkGreen,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(s.planCurrentLabel, style: textTheme.bodySmall),
                Row(
                  children: <Widget>[
                    Text(plan.label(s), style: textTheme.titleMedium),
                    if (isTrial) ...<Widget>[
                      const SizedBox(width: AppSpacing.sm),
                      _Pill(text: s.trialBadge, color: AppColors.info),
                    ],
                  ],
                ),
                if (plan != UserPlan.free && expiresAt != null)
                  Text(
                    '${s.proExpiresLabel}: '
                    '${s.dyn(DateFormat('d MMMM yyyy', s.localeCode).format(expiresAt!.toLocal()))}',
                    style: textTheme.labelSmall,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return AppCard(
      borderColor: color,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, color: color),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title, style: textTheme.titleSmall),
                const SizedBox(height: AppSpacing.xs),
                Text(body, style: textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Tarif kartasi: nomi, narxi, muddati, to'liq imkoniyatlar ro'yxati va harakat tugmasi.
class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.title,
    required this.price,
    required this.duration,
    required this.features,
    required this.actionLabel,
    required this.busy,
    required this.showAction,
    this.onAction,
    this.isCurrent = false,
    this.isIncluded = false,
    this.highlighted = false,
    this.currentBadge,
  });

  final String title;
  final String price;
  final String duration;
  final List<String> features;
  final String actionLabel;
  final bool busy;
  final bool showAction;
  final VoidCallback? onAction;

  /// Shu tarif hozir faol.
  final bool isCurrent;

  /// Yuqoriroq tarif (Pro) shu tarifni o'z ichiga oladi.
  final bool isIncluded;
  final bool highlighted;

  /// Faol belgisi o'rniga ko'rsatiladigan matn (masalan, "Bepul sinov").
  final String? currentBadge;

  @override
  Widget build(BuildContext context) {
    final AppStrings s = context.s;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return AppCard(
      borderColor: highlighted || isCurrent ? AppColors.primary : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(child: Text(title, style: textTheme.titleMedium)),
              if (isCurrent || isIncluded)
                _Pill(
                  text: currentBadge ?? s.planActiveLabel,
                  color: AppColors.primary,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            price,
            style: textTheme.titleLarge?.copyWith(color: AppColors.primary),
          ),
          Row(
            children: <Widget>[
              Icon(Icons.schedule_rounded,
                  size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(duration, style: textTheme.labelSmall),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(s.planWhatIncluded, style: textTheme.labelMedium),
          const SizedBox(height: AppSpacing.sm),
          for (final String feature in features)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Icon(
                    Icons.check_circle_rounded,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(child: Text(feature, style: textTheme.bodyMedium)),
                ],
              ),
            ),
          if (showAction) ...<Widget>[
            const SizedBox(height: AppSpacing.sm),
            AppButton(
              label: actionLabel,
              isLoading: busy,
              onPressed: onAction,
            ),
          ],
        ],
      ),
    );
  }
}

/// To'lov kutilmoqda holati (TZ 36.2): foydalanuvchi holatni qo'lda ham tekshira oladi.
class _PendingCard extends StatelessWidget {
  const _PendingCard({required this.onCheck});

  final VoidCallback onCheck;

  @override
  Widget build(BuildContext context) {
    final AppStrings s = context.s;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return AppCard(
      color: AppColors.warningSurface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(strokeWidth: 2.2),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  s.paymentPendingTitle,
                  style: textTheme.titleSmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(s.paymentPendingBody, style: textTheme.bodySmall),
          const SizedBox(height: AppSpacing.md),
          AppButton(
            label: s.checkStatusAction,
            variant: AppButtonVariant.outline,
            size: AppButtonSize.medium,
            onPressed: onCheck,
          ),
        ],
      ),
    );
  }
}
