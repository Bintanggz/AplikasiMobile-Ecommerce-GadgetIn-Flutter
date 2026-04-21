import 'package:flutter/material.dart';
import 'package:shop/components/product/product_card.dart';
import 'package:shop/route/route_constants.dart';
import 'package:shop/services/product_service.dart';

import '../../../constants.dart';

class BookmarkScreen extends StatelessWidget {
  const BookmarkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ProductService _productService = ProductService();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.symmetric(
                horizontal: defaultPadding, vertical: defaultPadding),
            sliver: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _productService.getProducts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (snapshot.hasError) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Text('Terjadi kesalahan: ${snapshot.error}'),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const SliverFillRemaining(
                    child: Center(
                      child: Text('Tidak ada produk tersedia'),
                    ),
                  );
                }

                final products = snapshot.data!;
                return SliverGrid(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200.0,
                mainAxisSpacing: defaultPadding,
                crossAxisSpacing: defaultPadding,
                childAspectRatio: 0.66,
              ),
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                      final productData =
                          ProductService.mapToProductCard(products[index]);
                  return ProductCard(
                        image: productData['image'] as String,
                        brandName: productData['brandName'] as String,
                        title: productData['title'] as String,
                        price: productData['price'] as double,
                    priceAfetDiscount:
                            productData['priceAfetDiscount'] as double?,
                        dicountpercent:
                            productData['dicountpercent'] as int?,
                    press: () {
                          Navigator.pushNamed(
                            context,
                            productDetailsScreenRoute,
                            arguments: products[index], // Pass full product data
                          );
                    },
                  );
                },
                    childCount: products.length,
              ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
