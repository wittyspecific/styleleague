import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/app_header.dart';
import '../widgets/outfit_image.dart';

class MatchScreen extends StatelessWidget {
  const MatchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        const AppHeader(showBell: false),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Row(
            children: [
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
                decoration: BoxDecoration(
                  color: AppColors.softCard,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Text(
                  '3/3',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const Center(
          child: Text(
            'Welches Outfit\ngefällt dir besser?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 26,
              height: 1.08,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: 26),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Row(
            children: const [
              Expanded(
                child: _MatchCard(label: 'A', name: 'alex.style'),
              ),
              SizedBox(width: 14),
              Expanded(
                child: _MatchCard(label: 'B', name: 'jona.outfits'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 36),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 42),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              _VoteButton(label: 'A'),
              Text('oder', style: TextStyle(color: AppColors.muted)),
              _VoteButton(label: 'B'),
            ],
          ),
        ),
        const SizedBox(height: 22),
        const Center(
          child: Text(
            'Übrige Votes heute: 0',
            style: TextStyle(
              color: AppColors.muted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _MatchCard extends StatelessWidget {
  final String label;
  final String name;

  const _MatchCard({
    required this.label,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        OutfitImage(height: 300, label: name),
        Positioned(
          left: 10,
          top: 10,
          child: CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.card,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.black,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _VoteButton extends StatelessWidget {
  final String label;

  const _VoteButton({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: AppColors.card,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.black, width: 1.4),
      ),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 31,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}