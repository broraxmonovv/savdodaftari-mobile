import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../auth/state/auth_providers.dart';
import '../../debts/data/debt_models.dart';
import '../../debts/state/debts_providers.dart';
import '../../expenses/data/expense_models.dart';
import '../../expenses/state/expenses_providers.dart';
import '../../inventory/data/product_models.dart';
import '../../inventory/state/products_providers.dart';
import '../../sales/data/sale_models.dart';
import '../../sales/state/sales_providers.dart';

/// TZ 5-bo'lim: dashboard holati — mavjud summary endpointlaridan yig'iladi:
/// GET /sales/summary, /debts/summary, /products/summary, /expenses/summary.
class HomeDashboardState {
  const HomeDashboardState({
    this.isLoading = true,
    this.sales,
    this.debts,
    this.products,
    this.expenses,
    this.error,
  });

  final bool isLoading;
  final SalesSummary? sales;
  final DebtsSummary? debts;
  final ProductsSummary? products;

  /// Backend `/expenses` hali tayyor bo'lmasa null qoladi —
  /// dashboard baribir ishlayveradi.
  final ExpensesSummary? expenses;
  final ApiException? error;

  /// Qarz summary'si har doim yuklanadi; savdo/ombor faqat pullik tarifda.
  bool get hasData => debts != null;

  HomeDashboardState copyWith({
    bool? isLoading,
    SalesSummary? sales,
    DebtsSummary? debts,
    ProductsSummary? products,
    ExpensesSummary? expenses,
    ApiException? error,
    bool clearError = false,
  }) {
    return HomeDashboardState(
      isLoading: isLoading ?? this.isLoading,
      sales: sales ?? this.sales,
      debts: debts ?? this.debts,
      products: products ?? this.products,
      expenses: expenses ?? this.expenses,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class HomeController extends StateNotifier<HomeDashboardState> {
  HomeController(this._ref) : super(const HomeDashboardState());

  final Ref _ref;
  int _requestId = 0;

  Future<void> load() async {
    final int requestId = ++_requestId;
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      // Savdo va ombor Standart/Pro tarifda ochiq — bepul tarifda ular
      // so'ralmaydi (backend 403 `plan_required` qaytaradi).
      final bool hasSalesAndInventory =
          _ref.read(authControllerProvider).user?.hasSalesAndInventory ?? false;

      // Summary'lar parallel yuklanadi — dashboard tezroq ochiladi.
      final List<Object?> results = await Future.wait(<Future<Object?>>[
        _ref.read(debtsRepositoryProvider).summary(),
        if (hasSalesAndInventory) ...<Future<Object?>>[
          _ref.read(salesRepositoryProvider).summary(),
          _ref.read(productsRepositoryProvider).summary(),
        ],
      ]);
      final DebtsSummary debts = results[0] as DebtsSummary;
      final SalesSummary? sales =
          hasSalesAndInventory ? results[1] as SalesSummary : null;
      final ProductsSummary? products =
          hasSalesAndInventory ? results[2] as ProductsSummary : null;

      // Xarajatlar endpointi backendda hali bo'lmasligi mumkin —
      // uning xatosi dashboardni to'xtatmaydi.
      ExpensesSummary? expenses;
      try {
        expenses = await _ref.read(expensesRepositoryProvider).summary();
      } on ApiException {
        expenses = null;
      }

      if (requestId != _requestId || !mounted) {
        return;
      }
      state = state.copyWith(
        isLoading: false,
        sales: sales,
        debts: debts,
        products: products,
        expenses: expenses,
      );
    } on ApiException catch (error) {
      if (requestId != _requestId || !mounted) {
        return;
      }
      state = state.copyWith(isLoading: false, error: error);
    }
  }
}

final StateNotifierProvider<HomeController, HomeDashboardState>
    homeControllerProvider =
    StateNotifierProvider<HomeController, HomeDashboardState>(
  HomeController.new,
);
