import 'package:shared_preferences/shared_preferences.dart';

/// Helper para gestionar cuándo y cómo pedir al usuario que califique la app
class RatingHelper {
  static const String _keyCalculationCount = 'calculation_count';
  static const String _keyHasRated = 'has_rated';
  static const String _keyNeverAskAgain = 'never_ask_again';
  static const String _keyLastPromptDate = 'last_prompt_date';

  // Configuración: después de cuántos cálculos preguntar
  static const int calculationsBeforePrompt = 5;

  // Días mínimos entre prompts si el usuario elige "Más tarde"
  static const int daysBeforeAskingAgain = 7;

  /// Incrementa el contador de cálculos exitosos
  static Future<void> incrementCalculationCount() async {
    final prefs = await SharedPreferences.getInstance();
    final count = prefs.getInt(_keyCalculationCount) ?? 0;
    await prefs.setInt(_keyCalculationCount, count + 1);
  }

  /// Verifica si debemos mostrar el diálogo de calificación
  static Future<bool> shouldShowRatingDialog() async {
    final prefs = await SharedPreferences.getInstance();

    // Si ya calificó o dijo "nunca preguntar", no mostrar
    final hasRated = prefs.getBool(_keyHasRated) ?? false;
    final neverAsk = prefs.getBool(_keyNeverAskAgain) ?? false;

    if (hasRated || neverAsk) {
      return false;
    }

    // Verificar si pasaron suficientes días desde la última vez
    final lastPromptTimestamp = prefs.getInt(_keyLastPromptDate) ?? 0;
    if (lastPromptTimestamp > 0) {
      final lastPrompt = DateTime.fromMillisecondsSinceEpoch(
        lastPromptTimestamp,
      );
      final daysSinceLastPrompt = DateTime.now().difference(lastPrompt).inDays;

      if (daysSinceLastPrompt < daysBeforeAskingAgain) {
        return false;
      }
    }

    // Verificar si alcanzó el número de cálculos requeridos
    final count = prefs.getInt(_keyCalculationCount) ?? 0;
    return count >= calculationsBeforePrompt;
  }

  /// Marca que el usuario ya calificó la app
  static Future<void> markAsRated() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyHasRated, true);
  }

  /// Marca que el usuario eligió "Más tarde"
  static Future<void> markAsPostponed() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now().millisecondsSinceEpoch;
    await prefs.setInt(_keyLastPromptDate, now);

    // Resetear contador para que tenga que hacer más cálculos
    await prefs.setInt(_keyCalculationCount, 0);
  }

  /// Marca que el usuario eligió "No, gracias" (nunca preguntar de nuevo)
  static Future<void> markAsNeverAskAgain() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNeverAskAgain, true);
  }

  /// Resetea todos los datos (útil para testing)
  static Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyCalculationCount);
    await prefs.remove(_keyHasRated);
    await prefs.remove(_keyNeverAskAgain);
    await prefs.remove(_keyLastPromptDate);
  }

  /// Obtiene el contador actual de cálculos
  static Future<int> getCalculationCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyCalculationCount) ?? 0;
  }
}
