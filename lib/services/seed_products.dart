
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shop/models/product_model.dart';
import 'package:shop/services/product_service.dart';

class ProductSeeder {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final ProductService _productService = ProductService();

  Future<void> seedProducts() async {
    print("🚀 Starting seeding...");

    // 1. Seed Popular Products
    await _seedList(demoPopularProducts, isPopular: true);

    // 2. Seed Flash Sale
    await _seedList(demoFlashSaleProducts, isFlashSale: true);

    // 3. Seed Best Sellers
    await _seedList(demoBestSellersProducts, isBestSeller: true);

    // 4. Seed Accessories (Kids)
    await _seedList(kidsProducts, category: "Accessories");

    print("✅ Seeding completed!");
  }

  Future<void> _seedList(List<ProductModel> products,
      {bool isPopular = false,
      bool isFlashSale = false,
      bool isBestSeller = false,
      String? category}) async {
    
    for (var product in products) {
      // Cek apakah produk dengan nama yang sama sudah ada
      final query = await _db
          .collection('product') // ProductService uses "product" collection
          .where('title', isEqualTo: product.title)
          .get();

      if (query.docs.isNotEmpty) {
        print("⚠️ Skipped: ${product.title} (Already exists)");
        continue;
      }

      // Map local model to Firestore Map
      // Sesuaikan nama field dengan yang diharapkan ProductService.mapToProductCard
      final data = {
        'title': product.title,
        'brandName': product.brandName,
        'image': product.image, // ProductService handles 'image' key
        'price': product.price,
        'priceAfterDiscount': product.priceAfetDiscount,
        'discountPercent': product.dicountpercent,
        'isPopular': isPopular,
        'isFlashSale': isFlashSale,
        'isBestSeller': isBestSeller,
        'category': category ?? "Gadget", // Default category
        'createdAt': FieldValue.serverTimestamp(),
      };

      await _productService.addProduct(data);
      print("✅ Added: ${product.title}");
    }
  }
}
