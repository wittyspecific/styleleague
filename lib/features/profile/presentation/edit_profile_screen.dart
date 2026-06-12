import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../data/user_repository.dart';
import '../models/app_user.dart';

class EditProfileScreen extends StatefulWidget {
  final AppUser user;

  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final UserRepository _userRepository = UserRepository();

  late final TextEditingController _displayNameController;
  late final TextEditingController _bioController;
  late final TextEditingController _locationController;

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    _displayNameController = TextEditingController(
      text: widget.user.displayName,
    );

    _bioController = TextEditingController(text: widget.user.bio);

    _locationController = TextEditingController(text: widget.user.location);
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _bioController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final displayName = _displayNameController.text.trim();
    final bio = _bioController.text.trim();
    final location = _locationController.text.trim();

    if (displayName.isEmpty) {
      setState(() {
        _errorMessage = 'Der Profilname darf nicht leer sein.';
      });
      return;
    }

    if (displayName.length > 30) {
      setState(() {
        _errorMessage = 'Der Profilname darf maximal 30 Zeichen enthalten.';
      });
      return;
    }

    if (bio.length > 150) {
      setState(() {
        _errorMessage = 'Die Bio darf maximal 150 Zeichen enthalten.';
      });
      return;
    }

    if (location.length > 40) {
      setState(() {
        _errorMessage = 'Der Ort darf maximal 40 Zeichen enthalten.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _userRepository.updateCurrentUserProfile(
        displayName: displayName,
        bio: bio,
        location: location,
      );

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Profil konnte nicht gespeichert werden: $error';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil bearbeiten')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: ListView(
            padding: const EdgeInsets.all(22),
            children: [
              Center(
                child: CircleAvatar(
                  radius: 48,
                  backgroundColor: AppColors.black,
                  backgroundImage: widget.user.profileImageUrl != null
                      ? NetworkImage(widget.user.profileImageUrl!)
                      : null,
                  child: widget.user.profileImageUrl == null
                      ? const Icon(Icons.person, color: Colors.white, size: 48)
                      : null,
                ),
              ),

              const SizedBox(height: 10),

              const Center(
                child: Text(
                  'Profilbild wird später ergänzt',
                  style: TextStyle(color: AppColors.muted, fontSize: 13),
                ),
              ),

              const SizedBox(height: 28),

              TextField(
                controller: _displayNameController,
                enabled: !_isLoading,
                maxLength: 30,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Profilname',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 12),

              TextField(
                controller: _bioController,
                enabled: !_isLoading,
                maxLength: 150,
                minLines: 3,
                maxLines: 5,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Bio',
                  hintText: 'Beschreibe deinen Style kurz.',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 12),

              TextField(
                controller: _locationController,
                enabled: !_isLoading,
                maxLength: 40,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) {
                  if (!_isLoading) {
                    _saveProfile();
                  }
                },
                decoration: const InputDecoration(
                  labelText: 'Ort',
                  hintText: 'z. B. Berlin',
                  border: OutlineInputBorder(),
                ),
              ),

              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4, bottom: 12),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

              const SizedBox(height: 12),

              SizedBox(
                height: 50,
                child: FilledButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  child: _isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Änderungen speichern'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
