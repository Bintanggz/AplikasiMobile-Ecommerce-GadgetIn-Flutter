import 'package:flutter/material.dart';
import 'package:shop/components/product/product_card.dart';
import 'package:shop/route/route_constants.dart';
import 'package:shop/services/product_service.dart';

import '../../../constants.dart';

class OnSaleScreen extends StatelessWidget {
  const OnSaleScreen({super.key, this.category});

  final String? category;

  @override
  Widget build(BuildContext context) {
    final ProductService _productService = ProductService();
    final String screenTitle = category != null ? category! : 'Produk Diskon';
    final Stream<List<Map<String, dynamic>>> productStream = 
        category != null 
            ? _productService.getProductsByCategory(category!)
            : _productService.getOnSaleProducts();

    return Scaffold(
      appBar: AppBar(
        title: Text(screenTitle),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: productStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Terjadi kesalahan: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            // Fallback ke semua produk jika tidak ada produk on sale
            return StreamBuilder<List<Map<String, dynamic>>>(
              stream: _productService.getProducts(),
              builder: (context, allSnapshot) {
                if (allSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!allSnapshot.hasData || allSnapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('Tidak ada produk tersedia'),
                  );
                }
                final products = allSnapshot.data!;
                return _buildProductGrid(context, products);
              },
            );
          }

          final products = snapshot.data!;
          return _buildProductGrid(context, products);
        },
      ),
    );
  }

  Widget _buildProductGrid(
      BuildContext context, List<Map<String, dynamic>> products) {
    return GridView.builder(
      padding: const EdgeInsets.all(defaultPadding),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: defaultPadding,
        mainAxisSpacing: defaultPadding,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final productData = ProductService.mapToProductCard(products[index]);
        return ProductCard(
          image: productData['image'] as String,
          brandName: productData['brandName'] as String,
          title: productData['title'] as String,
          price: productData['price'] as double,
          priceAfetDiscount: productData['priceAfetDiscount'] as double?,
          dicountpercent: productData['dicountpercent'] as int?,
          press: () {
            Navigator.pushNamed(
              context,
              productDetailsScreenRoute,
              arguments: products[index], // Pass full product data
            );
          },
        );
      },
    );
  }
}
