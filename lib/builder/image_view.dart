import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class ImageViewBuilder extends StatelessWidget {
  const ImageViewBuilder({
    required this.url,
    required this.title,
    super.key,
  });

  final String url;
  final String title;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () {
          Navigator.of(context).pop();
        },
        child: PhotoView(
          imageProvider: NetworkImage(url),
        ),
      );
}
