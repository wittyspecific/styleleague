import 'package:flutter/material.dart';

class OutfitImage extends StatelessWidget {
  final double height;
  final String label;
  final IconData icon;

  const OutfitImage({
    super.key,
    required this.height,
    required this.label,
    this.icon = Icons.person_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFD8D0C6),
            Color(0xFF9F978F),
          ],
        ),
      ),
      child: Stack(
        children: [
          Center(
            child: Icon(
              icon,
              size: height * 0.35,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          if (label.isNotEmpty)
            Positioned(
              left: 14,
              bottom: 14,
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }
}