import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/recipe_model.dart';
import '../../providers/recipe_provider.dart';

class RecipeDetailScreen extends StatefulWidget {
  final int? recipeId;
  final Recipe? recipe;

  const RecipeDetailScreen({
    super.key, 
    this.recipeId,
    this.recipe,
  }) : assert(recipeId != null || recipe != null, 'Either recipeId or recipe must be provided');

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  late Future<Recipe> _recipeFuture;
  bool _isEditing = false;
  late Recipe _editedRecipe;
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    if (widget.recipe != null) {
      _recipeFuture = Future.value(widget.recipe);
      _editedRecipe = widget.recipe!;
    } else {
      _recipeFuture = _loadRecipe();
    }
  }

  Future<Recipe> _loadRecipe() async {
    final recipe = await Provider.of<RecipeProvider>(context, listen: false)
        .getRecipeById(widget.recipeId!);
    _editedRecipe = recipe;
    return recipe;
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _initControllers(Recipe recipe) {
    _controllers['name'] = TextEditingController(text: recipe.name);
    _controllers['prepTime'] = TextEditingController(text: recipe.prepTimeMinutes.toString());
    _controllers['cookTime'] = TextEditingController(text: recipe.cookTimeMinutes.toString());
    _controllers['servings'] = TextEditingController(text: recipe.servings.toString());
    
    // Clear existing ingredient controllers
    _controllers.removeWhere((key, _) => key.startsWith('ingredient_'));
    
    // Add new ingredient controllers
    for (var i = 0; i < recipe.ingredients.length; i++) {
      _controllers['ingredient_$i'] = TextEditingController(text: recipe.ingredients[i]);
    }
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        _saveChanges();
      } else {
        // Initialize controllers when entering edit mode
        if (_controllers.isEmpty && _editedRecipe != null) {
          _initControllers(_editedRecipe);
        }
      }
    });
  }

 Future<void> _saveChanges() async {
  // Save local changes before API call (optimistic update)
  final previousRecipe = _editedRecipe;

  _editedRecipe = _editedRecipe.copyWith(
    name: _controllers['name']!.text,
    prepTimeMinutes: int.tryParse(_controllers['prepTime']!.text) ?? _editedRecipe.prepTimeMinutes,
    cookTimeMinutes: int.tryParse(_controllers['cookTime']!.text) ?? _editedRecipe.cookTimeMinutes,
    servings: int.tryParse(_controllers['servings']!.text) ?? _editedRecipe.servings,
    ingredients: _controllers.entries
        .where((entry) => entry.key.startsWith('ingredient_'))
        .map((entry) => entry.value.text)
        .toList(),
  );

  // Update UI instantly
  setState(() {
    _recipeFuture = Future.value(_editedRecipe);
    _isEditing = false;
  });

  try {
    // Call API to persist changes
    final updatedRecipe = await Provider.of<RecipeProvider>(context, listen: false)
        .updateRecipe(_editedRecipe.id, _editedRecipe);

    // Replace local recipe with API response (if valid)
    setState(() {
      _editedRecipe = updatedRecipe;
      _initControllers(updatedRecipe);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Recipe updated successfully')),
    );
  } catch (e) {
    // Revert changes if API fails
    setState(() {
      _editedRecipe = previousRecipe;
      _initControllers(previousRecipe);
      _isEditing = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to update recipe: $e')),
    );
  }
}

  Widget _buildEditableField(String label, String controllerKey) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: _controllers[controllerKey],
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(value),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipe Details'),
        actions: [
          if (widget.recipeId != null) // Only show edit for recipes from API
            IconButton(
              icon: Icon(_isEditing ? Icons.save : Icons.edit),
              onPressed: _toggleEdit,
            ),
        ],
      ),
      body: FutureBuilder<Recipe>(
        future: _recipeFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && widget.recipe == null) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError && widget.recipe == null) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final recipe = snapshot.data ?? widget.recipe!;
          if (_isEditing && _controllers.isEmpty) {
            _editedRecipe = recipe;
            _initControllers(recipe);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
        
              children: [
                if (_isEditing)
                  _buildEditableField('Recipe Name', 'name')
                else
                  _buildReadOnlyField('Recipe Name', recipe.name),
                
              if (recipe.image.isNotEmpty)
  Center(
    child: recipe.image.startsWith('http')
        ? Image.network(
            recipe.image,
            height: 200,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(Icons.broken_image, size: 100);
            },
          ) 
        : Image.file(
            File(recipe.image),
            height: 200,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(Icons.broken_image, size: 100);
            },
          ),
  ),
                const SizedBox(height: 16),
                
                if (_isEditing)
                  _buildEditableField('Prep Time (minutes)', 'prepTime')
                else
                  _buildReadOnlyField('Prep Time', '${recipe.prepTimeMinutes} minutes'),
                
                if (_isEditing)
                  _buildEditableField('Cook Time (minutes)', 'cookTime')
                else
                  _buildReadOnlyField('Cook Time', '${recipe.cookTimeMinutes} minutes'),
                
                if (_isEditing)
                  _buildEditableField('Servings', 'servings')
                else
                  _buildReadOnlyField('Servings', recipe.servings.toString()),
                
                const SizedBox(height: 16),
                const Text(
                  'Ingredients',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                if (_isEditing)
                  Column(
                    children: [
                      ..._controllers.entries
                          .where((entry) => entry.key.startsWith('ingredient_'))
                          .map((entry) {
                        final index = int.parse(entry.key.split('_')[1]);
                        return Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: entry.value,
                                decoration: const InputDecoration(
                                  hintText: 'Ingredient',
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: () {
                                setState(() {
                                  _controllers.remove(entry.key);
                                  _editedRecipe = _editedRecipe.copyWith(
                                    ingredients: _editedRecipe.ingredients..removeAt(index),
                                  );
                                });
                              },
                            ),
                          ],
                        );
                      }).toList(),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            final newKey = 'ingredient_${_controllers.entries.where((entry) => entry.key.startsWith('ingredient_')).length}';
                            _controllers[newKey] = TextEditingController();
                            _editedRecipe = _editedRecipe.copyWith(
                              ingredients: _editedRecipe.ingredients..add(''),
                            );
                          });
                        },
                        child: const Text('Add Ingredient'),
                      ),
                    ],
                  )
                else
                  ...recipe.ingredients.map((ingredient) => Text('• $ingredient')).toList(),
                
                const SizedBox(height: 16),
                const Text(
                  'Instructions',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ...recipe.instructions.map((instruction) => Text('• $instruction')).toList(),
                
                const SizedBox(height: 16),
                const Text(
                  'Tags',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Wrap(
                  spacing: 8,
                  children: recipe.tags.map((tag) => Chip(label: Text(tag))).toList(),
                ),
                
                const SizedBox(height: 16),
                const Text(
                  'Meal Types',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Wrap(
                  spacing: 8,
                  children: recipe.mealType.map((type) => Chip(label: Text(type))).toList(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}