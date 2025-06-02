import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:holdem/gen/assets.gen.dart';

class CommonImage {
  static Widget net({
    required String imageUrl,
    double? width,
    double? height,
    BoxFit? fit,
    double radius = 0,
  }) =>
      ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          fit: fit ?? BoxFit.cover,
          width: width,
          height: height,
          placeholder: (context, url) => Assets.images.imageLoadingDef.image(
            fit: BoxFit.fill,
          ),
          errorWidget: (context, url, error) => Assets.images.imageLoadingDef.image(
            fit: BoxFit.fill,
          ),
        ),
      );
}
