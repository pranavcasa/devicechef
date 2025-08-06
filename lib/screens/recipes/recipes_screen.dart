import 'dart:io';

import 'package:devicechef/data/models/recipe_model.dart';
import 'package:devicechef/screens/recipes/add_recipe_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/recipe_provider.dart';
import 'recipe_detail_screen.dart';

class RecipeListScreen extends StatefulWidget {
  const RecipeListScreen({Key? key}) : super(key: key);

  @override
  State<RecipeListScreen> createState() => _RecipeListScreenState();
}

class _RecipeListScreenState extends State<RecipeListScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final recipeProvider = Provider.of<RecipeProvider>(context, listen: false);
    recipeProvider.loadRecipes();
    recipeProvider.loadTags();

    _scrollController.addListener(_scrollListener);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    final recipeProvider = Provider.of<RecipeProvider>(context, listen: false);
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !recipeProvider.isLoading &&
        recipeProvider.hasMore) {
      recipeProvider.loadRecipes();
    }
  }

  void _onSearchChanged() {
    Provider.of<RecipeProvider>(
      context,
      listen: false,
    ).setSearchQuery(_searchController.text);
  }

  void _showFilters(BuildContext context) {
    final recipeProvider = Provider.of<RecipeProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: const EdgeInsets.all(16),
              height: MediaQuery.of(context).size.height * 0.8,
              child: SingleChildScrollView(
                // Add this
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Filters',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Tags',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children:
                          recipeProvider.tags.map((tag) {
                            return FilterChip(
                              label: Text(tag),
                              selected: recipeProvider.selectedTags.contains(
                                tag,
                              ),
                              onSelected: (selected) {
                                recipeProvider.toggleTag(tag);
                                setState(() {});
                              },
                            );
                          }).toList(),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Meal Types',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children:
                          recipeProvider.mealTypes.map((type) {
                            return FilterChip(
                              label: Text(type),
                              selected: recipeProvider.selectedMealTypes
                                  .contains(type),
                              onSelected: (selected) {
                                recipeProvider.toggleMealType(type);
                                setState(() {});
                              },
                            );
                          }).toList(),
                    ),
                    const SizedBox(height: 16), // Add some space before buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () {
                            recipeProvider.clearSelectedTags();
                            recipeProvider.clearSelectedMealTypes();
                            recipeProvider.setSearchQuery('');
                            _searchController.clear();
                            recipeProvider.refreshRecipes();
                            Navigator.pop(context);
                          },
                          child: const Text('Reset Filters'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            recipeProvider.refreshRecipes();
                            Navigator.pop(context);
                          },
                          child: const Text('Apply Filters'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

Future<void> _confirmDelete(int recipeId) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Delete Recipe'),
      content: const Text('Are you sure you want to delete this recipe?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Delete'),
        ),
      ],
    ),
  );

  if (confirmed == true) {
    final recipeProvider = Provider.of<RecipeProvider>(context, listen: false);
    final success = await recipeProvider.deleteRecipe(recipeId);

    if (!mounted) return;
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Recipe deleted successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Deleted locally but failed to delete from server'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Consumer<RecipeProvider>(
      builder: (context, recipeProvider, child) {
        return Scaffold(
        floatingActionButton: FloatingActionButton(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddRecipeScreen(),
                ),
              );
              
              if (result != null && result is Recipe) {
                // Show newly created recipe
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RecipeDetailScreen(recipe: result),
                  ),
                );
              }
            },
            child: const Icon(Icons.add),
          ),
          appBar: AppBar(
            title: const Text('Recipes'),
            actions: [
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: () => _showFilters(context),
              ),
            ],
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search recipes...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => recipeProvider.refreshRecipes(),
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: recipeProvider.recipes.length + 1,
                    itemBuilder: (context, index) {
                      if (index < recipeProvider.recipes.length) {
                        final recipe = recipeProvider.recipes[index];
                        return Card(
                          margin: const EdgeInsets.all(8),
                          child: ListTile(
                            leading:
                                recipe.image.isNotEmpty
                                    ? (recipe.image.startsWith('http')
                                        ? Image.network(
                                          recipe.image,
                                          width: 60,
                                          height: 60,
                                          fit: BoxFit.cover,
                                        )
                                        : Image.file(
                                          File(recipe.image),
                                          width: 60,
                                          height: 60,
                                          fit: BoxFit.cover,
                                        ))
                                    : const Icon(Icons.fastfood, size: 40),
                            title: Text(recipe.name),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Ingredients: ${recipe.ingredients.take(3).join(', ')}${recipe.ingredients.length > 3 ? '...' : ''}',
                                ),
                                Text(
                                  'Tags: ${recipe.tags.take(3).join(', ')}${recipe.tags.length > 3 ? '...' : ''}',
                                ),
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _confirmDelete(recipe.id),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => RecipeDetailScreen(
                                        recipeId: recipe.id,
                                      ),
                                ),
                              );
                            },
                          ),
                        );
                      } else {
                        return Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Center(
                            child:
                                recipeProvider.isLoading
                                    ? const CircularProgressIndicator()
                                    : recipeProvider.hasMore
                                    ? const Text('Load more recipes')
                                    : const Text('No more recipes to load'),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
