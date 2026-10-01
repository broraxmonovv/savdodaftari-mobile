import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import 'calculator_engine.dart';

/// Hamma sahifada ekran chetiga yopishib turuvchi kalkulyator.
///
/// [MaterialApp.builder] ichida Navigator ustiga qo'yiladi. Tugma ekranning
/// chap yoki o'ng chetida turadi, vertikal va gorizontal surish mumkin (qo'yib
/// yuborilganda eng yaqin chetga yopishadi). Bosilganda real ishlovchi
/// kalkulyator paneli ochiladi.
class CalculatorOverlay extends StatefulWidget {
  const CalculatorOverlay({super.key, required this.child, this.enabled = true});

  final Widget child;

  /// false bo'lsa (masalan, splash paytida) faqat [child] ko'rsatiladi.
  final bool enabled;

  @override
  State<CalculatorOverlay> createState() => _CalculatorOverlayState();
}

class _CalculatorOverlayState extends State<CalculatorOverlay> {
  static const double _tabWidth = 40;
  static const double _tabHeight = 56;

  final CalculatorEngine _engine = CalculatorEngine();
  bool _open = false;
  bool _dragging = false;
  Offset? _position;

  void _key(void Function() action) {
    HapticFeedback.selectionClick();
    setState(action);
  }

  Offset _clamp(Offset value, Size size, EdgeInsets padding) {
    final double minY = padding.top + 8;
    final double maxY = size.height - padding.bottom - _tabHeight - 8;
    return Offset(
      value.dx.clamp(0, size.width - _tabWidth).toDouble(),
      value.dy.clamp(minY, maxY < minY ? minY : maxY).toDouble(),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Daraxt tuzilishi `enabled` o'zgarganda ham bir xil qoladi (Navigator va undagi kiritish
    // maydonlari qayta yaratilmaydi, fokus va klaviatura yo'qolmaydi); faqat kalkulyator yashiriladi.
    final MediaQueryData media = MediaQuery.of(context);
    final Size size = media.size;
    final Offset position = _clamp(
      _position ?? Offset(size.width - _tabWidth, size.height * 0.55),
      size,
      media.padding,
    );

    return Stack(
      children: <Widget>[
        Positioned.fill(child: widget.child),
        if (widget.enabled && _open)
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => setState(() => _open = false),
              child: ColoredBox(color: Colors.black.withOpacity(0.35)),
            ),
          ),
        if (widget.enabled && _open) _buildPanel(context, media),
        if (widget.enabled && !_open)
          AnimatedPositioned(
            duration: _dragging
                ? Duration.zero
                : const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            left: position.dx,
            top: position.dy,
            child: _buildTab(context, position, size, media),
          ),
      ],
    );
  }

  Widget _buildTab(
    BuildContext context,
    Offset position,
    Size size,
    MediaQueryData media,
  ) {
    final bool onLeft = position.dx < (size.width - _tabWidth) / 2;

    return GestureDetector(
      onTap: () => setState(() => _open = true),
      onPanStart: (_) => setState(() => _dragging = true),
      onPanUpdate: (DragUpdateDetails details) {
        setState(() {
          _position = _clamp(position + details.delta, size, media.padding);
        });
      },
      onPanEnd: (_) {
        // Eng yaqin chetga yopishadi.
        final Offset current = _position ?? position;
        final bool toLeft = current.dx + _tabWidth / 2 < size.width / 2;
        setState(() {
          _dragging = false;
          _position = Offset(toLeft ? 0 : size.width - _tabWidth, current.dy);
        });
      },
      child: Material(
        color: AppColors.primary,
        elevation: 6,
        shadowColor: Colors.black45,
        borderRadius: BorderRadius.horizontal(
          left: onLeft ? Radius.zero : const Radius.circular(18),
          right: onLeft ? const Radius.circular(18) : Radius.zero,
        ),
        child: const SizedBox(
          width: _tabWidth,
          height: _tabHeight,
          child: Icon(Icons.calculate_rounded, color: Colors.white, size: 26),
        ),
      ),
    );
  }

  Widget _buildPanel(BuildContext context, MediaQueryData media) {
    final AppStrings s = context.s;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final double width = (media.size.width - 32).clamp(240, 340).toDouble();
    final String? preview = _engine.preview;
    final String shown = _engine.hasError
        ? s.calcError
        : (_engine.expression.isEmpty
            ? '0'
            : CalculatorEngine.display(_engine.expression));

    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: media.viewInsets.bottom + media.padding.bottom + 16,
        ),
        child: Material(
          color: AppColors.card,
          elevation: 12,
          borderRadius: AppRadius.card,
          clipBehavior: Clip.antiAlias,
          child: SizedBox(
            width: width,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Icon(Icons.calculate_rounded,
                          size: 20, color: AppColors.textSecondary),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(s.calculatorTitle,
                            style: textTheme.titleSmall),
                      ),
                      InkResponse(
                        onTap: () => setState(() => _open = false),
                        radius: 20,
                        child: Icon(Icons.close_rounded,
                            color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: AppRadius.field,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        SizedBox(
                          height: 20,
                          child: Text(
                            preview == null
                                ? ''
                                : '= ${CalculatorEngine.display(preview)}',
                            style: textTheme.bodySmall,
                          ),
                        ),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerRight,
                          child: Text(
                            shown,
                            maxLines: 1,
                            style: textTheme.headlineSmall?.copyWith(
                              fontSize: 30,
                              color: _engine.hasError
                                  ? AppColors.danger
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _row(<_Key>[
                    _Key('C', () => _key(_engine.clear), _KeyKind.action),
                    _Key('⌫', () => _key(_engine.backspace),
                        _KeyKind.action),
                    _Key('%', () => _key(_engine.percent), _KeyKind.action),
                    _Key(CalculatorEngine.divide,
                        () => _key(() => _engine.inputOperator(CalculatorEngine.divide)),
                        _KeyKind.operator),
                  ]),
                  _row(<_Key>[
                    _digit('7'),
                    _digit('8'),
                    _digit('9'),
                    _Key(CalculatorEngine.times,
                        () => _key(() => _engine.inputOperator(CalculatorEngine.times)),
                        _KeyKind.operator),
                  ]),
                  _row(<_Key>[
                    _digit('4'),
                    _digit('5'),
                    _digit('6'),
                    _Key(CalculatorEngine.minus,
                        () => _key(() => _engine.inputOperator(CalculatorEngine.minus)),
                        _KeyKind.operator),
                  ]),
                  _row(<_Key>[
                    _digit('1'),
                    _digit('2'),
                    _digit('3'),
                    _Key(CalculatorEngine.plus,
                        () => _key(() => _engine.inputOperator(CalculatorEngine.plus)),
                        _KeyKind.operator),
                  ]),
                  _row(<_Key>[
                    _Key('±', () => _key(_engine.toggleSign),
                        _KeyKind.action),
                    _digit('0'),
                    _Key('.', () => _key(_engine.inputDot), _KeyKind.digit),
                    _Key('=', () => _key(_engine.equals), _KeyKind.equals),
                  ]),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  _Key _digit(String d) =>
      _Key(d, () => _key(() => _engine.inputDigit(d)), _KeyKind.digit);

  Widget _row(List<_Key> keys) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: <Widget>[
          for (int i = 0; i < keys.length; i++) ...<Widget>[
            if (i > 0) const SizedBox(width: AppSpacing.sm),
            Expanded(child: _KeyButton(keys[i])),
          ],
        ],
      ),
    );
  }
}

enum _KeyKind { digit, action, operator, equals }

class _Key {
  const _Key(this.label, this.onTap, this.kind);

  final String label;
  final VoidCallback onTap;
  final _KeyKind kind;
}

class _KeyButton extends StatelessWidget {
  const _KeyButton(this.data);

  final _Key data;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    final (Color background, Color foreground) = switch (data.kind) {
      _KeyKind.digit => (AppColors.background, AppColors.textPrimary),
      _KeyKind.action => (AppColors.border, AppColors.textPrimary),
      _KeyKind.operator => (AppColors.lightGreen, AppColors.darkGreen),
      _KeyKind.equals => (AppColors.primary, Colors.white),
    };

    return Material(
      color: background,
      borderRadius: AppRadius.field,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: data.onTap,
        child: SizedBox(
          height: 48,
          child: Center(
            child: Text(
              data.label,
              style: textTheme.titleMedium?.copyWith(
                color: foreground,
                fontSize: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
