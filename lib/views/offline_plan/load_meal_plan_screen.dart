import 'package:flutter/material.dart';
import 'package:campus_pal/models/meal_plan_model.dart';
import 'package:campus_pal/models/meal_plan_repository.dart';
import 'instructions.dart';
import 'auto_shopping.dart';

class LoadMealPlanScreen extends StatefulWidget {
  @override
  _LoadMealPlanScreenState createState() => _LoadMealPlanScreenState();
}

class _LoadMealPlanScreenState extends State<LoadMealPlanScreen> {
  final MealPlanRepository _mealPlanRepository = MealPlanRepository();
  List<MealPlanModel> _savedMealPlan = [];

  @override
  void initState() {
    super.initState();
    _loadSavedMealPlan();
  }

  Future<void> _loadSavedMealPlan() async {
    try {
      final mealPlan = await _mealPlanRepository.loadMealPlan();
      setState(() {
        _savedMealPlan = mealPlan;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading meal plan: $e')),
      );
    }
  }

  List<String> _extractIngredients(List<MealPlanModel> mealPlans) {
    final Set<String> ingredientsSet = {};

    mealPlans.forEach((mealPlan) {
      mealPlan.recipes.forEach((mealType, recipe) {
        recipe.ingredients.forEach((ingredient) {
          ingredientsSet.add(ingredient);
        });
      });
    });

    return ingredientsSet.toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Saved Meal Plan'),
        backgroundColor: Color(0xff0cb945),
        actions: [
          IconButton(
            icon: Icon(Icons.list),
            onPressed: () {
              final ingredients = _extractIngredients(_savedMealPlan);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GroceryListScreen(
                    ingredients: ingredients,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: _savedMealPlan.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _savedMealPlan.length,
              itemBuilder: (context, index) {
                final mealPlan = _savedMealPlan[index];
                return Card(
                  child: ExpansionTile(
                    title: Text(
                      '${mealPlan.day} (${mealPlan.date.toLocal().toIso8601String().substring(0, 10)})',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    children: mealPlan.recipes.entries.map((entry) {
                      return ListTile(
                        title: Text(entry.value.title),
                        subtitle: Text(
                          'Type: ${entry.key} | Duration: ${entry.value.duration}',
                        ),
                        leading: Image.asset(
                          entry.value.dishImage,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CookingStepsScreen(
                                recipe: entry.value,
                              ),
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ),
                );
              },
            ),
    );
  }
}
