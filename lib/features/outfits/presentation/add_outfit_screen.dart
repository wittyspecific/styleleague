import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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
  final ImagePicker _imagePicker = ImagePicker();
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
  Uint8List? _selectedImageBytes;
  String? _selectedImageExtension;

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final pickedImage = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1600,
      );

      if (pickedImage == null) {
        return;
      }

      final imageBytes = await pickedImage.readAsBytes();

      if (imageBytes.length > 5 * 1024 * 1024) {
        setState(() {
          _errorMessage = 'Das Bild darf maximal 5 MB groß sein.';
        });
        return;
      }

      setState(() {
        _selectedImageBytes = imageBytes;
        _selectedImageExtension = _getExtensionFromFileName(pickedImage.name);
        _errorMessage = null;
      });
    } catch (error) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Bild konnte nicht ausgewählt werden: $error';
        });
      }
    }
  }

  Future<void> _createOutfit() async {
    final imageBytes = _selectedImageBytes;

    if (imageBytes == null) {
      setState(() {
        _errorMessage = 'Bitte zuerst ein Bild auswählen.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _outfitRepository.createOutfit(
        caption: _captionController.text,
        category: _selectedCategory,
        imageBytes: imageBytes,
        imageExtension: _selectedImageExtension ?? 'jpg',
      );

      if (mounted) {
        _captionController.clear();

        setState(() {
          _selectedImageBytes = null;
          _selectedImageExtension = null;
        });

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

  String _getExtensionFromFileName(String fileName) {
    final lowerFileName = fileName.toLowerCase();

    if (lowerFileName.endsWith('.png')) {
      return 'png';
    }

    if (lowerFileName.endsWith('.webp')) {
      return 'webp';
    }

    if (lowerFileName.endsWith('.jpeg')) {
      return 'jpeg';
    }

    return 'jpg';
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
                'Wähle ein Outfit-Bild aus und ergänze Beschreibung sowie Kategorie.',
                style: TextStyle(color: AppColors.muted, height: 1.4),
              ),
              const SizedBox(height: 26),
              GestureDetector(
                onTap: _isLoading ? null : _pickImage,
                child: Container(
                  height: 300,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.softCard,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.black.withOpacity(0.06)),
                  ),
                  child: _selectedImageBytes == null
                      ? const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate_outlined,
                              size: 58,
                              color: AppColors.muted,
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Bild auswählen',
                              style: TextStyle(
                                color: AppColors.muted,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Maximal 5 MB',
                              style: TextStyle(
                                color: AppColors.muted,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: Image.memory(
                            _selectedImageBytes!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        ),
                ),
              ),
              if (_selectedImageBytes != null) ...[
                const SizedBox(height: 10),
                TextButton.icon(
                  onPressed: _isLoading ? null : _pickImage,
                  icon: const Icon(Icons.swap_horiz_rounded),
                  label: const Text('Anderes Bild auswählen'),
                ),
              ],
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
