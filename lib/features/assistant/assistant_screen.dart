import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/network/api_error_text.dart';
import '../../core/network/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/widgets/widgets.dart';
import '../auth/data/auth_models.dart';
import '../auth/state/auth_providers.dart';
import '../billing/pro_upsell.dart';
import '../extras/data/extras_models.dart';
import '../extras/state/extras_providers.dart';

/// Pro bo'lsa AI yordamchi ochiladi, aks holda Pro taklifi (TZ 24, 34).
Future<void> openAssistant(BuildContext context, WidgetRef ref) async {
  final AppStrings s = context.s;
  final AuthUser? user = ref.read(authControllerProvider).user;

  if (user == null || !user.isPro) {
    await showProUpsell(
      context,
      ref,
      title: s.voiceProTitle,
      body: s.assistantProBody,
      icon: Icons.auto_awesome_rounded,
    );
    return;
  }

  await Navigator.of(context).push<void>(
    MaterialPageRoute<void>(builder: (BuildContext _) => const AssistantScreen()),
  );
}

/// AI biznes yordamchi: erkin savol-javob. Javoblar foydalanuvchining haqiqiy
/// ma'lumotlariga asoslanadi (backend `/ai/assistant`, faqat o'qish).
class AssistantScreen extends ConsumerStatefulWidget {
  const AssistantScreen({super.key});

  @override
  ConsumerState<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends ConsumerState<AssistantScreen> {
  final TextEditingController _input = TextEditingController();
  final ScrollController _scroll = ScrollController();
  final List<ChatMessage> _messages = <ChatMessage>[];
  bool _busy = false;

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send(String text) async {
    final String message = text.trim();
    if (message.isEmpty || _busy) {
      return;
    }
    final AppStrings s = context.s;

    // Oxirgi 10 xabar kontekst sifatida yuboriladi.
    final List<ChatMessage> history = _messages.length > 10
        ? _messages.sublist(_messages.length - 10)
        : List<ChatMessage>.of(_messages);

    setState(() {
      _messages.add(ChatMessage(role: 'user', content: message));
      _input.clear();
      _busy = true;
    });
    _scrollToEnd();

    try {
      final String reply =
          await ref.read(extrasRepositoryProvider).assistant(message, history);
      if (mounted) {
        setState(() => _messages.add(ChatMessage(role: 'assistant', content: reply)));
      }
    } on ApiException catch (error) {
      if (mounted) {
        setState(() => _messages.add(
              ChatMessage(role: 'assistant', content: apiErrorText(s, error)),
            ));
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
        _scrollToEnd();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppStrings s = context.s;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final List<String> suggestions = <String>[
      s.assistantQ1,
      s.assistantQ2,
      s.assistantQ3,
      s.assistantQ4,
      s.assistantQ5,
    ];

    return Scaffold(
      appBar: AppBar(title: Text(s.assistantTitle)),
      body: Column(
        children: <Widget>[
          Expanded(
            child: _messages.isEmpty
                ? ListView(
                    padding: const EdgeInsets.all(AppSpacing.screen),
                    children: <Widget>[
                      const SizedBox(height: AppSpacing.xl),
                      Center(
                        child: Container(
                          height: 84,
                          width: 84,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.lightGreen,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.auto_awesome_rounded,
                              size: 38, color: AppColors.primary),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        s.assistantIntro,
                        textAlign: TextAlign.center,
                        style: textTheme.bodyMedium,
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      for (final String q in suggestions) ...<Widget>[
                        AppCard(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          onTap: () => _send(q),
                          child: Row(
                            children: <Widget>[
                              const Icon(Icons.chat_bubble_outline_rounded,
                                  size: 18, color: AppColors.primary),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(child: Text(q, style: textTheme.bodyMedium)),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                      ],
                    ],
                  )
                : ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.all(AppSpacing.screen),
                    itemCount: _messages.length + (_busy ? 1 : 0),
                    itemBuilder: (BuildContext context, int index) {
                      if (index == _messages.length) {
                        return _Bubble(text: s.assistantThinking, isUser: false, muted: true);
                      }
                      final ChatMessage m = _messages[index];
                      return _Bubble(text: m.content, isUser: m.isUser);
                    },
                  ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screen,
                AppSpacing.sm,
                AppSpacing.screen,
                AppSpacing.md,
              ),
              child: AppTextField(
                hint: s.assistantHint,
                controller: _input,
                textInputAction: TextInputAction.send,
                onSubmitted: _send,
                suffix: IconButton(
                  onPressed: _busy ? null : () => _send(_input.text),
                  icon: const Icon(Icons.send_rounded, color: AppColors.primary),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.text, required this.isUser, this.muted = false});

  final String text;
  final bool isUser;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm + 2,
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.82,
        ),
        decoration: BoxDecoration(
          color: isUser ? AppColors.primary : AppColors.card,
          borderRadius: AppRadius.card,
          border: isUser ? null : Border.all(color: AppColors.border),
        ),
        child: Text(
          text,
          style: textTheme.bodyMedium?.copyWith(
            color: isUser
                ? Colors.white
                : (muted ? AppColors.textSecondary : AppColors.textPrimary),
          ),
        ),
      ),
    );
  }
}
