import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/widgets/widgets.dart';
import 'receipt_printer.dart';

/// Matn: [PrintResult] natijasini foydalanuvchi tilidagi xabarga aylantiradi.
String printResultText(AppStrings s, PrintResult result) => switch (result) {
      PrintResult.ok => s.printerPrinted,
      PrintResult.noPermission => s.printerPermission,
      PrintResult.bluetoothOff => s.printerBluetoothOff,
      PrintResult.connectFailed || PrintResult.writeFailed => s.printerFailed,
    };

/// Chek printerini tanlash (telefonga juftlangan Bluetooth qurilmalar),
/// qog'oz kengligi (58/80 mm) va sinov cheki. Tanlov qurilmada saqlanadi.
class PrinterScreen extends ConsumerStatefulWidget {
  const PrinterScreen({super.key});

  @override
  ConsumerState<PrinterScreen> createState() => _PrinterScreenState();
}

class _PrinterScreenState extends ConsumerState<PrinterScreen> {
  PrinterConfig? _config;
  List<BluetoothInfo> _devices = <BluetoothInfo>[];
  bool _loading = true;
  bool _busy = false;
  String? _problem;

  @override
  void initState() {
    super.initState();
    // context.s initState ichida ishlamaydi — kadrdan keyin yuklanadi.
    Future<void>.microtask(_load);
  }

  Future<void> _load() async {
    final AppStrings s = context.s;
    final ReceiptPrinter printer = ref.read(receiptPrinterProvider);
    setState(() {
      _loading = true;
      _problem = null;
    });

    final PrinterConfig? saved = await printer.savedPrinter();
    List<BluetoothInfo> devices = <BluetoothInfo>[];
    String? problem;

    if (!await printer.ensurePermissions()) {
      problem = s.printerPermission;
    } else if (!await printer.bluetoothEnabled()) {
      problem = s.printerBluetoothOff;
    } else {
      try {
        devices = await printer.pairedDevices();
      } catch (_) {
        problem = s.printerFailed;
      }
    }

    if (!mounted) {
      return;
    }
    setState(() {
      _config = saved;
      _devices = devices;
      _problem = problem;
      _loading = false;
    });
  }

  Future<void> _select(BluetoothInfo device) async {
    final PrinterConfig config = PrinterConfig(
      mac: device.macAdress,
      name: device.name,
      paper: _config?.paper ?? 58,
    );
    await ref.read(receiptPrinterProvider).save(config);
    if (mounted) {
      setState(() => _config = config);
    }
  }

  Future<void> _setPaper(int paper) async {
    final PrinterConfig? current = _config;
    if (current == null) {
      return;
    }
    final PrinterConfig updated = current.copyWith(paper: paper);
    await ref.read(receiptPrinterProvider).save(updated);
    if (mounted) {
      setState(() => _config = updated);
    }
  }

  Future<void> _testPrint() async {
    final PrinterConfig? config = _config;
    if (config == null) {
      return;
    }
    final AppStrings s = context.s;
    setState(() => _busy = true);
    final PrintResult result =
        await ref.read(receiptPrinterProvider).printLines(config, <String>[
      'Savdo Up',
      DateTime.now().toString().substring(0, 16),
      '--------------------------------',
      s.printerTest,
      '--------------------------------',
    ]);
    if (!mounted) {
      return;
    }
    setState(() => _busy = false);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(printResultText(s, result))));
  }

  @override
  Widget build(BuildContext context) {
    final AppStrings s = context.s;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(s.printerTitle)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.screen),
              children: <Widget>[
                AppCard(
                  child: Row(
                    children: <Widget>[
                      const Icon(Icons.print_rounded, color: AppColors.primary),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          _config == null
                              ? s.printerNone
                              : '${_config!.name}  (${_config!.mac})',
                          style: textTheme.titleSmall,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_config != null) ...<Widget>[
                  const SizedBox(height: AppSpacing.lg),
                  Text(s.printerPaper, style: textTheme.titleSmall),
                  const SizedBox(height: AppSpacing.sm),
                  SegmentedButton<int>(
                    segments: const <ButtonSegment<int>>[
                      ButtonSegment<int>(value: 58, label: Text('58 mm')),
                      ButtonSegment<int>(value: 80, label: Text('80 mm')),
                    ],
                    selected: <int>{_config!.paper},
                    onSelectionChanged: (Set<int> value) =>
                        _setPaper(value.first),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppButton(
                    label: s.printerTest,
                    icon: Icons.receipt_long_rounded,
                    isLoading: _busy,
                    onPressed: _testPrint,
                  ),
                ],
                const SizedBox(height: AppSpacing.xl),
                Text(s.printerPairedHint, style: textTheme.bodySmall),
                const SizedBox(height: AppSpacing.md),
                if (_problem != null)
                  AppCard(
                    color: AppColors.warningSurface,
                    child: Row(
                      children: <Widget>[
                        Expanded(child: Text(_problem!)),
                        TextButton(onPressed: _load, child: Text(s.retry)),
                      ],
                    ),
                  )
                else if (_devices.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Text(
                      s.printerNoDevices,
                      textAlign: TextAlign.center,
                      style: textTheme.bodySmall,
                    ),
                  )
                else
                  for (final BluetoothInfo device in _devices) ...<Widget>[
                    AppCard(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      onTap: () => _select(device),
                      child: Row(
                        children: <Widget>[
                          const Icon(Icons.bluetooth_rounded,
                              color: AppColors.info),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(device.name, style: textTheme.titleSmall),
                                Text(device.macAdress,
                                    style: textTheme.labelSmall),
                              ],
                            ),
                          ),
                          if (_config?.mac == device.macAdress)
                            const Icon(Icons.check_circle_rounded,
                                color: AppColors.primary),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                  ],
              ],
            ),
    );
  }
}
