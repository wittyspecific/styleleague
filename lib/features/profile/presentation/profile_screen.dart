import 'package:flutter/material.dart';

import '../../../core/services/auth_service.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/app_header.dart';
import '../../../widgets/outfit_image.dart';
import '../data/user_repository.dart';
import '../models/app_user.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});

  final UserRepository _userRepository = UserRepository();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AppUser?>(
      stream: _userRepository.watchCurrentUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(
            child: Text('Profil konnte nicht geladen werden.'),
          );
        }

        final user = snapshot.data;

        if (user == null) {
          return const Center(child: Text('Kein Profil gefunden.'));
        }

        return _ProfileContent(user: user);
      },
    );
  }
}

class _ProfileContent extends StatelessWidget {
  final AppUser user;

  const _ProfileContent({required this.user});

  @override
  Widget build(BuildContext context) {
    final displayName = user.displayName.trim().isNotEmpty
        ? user.displayName
        : user.username;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        const AppHeader(showBack: true),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 44,
                    backgroundColor: AppColors.black,
                    backgroundImage:
                        user.profileImageUrl != null &&
                            user.profileImageUrl!.trim().isNotEmpty
                        ? NetworkImage(user.profileImageUrl!)
                        : null,
                    child:
                        user.profileImageUrl == null ||
                            user.profileImageUrl!.trim().isEmpty
                        ? const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 44,
                          )
                        : null,
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '@${user.username}',
                          style: const TextStyle(color: AppColors.muted),
                        ),
                        if (user.location.trim().isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            user.location,
                            style: const TextStyle(color: AppColors.muted),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),

              if (user.bio.trim().isNotEmpty) ...[
                const SizedBox(height: 18),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    user.bio,
                    style: const TextStyle(fontSize: 14, height: 1.4),
                  ),
                ),
              ],

              const SizedBox(height: 26),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _ProfileStat(
                    value: user.outfitCount.toString(),
                    label: 'Outfits',
                  ),
                  _ProfileStat(
                    value: _formatNumber(user.followerCount),
                    label: 'Follower',
                  ),
                  _ProfileStat(
                    value: _formatNumber(user.followingCount),
                    label: 'Gefolgt',
                  ),
                ],
              ),

              const SizedBox(height: 26),

              Row(
                children: [
                  const Text(
                    'Style Score',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const Spacer(),
                  Text(
                    _formatNumber(user.points),
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ],
              ),

              const SizedBox(height: 9),

              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: LinearProgressIndicator(
                  value: _calculateLevelProgress(user.points),
                  minHeight: 8,
                  backgroundColor: AppColors.softCard,
                  valueColor: const AlwaysStoppedAnimation(AppColors.beige),
                ),
              ),

              const SizedBox(height: 8),

              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Level ${user.level}',
                  style: const TextStyle(color: AppColors.muted, fontSize: 12),
                ),
              ),

              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: _ProfileButton(
                      label: 'Profil bearbeiten',
                      filled: true,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => EditProfileScreen(user: user),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ProfileButton(
                      label: 'Logout',
                      filled: false,
                      onTap: () async {
                        await AuthService().logout();
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 26),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: const [
                  Icon(Icons.grid_view_rounded),
                  Icon(Icons.bookmark_border_rounded, color: AppColors.muted),
                  Icon(Icons.ios_share_rounded, color: AppColors.muted),
                ],
              ),

              const SizedBox(height: 18),

              GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                physics: const NeverScrollableScrollPhysics(),
                children: const [
                  OutfitImage(height: 120, label: ''),
                  OutfitImage(height: 120, label: ''),
                  OutfitImage(height: 120, label: ''),
                  OutfitImage(height: 120, label: ''),
                  OutfitImage(height: 120, label: ''),
                  OutfitImage(height: 120, label: ''),
                ],
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ],
    );
  }

  String _formatNumber(int value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    }

    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }

    return value.toString();
  }

  double _calculateLevelProgress(int points) {
    const nextLevelPoints = 10000;

    if (points <= 0) {
      return 0;
    }

    if (points >= nextLevelPoints) {
      return 1;
    }

    return points / nextLevelPoints;
  }
}

class _ProfileStat extends StatelessWidget {
  final String value;
  final String label;

  const _ProfileStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: AppColors.muted)),
      ],
    );
  }
}

class _ProfileButton extends StatelessWidget {
  final String label;
  final bool filled;
  final VoidCallback onTap;

  const _ProfileButton({
    required this.label,
    required this.filled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: filled ? AppColors.black : AppColors.softCard,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: filled ? Colors.white : AppColors.black,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}
