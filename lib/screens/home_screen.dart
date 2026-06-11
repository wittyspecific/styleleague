import 'package:flutter/material.dart';
import '../widgets/app_header.dart';
import '../widgets/outfit_post_card.dart';
import '../widgets/section_title.dart';
import '../widgets/tab_text.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: const [
        AppHeader(),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 22),
          child: _HomeTabs(),
        ),
        SizedBox(height: 18),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 22),
          child: SectionTitle(
            title: 'Outfit des Tages',
            trailing: '07:45:32',
          ),
        ),
        SizedBox(height: 10),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 22),
          child: OutfitPostCard(
            name: 'Lina.bln',
            category: 'Streetwear',
            likes: '342',
            height: 330,
          ),
        ),
        SizedBox(height: 16),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 22),
          child: OutfitPostCard(
            name: 'max.fit',
            category: 'Casual',
            likes: '287',
            height: 220,
          ),
        ),
        SizedBox(height: 30),
      ],
    );
  }
}

class _HomeTabs extends StatelessWidget {
  const _HomeTabs();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        TabText(label: 'Für dich', active: true),
        SizedBox(width: 30),
        TabText(label: 'Folge ich', active: false),
      ],
    );
  }
}