import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/recipe_model.dart';
import '../../providers/recipe_provider.dart';
import '../../core/image_picker_helper.dart'; // <-- Import helper

class AddRecipeScreen extends StatefulWidget {
  const AddRecipeScreen({Key? key}) : super(key: key);

  @override
  State<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  final _formKey = GlobalKey<FormState>();

  // Existing controllers...
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

  String? _imagePath; // <-- Local image file path

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
    if (item.isNotEmpty) {
      setState(() {
        list.add(item);
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
        
        Navigator.pop(context, addedRecipe); // Return the created recipe
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add recipe: $e')),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add New Recipe')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image picker preview
              GestureDetector(
                onTap: _pickImage,
                child: _imagePath == null
                    ? Container(
                        height: 150,
                        width: double.infinity,
                        color: Colors.grey[300],
                        child: const Icon(Icons.add_a_photo, size: 50, color: Colors.black54),
                      )
                    : Stack(
                        children: [
                          Image.file(File(_imagePath!), height: 150, width: double.infinity, fit: BoxFit.cover),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: _clearImage,
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                padding: const EdgeInsets.all(4),
                                child: const Icon(Icons.close, color: Colors.white),
                              ),
                            ),
                          )
                        ],
                      ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Recipe Name'),
                validator: (value) => value?.isEmpty ?? true ? 'Please enter a name' : null,
              ),
              TextFormField(
                controller: _prepTimeController,
                decoration: const InputDecoration(labelText: 'Prep Time (minutes)'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _cookTimeController,
                decoration: const InputDecoration(labelText: 'Cook Time (minutes)'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _servingsController,
                decoration: const InputDecoration(labelText: 'Servings'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _caloriesController,
                decoration: const InputDecoration(labelText: 'Calories per Serving'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _cuisineController,
                decoration: const InputDecoration(labelText: 'Cuisine'),
              ),
              TextFormField(
                controller: _difficultyController,
                decoration: const InputDecoration(labelText: 'Difficulty (Easy/Medium/Hard)'),
              ),

              // Ingredients section
              const SizedBox(height: 16),
              const Text('Ingredients', style: TextStyle(fontWeight: FontWeight.bold)),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _ingredientController,
                      decoration: const InputDecoration(labelText: 'Add Ingredient'),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => _addItem(_ingredients, _ingredientController.text, _ingredientController),
                  ),
                ],
              ),
              ..._ingredients.asMap().entries.map((entry) => ListTile(
                    title: Text(entry.value),
                    trailing: IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () => _removeItem(_ingredients, entry.key),
                    ),
                  )),

              // Instructions section
              const SizedBox(height: 16),
              const Text('Instructions', style: TextStyle(fontWeight: FontWeight.bold)),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _instructionController,
                      decoration: const InputDecoration(labelText: 'Add Instruction'),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => _addItem(_instructions, _instructionController.text, _instructionController),
                  ),
                ],
              ),
              ..._instructions.asMap().entries.map((entry) => ListTile(
                    title: Text(entry.value),
                    trailing: IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () => _removeItem(_instructions, entry.key),
                    ),
                  )),

              // Tags section
              const SizedBox(height: 16),
              const Text('Tags', style: TextStyle(fontWeight: FontWeight.bold)),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _tagController,
                      decoration: const InputDecoration(labelText: 'Add Tag'),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => _addItem(_tags, _tagController.text, _tagController),
                  ),
                ],
              ),
              Wrap(
                spacing: 8,
                children: _tags
                    .map((tag) => Chip(
                          label: Text(tag),
                          onDeleted: () => _removeItem(_tags, _tags.indexOf(tag)),
                        ))
                    .toList(),
              ),

              // Meal Types section
              const SizedBox(height: 16),
              const Text('Meal Types', style: TextStyle(fontWeight: FontWeight.bold)),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _mealTypeController,
                      decoration: const InputDecoration(labelText: 'Add Meal Type'),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => _addItem(_mealTypes, _mealTypeController.text, _mealTypeController),
                  ),
                ],
              ),
              Wrap(
                spacing: 8,
                children: _mealTypes
                    .map((type) => Chip(
                          label: Text(type),
                          onDeleted: () => _removeItem(_mealTypes, _mealTypes.indexOf(type)),
                        ))
                    .toList(),
              ),

              const SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: _submitForm,
                  child: const Text('Save Recipe'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
