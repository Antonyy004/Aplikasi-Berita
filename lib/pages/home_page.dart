import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/cupertino.dart';

import '../models/article.dart';
import '../service/news_service.dart';
import '../config.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isSearching = false;
  final TextEditingController _controller = TextEditingController();

  // Pakai API key dari config.dart
  late final NewsService _service = NewsService(apiKey: kNewsApiKey);
  late Future<List<Article>> _future;

  @override
  void initState() {
    super.initState();
    _future = _loadHeadlinesWithFallback();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Ambil top-headlines Indonesia; jika kosong -> fallback ke US
  Future<List<Article>> _loadHeadlinesWithFallback() async {
    final idItems = await _service.topHeadlines(country: 'id', pageSize: 20);
    if (idItems.isEmpty) {
      debugPrint('TopHeadlines(ID) kosong, fallback ke US');
      final usItems = await _service.topHeadlines(country: 'us', pageSize: 20);
      return usItems;
    }
    return idItems;
  }

  void _runSearch(String q) {
    final query = q.trim();
    if (query.isEmpty) return;
    setState(() {
      _future = _service
          .everything(
            q: query,
            language: 'id',
            sortBy: 'publishedAt',
            pageSize: 20,
          )
          .then((items) async {
            if (items.isEmpty) {
              // fallback tanpa filter bahasa agar cakupan lebih luas
              debugPrint(
                'Search "$query" (lang=id) kosong, coba tanpa language',
              );
              return await _service.everything(
                q: query,
                sortBy: 'publishedAt',
                pageSize: 20,
              );
            }
            return items;
          });
      _isSearching = false;
    });
  }

  void _reloadHeadlines() {
    setState(() {
      _future = _loadHeadlinesWithFallback();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        centerTitle: false,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SvgPicture.asset(
            'assets/images/Logo.svg',
            fit: BoxFit.contain,
            height: 40,
          ),
        ),
        title: _isSearching
            ? TextField(
                controller: _controller,
                autofocus: true,
                textInputAction: TextInputAction.search,
                decoration: const InputDecoration(
                  hintText: 'Cari Berita...',
                  border: InputBorder.none,
                  isCollapsed: true,
                ),
                onSubmitted: _runSearch,
              )
            : const SizedBox.shrink(), // tidak ada teks saat bukan mode search

        shape: const Border(
          bottom: BorderSide(color: Colors.black87, width: 1),
        ),
        actions: [
          _isSearching
              ? IconButton(
                  icon: const Icon(Icons.close),
                  color: Colors.black87,
                  tooltip: 'Tutup',
                  onPressed: () {
                    setState(() {
                      _isSearching = false;
                      _controller.clear();
                    });
                  },
                )
              : IconButton(
                  icon: const Icon(Icons.search),
                  color: Colors.black87,
                  tooltip: 'Cari Berita',
                  onPressed: () => setState(() => _isSearching = true),
                ),
        ],
      ),
      body: FutureBuilder<List<Article>>(
        future: _future,
        builder: (context, snap) {
          // Validasi API key (harus di-set lewat --dart-define)
          if (kNewsApiKey.isEmpty) {
            return _ErrorView(
              message:
                  'NEWSAPI_KEY belum di-set.\n'
                  'Jalankan dengan:\n'
                  '--dart-define=NEWSAPI_KEY=YOUR_KEY_HERE',
              onRetry: _reloadHeadlines,
            );
          }

          if (snap.connectionState == ConnectionState.waiting) {
            return const _LoadingList();
          }

          if (snap.hasError) {
            return _ErrorView(
              message: 'Gagal memuat data.\n${snap.error}',
              onRetry: _reloadHeadlines,
            );
          }

          final items = snap.data ?? [];
          if (items.isEmpty) return _EmptyView(onReload: _reloadHeadlines);

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                final q = _controller.text.trim();
                _future = q.isNotEmpty
                    ? _service
                          .everything(
                            q: q,
                            language: 'id',
                            sortBy: 'publishedAt',
                            pageSize: 20,
                          )
                          .then((items) async {
                            if (items.isEmpty) {
                              debugPrint(
                                'Refresh search kosong, coba tanpa language',
                              );
                              return _service.everything(
                                q: q,
                                sortBy: 'publishedAt',
                                pageSize: 20,
                              );
                            }
                            return items;
                          })
                    : _loadHeadlinesWithFallback();
              });
              await _future;
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) => _NewsCard(article: items[i]),
            ),
          );
        },
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Garis di atas navbar
          Container(
            height: 1,
            color: Colors.black26, // Ubah warna sesuai kebutuhan
          ),
          const CustomNavBarCurved(),
        ],
      ),
    );
  }
}

class BottomNavCurvePainter extends CustomPainter {
  Color backgroundColor;

  double insetRadius;
  BottomNavCurvePainter({
    this.backgroundColor = Colors.black,
    this.insetRadius = 38,
  });
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;
    Path path = Path()..moveTo(0, 0);

    double insetCurveBeginnningX = size.width / 2 - insetRadius;
    double insetCurveEndX = size.width / 2 + insetRadius;
    double transitionToInsetCurveWidth = size.width * .05;

    path.quadraticBezierTo(
      size.width * 0.20,
      0,
      insetCurveBeginnningX - transitionToInsetCurveWidth,
      0,
    );
    path.quadraticBezierTo(
      insetCurveBeginnningX,
      0,
      insetCurveBeginnningX,
      insetRadius / 2,
    );
    path.arcToPoint(
      Offset(insetCurveEndX, insetRadius / 2),
      radius: const Radius.circular(10.0),
      clockwise: false,
    );
    path.quadraticBezierTo(
      insetCurveEndX,
      0,
      insetCurveEndX + transitionToInsetCurveWidth,
      0,
    );
    path.quadraticBezierTo(size.width * 0.80, 0, size.width, 0);

    // Pastikan path benar-benar menutup ke bawah dan sisi kiri-kanan
    path.lineTo(size.width, size.height); // kanan bawah
    path.lineTo(0, size.height); // kiri bawah
    path.lineTo(0, 0); // kembali ke kiri atas
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class CustomNavBarCurved extends StatefulWidget {
  const CustomNavBarCurved({super.key});

  @override
  CustomNavBarCurvedState createState() => CustomNavBarCurvedState();
}

class CustomNavBarCurvedState extends State<CustomNavBarCurved> {
  // Track selected index
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double height = 56;

    // Use theme colors
    final primaryColor = Theme.of(context).colorScheme.primary;
    final secondaryColor = Theme.of(context).colorScheme.secondary;
    final backgroundColor = Theme.of(context).colorScheme.surface;

    return BottomAppBar(
      color: Colors.white,
      elevation: 0,
      child: SafeArea(
        bottom: true,
        child: SizedBox(
          height: 56 + MediaQuery.of(context).padding.bottom,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              NavBarIcon(
                text: "Home",
                icon: CupertinoIcons.home,
                selected: _selectedIndex == 0,
                onPressed: () => _onNavBarItemTapped(0),
                defaultColor: secondaryColor,
                selectedColor: primaryColor,
              ),
              NavBarIcon(
                text: "Search",
                icon: CupertinoIcons.search,
                selected: _selectedIndex == 1,
                onPressed: () => _onNavBarItemTapped(1),
                defaultColor: secondaryColor,
                selectedColor: primaryColor,
              ),
              FloatingActionButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100.0),
                ),
                backgroundColor: Colors.red,
                elevation: 0.1,
                onPressed: () {},
                child: const Icon(
                  Icons.local_fire_department,
                  color: Colors.black,
                ),
              ),
              NavBarIcon(
                text: "Cart",
                icon: Icons.local_grocery_store_outlined,
                selected: _selectedIndex == 2,
                onPressed: () => _onNavBarItemTapped(2),
                defaultColor: secondaryColor,
                selectedColor: primaryColor,
              ),
              NavBarIcon(
                text: "Calendar",
                icon: CupertinoIcons.person,
                selected: _selectedIndex == 3,
                onPressed: () => _onNavBarItemTapped(3),
                selectedColor: primaryColor,
                defaultColor: secondaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Update index when an item is tapped
  void _onNavBarItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Navigate to different pages based on the tapped index
    switch (index) {
      case 0:
        // Navigate to Home
        break;
      case 1:
        // Navigate to Search
        break;
      case 2:
        // Navigate to Cart
        break;
      case 3:
        // Navigate to Profile
        break;
    }
  }
}

class NavBarIcon extends StatelessWidget {
  final String text;
  final IconData icon;
  final bool selected;
  final Function() onPressed;
  final Color defaultColor;
  final Color selectedColor;
  const NavBarIcon({
    super.key,
    required this.text,
    required this.icon,
    required this.selected,
    required this.onPressed,
    this.selectedColor = const Color(0xffFF8527),
    this.defaultColor = Colors.black54,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      icon: CircleAvatar(
        backgroundColor: selected ? Colors.red : Colors.transparent,
        child: Icon(
          icon,
          size: 25,
          color: selected ? Colors.black : defaultColor,
        ),
      ),
    );
  }
}

/* ===== Widget pendukung ringkas ===== */

class _NewsCard extends StatelessWidget {
  final Article article;
  const _NewsCard({required this.article});

  @override
  Widget build(BuildContext context) {
    final img = article.urlToImage;
    return InkWell(
      onTap: () => ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(article.title))),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: (img == null || img.isEmpty)
                  ? Container(
                      width: 110,
                      height: 90,
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.image_not_supported),
                    )
                  : Image.network(
                      img,
                      width: 110,
                      height: 90,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 110,
                        height: 90,
                        color: Colors.grey.shade300,
                        child: const Icon(Icons.broken_image),
                      ),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 90,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const Spacer(),
                    Text(
                      _metaText(article),
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _metaText(Article a) {
    final source = a.sourceName ?? 'Unknown';
    final time = a.publishedAt != null ? ' • ${_fmtAgo(a.publishedAt!)}' : '';
    return '$source$time';
  }

  static String _fmtAgo(DateTime t) {
    final d = DateTime.now().difference(t);
    if (d.inMinutes < 60) return '${d.inMinutes}m';
    if (d.inHours < 24) return '${d.inHours}h';
    return '${d.inDays}d';
  }
}

class _LoadingList extends StatelessWidget {
  const _LoadingList();
  @override
  Widget build(BuildContext context) => ListView.separated(
    padding: const EdgeInsets.all(16),
    itemCount: 6,
    separatorBuilder: (_, __) => const SizedBox(height: 12),
    itemBuilder: (_, __) => Container(
      height: 90,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );
}

class _EmptyView extends StatelessWidget {
  final VoidCallback onReload;
  const _EmptyView({required this.onReload});
  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.article_outlined, size: 48, color: Colors.grey),
        const SizedBox(height: 8),
        const Text('Belum ada artikel'),
        const SizedBox(height: 12),
        FilledButton(onPressed: onReload, child: const Text('Muat ulang')),
      ],
    ),
  );
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          FilledButton(onPressed: onRetry, child: const Text('Coba lagi')),
        ],
      ),
    ),
  );
}
