import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'outfit_image.dart';

class OutfitPostCard extends StatelessWidget {
  final String name;
  final String category;
  final String likes;
  final double height;

  const OutfitPostCard({
    super.key,
    required this.name,
    required this.category,
    required this.likes,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.border),
      ),
      child: Stack(
        children: [
          OutfitImage(height: height, label: ''),
          Positioned(
            left: 14,
            bottom: 14,
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.black,
                  child: Icon(Icons.person, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      category,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            right: 16,
            bottom: 20,
            child: Row(
              children: [
                const Icon(Icons.favorite_border_rounded, color: Colors.white),
                const SizedBox(width: 4),
                Text(
                  likes,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}