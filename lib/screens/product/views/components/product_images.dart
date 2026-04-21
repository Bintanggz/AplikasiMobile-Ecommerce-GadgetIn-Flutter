import 'package:flutter/material.dart';
import '/components/network_image_with_loader.dart';

import '../../../../constants.dart';

class ProductImages extends StatefulWidget {
  const ProductImages({
    super.key,
    required this.images,
  });

  final List<String> images;

  @override
  State<ProductImages> createState() => _ProductImagesState();
}

class _ProductImagesState extends State<ProductImages> {
  late PageController _controller;

  int _currentPage = 0;

  @override
  void initState() {
    _controller =
        PageController(viewportFraction: 0.9, initialPage: _currentPage);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: AspectRatio(
        aspectRatio: 1,
        child: Stack(
          children: [
            PageView.builder(
              controller: _controller,
              onPageChanged: (pageNum) {
                setState(() {
                  _currentPage = pageNum;
                });
              },
              itemCount: widget.images.length,
              itemBuilder: (context, index) {
                final imageUrl = widget.images[index].toString().trim();
                
                // Validasi URL yang lebih fleksibel untuk Firebase Storage
                final isValidUrl = imageUrl.isNotEmpty && 
                    imageUrl != 'null' && 
                    imageUrl != '[]' &&
                    imageUrl != '{}' &&
                    imageUrl.toLowerCase() != 'undefined' &&
                    (imageUrl.startsWith('http://') || 
                     imageUrl.startsWith('https://') || 
                     imageUrl.startsWith('assets/') ||
                     imageUrl.startsWith('/') ||
                     // Support Firebase Storage URLs dan URL dengan extension
                     (imageUrl.contains('.') && (imageUrl.contains('/') || 
                                                  imageUrl.endsWith('.jpg') || 
                                                  imageUrl.endsWith('.png') || 
                                                  imageUrl.endsWith('.jpeg') || 
                                                  imageUrl.endsWith('.webp'))));
                
                if (!isValidUrl) {
                  print('⚠️ ProductImages: Invalid image URL at index $index: $imageUrl');
                  return Padding(
                    padding: const EdgeInsets.only(right: defaultPadding),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.all(
                        Radius.circular(defaultBorderRadious * 2),
                      ),
                      child: Container(
                        color: Colors.grey.shade100,
                        child: const Center(
                          child: Icon(Icons.image_not_supported, size: 64, color: Colors.grey),
                        ),
                      ),
                    ),
                  );
                }
                
                print('✅ ProductImages: Displaying image $index: $imageUrl');
                return Padding(
                  padding: const EdgeInsets.only(right: defaultPadding),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(
                      Radius.circular(defaultBorderRadious * 2),
                    ),
                    child: NetworkImageWithLoader(
                      imageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
            if (widget.images.length > 1)
              Positioned(
                height: 20,
                bottom: 24,
                right: MediaQuery.of(context).size.width * 0.15,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: defaultPadding * 0.75,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: const BorderRadius.all(Radius.circular(50)),
                  ),
                  child: Row(
                    children: List.generate(
                      widget.images.length,
                      (index) => Padding(
                        padding: EdgeInsets.only(
                            right: index == (widget.images.length - 1)
                                ? 0
                                : defaultPadding / 4),
                        child: CircleAvatar(
                          radius: 3,
                          backgroundColor: Theme.of(context)
                              .textTheme
                              .bodyLarge!
                              .color!
                              .withOpacity(index == _currentPage ? 1 : 0.2),
                        ),
                      ),
                    ),
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }
}
