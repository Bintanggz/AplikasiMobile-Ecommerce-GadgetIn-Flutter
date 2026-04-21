import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shop/components/cart_button.dart';
import 'package:shop/components/custom_modal_bottom_sheet.dart';
import 'package:shop/components/product/product_card.dart';
import 'package:shop/constants.dart';
import 'package:shop/screens/product/views/product_returns_screen.dart';
import 'package:shop/route/screen_export.dart';
import 'package:shop/services/product_service.dart';

import 'components/notify_me_card.dart';
import 'components/product_images.dart';
import 'components/product_info.dart';
import 'components/product_list_tile.dart';
import '../../../components/review_card.dart';
import 'product_buy_now_screen.dart';

class ProductDetailsScreen extends StatelessWidget {
  const ProductDetailsScreen({
    super.key,
    required this.productData,
  });

  final Map<String, dynamic> productData;

  // Helper method untuk extract data dari Firebase
  Map<String, dynamic> _getProductInfo() {
    // Debug: print semua field yang ada di productData
    print('📦 Product Data Keys: ${productData.keys.toList()}');
    print('📦 Product Data: $productData');
    
    // Cari image dari berbagai kemungkinan field name di Firebase
    final imageUrl = (productData['imageUrl'] ?? 
                     productData['image'] ?? 
                     productData['imageURL'] ??
                     productData['productImage'] ??
                     productData['photo'] ??
                     productData['img'] ??
                     '').toString().trim();
    
    // Cari images array dari berbagai kemungkinan field name
    final images = (productData['images'] ?? 
                   productData['imageList'] ?? 
                   productData['productImages'] ??
                   productData['photos'] ??
                   productData['gallery'] ??
                   productData['imageUrls']) as List<dynamic>?;
    
    print('🖼️ ImageUrl found: $imageUrl');
    print('🖼️ Images array found: $images');
    
    // Pastikan semua gambar muncul - gabungkan images array dengan imageUrl
    List<String> imageList = [];
    
    // Helper function untuk validasi dan menambah image URL
    void addImageIfValid(String? imgUrl) {
      if (imgUrl == null || imgUrl.isEmpty) return;
      
      final cleanUrl = imgUrl.toString().trim();
      
      // Validasi: tidak boleh null, empty, atau object/array string representation
      if (cleanUrl.isEmpty || 
          cleanUrl == 'null' || 
          cleanUrl == '[]' ||
          cleanUrl == '{}' ||
          cleanUrl.toLowerCase() == 'undefined') {
        return;
      }
      
      // Validasi URL: support http, https, assets, atau path yang valid
      // Firebase Storage URLs biasanya https://firebasestorage.googleapis.com/...
      // Juga support relative path atau URL lainnya
      final isValidUrl = cleanUrl.startsWith('http://') || 
                        cleanUrl.startsWith('https://') || 
                        cleanUrl.startsWith('assets/') ||
                        cleanUrl.startsWith('/') ||
                        cleanUrl.contains('.') && (cleanUrl.contains('/') || cleanUrl.endsWith('.jpg') || cleanUrl.endsWith('.png') || cleanUrl.endsWith('.jpeg') || cleanUrl.endsWith('.webp'));
      
      if (isValidUrl && !imageList.contains(cleanUrl)) {
        imageList.add(cleanUrl);
        print('✅ Added image: $cleanUrl');
      } else {
        print('❌ Invalid image URL skipped: $cleanUrl');
      }
    }
    
    // 1. Ambil dari images array jika ada (handle berbagai format)
    if (images != null && images.isNotEmpty) {
      print('📸 Processing images array with ${images.length} items');
      for (var img in images) {
        if (img != null) {
          // Handle jika img adalah Map (Firebase Storage URL object)
          if (img is Map) {
            // Coba ambil URL dari berbagai field
            final url = img['url'] ?? img['downloadURL'] ?? img['path'] ?? img['src'] ?? img.toString();
            addImageIfValid(url.toString());
          } else {
            // Handle jika img adalah String langsung
            addImageIfValid(img.toString());
          }
        }
      }
    }
    
    // 2. Jika images array kosong tapi ada imageUrl, tambahkan imageUrl
    if (imageUrl.isNotEmpty && imageUrl != 'null') {
      addImageIfValid(imageUrl);
    }
    
    // 3. Fallback jika masih kosong - gunakan demo image
    if (imageList.isEmpty) {
      print('⚠️ No valid images found, using demo image');
      imageList = [productDemoImg1];
    }
    
    // Remove duplicates
    imageList = imageList.toSet().toList();
    
    // Debug: print final images yang akan ditampilkan
    print('📸 Final Product Images (${imageList.length}):');
    for (var i = 0; i < imageList.length; i++) {
      print('   ${i + 1}. ${imageList[i]}');
    }
    
    // Extract brandName dengan fallback yang lebih pintar
    String brand = (productData['brandName'] ?? productData['brand'] ?? '').toString();
    final titleDisplay = (productData['title'] ?? productData['name'] ?? 'Unknown Product').toString();
    final titleLower = titleDisplay.toLowerCase();
    
    // Jika brand kosong, coba ekstrak dari title
    if (brand.isEmpty || brand.trim().isEmpty) {
      if (titleLower.contains('macbook') || 
          titleLower.contains('iphone') || 
          titleLower.contains('ipad') || 
          titleLower.contains('apple watch') ||
          titleLower.contains('airpods') ||
          titleLower.contains('imac') ||
          titleLower.contains('mac mini') ||
          titleLower.contains('mac studio')) {
        brand = 'Apple';
      } else if (titleLower.contains('samsung') || titleLower.contains('galaxy')) {
        brand = 'Samsung';
      } else if (titleLower.contains('xiaomi') || titleLower.contains('redmi') || titleLower.contains('mi ')) {
        brand = 'Xiaomi';
      } else if (titleLower.contains('oppo')) {
        brand = 'OPPO';
      } else if (titleLower.contains('vivo')) {
        brand = 'Vivo';
      } else if (titleLower.contains('realme')) {
        brand = 'Realme';
      } else if (titleLower.contains('oneplus')) {
        brand = 'OnePlus';
      } else if (titleLower.contains('asus') || titleLower.contains('rog')) {
        brand = 'ASUS';
      } else if (titleLower.contains('lenovo') || titleLower.contains('thinkpad')) {
        brand = 'Lenovo';
      } else if (titleLower.contains('hp ') || titleLower.contains('hp ')) {
        brand = 'HP';
      } else if (titleLower.contains('dell')) {
        brand = 'Dell';
      } else if (titleLower.contains('acer')) {
        brand = 'Acer';
      } else if (titleLower.contains('msi')) {
        brand = 'MSI';
      } else if (titleLower.contains('logitech')) {
        brand = 'Logitech';
      } else if (titleLower.contains('sony')) {
        brand = 'Sony';
      } else if (titleLower.contains('razer')) {
        brand = 'Razer';
      } else if (titleLower.contains('hyperx')) {
        brand = 'HyperX';
      } else if (titleLower.contains('anker')) {
        brand = 'Anker';
      } else {
        brand = 'Unknown Brand';
      }
    }
    final description = (productData['description'] ?? productData['desc'] ?? 'No description available').toString();
    final price = (productData['price'] ?? 0).toDouble();
    final priceAfterDiscount = productData['priceAfterDiscount'] != null
        ? (productData['priceAfterDiscount'] as num).toDouble()
        : productData['discountedPrice'] != null
            ? (productData['discountedPrice'] as num).toDouble()
            : null;
    final stock = (productData['stock'] ?? 0) as int;
    final isAvailable = stock > 0;
    final rating = (productData['rating'] ?? 4.0).toDouble();
    final numOfReviews = (productData['numOfReviews'] ?? productData['reviews'] ?? 0) as int;

    return {
      'images': imageList,
      'brand': brand,
      'title': titleDisplay,
      'description': description,
      'price': price,
      'priceAfterDiscount': priceAfterDiscount,
      'isAvailable': isAvailable,
      'rating': rating,
      'numOfReviews': numOfReviews,
    };
  }

  @override
  Widget build(BuildContext context) {
    final info = _getProductInfo();
    final images = List<String>.from((info['images'] as List));
    final brand = info['brand'] as String;
    final title = info['title'] as String;
    final description = info['description'] as String;
    final price = info['price'] as double;
    final priceAfterDiscount = info['priceAfterDiscount'] as double?;
    final isAvailable = info['isAvailable'] as bool;
    final rating = info['rating'] as double;
    final numOfReviews = info['numOfReviews'] as int;

    // Gunakan harga setelah diskon jika ada, jika tidak gunakan harga normal
    final displayPrice = priceAfterDiscount ?? price;

    return Scaffold(
      bottomNavigationBar: isAvailable
          ? CartButton(
              price: displayPrice,
              title: "Beli Sekarang",
              subTitle: "Mulai dari",
              press: () {
                customModalBottomSheet(
                  context,
                  height: MediaQuery.of(context).size.height * 0.92,
                  child: ProductBuyNowScreen(productData: productData),
                );
              },
            )
          : NotifyMeCard(
              isNotify: false,
              onChanged: (value) {
                // Handle notify me functionality
              },
            ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              floating: true,
              actions: [
                IconButton(
                  onPressed: () {},
                  icon: SvgPicture.asset("assets/icons/Bookmark.svg",
                      color: Theme.of(context).textTheme.bodyLarge!.color),
                ),
              ],
            ),
            ProductImages(
              images: images.isNotEmpty 
                  ? images.where((img) => img.isNotEmpty && img != 'null').toList()
                  : [productDemoImg1],
            ),
            ProductInfo(
              brand: brand,
              title: title,
              isAvailable: isAvailable,
              description: description,
              rating: rating,
              numOfReviews: numOfReviews,
            ),
            ProductListTile(
              svgSrc: "assets/icons/Product.svg",
              title: "Detail Produk",
              press: () {
                customModalBottomSheet(
                  context,
                  height: MediaQuery.of(context).size.height * 0.92,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(defaultPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Detail Produk",
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: defaultPadding),
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: defaultPadding / 2),
                        Text(
                          "Brand: $brand",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: defaultPadding),
                        Text(
                          "Deskripsi:",
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: defaultPadding / 2),
                        Text(
                          description,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: defaultPadding),
                        Text(
                          "Spesifikasi:",
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: defaultPadding / 2),
                        ...(productData['specifications'] as Map<String, dynamic>? ?? {}).entries.map((e) => Padding(
                          padding: const EdgeInsets.only(bottom: defaultPadding / 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 120,
                                child: Text(
                                  "${e.key}:",
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  e.value.toString(),
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                        )),
                      ],
                    ),
                  ),
                );
              },
            ),
            ProductListTile(
              svgSrc: "assets/icons/Delivery.svg",
              title: "Informasi Pengiriman",
              press: () {
                customModalBottomSheet(
                  context,
                  height: MediaQuery.of(context).size.height * 0.92,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(defaultPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Informasi Pengiriman",
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: defaultPadding),
                        _buildShippingInfo(
                          context,
                          "Pengiriman Standar",
                          "5-7 hari kerja",
                          "Rp 15.000",
                          "Melalui JNE/Pos Indonesia",
                        ),
                        const SizedBox(height: defaultPadding),
                        _buildShippingInfo(
                          context,
                          "Pengiriman Express",
                          "2-3 hari kerja",
                          "Rp 25.000",
                          "Melalui JNE Express/J&T Express",
                        ),
                        const SizedBox(height: defaultPadding),
                        _buildShippingInfo(
                          context,
                          "Pengiriman Instant",
                          "1 hari kerja",
                          "Rp 50.000",
                          "Melalui GoSend/GrabExpress",
                        ),
                        const SizedBox(height: defaultPadding),
                        Text(
                          "Catatan:",
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: defaultPadding / 2),
                        Text(
                          "• Pengiriman hanya tersedia di wilayah Indonesia\n"
                          "• Barang akan dikemas dengan aman\n"
                          "• Resi pengiriman akan dikirim ke email setelah barang dikirim\n"
                          "• Estimasi pengiriman dapat berubah sesuai kondisi cuaca dan lokasi tujuan",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            ProductListTile(
              svgSrc: "assets/icons/Return.svg",
              title: "Kebijakan Pengembalian",
              isShowBottomBorder: true,
              press: () {
                customModalBottomSheet(
                  context,
                  height: MediaQuery.of(context).size.height * 0.92,
                  child: const ProductReturnsScreen(),
                );
              },
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(defaultPadding),
                child: ReviewCard(
                  rating: rating,
                  numOfReviews: numOfReviews,
                  // Default values jika tidak ada di Firebase
                  numOfFiveStar: productData['numOfFiveStar'] ?? (numOfReviews * 0.6).round(),
                  numOfFourStar: productData['numOfFourStar'] ?? (numOfReviews * 0.25).round(),
                  numOfThreeStar: productData['numOfThreeStar'] ?? (numOfReviews * 0.05).round(),
                  numOfTwoStar: productData['numOfTwoStar'] ?? (numOfReviews * 0.05).round(),
                  numOfOneStar: productData['numOfOneStar'] ?? (numOfReviews * 0.05).round(),
                ),
              ),
            ),
            ProductListTile(
              svgSrc: "assets/icons/Chat.svg",
              title: "Ulasan",
              isShowBottomBorder: true,
              press: () {
                Navigator.pushNamed(context, productReviewsScreenRoute);
              },
            ),
            SliverPadding(
              padding: const EdgeInsets.all(defaultPadding),
              sliver: SliverToBoxAdapter(
                child: Text(
                  "Anda mungkin juga suka",
                  style: Theme.of(context).textTheme.titleSmall!,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 220,
                child: StreamBuilder<List<Map<String, dynamic>>>(
                  stream: ProductService().getProducts(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    final products = snapshot.data!.where((p) {
                      // Exclude current product
                      final currentId = productData['id'] ?? productData['docId'] ?? '';
                      final productId = p['id'] ?? p['docId'] ?? '';
                      return productId != currentId;
                    }).take(5).toList();
                    
                    if (products.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        final productDataCard = ProductService.mapToProductCard(product);
                        return Padding(
                          padding: EdgeInsets.only(
                              left: defaultPadding,
                              right: index == products.length - 1 ? defaultPadding : 0),
                          child: ProductCard(
                            image: productDataCard['image'] as String,
                            brandName: productDataCard['brandName'] as String,
                            title: productDataCard['title'] as String,
                            price: productDataCard['price'] as double,
                            priceAfetDiscount: productDataCard['priceAfetDiscount'] as double?,
                            dicountpercent: productDataCard['dicountpercent'] as int?,
                            press: () {
                              Navigator.pushNamed(
                                context,
                                productDetailsScreenRoute,
                                arguments: product,
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: defaultPadding),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildShippingInfo(
    BuildContext context,
    String title,
    String duration,
    String cost,
    String method,
  ) {
    return Container(
      padding: const EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(defaultBorderRadious),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                cost,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: defaultPadding / 4),
          Text(
            "Durasi: $duration",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: defaultPadding / 4),
          Text(
            method,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}
