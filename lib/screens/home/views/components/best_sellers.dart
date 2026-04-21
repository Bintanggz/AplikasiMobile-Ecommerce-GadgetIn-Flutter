import 'package:flutter/material.dart';
import 'package:shop/components/product/product_card.dart';
import 'package:shop/services/product_service.dart';

import '../../../../constants.dart';
import '../../../../route/route_constants.dart';

class BestSellers extends StatelessWidget {
  const BestSellers({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final ProductService _productService = ProductService();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: defaultPadding / 2),
        Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child: Text(
            "Terlaris",
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        SizedBox(
          height: 220,
          child: StreamBuilder<List<Map<String, dynamic>>>(
            stream: _productService.getBestSellersProducts(),
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
                // Fallback ke semua produk jika tidak ada produk best seller
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
                    return _buildProductList(context, products);
                  },
                );
              }

              final products = snapshot.data!;
              return _buildProductList(context, products);
            },
          ),
        )
      ],
    );
  }

  Widget _buildProductList(
      BuildContext context, List<Map<String, dynamic>> products) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: products.length,
      itemBuilder: (context, index) {
        final productData = ProductService.mapToProductCard(products[index]);
        return Padding(
          padding: EdgeInsets.only(
            left: defaultPadding,
            right: index == products.length - 1 ? defaultPadding : 0,
          ),
          child: ProductCard(
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
          ),
        );
      },
    );
  }
}
