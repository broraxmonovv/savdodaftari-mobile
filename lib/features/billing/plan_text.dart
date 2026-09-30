import '../../core/l10n/app_strings.dart';
import '../auth/data/auth_models.dart';

extension UserPlanText on UserPlan {
  /// Tarifning foydalanuvchi tilidagi nomi: Bepul / Standart / Pro.
  String label(AppStrings s) => switch (this) {
        UserPlan.free => s.planFreeName,
        UserPlan.standard => s.planStandardName,
        UserPlan.pro => s.planProName,
      };
}
