import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/recipe_model.dart';

class RecipeService {
  final String baseUrl = 'https://dummyjson.com/recipes';

  Future<List<Recipe>> getRecipes({int skip = 0, int limit = 10}) async {
    final response = await http.get(Uri.parse('$baseUrl?skip=$skip&limit=$limit'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> recipesJson = data['recipes'];
      return recipesJson.map((json) => Recipe.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load recipes');
    }
  }

  Future<Recipe> getRecipeById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/$id'));
    if (response.statusCode == 200) {
      return Recipe.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load recipe');
    }
  }

  Future<List<Recipe>> searchRecipes(String query) async {
    final response = await http.get(Uri.parse('$baseUrl/search?q=$query'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> recipesJson = data['recipes'];
      return recipesJson.map((json) => Recipe.fromJson(json)).toList();
    } else {
      throw Exception('Failed to search recipes');
    }
  }

  Future<List<Recipe>> getRecipesByTag(String tag) async {
    final response = await http.get(Uri.parse('$baseUrl/tag/$tag'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> recipesJson = data['recipes'];
      return recipesJson.map((json) => Recipe.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load recipes by tag');
    }
  }

  Future<List<Recipe>> getRecipesByMealType(String mealType) async {
    final response = await http.get(Uri.parse('$baseUrl/meal-type/$mealType'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> recipesJson = data['recipes'];
      return recipesJson.map((json) => Recipe.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load recipes by meal type');
    }
  }

  Future<List<String>> getTags() async {
    final response = await http.get(Uri.parse('$baseUrl/tags'));
    if (response.statusCode == 200) {
      final List<dynamic> tagsJson = json.decode(response.body);
      return tagsJson.map((tag) => tag.toString()).toList();
    } else {
      throw Exception('Failed to load tags');
    }
  }

  Future<Recipe> addRecipe(Recipe recipe) async {
    final response = await http.post(
      Uri.parse('$baseUrl/add'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(recipe.toJson()),
    );
    if (response.statusCode == 200) {
      return Recipe.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to add recipe');
    }
  }

  Future<Recipe> updateRecipe(int id, Recipe recipe) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(recipe.toJson()),
    );
    if (response.statusCode == 200) {
      return Recipe.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update recipe');
    }
  }

  Future<bool> deleteRecipe(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));
    return response.statusCode == 200;
  }
}