import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/models/recipe_model.dart';
import '../data/services/recipe_service.dart';

class RecipeProvider with ChangeNotifier {
  final RecipeService _recipeService = RecipeService();

  List<Recipe> _recipes = [];
  List<Recipe> _filteredRecipes = [];
  List<String> _tags = [];
  List<String> _selectedTags = [];
  List<String> _mealTypes = ['Breakfast', 'Lunch', 'Dinner', 'Snack', 'Dessert'];
  List<String> _selectedMealTypes = [];
  String _searchQuery = '';
  bool _isLoading = false;
  int _currentPage = 0;
  final int _perPage = 10;
  bool _hasMore = true;

  List<Recipe> get recipes => _filteredRecipes;
  List<String> get tags => _tags;
  List<String> get selectedTags => _selectedTags;
  List<String> get mealTypes => _mealTypes;
  List<String> get selectedMealTypes => _selectedMealTypes;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;

  Future<void> loadRecipes() async {
    if (_isLoading) return;
    
    _isLoading = true;
    notifyListeners();

    try {
      final newRecipes = await _recipeService.getRecipes(
        skip: _currentPage * _perPage,
        limit: _perPage,
      );

      if (newRecipes.isEmpty) {
        _hasMore = false;
      } else {
        _recipes.addAll(newRecipes);
        _currentPage++;
        _filterRecipes();
      }
    } catch (e) {
      debugPrint('Error loading recipes: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadTags() async {
    try {
      _tags = await _recipeService.getTags();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading tags: $e');
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _filterRecipes();
  }

  void toggleTag(String tag) {
    if (_selectedTags.contains(tag)) {
      _selectedTags.remove(tag);
    } else {
      _selectedTags.add(tag);
    }
    _filterRecipes();
  }

  void toggleMealType(String mealType) {
    if (_selectedMealTypes.contains(mealType)) {
      _selectedMealTypes.remove(mealType);
    } else {
      _selectedMealTypes.add(mealType);
    }
    _filterRecipes();
  }

  void _filterRecipes() {
    _filteredRecipes = _recipes.where((recipe) {
      // Search filter
      final matchesSearch = recipe.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          recipe.ingredients.any((ingredient) => ingredient.toLowerCase().contains(_searchQuery.toLowerCase()));

      // Tags filter
      final matchesTags = _selectedTags.isEmpty || 
          _selectedTags.any((tag) => recipe.tags.contains(tag));

      // Meal type filter
      final matchesMealTypes = _selectedMealTypes.isEmpty ||
          _selectedMealTypes.any((type) => recipe.mealType.contains(type));

      return matchesSearch && matchesTags && matchesMealTypes;
    }).toList();

    notifyListeners();
  }

  Future<void> refreshRecipes() async {
    _recipes = [];
    _filteredRecipes = [];
    _currentPage = 0;
    _hasMore = true;
    await loadRecipes();
  }

  Future<bool> deleteRecipe(int id) async {
    try {
      final success = await _recipeService.deleteRecipe(id);
      if (success) {
        _recipes.removeWhere((recipe) => recipe.id == id);
        _filterRecipes();
      }
      return success;
    } catch (e) {
      debugPrint('Error deleting recipe: $e');
      return false;
    }
  }

  // Add these missing methods
  Future<Recipe> getRecipeById(int id) async {
    try {
      // First check local cache
      final localRecipe = _recipes.firstWhere(
        (recipe) => recipe.id == id,
        orElse: () => throw Exception('Not found locally'),
      );
      return localRecipe;
    } catch (e) {
      // If not found locally, fetch from API
      debugPrint('Recipe not found locally, fetching from API: $e');
      return await _recipeService.getRecipeById(id);
    }
  }


  Future<Recipe> updateRecipe(int id, Recipe recipe) async {
    try {
      return await _recipeService.updateRecipe(id, recipe);
    } catch (e) {
      debugPrint('Error updating recipe: $e');
      rethrow;
    }
  }
 Future<Recipe> addRecipe(Recipe recipe) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Add to local list immediately
      _recipes.insert(0, recipe);
      _filterRecipes();
      
      // Then try to sync with API
      final addedRecipe = await _recipeService.addRecipe(recipe);
      
      // Replace local version with server version if successful
      _recipes.remove(recipe);
      _recipes.insert(0, addedRecipe);
      _filterRecipes();
      
      return addedRecipe;
    } catch (e) {
      // If API fails, keep the local version
      debugPrint('Error adding recipe: $e');
      return recipe;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  // Add methods to clear filters
  void clearSelectedTags() {
    _selectedTags = [];
    notifyListeners();
  }

  void clearSelectedMealTypes() {
    _selectedMealTypes = [];
    notifyListeners();
  }
}