import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/recipe_model.dart';
import '../../providers/recipe_provider.dart';

class RecipeDetailScreen extends StatefulWidget {
  final int recipeId;

  const RecipeDetailScreen({super.key, required this.recipeId});

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
    _recipeFuture = Provider.of<RecipeProvider>(context, listen: false)
        .getRecipeById(widget.recipeId);
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
    
    for (var i = 0; i < recipe.ingredients.length; i++) {
      _controllers['ingredient_$i'] = TextEditingController(text: recipe.ingredients[i]);
    }
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        _saveChanges();
      }
    });
  }

  Future<void> _saveChanges() async {
    try {
      // Update the edited recipe with values from controllers
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

      await Provider.of<RecipeProvider>(context, listen: false)
          .updateRecipe(_editedRecipe.id, _editedRecipe);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Recipe updated successfully')),
      );
    } catch (e) {
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
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: _toggleEdit,
          ),
        ],
      ),
      body: FutureBuilder<Recipe>(
        future: _recipeFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No recipe found'));
          }

          final recipe = snapshot.data!;
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
                    child: Image.network(
                      recipe.image,
                      height: 200,
                      fit: BoxFit.cover,
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

extension RecipeCopyWith on Recipe {
  Recipe copyWith({
    int? id,
    String? name,
    List<String>? ingredients,
    List<String>? instructions,
    int? prepTimeMinutes,
    int? cookTimeMinutes,
    int? servings,
    String? difficulty,
    String? cuisine,
    int? caloriesPerServing,
    List<String>? tags,
    int? userId,
    String? image,
    double? rating,
    int? reviewCount,
    List<String>? mealType,
  }) {
    return Recipe(
      id: id ?? this.id,
      name: name ?? this.name,
      ingredients: ingredients ?? this.ingredients,
      instructions: instructions ?? this.instructions,
      prepTimeMinutes: prepTimeMinutes ?? this.prepTimeMinutes,
      cookTimeMinutes: cookTimeMinutes ?? this.cookTimeMinutes,
      servings: servings ?? this.servings,
      difficulty: difficulty ?? this.difficulty,
      cuisine: cuisine ?? this.cuisine,
      caloriesPerServing: caloriesPerServing ?? this.caloriesPerServing,
      tags: tags ?? this.tags,
      userId: userId ?? this.userId,
      image: image ?? this.image,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      mealType: mealType ?? this.mealType,
    );
  }
}