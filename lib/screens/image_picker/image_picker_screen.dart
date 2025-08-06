import 'dart:io';
import 'package:flutter/material.dart';
import '../../core/image_picker_helper.dart';

class ImagePickerScreen extends StatefulWidget {
  const ImagePickerScreen({super.key});

  @override
  State<ImagePickerScreen> createState() => _ImagePickerScreenState();
}

class _ImagePickerScreenState extends State<ImagePickerScreen> {
  String? _selectedImagePath;

  Future<void> _pickImage() async {
    final path = await ImagePickerHelper.pickImage();
    if (path != null) {
      setState(() => _selectedImagePath = path);
    }
  }

  void _clearImage() {
    setState(() => _selectedImagePath = null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _selectedImagePath == null
                ? const Text('No Image Selected')
                : Image.file(File(_selectedImagePath!), height: 200),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text(_selectedImagePath == null ? 'Pick Image' : 'Change Image'),
            ),
            if (_selectedImagePath != null) ...[
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _clearImage,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Clear Image'),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
