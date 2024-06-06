import 'package:flutter/material.dart';
import 'package:campus_pal/models/simple_recipe.dart';
import 'package:campus_pal/services/mock.dart';
import 'instructions.dart';

class RecipeListScreen extends StatefulWidget {
  const RecipeListScreen({Key? key}) : super(key: key);

  @override
  State<RecipeListScreen> createState() => _RecipeListScreenState();
}

class _RecipeListScreenState extends State<RecipeListScreen> {
  final mockService = mock();
  List<SimpleRecipe> _recipes = [];
  String _searchTerm = '';
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadRecipes();
  }

  Future<void> _loadRecipes() async {
    final recipes = await mockService.getRecipes();
    setState(() {
      _recipes = recipes;
    });
  }

  void _scrollToResult(String searchTerm) {
    for (int i = 0; i < _recipes.length; i++) {
      if (_recipes[i].title.toLowerCase().contains(searchTerm)) {
        _scrollController.animateTo(
          i * 200.0, // Assuming each recipe card is 200 pixels high
          duration: const Duration(milliseconds: 500),
          curve: Curves.ease,
        );
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Recipes'),
        backgroundColor: Color(0xff0cb945),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search by title',
              prefixIcon: const Icon(Icons.search),
            ),
            onChanged: (value) {
              setState(() {
                _searchTerm = value.toLowerCase();
                _scrollToResult(
                    _searchTerm); // Scroll to the first matching result
              });
            },
          ),
        ),
      ),
      body: SafeArea(
        child: GridView.builder(
          controller: _scrollController, // Use the scroll controller
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
          ),
          itemCount: _recipes.length,
          itemBuilder: (context, index) {
            final recipe = _recipes[index];
            if (recipe.title.toLowerCase().contains(_searchTerm)) {
              return GestureDetector(
                onTap: () {
                  Navigator.pop(context, recipe); // Return the selected recipe
                },
                child: Card(
                  child: Column(
                    children: [
                      Image.asset(recipe.dishImage),
                      Text(recipe.title),
                      Text(recipe.duration),
                    ],
                  ),
                ),
              );
            } else {
              return const SizedBox.shrink();
            }
          },
        ),
      ),
    );
  }
}
