import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/recipe_model.dart';
import '../../providers/recipe_provider.dart';
import '../../core/image_picker_helper.dart';

class AddRecipeScreen extends StatefulWidget {
  const AddRecipeScreen({Key? key}) : super(key: key);

  @override
  State<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameController = TextEditingController();
  final _prepTimeController = TextEditingController();
  final _cookTimeController = TextEditingController();
  final _servingsController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _cuisineController = TextEditingController();
  final _difficultyController = TextEditingController();
  final _ingredientController = TextEditingController();
  final _instructionController = TextEditingController();
  final _tagController = TextEditingController();
  final _mealTypeController = TextEditingController();

  List<String> _ingredients = [];
  List<String> _instructions = [];
  List<String> _tags = [];
  List<String> _mealTypes = [];

  String? _imagePath;

  @override
  void dispose() {
    _nameController.dispose();
    _prepTimeController.dispose();
    _cookTimeController.dispose();
    _servingsController.dispose();
    _caloriesController.dispose();
    _cuisineController.dispose();
    _difficultyController.dispose();
    _ingredientController.dispose();
    _instructionController.dispose();
    _tagController.dispose();
    _mealTypeController.dispose();
    super.dispose();
  }

  void _addItem(List<String> list, String item, TextEditingController controller) {
    if (item.trim().isNotEmpty) {
      setState(() {
        list.add(item.trim());
        controller.clear();
      });
    }
  }

  void _removeItem(List<String> list, int index) {
    setState(() {
      list.removeAt(index);
    });
  }

  Future<void> _pickImage() async {
    final path = await ImagePickerHelper.pickImage();
    if (path != null) {
      setState(() => _imagePath = path);
    }
  }

  void _clearImage() {
    setState(() => _imagePath = null);
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final newRecipe = Recipe(
        id: DateTime.now().millisecondsSinceEpoch,
        name: _nameController.text,
        ingredients: _ingredients,
        instructions: _instructions,
        prepTimeMinutes: int.tryParse(_prepTimeController.text) ?? 0,
        cookTimeMinutes: int.tryParse(_cookTimeController.text) ?? 0,
        servings: int.tryParse(_servingsController.text) ?? 1,
        difficulty: _difficultyController.text,
        cuisine: _cuisineController.text,
        caloriesPerServing: int.tryParse(_caloriesController.text) ?? 0,
        tags: _tags,
        userId: 1,
        image: _imagePath ?? '',
        rating: 0.0,
        reviewCount: 0,
        mealType: _mealTypes,
      );

      try {
        final recipeProvider = Provider.of<RecipeProvider>(context, listen: false);
        final addedRecipe = await recipeProvider.addRecipe(newRecipe);
        
        Navigator.pop(context, addedRecipe);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add recipe: $e'),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  Widget _buildSectionCard({required String title, required Widget child, IconData? icon}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 20),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: Theme.of(context).primaryColor, size: 20),
                  ),
                  const SizedBox(width: 12),
                ],
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildStyledTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    IconData? prefixIcon,
    int maxLines = 1,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 20) : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return _buildSectionCard(
      title: 'Recipe Photo',
      icon: Icons.photo_camera,
      child: GestureDetector(
        onTap: _pickImage,
        child: Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300, width: 2, style: BorderStyle.solid),
            color: _imagePath == null ? Colors.grey.shade100 : null,
          ),
          child: _imagePath == null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_a_photo, size: 50, color: Colors.grey.shade400),
                    const SizedBox(height: 8),
                    Text(
                      'Tap to add a photo',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                    ),
                  ],
                )
              : Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(
                        File(_imagePath!),
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: _clearImage,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(8),
                          child: const Icon(Icons.close, color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildListSection({
    required String title,
    required IconData icon,
    required List<String> items,
    required TextEditingController controller,
    required String hintText,
    bool useChips = false,
  }) {
    return _buildSectionCard(
      title: title,
      icon: icon,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: hintText,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onSubmitted: (value) => _addItem(items, value, controller),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.add, color: Colors.white),
                  onPressed: () => _addItem(items, controller.text, controller),
                ),
              ),
            ],
          ),
          if (items.isNotEmpty) ...[
            const SizedBox(height: 16),
            if (useChips)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: items.map((item) => Chip(
                  label: Text(item),
                  backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                  deleteIcon: const Icon(Icons.close, size: 18),
                  onDeleted: () => _removeItem(items, items.indexOf(item)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                )).toList(),
              )
            else
              ...items.asMap().entries.map((entry) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${entry.key + 1}',
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text(entry.value)),
                    IconButton(
                      icon: Icon(Icons.delete_outline, color: Colors.red.shade400),
                      onPressed: () => _removeItem(items, entry.key),
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
              )),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Add New Recipe', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Image Picker
              _buildImagePicker(),

              // Basic Info Section
              _buildSectionCard(
                title: 'Basic Information',
                icon: Icons.info_outline,
                child: Column(
                  children: [
                    _buildStyledTextField(
                      controller: _nameController,
                      label: 'Recipe Name',
                      hint: 'Enter recipe name',
                      prefixIcon: Icons.restaurant_menu,
                      validator: (value) => value?.isEmpty ?? true ? 'Please enter a name' : null,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStyledTextField(
                            controller: _prepTimeController,
                            label: 'Prep Time',
                            hint: 'Minutes',
                            prefixIcon: Icons.timer,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildStyledTextField(
                            controller: _cookTimeController,
                            label: 'Cook Time',
                            hint: 'Minutes',
                            prefixIcon: Icons.local_fire_department,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStyledTextField(
                            controller: _servingsController,
                            label: 'Servings',
                            hint: '4',
                            prefixIcon: Icons.people,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildStyledTextField(
                            controller: _caloriesController,
                            label: 'Calories',
                            hint: 'Per serving',
                            prefixIcon: Icons.local_fire_department_outlined,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStyledTextField(
                            controller: _cuisineController,
                            label: 'Cuisine',
                            hint: 'Italian, Chinese, etc.',
                            prefixIcon: Icons.public,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildStyledTextField(
                            controller: _difficultyController,
                            label: 'Difficulty',
                            hint: 'Easy, Medium, Hard',
                            prefixIcon: Icons.bar_chart,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Ingredients Section
              _buildListSection(
                title: 'Ingredients',
                icon: Icons.shopping_cart,
                items: _ingredients,
                controller: _ingredientController,
                hintText: 'Add an ingredient',
              ),

              // Instructions Section
              _buildListSection(
                title: 'Instructions',
                icon: Icons.list_alt,
                items: _instructions,
                controller: _instructionController,
                hintText: 'Add cooking instruction',
              ),

              // Tags Section
              _buildListSection(
                title: 'Tags',
                icon: Icons.label,
                items: _tags,
                controller: _tagController,
                hintText: 'Add a tag',
                useChips: true,
              ),

              // Meal Types Section
              _buildListSection(
                title: 'Meal Types',
                icon: Icons.schedule,
                items: _mealTypes,
                controller: _mealTypeController,
                hintText: 'Breakfast, Lunch, Dinner',
                useChips: true,
              ),

              // Save Button
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 3,
                    shadowColor: Theme.of(context).primaryColor.withOpacity(0.3),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.save, size: 24),
                      SizedBox(width: 8),
                      Text(
                        'Save Recipe',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}