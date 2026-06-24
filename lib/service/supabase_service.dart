import 'package:supabase_flutter/supabase_flutter.dart';

/// Acceso seguro al cliente de Supabase.
///
/// [ready] lo marca `main._initSupabase()` tras `Supabase.initialize()`.
/// [clientOrNull] devuelve `null` si Supabase no inicializó, para que los
/// llamadores puedan caer en el comportamiento offline/actual sin lanzar.
class SupabaseService {
  SupabaseService._();

  static bool ready = false;

  static SupabaseClient? get clientOrNull {
    if (!ready) return null;
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }
}
