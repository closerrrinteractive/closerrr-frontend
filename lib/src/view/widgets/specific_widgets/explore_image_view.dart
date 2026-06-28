import 'package:cached_network_image/cached_network_image.dart';
import 'package:closerrr/core/themes/colors.dart';
import 'package:closerrr/core/utils/api_string.dart';
import 'package:flutter/material.dart';

import '../../../models/showcase/get_showcase.dart';

class ExploreImageView extends StatelessWidget {
  final bool isActive;
  final ShowcaseData showcaseData;
  final double? width;
  final double? height;
  const ExploreImageView(
      {super.key,
      required this.isActive,
      required this.showcaseData,
      this.width,
      this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      margin: EdgeInsets.symmetric(
        vertical: isActive ? 8 : 36,
        horizontal: isActive ? 8 : 12,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: CachedNetworkImage(
          imageUrl: '${ApiStrings.imageUrl}${showcaseData.path}',
          fit: BoxFit.cover,
          errorWidget: (context, url, error) => Container(
            color: backScreenColor,
            child: const Center(
              child: Text('Image Not Found'),
            ),
          ),
          placeholder: (context, url) => const Center(
            child: CircularProgressIndicator(
              color: primaryColor,
              strokeWidth: 1,
            ),
          ),
        ),
      ),
    );
  }
}
