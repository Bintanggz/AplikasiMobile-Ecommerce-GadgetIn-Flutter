import 'package:flutter/material.dart';
import 'package:shop/constants.dart';
import 'package:shop/route/route_constants.dart';
import 'package:shop/services/product_service.dart';
import 'package:shop/components/network_image_with_loader.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final ProductService _productService = ProductService();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: "Cari smartphone, laptop, smartwatch...",
            border: InputBorder.none,
          ),
          onChanged: (value) {
            setState(() {
              _query = value.toLowerCase();
            });
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              _controller.clear();
              setState(() => _query = '');
            },
          )
        ],
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _productService.getProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Terjadi kesalahan: ${snapshot.error}'),
            );
          }

          final products = snapshot.data ?? [];
          final results = products.where((product) {
            if (_query.isEmpty) return true;
            final title =
                (product['name'] ?? product['title'] ?? '').toString().toLowerCase();
            final brand =
                (product['brandName'] ?? product['brand'] ?? '').toString().toLowerCase();
            return title.contains(_query) || brand.contains(_query);
          }).toList();

          if (results.isEmpty) {
            return const Center(
              child: Text('Gadget yang kamu cari belum tersedia'),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(defaultPadding),
            itemBuilder: (context, index) {
              final product = results[index];
              final price = (product['price'] ?? 0).toDouble();
              final image = product['imageUrl'] ??
                  product['image'] ??
                  (product['images'] is List && (product['images'] as List).isNotEmpty
                      ? (product['images'] as List).first
                      : '');

              return ListTile(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    productDetailsScreenRoute,
                    arguments: product,
                  );
                },
                leading: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(12)),
                  child: NetworkImageWithLoader(
                    image,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    radius: 12,
                  ),
                ),
                title: Text(
                  product['name'] ?? product['title'] ?? 'Produk',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  formatCurrency(price),
                  style: const TextStyle(
                      color: Color(0xFF31B0D8), fontWeight: FontWeight.w600),
                ),
                trailing: const Icon(Icons.chevron_right),
              );
            },
            separatorBuilder: (_, __) => const Divider(),
            itemCount: results.length,
          );
        },
      ),
    );
  }
}
