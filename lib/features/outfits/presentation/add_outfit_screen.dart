import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../widgets/app_header.dart';
import '../data/outfit_repository.dart';

class AddOutfitScreen extends StatefulWidget {
  const AddOutfitScreen({super.key});

  @override
  State<AddOutfitScreen> createState() => _AddOutfitScreenState();
}

class _AddOutfitScreenState extends State<AddOutfitScreen> {
  final OutfitRepository _outfitRepository = OutfitRepository();
  final TextEditingController _captionController = TextEditingController();

  final List<String> _categories = const [
    'Streetwear',
    'Casual',
    'Business',
    'Sport',
    'Party',
    'Minimal',
    'Vintage',
  ];

  String _selectedCategory = 'Streetwear';
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  Future<void> _createOutfit() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _outfitRepository.createOutfit(
        caption: _captionController.text,
        category: _selectedCategory,
      );

      if (mounted) {
        _captionController.clear();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Outfit wurde gespeichert.')),
        );
      }
    } on FormatException catch (error) {
      if (mounted) {
        setState(() {
          _errorMessage = error.message;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Outfit konnte nicht gespeichert werden: $error';
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
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        const AppHeader(showBack: true),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Outfit posten',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              const Text(
                'Erstelle zunächst einen einfachen Outfit-Post. Der Bild-Upload wird später ergänzt.',
                style: TextStyle(color: AppColors.muted, height: 1.4),
              ),

              const SizedBox(height: 26),

              Container(
                height: 220,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.softCard,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.black.withOpacity(0.06)),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.image_outlined,
                      size: 54,
                      color: AppColors.muted,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Bild-Upload folgt später',
                      style: TextStyle(
                        color: AppColors.muted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              DropdownButtonFormField<String>(
                value: _selectedCategory,
                items: _categories.map((category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: _isLoading
                    ? null
                    : (value) {
                        if (value == null) {
                          return;
                        }

                        setState(() {
                          _selectedCategory = value;
                        });
                      },
                decoration: const InputDecoration(
                  labelText: 'Kategorie',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: _captionController,
                enabled: !_isLoading,
                maxLength: 150,
                minLines: 3,
                maxLines: 5,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) {
                  if (!_isLoading) {
                    _createOutfit();
                  }
                },
                decoration: const InputDecoration(
                  labelText: 'Beschreibung',
                  hintText: 'z. B. Clean Streetwear Look für den Alltag',
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
                width: double.infinity,
                height: 50,
                child: FilledButton(
                  onPressed: _isLoading ? null : _createOutfit,
                  child: _isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Outfit speichern'),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ],
    );
  }
}
