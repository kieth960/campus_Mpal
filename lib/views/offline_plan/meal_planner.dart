import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:campus_pal/models/simple_recipe.dart';
import 'package:campus_pal/models/meal_plan_model.dart';
import 'package:campus_pal/models/meal_plan_repository.dart';
import 'package:campus_pal/services/gemin.dart';
import 'load_meal_plan_screen.dart';
import 'instructions.dart';
import 'recipe_list.dart'; // Import RecipeListScreen
import 'nutrition.dart'; // Import the new screen

class MealPlanScreen extends StatefulWidget {
  final Map<String, Map<DateTime, Map<String, SimpleRecipe>>> mealPlan;

  MealPlanScreen({required this.mealPlan});

  @override
  _MealPlanScreenState createState() => _MealPlanScreenState();
}

class _MealPlanScreenState extends State<MealPlanScreen> {
  late Map<String, Map<DateTime, Map<String, SimpleRecipe>>> _editableMealPlan;

  @override
  void initState() {
    super.initState();
    _editableMealPlan = Map.from(widget.mealPlan);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Weekly Meal Plan'),
        backgroundColor: Color(0xff0cb945),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () {
              _saveMealPlan(context);
            },
          ),
          IconButton(
            icon: Icon(Icons.folder_open),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LoadMealPlanScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _editableMealPlan.length,
        itemBuilder: (context, index) {
          final day = _editableMealPlan.keys.toList()[index];
          final recipesForDay = _editableMealPlan[day]!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  '$day (${DateFormat('yyyy-MM-dd').format(recipesForDay.keys.first)})',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              for (var entry in recipesForDay.entries)
                _buildMealSlot(context, day, entry.key, entry.value),
            ],
          );
        },
      ),
    );
  }

  Future<void> _saveMealPlan(BuildContext context) async {
    try {
      final mealPlanModels = _convertToMealPlanModels(_editableMealPlan);
      final repository = MealPlanRepository();
      await repository.saveMealPlan(mealPlanModels);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Meal plan saved')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving meal plan: $e')),
      );
    }
  }

  List<MealPlanModel> _convertToMealPlanModels(
      Map<String, Map<DateTime, Map<String, SimpleRecipe>>> mealPlan) {
    List<MealPlanModel> mealPlanModels = [];
    mealPlan.forEach((day, dayMeals) {
      dayMeals.forEach((date, recipes) {
        final mealPlanModel = MealPlanModel(
          day: day,
          date: date,
          recipes: recipes,
        );
        mealPlanModels.add(mealPlanModel);
      });
    });
    return mealPlanModels;
  }

  Widget _buildMealSlot(BuildContext context, String day, DateTime date,
      Map<String, SimpleRecipe> recipes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var mealSlotEntry in recipes.entries)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${mealSlotEntry.key}:',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            _editRecipe(context, day, date, mealSlotEntry.key);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            _removeRecipe(day, date, mealSlotEntry.key);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.info_outline),
                          onPressed: () {
                            _showNutritionalInfo(context, mealSlotEntry.value);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CookingStepsScreen(
                        recipe: mealSlotEntry.value,
                      ),
                    ),
                  );
                },
                child: ListTile(
                  title: Text(mealSlotEntry.value.title),
                  subtitle: Text('${mealSlotEntry.value.duration}'),
                  leading: Image.asset(mealSlotEntry.value.dishImage),
                ),
              ),
            ],
          ),
      ],
    );
  }

  void _showNutritionalInfo(BuildContext context, SimpleRecipe recipe) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Fetching nutritional information...')),
    );

    try {
      final nutritionalInfo =
          await GeminiServices.instance.getNutritionalInfo(recipe);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NutritionalInfoScreen(
            nutritionalInfo: nutritionalInfo,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching nutritional info: $e')),
      );
    }
  }

  void _removeRecipe(String day, DateTime date, String mealType) {
    setState(() {
      _editableMealPlan[day]![date]!.remove(mealType);
      if (_editableMealPlan[day]![date]!.isEmpty) {
        _editableMealPlan[day]!.remove(date);
        if (_editableMealPlan[day]!.isEmpty) {
          _editableMealPlan.remove(day);
        }
      }
    });
  }

  void _editRecipe(
      BuildContext context, String day, DateTime date, String mealType) async {
    final selectedRecipe = await Navigator.push<SimpleRecipe>(
      context,
      MaterialPageRoute(
        builder: (context) => RecipeListScreen(),
      ),
    );

    if (selectedRecipe != null) {
      bool isDuplicate = false;
      bool isWrongMealType = selectedRecipe.mealType != mealType;

      _editableMealPlan[day]![date]!.forEach((key, recipe) {
        if (recipe.title == selectedRecipe.title) {
          isDuplicate = true;
        }
      });

      if (isDuplicate) {
        _showDuplicateRecipeDialog(context);
      } else if (isWrongMealType) {
        _showWrongMealTypeDialog(context, mealType);
      } else {
        setState(() {
          _editableMealPlan[day]![date]![mealType] = selectedRecipe;
        });
      }
    }
  }

  void _showDuplicateRecipeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Duplicate Recipe'),
        content: Text(
            'This recipe is already used for the selected day. Please select another recipe.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showWrongMealTypeDialog(BuildContext context, String expectedMealType) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Wrong Meal Type'),
        content: Text(
            'The selected recipe does not match the meal type ($expectedMealType). Please select another recipe.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}
