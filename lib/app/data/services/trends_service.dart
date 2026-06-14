import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile_app/app/core/config/app_config.dart';

class TrendItem {
  final int rank;
  final String article;
  final int views90d;
  final String description;

  const TrendItem({
    required this.rank,
    required this.article,
    required this.views90d,
    required this.description,
  });

  factory TrendItem.fromJson(Map<String, dynamic> j) => TrendItem(
        rank: j['rank'] as int,
        article: j['article'] as String,
        views90d: j['views_90d'] as int,
        description: (j['description'] as String?) ?? '',
      );
}

class TrendsService {
  static Future<List<TrendItem>> fetchTrending({int limit = 5}) async {
    final resp = await http.get(
      Uri.parse('${AppConfig.trendingEndpoint}?limit=$limit'),
    );
    if (resp.statusCode != 200) {
      throw Exception('Failed to fetch trends: ${resp.statusCode}');
    }
    final data = jsonDecode(resp.body);
    return (data['trending'] as List)
        .map((e) => TrendItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
