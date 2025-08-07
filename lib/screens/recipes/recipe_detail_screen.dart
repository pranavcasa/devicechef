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

class _RecipeDetailScreenState extends State<RecipeDetailScreen> with TickerProviderStateMixin {
  late Future<Recipe> _recipeFuture;
  bool _isEditing = false;
  late Recipe _editedRecipe;
  final Map<String, TextEditingController> _controllers = {};
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic));

    if (widget.recipe != null) {
      _recipeFuture = Future.value(widget.recipe);
      _editedRecipe = widget.recipe!;
      _animationController.forward();
    } else {
      _recipeFuture = _loadRecipe();
    }
  }

  Future<Recipe> _loadRecipe() async {
    final recipe = await Provider.of<RecipeProvider>(context, listen: false)
        .getRecipeById(widget.recipeId!);
    _editedRecipe = recipe;
    _animationController.forward();
    return recipe;
  }

  @override
  void dispose() {
    _animationController.dispose();
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
    
    _controllers.removeWhere((key, _) => key.startsWith('ingredient_'));
    
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
        if (_controllers.isEmpty && _editedRecipe != null) {
          _initControllers(_editedRecipe);
        }
      }
    });
  }

  Future<void> _saveChanges() async {
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

    setState(() {
      _recipeFuture = Future.value(_editedRecipe);
      _isEditing = false;
    });

    try {
      final updatedRecipe = await Provider.of<RecipeProvider>(context, listen: false)
          .updateRecipe(_editedRecipe.id, _editedRecipe);

      setState(() {
        _editedRecipe = updatedRecipe;
        _initControllers(updatedRecipe);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Recipe updated successfully'),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } catch (e) {
      setState(() {
        _editedRecipe = previousRecipe;
        _initControllers(previousRecipe);
        _isEditing = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text('Failed to update recipe: $e')),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  Widget _buildEditableField(String label, String controllerKey, {IconData? icon, String? suffix}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: _controllers[controllerKey],
        decoration: InputDecoration(
          labelText: label,
          suffixText: suffix,
          prefixIcon: icon != null ? Icon(icon, color: Colors.blue.shade600) : null,
          filled: true,
          fillColor: Colors.blue.shade50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blue.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blue.shade400, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.1), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, Widget content, {Color? color}) {
    final sectionColor = color ?? Colors.blue;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [sectionColor, sectionColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: content,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: FutureBuilder<Recipe>(
        future: _recipeFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && widget.recipe == null) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.blue.shade50, Colors.white],
                ),
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
              ),
            );
          } else if (snapshot.hasError && widget.recipe == null) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.red.shade50, Colors.white],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Error: ${snapshot.error}',
                        style: const TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            );
          }

          final recipe = snapshot.data ?? widget.recipe!;
          if (_isEditing && _controllers.isEmpty) {
            _editedRecipe = recipe;
            _initControllers(recipe);
          }

          return CustomScrollView(
            slivers: [
              // Beautiful App Bar with Hero Image
              SliverAppBar(
                expandedHeight: 300,
                floating: false,
                pinned: true,
                elevation: 0,
                backgroundColor: Colors.blue.shade600,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Recipe Image
                      if (recipe.image.isNotEmpty)
                        recipe.image.startsWith('http')
                            ? Image.network(
                                recipe.image,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [Colors.blue.shade400, Colors.blue.shade600],
                                      ),
                                    ),
                                    child: const Icon(Icons.restaurant_menu, size: 80, color: Colors.white),
                                  );
                                },
                              )
                            : Image.file(
                                File(recipe.image),
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [Colors.blue.shade400, Colors.blue.shade600],
                                      ),
                                    ),
                                    child: const Icon(Icons.restaurant_menu, size: 80, color: Colors.white),
                                  );
                                },
                              )
                      else
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.blue.shade400, Colors.blue.shade600],
                            ),
                          ),
                          child: const Icon(Icons.restaurant_menu, size: 80, color: Colors.white),
                        ),
                      
                      // Gradient Overlay
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                            ],
                          ),
                        ),
                      ),
                      
                      // Recipe Title
                      Positioned(
                        bottom: 60,
                        left: 20,
                        right: 20,
                        child: _isEditing 
                            ? Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: TextField(
                                  controller: _controllers['name'],
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'Recipe Name',
                                  ),
                                ),
                              )
                            : Text(
                                recipe.name,
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(offset: Offset(0, 2), blurRadius: 4, color: Colors.black54),
                                  ],
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  if (widget.recipeId != null)
                    Container(
                      margin: const EdgeInsets.only(right: 16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(_isEditing ? Icons.save : Icons.edit, color: Colors.white),
                        onPressed: _toggleEdit,
                      ),
                    ),
                ],
              ),
              
              // Content
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          // Time & Servings Info Cards
                          Row(
                            children: [
                              Expanded(
                                child: _isEditing
                                    ? _buildEditableField('Prep Time', 'prepTime', 
                                        icon: Icons.schedule, suffix: 'min')
                                    : _buildInfoCard(
                                        'Prep Time',
                                        '${recipe.prepTimeMinutes} min',
                                        Icons.schedule,
                                        Colors.blue,
                                      ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _isEditing
                                    ? _buildEditableField('Cook Time', 'cookTime', 
                                        icon: Icons.local_fire_department, suffix: 'min')
                                    : _buildInfoCard(
                                        'Cook Time',
                                        '${recipe.cookTimeMinutes} min',
                                        Icons.local_fire_department,
                                        Colors.red,
                                      ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 16),
                          
                          Row(
                            children: [
                              Expanded(
                                child: _isEditing
                                    ? _buildEditableField('Servings', 'servings', 
                                        icon: Icons.people)
                                    : _buildInfoCard(
                                        'Servings',
                                        recipe.servings.toString(),
                                        Icons.people,
                                        Colors.green,
                                      ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildInfoCard(
                                  'Total Time',
                                  '${recipe.prepTimeMinutes + recipe.cookTimeMinutes} min',
                                  Icons.timer,
                                  Colors.purple,
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 32),
                          
                          // Ingredients Section
                          _buildSection(
                            'Ingredients',
                            Icons.list_alt,
                            _isEditing
                                ? Column(
                                    children: [
                                      ..._controllers.entries
                                          .where((entry) => entry.key.startsWith('ingredient_'))
                                          .map((entry) {
                                        final index = int.parse(entry.key.split('_')[1]);
                                        return Container(
                                          margin: const EdgeInsets.only(bottom: 12),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: TextField(
                                                  controller: entry.value,
                                                  decoration: InputDecoration(
                                                    hintText: 'Enter ingredient',
                                                    filled: true,
                                                    fillColor: Colors.grey.shade50,
                                                    border: OutlineInputBorder(
                                                      borderRadius: BorderRadius.circular(12),
                                                      borderSide: BorderSide.none,
                                                    ),
                                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.red.shade50,
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: IconButton(
                                                  icon: Icon(Icons.remove, color: Colors.red.shade600),
                                                  onPressed: () {
                                                    setState(() {
                                                      _controllers.remove(entry.key);
                                                      _editedRecipe = _editedRecipe.copyWith(
                                                        ingredients: _editedRecipe.ingredients..removeAt(index),
                                                      );
                                                    });
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                      const SizedBox(height: 16),
                                      ElevatedButton.icon(
                                        onPressed: () {
                                          setState(() {
                                            final newKey = 'ingredient_${_controllers.entries.where((entry) => entry.key.startsWith('ingredient_')).length}';
                                            _controllers[newKey] = TextEditingController();
                                            _editedRecipe = _editedRecipe.copyWith(
                                              ingredients: _editedRecipe.ingredients..add(''),
                                            );
                                          });
                                        },
                                        icon: const Icon(Icons.add),
                                        label: const Text('Add Ingredient'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue.shade600,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                        ),
                                      ),
                                    ],
                                  )
                                : Column(
                                    children: recipe.ingredients
                                        .map((ingredient) => Container(
                                              margin: const EdgeInsets.only(bottom: 12),
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: Colors.blue.shade50,
                                                borderRadius: BorderRadius.circular(12),
                                                border: Border.all(color: Colors.blue.shade200),
                                              ),
                                              child: Row(
                                                children: [
                                                  Container(
                                                    width: 8,
                                                    height: 8,
                                                    decoration: BoxDecoration(
                                                      color: Colors.blue.shade600,
                                                      shape: BoxShape.circle,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Expanded(
                                                    child: Text(
                                                      ingredient,
                                                      style: const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.w500,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ))
                                        .toList(),
                                  ),
                            color: Colors.blue,
                          ),
                          
                          // Instructions Section
                          _buildSection(
                            'Instructions',
                            Icons.format_list_numbered,
                            Column(
                              children: recipe.instructions
                                  .asMap()
                                  .entries
                                  .map((entry) => Container(
                                        margin: const EdgeInsets.only(bottom: 16),
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [Colors.blue.shade50, Colors.white],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: Colors.blue.shade200),
                                        ),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              width: 24,
                                              height: 24,
                                              decoration: BoxDecoration(
                                                color: Colors.blue.shade600,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Center(
                                                child: Text(
                                                  '${entry.key + 1}',
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Text(
                                                entry.value,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  height: 1.4,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ))
                                  .toList(),
                            ),
                            color: Colors.blue,
                          ),
                          
                          // Tags Section
                          if (recipe.tags.isNotEmpty)
                            _buildSection(
                              'Tags',
                              Icons.tag,
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: recipe.tags
                                    .map((tag) => Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [Colors.green.shade400, Colors.green.shade600],
                                            ),
                                            borderRadius: BorderRadius.circular(20),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.green.withOpacity(0.3),
                                                blurRadius: 4,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Text(
                                            tag,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ))
                                    .toList(),
                              ),
                              color: Colors.green,
                            ),
                          
                          // Meal Types Section
                          if (recipe.mealType.isNotEmpty)
                            _buildSection(
                              'Meal Types',
                              Icons.restaurant,
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: recipe.mealType
                                    .map((type) => Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [Colors.purple.shade400, Colors.purple.shade600],
                                            ),
                                            borderRadius: BorderRadius.circular(20),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.purple.withOpacity(0.3),
                                                blurRadius: 4,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Text(
                                            type,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ))
                                    .toList(),
                              ),
                              color: Colors.purple,
                            ),
                          
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}