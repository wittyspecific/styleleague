import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../widgets/app_header.dart';
import '../data/outfit_repository.dart';
import '../models/outfit.dart';
import 'outfit_card.dart';

class HomeFeedScreen extends StatelessWidget {
  HomeFeedScreen({super.key});

  final OutfitRepository _outfitRepository = OutfitRepository();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Outfit>>(
      stream: _outfitRepository.watchLatestOutfits(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Column(
            children: [
              AppHeader(showBack: false),
              Expanded(child: Center(child: CircularProgressIndicator())),
            ],
          );
        }

        if (snapshot.hasError) {
          return const Column(
            children: [
              AppHeader(showBack: false),
              Expanded(
                child: Center(child: Text('Feed konnte nicht geladen werden.')),
              ),
            ],
          );
        }

        final outfits = snapshot.data ?? [];

        return RefreshIndicator(
          onRefresh: () async {},
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const AppHeader(showBack: false),
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 8, 22, 12),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Latest Fits',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.softCard,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '${outfits.length} Posts',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (outfits.isEmpty)
                const _EmptyFeed()
              else
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Column(
                    children: outfits.map((outfit) {
                      return OutfitCard(outfit: outfit);
                    }).toList(),
                  ),
                ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}

class _EmptyFeed extends StatelessWidget {
  const _EmptyFeed();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 80, 22, 0),
      child: Column(
        children: [
          Container(
            height: 110,
            width: 110,
            decoration: BoxDecoration(
              color: AppColors.softCard,
              borderRadius: BorderRadius.circular(32),
            ),
            child: const Icon(
              Icons.checkroom_rounded,
              size: 54,
              color: AppColors.muted,
            ),
          ),
          const SizedBox(height: 22),
          const Text(
            'Noch keine Outfits vorhanden',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          const Text(
            'Sobald ein Outfit gepostet wurde, erscheint es hier im Feed.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.muted, height: 1.4),
          ),
        ],
      ),
    );
  }
}
