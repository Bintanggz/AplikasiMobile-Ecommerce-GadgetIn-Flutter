import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../constants.dart';
import 'skleton/skelton.dart';

class NetworkImageWithLoader extends StatelessWidget {
  final BoxFit fit;
  final double? width;
  final double? height;

  const NetworkImageWithLoader(
    this.src, {
    super.key,
    this.fit = BoxFit.cover,
    this.radius = defaultPadding,
    this.width,
    this.height,
  });

  final String src;
  final double radius;

  @override
  Widget build(BuildContext context) {
    // Validasi URL - lebih fleksibel untuk Firebase Storage URLs
    final cleanSrc = src.trim();
    
    final isValidUrl = cleanSrc.isNotEmpty && 
        cleanSrc != 'null' && 
        cleanSrc != '[]' &&
        cleanSrc != '{}' &&
        (cleanSrc.startsWith('http://') || 
         cleanSrc.startsWith('https://') || 
         cleanSrc.startsWith('assets/') ||
         cleanSrc.startsWith('/') ||
         // Support Firebase Storage URLs yang mungkin tidak langsung http/https
         (cleanSrc.contains('.') && (cleanSrc.contains('/') || 
                                     cleanSrc.endsWith('.jpg') || 
                                     cleanSrc.endsWith('.png') || 
                                     cleanSrc.endsWith('.jpeg') || 
                                     cleanSrc.endsWith('.webp'))));

    // Jika URL tidak valid, tampilkan placeholder
    if (!isValidUrl) {
      print('⚠️ NetworkImageWithLoader: Invalid URL: $cleanSrc');
      return ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(radius)),
        child: SizedBox(
          width: width,
          height: height,
          child: Container(
            color: Colors.grey.shade200,
            child: Icon(
              Icons.image_not_supported,
              size: (width != null && height != null) 
                  ? (width! < height! ? width! * 0.3 : height! * 0.3)
                  : 48,
              color: Colors.grey.shade400,
            ),
          ),
        ),
      );
    }
    
    // Normalize URL: jika URL tidak punya scheme tapi terlihat seperti URL, tambahkan https://
    String finalUrl = cleanSrc;
    if (!finalUrl.startsWith('http://') && 
        !finalUrl.startsWith('https://') && 
        !finalUrl.startsWith('assets/') &&
        !finalUrl.startsWith('/') &&
        finalUrl.contains('.')) {
      // Coba normalisasi ke https jika terlihat seperti URL
      if (finalUrl.contains('firebasestorage') || 
          finalUrl.contains('firebase') ||
          finalUrl.contains('googleapis.com')) {
        finalUrl = 'https://$finalUrl';
        print('🔧 Normalized URL: $finalUrl');
      }
    }

    // Handle asset images
    if (finalUrl.startsWith('assets/')) {
      return ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(radius)),
        child: SizedBox(
          width: width,
          height: height,
          child: Image.asset(
            finalUrl,
            fit: fit,
            errorBuilder: (context, error, stackTrace) => Container(
              color: Colors.grey.shade200,
              child: Icon(
                Icons.broken_image,
                size: (width != null && height != null) 
                    ? (width! < height! ? width! * 0.3 : height! * 0.3)
                    : 48,
                color: Colors.grey.shade400,
              ),
            ),
          ),
        ),
      );
    }

    // Handle network images (http/https)
    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(radius)),
      child: SizedBox(
        width: width,
        height: height,
        child: CachedNetworkImage(
          fit: fit,
          imageUrl: finalUrl,
          httpHeaders: const {
            'Accept': 'image/*',
          },
          imageBuilder: (context, imageProvider) => Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: imageProvider,
                fit: fit,
              ),
            ),
          ),
          placeholder: (context, url) => SizedBox(
            width: width,
            height: height,
            child: const Skeleton(),
          ),
          errorWidget: (context, url, error) {
            // Try fallback to demo image jika error
            if (url != productDemoImg1) {
              return CachedNetworkImage(
                imageUrl: productDemoImg1,
                fit: fit,
                errorWidget: (context, url, error) => SizedBox(
                  width: width,
                  height: height,
                  child: Container(
                    color: Colors.grey.shade200,
                    child: Icon(
                      Icons.broken_image,
                      size: (width != null && height != null) 
                          ? (width! < height! ? width! * 0.3 : height! * 0.3)
                          : 48,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ),
              );
            }
            return SizedBox(
              width: width,
              height: height,
              child: Container(
                color: Colors.grey.shade200,
                child: Icon(
                  Icons.broken_image,
                  size: (width != null && height != null) 
                      ? (width! < height! ? width! * 0.3 : height! * 0.3)
                      : 48,
                  color: Colors.grey.shade400,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
