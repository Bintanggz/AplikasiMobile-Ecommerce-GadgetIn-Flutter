// Data produk gadget
import 'package:shop/constants.dart';

class ProductModel {
  final String image, brandName, title;
  final double price;
  final double? priceAfetDiscount;
  final int? dicountpercent;

  ProductModel({
    required this.image,
    required this.brandName,
    required this.title,
    required this.price,
    this.priceAfetDiscount,
    this.dicountpercent,
  });
}

// Produk Populer - Gadget
List<ProductModel> demoPopularProducts = [
  ProductModel(
    image: "https://images.unsplash.com/photo-1696446701796-da61225697cc?auto=format&fit=crop&w=800&q=80",
    title: "iPhone 15 Pro Max",
    brandName: "Apple",
    price: 24999000,
    priceAfetDiscount: 23999000,
    dicountpercent: 4,
  ),
  ProductModel(
    image: "https://images.unsplash.com/photo-1706606991536-e3250b73c4e3?auto=format&fit=crop&w=800&q=80",
    title: "Samsung Galaxy S24 Ultra",
    brandName: "Samsung",
    price: 21999000,
    priceAfetDiscount: 19999000,
    dicountpercent: 9,
  ),
  ProductModel(
    image: "https://images.unsplash.com/photo-1611186871348-b1ce696e52c9?auto=format&fit=crop&w=800&q=80",
    title: "MacBook Air M3",
    brandName: "Apple",
    price: 18999000,
    priceAfetDiscount: 17499000,
    dicountpercent: 8,
  ),
  ProductModel(
    image: "https://images.unsplash.com/photo-1593642702821-c8da6771f0c6?auto=format&fit=crop&w=800&q=80",
    title: "Dell XPS 15",
    brandName: "Dell",
    price: 28999000,
  ),
];

// Flash Sale - Gadget
List<ProductModel> demoFlashSaleProducts = [
  ProductModel(
    image: "https://images.unsplash.com/photo-1579586337278-3befd40fd17a?auto=format&fit=crop&w=800&q=80",
    title: "Apple Watch Series 9",
    brandName: "Apple",
    price: 6499000,
    priceAfetDiscount: 5999000,
    dicountpercent: 8,
  ),
  ProductModel(
    image: "https://images.unsplash.com/photo-1505740420928-5e560c06d30e?auto=format&fit=crop&w=800&q=80",
    title: "Sony WH-1000XM5",
    brandName: "Sony",
    price: 5999000,
    priceAfetDiscount: 4999000,
    dicountpercent: 17,
  ),
  ProductModel(
    image: "https://images.unsplash.com/photo-1588872657578-1841127b6d75?auto=format&fit=crop&w=800&q=80",
    title: "AirPods Pro 2",
    brandName: "Apple",
    price: 3999000,
    priceAfetDiscount: 3499000,
    dicountpercent: 12,
  ),
];

// Best Sellers - Gadget
List<ProductModel> demoBestSellersProducts = [
  ProductModel(
    image: "https://images.unsplash.com/photo-1603302576837-37561b2e2302?auto=format&fit=crop&w=800&q=80",
    title: "Asus ROG Zephyrus G14",
    brandName: "Asus",
    price: 26999000,
    priceAfetDiscount: 24999000,
    dicountpercent: 7,
  ),
  ProductModel(
    image: "https://images.unsplash.com/photo-1610945415295-d9bbf067e59c?auto=format&fit=crop&w=800&q=80",
    title: "Samsung Galaxy Tab S9",
    brandName: "Samsung",
    price: 12999000,
  ),
  ProductModel(
    image: "https://images.unsplash.com/photo-1593121925328-369cc8459c08?auto=format&fit=crop&w=800&q=80",
    title: "Google Pixel 8 Pro",
    brandName: "Google",
    price: 15999000,
    priceAfetDiscount: 14999000,
    dicountpercent: 6,
  ),
];

// Produk Lainnya / Kids (Reused as Accessories)
List<ProductModel> kidsProducts = [
  ProductModel(
    image: "https://images.unsplash.com/photo-1629131726692-1accd0c53ce0?auto=format&fit=crop&w=800&q=80",
    title: "Mechanical Keyboard Keychron K2",
    brandName: "Keychron",
    price: 1899000,
  ),
  ProductModel(
    image: "https://images.unsplash.com/photo-1572569028738-411a54c1b30f?auto=format&fit=crop&w=800&q=80",
    title: "Powerbank Anker 20000mAh",
    brandName: "Anker",
    price: 999000,
    priceAfetDiscount: 799000,
    dicountpercent: 20,
  ),
   ProductModel(
    image: "https://images.unsplash.com/photo-1600003014755-ba31aa59c4b6?auto=format&fit=crop&w=800&q=80",
    title: "Logitech MX Master 3S",
    brandName: "Logitech",
    price: 1699000,
  ),
];
