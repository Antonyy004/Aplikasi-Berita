import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'config.dart';
const String kNewsApiKey = String.fromEnvironment('NEWSAPI_KEY', defaultValue: '');

void main() {
  debugPrint('NEWSAPI_KEY set? ${kNewsApiKey.isNotEmpty}'); // harus true
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Portal Berita',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}
