import 'package:tablas_de_verdad_2025/class/truth_table.dart';
import 'package:tablas_de_verdad_2025/model/list_response.dart';
import 'package:tablas_de_verdad_2025/service/supabase_service.dart';

/// Repositorio de la librería de expresiones respaldada en Supabase
/// (`tv_expressions` + RPC `tv_register_expression`).
///
/// Todos los métodos son tolerantes a fallos: si Supabase no está disponible
/// devuelven `null`/no-op para que el llamador use el comportamiento actual
/// (JSON estático).
class SupabaseExpressions {
  SupabaseExpressions._();

  static const String _table = 'tv_expressions';

  static String typeName(TruthTableType type) {
    switch (type) {
      case TruthTableType.tautology:
        return 'TAUTOLOGY';
      case TruthTableType.contradiction:
        return 'CONTRADICTION';
      case TruthTableType.contingency:
        return 'CONTINGENCY';
    }
  }

  /// Registra (o incrementa el contador de) una expresión evaluada por el
  /// usuario. Fire-and-forget: nunca lanza ni bloquea el flujo de la app.
  static Future<void> register(String expression, TruthTableType type) async {
    final client = SupabaseService.clientOrNull;
    if (client == null) return;
    try {
      await client.rpc(
        'tv_register_expression',
        params: {'p_expression': expression, 'p_type': typeName(type)},
      );
    } catch (_) {
      // Best-effort: ignorar errores de red/permisos.
    }
  }

  /// Lee expresiones ordenadas por popularidad, paginadas.
  ///
  /// Devuelve `null` si Supabase no está disponible o falla, señal para que el
  /// llamador haga fallback al JSON estático.
  static Future<ListResponse?> getPopular({
    int page = 1,
    int perPage = 30,
    String type = '',
    bool videos = false,
  }) async {
    final client = SupabaseService.clientOrNull;
    if (client == null) return null;
    try {
      final from = (page - 1) * perPage;
      final to = from + perPage - 1;

      var query = client
          .from(_table)
          .select('id,expression,type,count,video_link,origin');
      if (type.isNotEmpty) query = query.eq('type', type);
      if (videos) query = query.not('video_link', 'is', null);

      final rows = await query.order('count', ascending: false).range(from, to);

      final data =
          (rows as List).map((row) {
            final r = row as Map<String, dynamic>;
            final videoLink = r['video_link'] as String?;
            return Expression(
              id: r['id'] as int?,
              expression: r['expression'] as String?,
              type: r['type'] as String?,
              count: r['count'] as int?,
              youtubeUrl:
                  (videoLink != null && videoLink.isNotEmpty) ? videoLink : null,
              origin: r['origin'] as String?,
            );
          }).toList();

      return ListResponse(currentPage: page, perPage: perPage, data: data);
    } catch (_) {
      return null;
    }
  }
}
