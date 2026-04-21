import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shop/components/cart_button.dart';
import 'package:shop/components/custom_modal_bottom_sheet.dart';
import 'package:shop/components/network_image_with_loader.dart';
import 'package:shop/screens/product/views/added_to_cart_message_screen.dart';
import 'package:shop/screens/product/views/components/product_list_tile.dart';
import 'package:shop/screens/product/views/location_permission_store_availability_screen.dart';
import 'package:shop/screens/product/views/size_guide_screen.dart';
import 'package:shop/services/cart_service.dart';

import '../../../constants.dart';
import 'components/product_quantity.dart';
import 'components/selected_colors.dart';
import 'components/selected_size.dart';
import 'components/unit_price.dart';

class ProductBuyNowScreen extends StatefulWidget {
  const ProductBuyNowScreen({super.key, this.productData});

  final Map<String, dynamic>? productData;

  @override
  _ProductBuyNowScreenState createState() => _ProductBuyNowScreenState();
}

class _ProductBuyNowScreenState extends State<ProductBuyNowScreen> {
  final CartService _cartService = CartService();
  int quantity = 1;
  bool _isSubmitting = false;

  Map<String, dynamic> _getProductInfo() {
    if (widget.productData == null) {
      return {
        'title': 'Product',
        'imageUrl': productDemoImg1,
        'price': 14500000.0,
        'priceAfterDiscount': 13470000.0,
      };
    }

    final data = widget.productData!;
    
    // Parse images - konsisten dengan product_details_screen
    List<String> imageList = [];
    
    // Cari image dari berbagai kemungkinan field name di Firebase
    final imageUrl = (data['imageUrl'] ?? 
                     data['image'] ?? 
                     data['imageURL'] ??
                     data['productImage'] ??
                     data['photo'] ??
                     data['img'] ??
                     '').toString().trim();
    
    // Cari images array dari berbagai kemungkinan field name
    final images = (data['images'] ?? 
                   data['imageList'] ?? 
                   data['productImages'] ??
                   data['photos'] ??
                   data['gallery'] ??
                   data['imageUrls']) as List<dynamic>?;
    
    // Helper function untuk validasi dan menambah image URL
    void addImageIfValid(String? imgUrl) {
      if (imgUrl == null || imgUrl.isEmpty) return;
      
      final cleanUrl = imgUrl.toString().trim();
      
      if (cleanUrl.isEmpty || 
          cleanUrl == 'null' || 
          cleanUrl == '[]' ||
          cleanUrl == '{}' ||
          cleanUrl.toLowerCase() == 'undefined') {
        return;
      }
      
      final isValidUrl = cleanUrl.startsWith('http://') || 
                        cleanUrl.startsWith('https://') || 
                        cleanUrl.startsWith('assets/') ||
                        cleanUrl.startsWith('/') ||
                        (cleanUrl.contains('.') && (cleanUrl.contains('/') || 
                                                    cleanUrl.endsWith('.jpg') || 
                                                    cleanUrl.endsWith('.png') || 
                                                    cleanUrl.endsWith('.jpeg') || 
                                                    cleanUrl.endsWith('.webp')));
      
      if (isValidUrl && !imageList.contains(cleanUrl)) {
        imageList.add(cleanUrl);
      }
    }
    
    // 1. Ambil dari images array jika ada
    if (images != null && images.isNotEmpty) {
      for (var img in images) {
        if (img != null) {
          if (img is Map) {
            final url = img['url'] ?? img['downloadURL'] ?? img['path'] ?? img['src'] ?? img.toString();
            addImageIfValid(url.toString());
          } else {
            addImageIfValid(img.toString());
          }
        }
      }
    }
    
    // 2. Tambahkan imageUrl jika valid
    if (imageUrl.isNotEmpty && imageUrl != 'null') {
      addImageIfValid(imageUrl);
    }
    
    // 3. Fallback jika masih kosong
    if (imageList.isEmpty) {
      imageList = [productDemoImg1];
    }
    
    // Remove duplicates
    imageList = imageList.toSet().toList();
    
    // Final imageUrl untuk ditampilkan
    final finalImageUrl = imageList.isNotEmpty ? imageList.first : productDemoImg1;
    final title = (data['title'] ?? data['name'] ?? 'Product').toString();
    final price = (data['price'] ?? 0).toDouble();
    final priceAfterDiscount = data['priceAfterDiscount'] != null
        ? (data['priceAfterDiscount'] as num).toDouble()
        : data['discountedPrice'] != null
            ? (data['discountedPrice'] as num).toDouble()
            : null;

    return {
      'title': title,
      'imageUrl': finalImageUrl,
      'images': imageList,
      'price': price,
      'priceAfterDiscount': priceAfterDiscount,
    };
  }

  Future<void> _handleAddToCart(double pricePerItem) async {
    if (widget.productData == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data produk tidak tersedia')),
        );
      }
      return;
    }

    final data = widget.productData!;
    final productId = (data['id'] ?? data['docId'] ?? '').toString();
    
    if (productId.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ID produk tidak valid')),
        );
      }
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      // Validasi data sebelum add to cart
      final name = (data['name'] ?? data['title'] ?? 'Produk').toString();
      final imageUrl = (data['imageUrl'] ??
              data['image'] ??
              (data['images'] is List && (data['images'] as List).isNotEmpty
                  ? (data['images'] as List).first.toString()
                  : productDemoImg1))
          .toString();

      if (name.isEmpty) {
        throw Exception('Nama produk tidak valid');
      }

      await _cartService.addToCart(
        productId: productId,
        name: name,
        price: pricePerItem.round(),
        imageUrl: imageUrl,
        quantity: quantity,
      );

      if (!mounted) return;
      Navigator.pop(context);
      customModalBottomSheet(
        context,
        isDismissible: true,
        child: const AddedToCartMessageScreen(),
      );
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Gagal menambah ke keranjang';
        if (e.toString().contains('User belum login')) {
          errorMessage = 'Silakan login terlebih dahulu';
        } else if (e.toString().isNotEmpty) {
          errorMessage = 'Gagal menambah ke keranjang: ${e.toString().replaceAll('Exception: ', '')}';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final info = _getProductInfo();
    final title = info['title'] as String;
    final imageUrl = info['imageUrl'] as String;
    final price = info['price'] as double;
    final priceAfterDiscount = info['priceAfterDiscount'] as double?;
    final displayPrice = priceAfterDiscount ?? price;
    final totalPrice = displayPrice * quantity;

    return Scaffold(
      bottomNavigationBar: CartButton(
        price: totalPrice,
        title: _isSubmitting ? "Memproses..." : "Tambah ke Keranjang",
        subTitle: "Total harga",
        press: () {
          if (_isSubmitting) return;
          _handleAddToCart(displayPrice);
        },
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: defaultPadding / 2, vertical: defaultPadding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const BackButton(),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: SvgPicture.asset("assets/icons/Bookmark.svg",
                      color: Theme.of(context).textTheme.bodyLarge!.color),
                ),
              ],
            ),
          ),
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
                    child: AspectRatio(
                      aspectRatio: 1.05,
                      child: NetworkImageWithLoader(imageUrl),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(defaultPadding),
                  sliver: SliverToBoxAdapter(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: UnitPrice(
                            price: price,
                            priceAfterDiscount: priceAfterDiscount,
                          ),
                        ),
                        ProductQuantity(
                          numOfItem: quantity,
                          onIncrement: () {
                            setState(() => quantity++);
                          },
                          onDecrement: () {
                            if (quantity > 1) {
                              setState(() => quantity--);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: Divider()),
                SliverToBoxAdapter(
                  child: SelectedColors(
                    colors: const [
                      Color(0xFFEA6262),
                      Color(0xFFB1CC63),
                      Color(0xFFFFBF5F),
                      Color(0xFF9FE1DD),
                      Color(0xFFC482DB),
                    ],
                    selectedColorIndex: 2,
                    press: (value) {},
                  ),
                ),
                SliverToBoxAdapter(
                  child: SelectedSize(
                    sizes: const ["128GB", "256GB", "512GB", "1TB"],
                    selectedIndex: 1,
                    press: (value) {},
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(vertical: defaultPadding),
                  sliver: ProductListTile(
                    title: "Panduan Ukuran",
                    svgSrc: "assets/icons/Sizeguid.svg",
                    isShowBottomBorder: true,
                    press: () {
                      customModalBottomSheet(
                        context,
                        height: MediaQuery.of(context).size.height * 0.9,
                        child: const SizeGuideScreen(),
                      );
                    },
                  ),
                ),
                SliverPadding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: defaultPadding),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: defaultPadding / 2),
                        Text(
                          "Ketersediaan pengambilan di toko",
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: defaultPadding / 2),
                        const Text(
                            "Pilih ukuran untuk memeriksa ketersediaan di toko dan opsi pengambilan di toko.")
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(vertical: defaultPadding),
                  sliver: ProductListTile(
                    title: "Cek Toko",
                    svgSrc: "assets/icons/Stores.svg",
                    isShowBottomBorder: true,
                    press: () {
                      customModalBottomSheet(
                        context,
                        height: MediaQuery.of(context).size.height * 0.92,
                        child: const LocationPermissonStoreAvailabilityScreen(),
                      );
                    },
                  ),
                ),
                const SliverToBoxAdapter(
                    child: SizedBox(height: defaultPadding))
              ],
            ),
          )
        ],
      ),
    );
  }
}
