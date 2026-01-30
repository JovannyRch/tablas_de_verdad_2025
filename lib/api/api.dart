import 'package:http/http.dart' as http;
import 'package:tablas_de_verdad_2025/class/truth_table.dart';
import 'package:tablas_de_verdad_2025/model/list_response.dart';
import 'dart:convert';

import 'package:tablas_de_verdad_2025/model/post_expression_response.dart';
import 'package:tablas_de_verdad_2025/const/backend_config.dart';

// NOTA: Usando modelo backendless con JSON estático
final String WEB_URL = BACKEND_URL;
final String API_URL = API_BASE_URL;
final String STATIC_JSON_URL =
    'https://static-json-backend.vercel.app/projects/truth-tables/expressions';

class Api {
  static Future<PostExpressionResponse> postExpression(
    String expression,
    TruthTableType type,
  ) async {
    String formattedType = formatType(type);
    var response = await http.post(
      Uri.parse('$API_URL/expressions'),
      body: {'expression': expression, 'type': formattedType},
    );
    return PostExpressionResponse.fromJson(json.decode(response.body));
  }

  static String formatType(TruthTableType type) {
    switch (type) {
      case TruthTableType.contingency:
        return 'CONTINGENCY';
      case TruthTableType.tautology:
        return 'TAUTOLOGY';
      case TruthTableType.contradiction:
        return 'CONTRADICTION';
    }
  }

  static Future<ListResponse> getListExpressions(
    int page,
    String type, {
    bool videos = false,
  }) async {
    try {
      // Obtener todas las expresiones del JSON estático
      var response = await http.get(Uri.parse(STATIC_JSON_URL));

      if (response.statusCode != 200) {
        print('Error: ${response.statusCode}');
        return ListResponse();
      }

      var json = jsonDecode(response.body);
      var data = ListResponse.fromJson(json);
      print('Fetched ${data.data?.length ?? 0} expressions');
      return data;
    } catch (e) {
      print('Error fetching expressions: $e');
      return ListResponse();
    }
  }

  //Get videos list
  static Future<ListResponse> getVideosList(int page) async {
    try {
      // Obtener todas las expresiones y filtrar las que tienen video
      var response = await http.get(Uri.parse(STATIC_JSON_URL));

      if (response.statusCode != 200) {
        print('Error: ${response.statusCode}');
        return ListResponse();
      }

      var json = jsonDecode(response.body);
      return ListResponse.fromJson(json);
    } catch (e) {
      print('Error fetching videos: $e');
      return ListResponse();
    }
  }
}
