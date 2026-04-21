import 'package:flutter/material.dart';
import 'package:shop/models/category_model.dart' as gadget_category;
import 'package:shop/route/screen_export.dart';
import 'package:shop/components/network_image_with_loader.dart';

import '../../../../constants.dart';

class Categories extends StatelessWidget {
  const Categories({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final categories = gadget_category.demoCategoriesWithImage;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(
          categories.length,
          (index) {
            final category = categories[index];
            return Padding(
              padding: EdgeInsets.only(
                left: index == 0 ? defaultPadding : defaultPadding / 2,
                right: index == categories.length - 1 ? defaultPadding : 0,
              ),
              child: _CategoryCard(
                title: category.title,
                image: category.image,
                press: () {
                  // Arahkan ke halaman produk dengan filter kategori
                  Navigator.pushNamed(
                    context,
                    onSaleScreenRoute,
                    arguments: category.title,
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.title,
    this.image,
    required this.press,
  });

  final String title;
  final String? image;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: press,
      borderRadius: const BorderRadius.all(Radius.circular(16)),
      child: Container(
        width: 120,
        height: 140,
        padding: const EdgeInsets.all(defaultPadding / 2),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.all(Radius.circular(16)),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(12)),
                child: image != null && image!.isNotEmpty
                    ? NetworkImageWithLoader(
                        image!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        radius: 0,
                      )
                    : Container(
                        color: lightGreyColor,
                        child: const Icon(Icons.devices_other),
                      ),
              ),
            ),
            const SizedBox(height: defaultPadding / 2),
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
