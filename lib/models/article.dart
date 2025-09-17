class Article {
  final String title;
  final String url;
  final String? description;
  final String? urlToImage;
  final String? sourceName;
  final DateTime? publishedAt;

  Article({
    required this.title,
    required this.url,
    this.description,
    this.urlToImage,
    this.sourceName,
    this.publishedAt,
  });

  factory Article.fromJson(Map<String, dynamic> j) {
    return Article(
      title: j['title'] ?? '',
      url: j['url'] ?? '',
      description: j['description'],
      urlToImage: j['urlToImage'],
      sourceName: (j['source'] is Map) ? j['source']['name'] as String? : null,
      publishedAt: j['publishedAt'] != null
          ? DateTime.tryParse(j['publishedAt'])
          : null,
    );
  }
}
