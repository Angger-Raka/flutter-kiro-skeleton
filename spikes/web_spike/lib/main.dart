import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

void main() {
  usePathUrlStrategy();
  runApp(const SpikeApp());
}

final _router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (_, __) => const HomePage()),
    GoRoute(path: '/a/b', builder: (_, __) => const DeepPage()),
  ],
);

class SpikeApp extends StatelessWidget {
  const SpikeApp({super.key});

  @override
  Widget build(BuildContext context) =>
      MaterialApp.router(routerConfig: _router, title: 'web_spike');
}

class Article {
  Article(this.title, this.imageUrl);
  final String title;
  final String imageUrl;
  String get host => Uri.tryParse(imageUrl)?.host ?? '?';
}

Future<List<Article>> fetchArticles() async {
  final res = await http.get(Uri.parse(
      'https://api.spaceflightnewsapi.net/v4/articles/?limit=10'));
  if (res.statusCode != 200) throw Exception('HTTP ${res.statusCode}');
  final results = (jsonDecode(res.body)['results'] as List);
  return results
      .map((e) => Article(e['title'] as String, e['image_url'] as String))
      .toList();
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final Future<List<Article>> _future = fetchArticles();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('web_spike /')),
      body: FutureBuilder<List<Article>>(
        future: _future,
        builder: (context, snap) {
          if (snap.hasError) return Center(child: Text('API error: ${snap.error}'));
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              TextButton(
                onPressed: () => context.go('/a/b'),
                child: const Text('Go to /a/b'),
              ),
              for (final a in snap.data!) _Row(article: a),
            ],
          );
        },
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.article});
  final Article article;

  Widget _framed(Widget child) => ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black, width: 0.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: SizedBox(height: 140, child: child),
        ),
      );

  Widget _error(String loader) => Center(
        child: Text('$loader FAILED',
            style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
      );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('host: ${article.host}',
              style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: _framed(Image.network(
                  article.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _error('Image.network'),
                )),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _framed(CachedNetworkImage(
                  imageUrl: article.imageUrl,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => _error('CachedNetworkImage'),
                )),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class DeepPage extends StatelessWidget {
  const DeepPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('web_spike /a/b')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Deep link /a/b works'),
              TextButton(
                  onPressed: () => context.go('/'), child: const Text('Back to /')),
            ],
          ),
        ),
      );
}
