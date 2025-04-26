import 'package:http/http.dart' as http;
import 'package:tablas_de_verdad_2025/class/truth_table.dart';
import 'package:tablas_de_verdad_2025/model/list_response.dart';
import 'dart:convert';

import 'package:tablas_de_verdad_2025/model/post_expression_response.dart';

final String WEB_URL = 'https://jovannyrch-1dfc553c9cbb.herokuapp.com';
final String API_URL = "$WEB_URL/api";

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

  static Future<ListResponse> getListExpressions(int page, String type) async {
    String url = "$API_URL/expressions?page=$page";
    if (type.isNotEmpty) {
      url = "$API_URL/expressions?type=${type}&page=$page";
    }
    print(url);
    try {
      var response = await http.get(Uri.parse(url));
      print(response.body);
      var json = jsonDecode(response.body);

      return ListResponse.fromJson(json);
    } catch (e) {
      print(e);
      return ListResponse();
    }
  }

  //Get videos list
  static Future<ListResponse> getVideosList(int page) async {
    String url = "$API_URL/expressions/videos?page=$page";

    var response = await http.get(Uri.parse(url));

    var json = jsonDecode(response.body);

    return ListResponse.fromJson(json);
  }
}
