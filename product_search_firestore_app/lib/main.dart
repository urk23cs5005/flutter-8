import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const ProductSearchApp());
}

class ProductSearchApp extends StatelessWidget {
  const ProductSearchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Product Search',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: const SearchPage(),
    );
  }
}

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _searchCtrl = TextEditingController();

  bool _loading = false;
  bool _searched = false;
  Map<String, dynamic>? _product; // null => not found

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  String _titleCase(String s) => s
    .split(' ')
    .map((w) => w.isEmpty ? w : w[0].toUpperCase() + w.substring(1).toLowerCase())
    .join(' ');

  Future<QuerySnapshot<Map<String, dynamic>>> _query(String name) {
    return FirebaseFirestore.instance
      .collection('products')
      .where('name', isEqualTo: name)
      .limit(1)
      .get();
  }

  Future<void> _searchProduct() async {
    final text = _searchCtrl.text.trim();
    if (text.isEmpty) return;
    FocusScope.of(context).unfocus();
    setState(() => _loading = true);

    try {
      // Try the text exactly as typed, then in Title Case (e.g. "rice" -> "Rice")
      var snap = await _query(text);
      if (snap.docs.isEmpty) {
        snap = await _query(_titleCase(text));
      }
      setState(() {
          _product = snap.docs.isEmpty ? null : snap.docs.first.data();
          _searched = true;
        });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _buildResult() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (!_searched) {
      return const Center(
        child: Text('Enter a product name and tap Search',
          style: TextStyle(color: Colors.grey, fontSize: 16)),
      );
    }
    if (_product == null) {
      return const Center(
        child: Text('Product not found',
          style: TextStyle(
            color: Colors.red, fontSize: 22, fontWeight: FontWeight.bold)),
      );
    }

    final String name = _product!['name'];
    final int qty = (_product!['quantity'] as num).toInt();
    final double price = (_product!['price'] as num).toDouble();
    final bool low = qty < 5;

    return Card(
      color: low ? Colors.red.shade50 : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: low
          ? const BorderSide(color: Colors.red, width: 1.5)
          : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name,
              style:
              const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
            const Divider(height: 28),
            Text('Quantity : $qty', style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 8),
            Text('Price : \u20B9${price.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 20)),
            if (low) ...[
              const SizedBox(height: 16),
              const Text('Low Stock!',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Search'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _searchCtrl,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _searchProduct(),
              decoration: const InputDecoration(
                labelText: 'Product Name',
                prefixIcon: Icon(Icons.inventory_2_outlined),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton.icon(
                onPressed: _searchProduct,
                icon: const Icon(Icons.search),
                label: const Text('SEARCH'),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(child: Align(alignment: Alignment.topCenter, child: _buildResult())),
          ],
        ),
      ),
    );
  }
}
