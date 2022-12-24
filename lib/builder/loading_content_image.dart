import 'package:flutter/material.dart';

class LoadingContentImageBuilder extends StatelessWidget {
  const LoadingContentImageBuilder({super.key, this.size = 50});

  final double size;

  @override
  Widget build(BuildContext context) => Center(
      child: Image.asset(
        'assets/images/loading.gif',
        width: size,
      ),
    );
}
