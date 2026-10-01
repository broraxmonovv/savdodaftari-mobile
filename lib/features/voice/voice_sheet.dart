import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

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
import '../customers/state/customers_providers.dart';
import '../debts/state/debts_providers.dart';
import '../extras/data/extras_models.dart';
import '../extras/state/extras_providers.dart';
import '../home/state/home_providers.dart';
import '../inventory/state/products_providers.dart';

/// Mikrofon tugmasi bosilganda: Pro bo'lsa ovozli yordamchi ochiladi, aks holda
/// Pro taklifi ko'rsatiladi (TZ 34: bosilganda Pro banneriga yo'naltiriladi).
Future<void> openVoiceAssistant(BuildContext context, WidgetRef ref) async {
  final AppStrings s = context.s;
  final AuthUser? user = ref.read(authControllerProvider).user;

  if (user == null || !user.isPro) {
    await showProUpsell(
      context,
      ref,
      title: s.voiceProTitle,
      body: s.voiceProBody,
      icon: Icons.mic_rounded,
    );
    return;
  }

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (BuildContext _) => const VoiceSheet(),
  );
}

/// Ovozli boshqaruv (TZ 8): mikrofon -> matn -> backend tahlili -> tasdiqlash -> amal.
/// Yozuvchi buyruqlar (qarz, to'lov, kirim) faqat foydalanuvchi "Tasdiqlash"ni
/// bosgandan keyin mavjud API'lar orqali bajariladi. Mikrofon ishlamasa buyruqni
/// yozib yuborish mumkin.
class VoiceSheet extends ConsumerStatefulWidget {
  const VoiceSheet({super.key});

  @override
  ConsumerState<VoiceSheet> createState() => _VoiceSheetState();
}

class _VoiceSheetState extends ConsumerState<VoiceSheet> {
  final SpeechToText _speech = SpeechToText();
  final TextEditingController _input = TextEditingController();

  /// Tanish tili: 'uz' yoki 'ru'. Boshlang'ich qiymat — ilova tili; foydalanuvchi
  /// ilova tilidan qat'i nazar istalgan tilda gapira oladi (backend ikkalasini ham tushunadi).
  String? _lang;
  bool _speechReady = false;
  bool _listening = false;
  bool _busy = false;
  bool _executing = false;
  bool _done = false;
  String? _error;
  VoiceResult? _result;

  int? _customerId;
  String? _customerName;
  int? _productId;
  String? _productName;

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(_initSpeech);
  }

  @override
  void dispose() {
    _speech.stop();
    _input.dispose();
    super.dispose();
  }

  Future<void> _initSpeech() async {
    try {
      final bool ready = await _speech.initialize(
        onStatus: (String status) {
          if ((status == 'done' || status == 'notListening') && mounted) {
            setState(() => _listening = false);
          }
        },
        onError: (SpeechRecognitionError error) {
          if (mounted) {
            final bool language = error.errorMsg.contains('language');
            setState(() {
              _listening = false;
              _error = language
                  ? context.s.voiceLangUnavailable
                  : context.s.voiceUnavailable;
            });
          }
        },
      );
      if (mounted) {
        setState(() => _speechReady = ready);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _speechReady = false);
      }
    }
  }

  /// Tanlangan til uchun tanish locale'i. Qurilma ro'yxatida bo'lsa o'sha (`uz_UZ`, `uz-UZ`, `ru_RU` ...),
  /// bo'lmasa ham aniq locale beriladi: aks holda tizim standarti (ko'pincha inglizcha) ishlatilib,
  /// o'zbekcha gap inglizcha matnga aylanib qoladi.
  Future<String> _pickLocale(String languageCode) async {
    final String fallback = languageCode == 'ru' ? 'ru_RU' : 'uz_UZ';
    try {
      final List<LocaleName> locales = await _speech.locales();
      final List<LocaleName> matches = locales
          .where(
            (LocaleName it) => it.localeId
                .toLowerCase()
                .replaceAll('-', '_')
                .startsWith('${languageCode}_'),
          )
          .toList();
      if (matches.isNotEmpty) {
        // O'zbekiston/Rossiya variantini afzal ko'ramiz
        for (final LocaleName it in matches) {
          if (it.localeId.toLowerCase().replaceAll('-', '_') ==
              fallback.toLowerCase()) {
            return it.localeId;
          }
        }
        return matches.first.localeId;
      }
    } catch (_) {}
    return fallback;
  }

  Future<void> _toggleListening() async {
    if (_listening) {
      await _speech.stop();
      if (mounted) {
        setState(() => _listening = false);
      }
      return;
    }
    if (!_speechReady) {
      setState(() => _error = context.s.voiceUnavailable);
      return;
    }

    final String? localeId = await _pickLocale(_lang ?? context.s.localeCode);
    if (!mounted) {
      return;
    }
    setState(() {
      _listening = true;
      _error = null;
      _result = null;
      _done = false;
    });

    await _speech.listen(
      localeId: localeId,
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      onResult: (SpeechRecognitionResult result) {
        if (!mounted) {
          return;
        }
        setState(() => _input.text = result.recognizedWords);
        if (result.finalResult && result.recognizedWords.trim().isNotEmpty) {
          _send(result.recognizedWords);
        }
      },
    );
  }

  Future<void> _send(String text) async {
    final String command = text.trim();
    if (command.isEmpty || _busy) {
      return;
    }
    final AppStrings s = context.s;

    setState(() {
      _busy = true;
      _error = null;
      _result = null;
      _done = false;
      _customerId = null;
      _productId = null;
    });

    try {
      final VoiceResult result =
          await ref.read(extrasRepositoryProvider).voice(command);
      if (!mounted) {
        return;
      }
      final Object? customer = result.params['customer'];
      final Object? product = result.params['product'];
      setState(() {
        _result = result;
        if (customer is Map) {
          _customerId = int.tryParse(customer['id']?.toString() ?? '');
          _customerName = customer['name']?.toString();
        }
        if (product is Map) {
          _productId = int.tryParse(product['id']?.toString() ?? '');
          _productName = product['name']?.toString();
        }
      });
    } on ApiException catch (error) {
      if (mounted) {
        setState(() => _error = apiErrorText(s, error));
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  double? _number(String key) =>
      double.tryParse(_result?.params[key]?.toString() ?? '');

  /// Amal uchun hamma kerakli ma'lumot bor (tasdiqlash mumkin).
  bool get _ready {
    final VoiceResult? r = _result;
    if (r == null || !r.isWrite) {
      return false;
    }
    return switch (r.intent) {
      'stock_in' => _productId != null && _number('quantity') != null,
      _ => _customerId != null && _number('amount') != null,
    };
  }

  Future<void> _confirm() async {
    final VoiceResult? r = _result;
    if (r == null || !_ready) {
      return;
    }
    final AppStrings s = context.s;
    setState(() {
      _executing = true;
      _error = null;
    });

    try {
      switch (r.intent) {
        case 'debt_add':
          await ref.read(debtsRepositoryProvider).create(
                customerId: _customerId!,
                amount: _number('amount')!.round(),
              );
        case 'debt_payment':
          await ref.read(customersRepositoryProvider).pay(
                _customerId!,
                amount: _number('amount')!.round(),
              );
        case 'stock_in':
          await ref
              .read(productsRepositoryProvider)
              .stockIn(_productId!, qty: _number('quantity')!);
      }
      ref.read(homeControllerProvider.notifier).load();
      if (mounted) {
        setState(() => _done = true);
      }
    } on ApiException catch (error) {
      if (mounted) {
        setState(() => _error = apiErrorText(s, error));
      }
    } finally {
      if (mounted) {
        setState(() => _executing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppStrings s = context.s;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final VoiceResult? result = _result;

    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screen),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                      child: Text(s.voiceTitle, style: textTheme.titleMedium)),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                    tooltip: s.close,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Center(
                child: SegmentedButton<String>(
                  showSelectedIcon: false,
                  segments: <ButtonSegment<String>>[
                    ButtonSegment<String>(
                        value: 'uz', label: Text(s.voiceLangUz)),
                    ButtonSegment<String>(
                        value: 'ru', label: Text(s.voiceLangRu)),
                  ],
                  selected: <String>{_lang ?? s.localeCode},
                  onSelectionChanged: _listening
                      ? null
                      : (Set<String> value) =>
                          setState(() => _lang = value.first),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Center(
                child: GestureDetector(
                  onTap: _busy || _executing ? null : _toggleListening,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: _listening ? 96 : 84,
                    width: _listening ? 96 : 84,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _listening ? AppColors.danger : AppColors.primary,
                      boxShadow: AppShadows.raised,
                    ),
                    child: Icon(
                      _listening ? Icons.stop_rounded : Icons.mic_rounded,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                _listening
                    ? s.voiceListening
                    : (_busy ? s.voiceProcessing : s.voiceIntro),
                textAlign: TextAlign.center,
                style: textTheme.titleSmall,
              ),
              const SizedBox(height: 2),
              Text(
                s.voiceExample,
                textAlign: TextAlign.center,
                style: textTheme.bodySmall,
              ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                hint: s.voiceTypeHint,
                controller: _input,
                textInputAction: TextInputAction.send,
                onSubmitted: _send,
                suffix: IconButton(
                  tooltip: s.voiceSend,
                  onPressed: _busy ? null : () => _send(_input.text),
                  icon:
                      const Icon(Icons.send_rounded, color: AppColors.primary),
                ),
              ),
              if (_error != null) ...<Widget>[
                const SizedBox(height: AppSpacing.md),
                Text(
                  _error!,
                  style: textTheme.bodySmall?.copyWith(color: AppColors.danger),
                ),
              ],
              if (_busy) ...<Widget>[
                const SizedBox(height: AppSpacing.lg),
                const Center(child: CircularProgressIndicator()),
              ],
              if (result != null) ...<Widget>[
                const SizedBox(height: AppSpacing.lg),
                _buildResult(s, textTheme, result),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResult(AppStrings s, TextTheme textTheme, VoiceResult r) {
    final List<Map<String, dynamic>> customerCandidates =
        r.paramList('candidates');
    final bool needsCustomer =
        (r.intent == 'debt_add' || r.intent == 'debt_payment') &&
            _customerId == null &&
            customerCandidates.isNotEmpty;
    final bool needsProduct = r.intent == 'stock_in' &&
        _productId == null &&
        customerCandidates.isNotEmpty;

    return AppCard(
      color: _done ? AppColors.successSurface : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            _done ? s.voiceDone : r.message,
            style: textTheme.titleSmall,
          ),
          if (!_done && (needsCustomer || needsProduct)) ...<Widget>[
            const SizedBox(height: AppSpacing.md),
            Text(
              needsProduct ? s.voiceChooseProduct : s.voiceChooseCustomer,
              style: textTheme.bodySmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: <Widget>[
                for (final Map<String, dynamic> c in customerCandidates)
                  ActionChip(
                    label: Text(c['name']?.toString() ?? ''),
                    onPressed: () => setState(() {
                      final int? id = int.tryParse(c['id']?.toString() ?? '');
                      if (needsProduct) {
                        _productId = id;
                        _productName = c['name']?.toString();
                      } else {
                        _customerId = id;
                        _customerName = c['name']?.toString();
                      }
                    }),
                  ),
              ],
            ),
          ],
          if (!_done &&
              r.isWrite &&
              !r.needsConfirmation &&
              _ready) ...<Widget>[
            const SizedBox(height: AppSpacing.sm),
            Text(_summary(r), style: textTheme.bodyMedium),
          ],
          if (r.result != null) ...<Widget>[
            const SizedBox(height: AppSpacing.md),
            ..._details(s, textTheme, r),
          ],
          if (!_done && r.isWrite) ...<Widget>[
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              label: s.voiceConfirm,
              icon: Icons.check_rounded,
              isLoading: _executing,
              onPressed: _ready ? _confirm : null,
            ),
          ],
          if (_done) ...<Widget>[
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              label: s.close,
              variant: AppButtonVariant.secondary,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ],
      ),
    );
  }

  String _summary(VoiceResult r) {
    if (r.intent == 'stock_in') {
      return '${_productName ?? ''}: ${_number('quantity')}';
    }
    return '${_customerName ?? ''}: ${Money.format(_number('amount') ?? 0)}';
  }

  /// O'qish so'rovlari natijasi: savdo/foyda raqamlari, qarzdorlar yoki kam qoldiq ro'yxati.
  List<Widget> _details(AppStrings s, TextTheme textTheme, VoiceResult r) {
    final Map<String, dynamic> data = r.result!;
    final Object? items = data['items'];

    if (items is List) {
      return <Widget>[
        for (final Object? item in items)
          if (item is Map)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(item['name']?.toString() ?? '',
                        style: textTheme.bodyMedium),
                  ),
                  Text(
                    item['amount'] != null
                        ? Money.format(
                            double.tryParse(item['amount'].toString()) ?? 0)
                        : '${item['stock']} ${item['unit'] ?? ''}',
                    style: textTheme.bodySmall,
                  ),
                ],
              ),
            ),
      ];
    }

    String money(String key) =>
        Money.format(double.tryParse(data[key]?.toString() ?? '') ?? 0);
    final List<(String, String)> rows = <(String, String)>[
      if (data['sales_total'] != null) (s.statSales, money('sales_total')),
      if (data['gross_profit'] != null)
        (s.grossProfitLabel, money('gross_profit')),
      if (data['net_profit'] != null) (s.netProfitLabel, money('net_profit')),
    ];
    return <Widget>[
      for (final (String label, String value) in rows)
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.xs),
          child: Row(
            children: <Widget>[
              Expanded(child: Text(label, style: textTheme.bodySmall)),
              Text(value, style: textTheme.titleSmall),
            ],
          ),
        ),
    ];
  }
}
