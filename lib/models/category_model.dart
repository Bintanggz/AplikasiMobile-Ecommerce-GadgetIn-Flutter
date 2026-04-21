class CategoryModel {
  final String title;
  final String? image, svgSrc;
  final List<CategoryModel>? subCategories;

  CategoryModel({
    required this.title,
    this.image,
    this.svgSrc,
    this.subCategories,
  });
}

final List<CategoryModel> demoCategoriesWithImage = [
  CategoryModel(title: "Smartphone", image: "https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?auto=format&fit=crop&w=800&q=80"),
  CategoryModel(title: "Laptop", image: "https://images.unsplash.com/photo-1496181133206-80ce9b88a853?auto=format&fit=crop&w=800&q=80"),
  CategoryModel(title: "Tablet", image: "https://images.unsplash.com/photo-1544244015-0df4b3ffc6b0?auto=format&fit=crop&w=800&q=80"),
  CategoryModel(title: "Aksesoris", image: "https://images.unsplash.com/photo-1505740420928-5e560c06d30e?auto=format&fit=crop&w=800&q=80"),
];

final List<CategoryModel> demoCategories = [
  CategoryModel(
    title: "Diskon",
    svgSrc: "assets/icons/Sale.svg",
    subCategories: [
      CategoryModel(title: "Semua Produk"),
      CategoryModel(title: "Produk Baru"),
      CategoryModel(title: "Smartphone"),
      CategoryModel(title: "Laptop"),
      CategoryModel(title: "Tablet"),
    ],
  ),
  CategoryModel(
    title: "Smartphone & Tablet",
    svgSrc: "assets/icons/Man&Woman.svg",
    subCategories: [
      CategoryModel(title: "Semua Produk"),
      CategoryModel(title: "Produk Baru"),
      CategoryModel(title: "Smartphone"),
      CategoryModel(title: "Tablet"),
    ],
  ),
  CategoryModel(
    title: "Laptop & PC",
    svgSrc: "assets/icons/Child.svg",
    subCategories: [
      CategoryModel(title: "Semua Produk"),
      CategoryModel(title: "Produk Baru"),
      CategoryModel(title: "Laptop"),
      CategoryModel(title: "Desktop PC"),
    ],
  ),
  CategoryModel(
    title: "Aksesoris",
    svgSrc: "assets/icons/Accessories.svg",
    subCategories: [
      CategoryModel(title: "Semua Aksesoris"),
      CategoryModel(title: "Produk Baru"),
      CategoryModel(title: "Headphone"),
      CategoryModel(title: "Mouse & Keyboard"),
      CategoryModel(title: "Power Bank"),
    ],
  ),
];
