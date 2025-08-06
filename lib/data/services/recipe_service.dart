import 'dart:developer';

import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/recipe_model.dart';

class RecipeService {
  final String baseUrl = 'https://dummyjson.com/recipes';

  Future<List<Recipe>> getRecipes({int skip = 0, int limit = 10}) async {
    final uri = Uri.parse('$baseUrl?skip=$skip&limit=$limit');
    print('GET Request: $uri');
    
    final response = await http.get(uri);
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> recipesJson = data['recipes'];
      return recipesJson.map((json) => Recipe.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load recipes');
    }
  }

  Future<Recipe> getRecipeById(int id) async {
    final uri = Uri.parse('$baseUrl/$id');
    print('GET Request: $uri');
    
    final response = await http.get(uri);
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    
    if (response.statusCode == 200) {
      return Recipe.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load recipe');
    }
  }

  Future<List<Recipe>> searchRecipes(String query) async {
    final uri = Uri.parse('$baseUrl/search?q=$query');
    print('GET Request: $uri');
    
    final response = await http.get(uri);
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> recipesJson = data['recipes'];
      return recipesJson.map((json) => Recipe.fromJson(json)).toList();
    } else {
      throw Exception('Failed to search recipes');
    }
  }

  Future<List<Recipe>> getRecipesByTag(String tag) async {
    final uri = Uri.parse('$baseUrl/tag/$tag');
    print('GET Request: $uri');
    
    final response = await http.get(uri);
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> recipesJson = data['recipes'];
      return recipesJson.map((json) => Recipe.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load recipes by tag');
    }
  }

  Future<List<Recipe>> getRecipesByMealType(String mealType) async {
    final uri = Uri.parse('$baseUrl/meal-type/$mealType');
    print('GET Request: $uri');
    
    final response = await http.get(uri);
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> recipesJson = data['recipes'];
      return recipesJson.map((json) => Recipe.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load recipes by meal type');
    }
  }

  Future<List<String>> getTags() async {
    final uri = Uri.parse('$baseUrl/tags');
    print('GET Request: $uri');
    
    final response = await http.get(uri);
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    
    if (response.statusCode == 200) {
      final List<dynamic> tagsJson = json.decode(response.body);
      return tagsJson.map((tag) => tag.toString()).toList();
    } else {
      throw Exception('Failed to load tags');
    }
  }

  Future<Recipe> addRecipe(Recipe recipe) async {
    final uri = Uri.parse('$baseUrl/add');
    final body = json.encode(recipe.toJson());
    
    print('POST Request: $uri');
    print('Request body: $body');
    
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );
    
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    
    if (response.statusCode == 200) {
      log("message: ${response.body}");
      log("status code: ${response.statusCode}");
      return Recipe.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to add recipe');
    }
  }

  Future<Recipe> updateRecipe(int id, Recipe recipe) async {
    final uri = Uri.parse('https://dummyjson.com/recipes/$id');
    final body = json.encode(recipe.toJson());
    
    print('PUT Request: $uri');
    print('Request body: $body');
    
    final response = await http.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );
    

    
    if (response.statusCode == 200) {
      log('Response status: ${response.statusCode}');
    log('Response body: ${response.body}');
      return Recipe.fromJson(json.decode(response.body)); 
    } else {
      throw Exception('Failed to update recipe');
    }
  }

  Future<bool> deleteRecipe(int id) async {
    final uri = Uri.parse('$baseUrl/$id');
    print('DELETE Request: $uri');
    
    final response = await http.delete(uri);
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    
    return response.statusCode == 200;
  }
}