import 'package:flutter/material.dart';
import 'package:shop/components/network_image_with_loader.dart';
import 'package:shop/constants.dart';
import 'cart_service.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> productData;

  const ProductDetailsScreen({
    super.key,
    required this.productData,
  });

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  final CartService _cartService = CartService();
  int quantity = 1;

  @override
  Widget build(BuildContext context) {
    final product = widget.productData;
    final productId = product['docId'];
    final isAvailable = (product['stock'] ?? 0) > 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(product['name'] ?? 'Product'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            NetworkImageWithLoader(
              product['imageUrl'] ?? productDemoImg1,
              height: 250,
              width: double.infinity,
              fit: BoxFit.cover,
              radius: 0,
            ),
            const SizedBox(height: 16),
            Text(
              product['name'] ?? '',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Rp ${product['price'] ?? 0}',
              style: const TextStyle(
                fontSize: 20,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              product['description'] ?? '',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Text(
              'Stock: ${product['stock'] ?? 0}',
              style: TextStyle(
                color: isAvailable ? Colors.black : Colors.red,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            if (isAvailable)
              Row(
                children: [
                  const Text('Quantity: '),
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: quantity > 1
                        ? () => setState(() => quantity--)
                        : null,
                  ),
                  Text('$quantity'),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => setState(() => quantity++),
                  ),
                ],
              ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: isAvailable
                  ? () => addToCart(productId)
                  : null,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Add to Cart'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> addToCart(String productId) async {
    try {
      final product = widget.productData;

      await _cartService.addToCart(
        productId: productId,
        name: product['name'],
        price: product['price'],
        imageUrl: product['imageUrl'],
        quantity: quantity,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Added to cart')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: $e')),
      );
    }
  }
}
