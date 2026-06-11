import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/outfit_image.dart';

class AddOutfitScreen extends StatelessWidget {
  const AddOutfitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 12, 22, 30),
      children: [
        Row(
          children: const [
            Text(
              'Abbrechen',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            Spacer(),
            Text(
              'Neues Outfit',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            Spacer(),
            Text(
              'Posten',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ],
        ),
        const SizedBox(height: 24),

        Stack(
          children: [
            const OutfitImage(height: 360, label: 'Preview'),
            Positioned(
              right: 16,
              top: 16,
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.88),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close_rounded, size: 22),
              ),
            ),
          ],
        ),

        const SizedBox(height: 22),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: const [
              _UploadAction(
                icon: Icons.photo_library_rounded,
                title: 'Bild aus Galerie auswählen',
                subtitle: 'Ein vorhandenes Outfit-Foto hochladen',
              ),
              SizedBox(height: 14),
              Divider(color: AppColors.border),
              SizedBox(height: 14),
              _UploadAction(
                icon: Icons.photo_camera_rounded,
                title: 'Foto aufnehmen',
                subtitle: 'Direkt ein neues Outfit fotografieren',
              ),
            ],
          ),
        ),

        const SizedBox(height: 26),

        const Text(
          'Beschreibung',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),

        Container(
          minHeight: 92,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          child: const Text(
            'Beschreibe dein Outfit...',
            style: TextStyle(
              color: AppColors.muted,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        const SizedBox(height: 24),

        const Text(
          'Kategorie',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),

        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: const [
            _CategoryChip(label: 'Streetwear', active: true),
            _CategoryChip(label: 'Casual'),
            _CategoryChip(label: 'Business'),
            _CategoryChip(label: 'Elegant'),
            _CategoryChip(label: 'Sportlich'),
          ],
        ),
      ],
    );
  }
}

class _UploadAction extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _UploadAction({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: AppColors.softCard,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: AppColors.black),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppColors.muted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        const Icon(Icons.chevron_right_rounded),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool active;

  const _CategoryChip({
    required this.label,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: active ? AppColors.black : AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: active ? AppColors.black : AppColors.border,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: active ? Colors.white : AppColors.black,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}