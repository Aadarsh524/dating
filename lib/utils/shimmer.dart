import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerSkeleton extends StatelessWidget {
  final int count;
  final double height;

  const ShimmerSkeleton({super.key, required this.count, required this.height});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int a = 1; a <= count; a++)
          Shimmer.fromColors(
            baseColor: Colors.grey.shade200,
            highlightColor: Colors.grey.shade100,
            child: Container(
              margin:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              width: double.infinity,
              height: height,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          )
      ],
    );
  }
}
