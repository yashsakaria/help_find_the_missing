import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'constants.dart';

class BuildImage extends StatelessWidget {
  final String imageURL;
  final double height;
  final double width;
  const BuildImage(
      {required this.imageURL, this.height = 100, this.width = 100});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: kDefaultBorderRadius,
      child: CachedNetworkImage(
        imageUrl: imageURL,
        height: height,
        width: width,
        fit: BoxFit.cover,
        placeholder: (context, url) {
          return Container(
            color: Colors.black12,
          );
        },
        errorWidget: (context, url, error) {
          return Container(
            color: Colors.black12,
            child: const Icon(
              Icons.error,
              color: Colors.red,
            ),
          );
        },
      ),
    );
  }
}
