import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerSkeleton extends StatelessWidget {
  final int count;
  final double height;

  const ShimmerSkeleton({super.key, required this.count, required this.height});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth; // Get the available width

        return Column(
          children: [
            for (int a = 1; a <= count; a++)
              Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade200,
                child: Container(
                  margin: const EdgeInsets.symmetric(
                      vertical: 4.0, horizontal: 8.0),
                  width: screenWidth *
                      0.9, // Use 90% of the screen width for responsive width
                  height: height,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
            const SizedBox(
              height: 40,
            ),
          ],
        );
      },
    );
  }
}
