import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/app_header.dart';
import '../widgets/tab_text.dart';

class RankingScreen extends StatelessWidget {
  const RankingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final users = [
      ['1', 'alex.style', '6.240'],
      ['2', 'Lina.bln', '4.852'],
      ['3', 'jana.outfits', '4.210'],
      ['4', 'tim.muc', '3.870'],
      ['5', 'fit.luca', '3.520'],
      ['6', 'sophie.wear', '3.120'],
      ['7', 'nic.fashion', '2.980'],
      ['8', 'emma.style', '2.450'],
    ];

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        const AppHeader(showBell: false),
        const Center(
          child: Text(
            'Rankings',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(height: 18),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              TabText(label: 'Global', active: true),
              TabText(label: 'Deutschland', active: false),
              TabText(label: 'Folge ich', active: false),
            ],
          ),
        ),
        const SizedBox(height: 30),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: const [
              Expanded(
                child: _PodiumUser(
                  place: '2',
                  name: 'Lina.bln',
                  score: '4.852',
                ),
              ),
              Expanded(
                child: _PodiumUser(
                  place: '1',
                  name: 'alex.style',
                  score: '6.240',
                  large: true,
                ),
              ),
              Expanded(
                child: _PodiumUser(
                  place: '3',
                  name: 'jana.outfits',
                  score: '4.210',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: users
                  .map(
                    (user) => _RankingRow(
                      place: user[0],
                      name: user[1],
                      score: user[2],
                      highlighted: user[0] == '1',
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.softCard,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Row(
              children: const [
                CircleAvatar(
                  backgroundColor: AppColors.black,
                  child: Text(
                    'Du',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                SizedBox(width: 14),
                Text(
                  'Du',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                Spacer(),
                Text(
                  '1.230',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PodiumUser extends StatelessWidget {
  final String place;
  final String name;
  final String score;
  final bool large;

  const _PodiumUser({
    required this.place,
    required this.name,
    required this.score,
    this.large = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (place == '1')
          const Icon(
            Icons.emoji_events_rounded,
            color: AppColors.gold,
            size: 32,
          ),
        CircleAvatar(
          radius: large ? 43 : 34,
          backgroundColor: place == '1' ? AppColors.gold : AppColors.beige,
          child: CircleAvatar(
            radius: large ? 38 : 30,
            backgroundColor: AppColors.black,
            child: const Icon(Icons.person, color: Colors.white),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          place,
          style: TextStyle(
            fontSize: large ? 31 : 22,
            color: place == '1' ? AppColors.gold : AppColors.black,
            fontWeight: FontWeight.w900,
          ),
        ),
        Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        Text(
          score,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.muted,
          ),
        ),
      ],
    );
  }
}

class _RankingRow extends StatelessWidget {
  final String place;
  final String name;
  final String score;
  final bool highlighted;

  const _RankingRow({
    required this.place,
    required this.name,
    required this.score,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 6),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.border.withOpacity(0.6),
          ),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              place,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          CircleAvatar(
            radius: 18,
            backgroundColor: highlighted ? AppColors.gold : AppColors.softCard,
            child: const Icon(
              Icons.person,
              size: 18,
              color: AppColors.black,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            name,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const Spacer(),
          Text(
            score,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}