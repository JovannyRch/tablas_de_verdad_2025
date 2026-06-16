import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tablas_de_verdad_2025/utils/rating_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('shouldShowOnMilestone', () {
    test('true on a fresh install', () async {
      SharedPreferences.setMockInitialValues({});
      expect(await RatingHelper.shouldShowOnMilestone(), true);
    });

    test('false once the user has rated', () async {
      SharedPreferences.setMockInitialValues({'has_rated': true});
      expect(await RatingHelper.shouldShowOnMilestone(), false);
    });

    test('false when the user chose "never ask again"', () async {
      SharedPreferences.setMockInitialValues({'never_ask_again': true});
      expect(await RatingHelper.shouldShowOnMilestone(), false);
    });

    test('false within the cooldown after postponing', () async {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      SharedPreferences.setMockInitialValues({
        'last_prompt_date': yesterday.millisecondsSinceEpoch,
      });
      expect(await RatingHelper.shouldShowOnMilestone(), false);
    });

    test('true again once the cooldown has elapsed', () async {
      final longAgo = DateTime.now().subtract(
        Duration(days: RatingHelper.daysBeforeAskingAgain + 1),
      );
      SharedPreferences.setMockInitialValues({
        'last_prompt_date': longAgo.millisecondsSinceEpoch,
      });
      expect(await RatingHelper.shouldShowOnMilestone(), true);
    });

    test('does not depend on the calculation count', () async {
      // No calculations recorded, but it is still a valid milestone moment.
      SharedPreferences.setMockInitialValues({'calculation_count': 0});
      expect(await RatingHelper.shouldShowOnMilestone(), true);
    });
  });
}
