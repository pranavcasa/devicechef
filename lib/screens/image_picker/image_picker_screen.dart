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
      //pBar: AppBar(title: const Text('Image Picker')),

      // Full screen image area
      body: Center(
        child: _selectedImagePath == null
            ? const Text(
                'No Image Selected',
                style: TextStyle(fontSize: 18),
              )
            : Padding(
              padding: const EdgeInsets.all(8.0),
              child: InteractiveViewer(
                  child: Image.file(
                    File(_selectedImagePath!),
                    fit: BoxFit.fill,// full fit to screen
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
            ),
      ),

      // Sticky bottom buttons
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              MaterialButton(
                color: Colors.blue,
                textColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                onPressed: _pickImage,
                child: Text(_selectedImagePath == null
                    ? 'Pick Image'
                    : 'Change Image'),
              ),
              if (_selectedImagePath != null) ...[
                const SizedBox(height: 10),
                MaterialButton(
                  color: Colors.red,
                  textColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  onPressed: _clearImage,
                  child: const Text('Clear Image'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
