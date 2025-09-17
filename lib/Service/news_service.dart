import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/article.dart';

class NewsService {
  final String apiKey;
  static const String _base = 'newsapi.org';

  NewsService({required this.apiKey});

  void _ensureKey() {
    if (apiKey.isEmpty) {
      throw StateError(
        'NEWSAPI_KEY belum di-set. Jalankan dengan '
            '--dart-define=NEWSAPI_KEY=YOUR_KEY_HERE',
      );
    }
  }

  /// GET /v2/everything
  Future<List<Article>> everything({
    required String q,
    DateTime? from,
    DateTime? to,
    String sortBy = 'publishedAt',
    String? language,
    int page = 1,
    int pageSize = 20,
  }) async {
    _ensureKey();

    final params = <String, String>{
      'q': q,
      'sortBy': sortBy,
      'page': '$page',
      'pageSize': '$pageSize',
      if (language != null) 'language': language,
      if (from != null) 'from': from.toIso8601String(),
      if (to != null) 'to': to.toIso8601String(),
    };

    final uri = Uri.https(_base, '/v2/everything', params);

    try {
      final res = await http
          .get(uri, headers: {'X-Api-Key': apiKey})
          .timeout(const Duration(seconds: 15));

      _logResponse('EVERYTHING', uri, res);

      final map = json.decode(res.body) as Map<String, dynamic>;
      if (res.statusCode != 200 || map['status'] == 'error') {
        throw Exception('${map['code'] ?? res.statusCode}: ${map['message'] ?? res.body}');
      }

      final List items = map['articles'] ?? [];
      debugPrint('EVERYTHING -> Articles: ${items.length}');
      return items.map((e) => Article.fromJson(e as Map<String, dynamic>)).toList();
    } on TimeoutException {
      throw Exception('Timeout: koneksi lambat/putus.');
    } on SocketException {
      throw Exception('Tidak ada internet.');
    }
  }

  /// GET /v2/top-headlines
  Future<List<Article>> topHeadlines({
    String country = 'id',
    String? category,
    int page = 1,
    int pageSize = 20,
  }) async {
    _ensureKey();

    final params = <String, String>{
      'country': country,
      'page': '$page',
      'pageSize': '$pageSize',
      if (category != null) 'category': category,
    };

    final uri = Uri.https(_base, '/v2/top-headlines', params);

    try {
      final res = await http
          .get(uri, headers: {'X-Api-Key': apiKey})
          .timeout(const Duration(seconds: 15));

      _logResponse('TOP_HEADLINES', uri, res);

      final map = json.decode(res.body) as Map<String, dynamic>;
      if (res.statusCode != 200 || map['status'] == 'error') {
        throw Exception('${map['code'] ?? res.statusCode}: ${map['message'] ?? res.body}');
      }

      final List items = map['articles'] ?? [];
      debugPrint('TOP_HEADLINES($country) -> Articles: ${items.length}');
      return items.map((e) => Article.fromJson(e as Map<String, dynamic>)).toList();
    } on TimeoutException {
      throw Exception('Timeout: koneksi lambat/putus.');
    } on SocketException {
      throw Exception('Tidak ada internet.');
    }
  }

  // ===== Helper logging =====
  void _logResponse(String tag, Uri uri, http.Response res) {
    debugPrint('$tag GET $uri  => ${res.statusCode}');
    final body = res.body;
    // batasi log agar tidak kebanyakan
    debugPrint(body.length > 800 ? '${body.substring(0, 800)}...' : body);
  }
}
