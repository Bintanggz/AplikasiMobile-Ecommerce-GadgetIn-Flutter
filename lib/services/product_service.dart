import 'package:cloud_firestore/cloud_firestore.dart';

class ProductService {
  final CollectionReference products =
  FirebaseFirestore.instance.collection("product");

  // Get semua produk
  Stream<List<Map<String, dynamic>>> getProducts() {
    return products.snapshots().map((snapshot) {
      if (snapshot.docs.isEmpty) {
        print('⚠️ ProductService: No products found in collection "product"');
        return <Map<String, dynamic>>[];
      }
      print('✅ ProductService: Found ${snapshot.docs.length} products');
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {...data, "id": doc.id};
      }).toList();
    }).handleError((error) {
      print('❌ ProductService Error: $error');
      return <Map<String, dynamic>>[];
    });
  }

  // Get produk popular (filter berdasarkan field 'isPopular')
  // Jika tidak ada produk dengan isPopular=true, akan return empty list
  Stream<List<Map<String, dynamic>>> getPopularProducts() {
    try {
      return products
          .where('isPopular', isEqualTo: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          return {...doc.data() as Map<String, dynamic>, "id": doc.id};
        }).toList();
      });
    } catch (e) {
      // Jika query gagal (misalnya field tidak ada), return stream kosong
      return Stream.value([]);
    }
  }

  // Get produk flash sale (filter berdasarkan field 'isFlashSale')
  // Jika tidak ada produk dengan isFlashSale=true, akan return empty list
  Stream<List<Map<String, dynamic>>> getFlashSaleProducts() {
    try {
      return products
          .where('isFlashSale', isEqualTo: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          return {...doc.data() as Map<String, dynamic>, "id": doc.id};
        }).toList();
      });
    } catch (e) {
      // Jika query gagal (misalnya field tidak ada), return stream kosong
      return Stream.value([]);
    }
  }

  // Get produk best sellers (filter berdasarkan field 'isBestSeller')
  // Jika tidak ada produk dengan isBestSeller=true, akan return empty list
  Stream<List<Map<String, dynamic>>> getBestSellersProducts() {
    try {
      return products
          .where('isBestSeller', isEqualTo: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          return {...doc.data() as Map<String, dynamic>, "id": doc.id};
        }).toList();
      });
    } catch (e) {
      // Jika query gagal (misalnya field tidak ada), return stream kosong
      return Stream.value([]);
    }
  }

  // Get produk on sale (produk yang memiliki diskon - priceAfterDiscount atau discountedPrice)
  Stream<List<Map<String, dynamic>>> getOnSaleProducts() {
    return products.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return {...data, "id": doc.id};
          })
          .where((product) {
            // Filter produk yang memiliki diskon
            final hasDiscount = product['priceAfterDiscount'] != null ||
                product['discountedPrice'] != null ||
                product['discountPercent'] != null ||
                product['discount'] != null;
            return hasDiscount;
          })
          .toList();
    }).handleError((error) {
      print('❌ ProductService Error (getOnSaleProducts): $error');
      return <Map<String, dynamic>>[];
    });
  }

  // Get produk berdasarkan kategori
  Stream<List<Map<String, dynamic>>> getProductsByCategory(String category) {
    return products.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return {...data, "id": doc.id};
          })
          .where((product) {
            // Cek kategori dari field category atau infer dari title/name
            final productCategory = (product['category'] ?? 
                                    product['productCategory'] ?? 
                                    product['type'] ?? 
                                    '').toString().toLowerCase();
            
            final title = (product['title'] ?? 
                         product['name'] ?? 
                         '').toString().toLowerCase();
            
            final categoryLower = category.toLowerCase();
            
            // Jika ada field category yang cocok
            if (productCategory.isNotEmpty && 
                (productCategory == categoryLower || 
                 productCategory.contains(categoryLower) ||
                 categoryLower.contains(productCategory))) {
              return true;
            }
            
            // Infer kategori dari title/name
            switch (categoryLower) {
              case 'smartphone':
                return title.contains('iphone') || 
                       (title.contains('samsung') && title.contains('galaxy')) ||
                       (title.contains('galaxy') && !title.contains('watch')) ||
                       title.contains('xiaomi') ||
                       title.contains('oppo') ||
                       title.contains('vivo') ||
                       title.contains('realme') ||
                       title.contains('oneplus') ||
                       title.contains('redmi') ||
                       title.contains('smartphone');
              case 'laptop':
                return title.contains('laptop') || 
                       title.contains('macbook') ||
                       title.contains('notebook') ||
                       title.contains('thinkpad') ||
                       title.contains('rog') ||
                       (title.contains('asus') && !title.contains('phone')) ||
                       (title.contains('lenovo') && !title.contains('phone')) ||
                       (title.contains('hp ') && !title.contains('phone')) ||
                       (title.contains('dell') && !title.contains('phone')) ||
                       (title.contains('acer') && !title.contains('phone')) ||
                       (title.contains('msi') && !title.contains('phone'));
              case 'tablet':
                return title.contains('ipad') || 
                       title.contains('tablet') ||
                       title.contains('tab ');
              case 'aksesoris':
              case 'accessories':
                return title.contains('headphone') || 
                       title.contains('earphone') ||
                       title.contains('airpods') ||
                       title.contains('mouse') ||
                       title.contains('keyboard') ||
                       title.contains('power bank') ||
                       title.contains('charger') ||
                       title.contains('case') ||
                       title.contains('watch') ||
                       title.contains('speaker') ||
                       title.contains('cable') ||
                       title.contains('adapter');
              default:
                // Jika kategori tidak dikenali, cek apakah ada di title
                return title.contains(categoryLower);
            }
          })
          .toList();
    }).handleError((error) {
      print('❌ ProductService Error (getProductsByCategory): $error');
      return <Map<String, dynamic>>[];
    });
  }

  // Get detail produk
  Future<Map<String, dynamic>?> getProductById(String id) async {
    final doc = await products.doc(id).get();
    if (doc.exists) {
      return {...doc.data() as Map<String, dynamic>, "id": doc.id};
    }
    return null;
  }

  // Add produk (khusus admin)
  Future<void> addProduct(Map<String, dynamic> data) async {
    await products.add(data);
  }

  // Update produk
  Future<void> updateProduct(String id, Map<String, dynamic> data) async {
    await products.doc(id).update(data);
  }

  // Delete produk
  Future<void> deleteProduct(String id) async {
    await products.doc(id).delete();
  }

  // Helper method untuk mapping data Firebase ke format ProductCard
  static Map<String, dynamic> mapToProductCard(Map<String, dynamic> firebaseData) {
    final title = (firebaseData['title'] ?? firebaseData['name'] ?? '').toString().toLowerCase();
    
    // Extract brandName dengan fallback yang lebih pintar
    String brandName = (firebaseData['brandName'] ?? firebaseData['brand'] ?? '').toString();
    
    // Jika brandName kosong, coba ekstrak dari title
    if (brandName.isEmpty || brandName.trim().isEmpty) {
      if (title.contains('macbook') || 
          title.contains('iphone') || 
          title.contains('ipad') || 
          title.contains('apple watch') ||
          title.contains('airpods') ||
          title.contains('imac') ||
          title.contains('mac mini') ||
          title.contains('mac studio')) {
        brandName = 'Apple';
      } else if (title.contains('samsung') || title.contains('galaxy')) {
        brandName = 'Samsung';
      } else if (title.contains('xiaomi') || title.contains('redmi') || title.contains('mi ')) {
        brandName = 'Xiaomi';
      } else if (title.contains('oppo')) {
        brandName = 'OPPO';
      } else if (title.contains('vivo')) {
        brandName = 'Vivo';
      } else if (title.contains('realme')) {
        brandName = 'Realme';
      } else if (title.contains('oneplus')) {
        brandName = 'OnePlus';
      } else if (title.contains('asus') || title.contains('rog')) {
        brandName = 'ASUS';
      } else if (title.contains('lenovo') || title.contains('thinkpad')) {
        brandName = 'Lenovo';
      } else if (title.contains('hp ') || title.contains('hp ')) {
        brandName = 'HP';
      } else if (title.contains('dell')) {
        brandName = 'Dell';
      } else if (title.contains('acer')) {
        brandName = 'Acer';
      } else if (title.contains('msi')) {
        brandName = 'MSI';
      } else if (title.contains('logitech')) {
        brandName = 'Logitech';
      } else if (title.contains('sony')) {
        brandName = 'Sony';
      } else if (title.contains('razer')) {
        brandName = 'Razer';
      } else if (title.contains('hyperx')) {
        brandName = 'HyperX';
      } else if (title.contains('anker')) {
        brandName = 'Anker';
      } else {
        brandName = ''; // Tetap kosong jika tidak bisa diidentifikasi
      }
    }
    
    return {
      'image': firebaseData['imageUrl'] ?? firebaseData['image'] ?? '',
      'brandName': brandName,
      'title': firebaseData['title'] ?? firebaseData['name'] ?? '',
      'price': (firebaseData['price'] ?? 0).toDouble(),
      'priceAfetDiscount': firebaseData['priceAfterDiscount'] != null 
          ? (firebaseData['priceAfterDiscount'] as num).toDouble()
          : firebaseData['discountedPrice'] != null
              ? (firebaseData['discountedPrice'] as num).toDouble()
              : null,
      'dicountpercent': firebaseData['discountPercent'] ?? 
                       firebaseData['discount'] ?? 
                       null,
      'images': (firebaseData['images'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      'id': firebaseData['id'] ?? firebaseData['docId'] ?? '',
    };
  }
}
