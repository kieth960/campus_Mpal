import 'dart:math';
import 'package:intl/intl.dart';
import 'simple_recipe.dart';

class MealPlanner {
  static Map<String, Map<DateTime, Map<String, SimpleRecipe>>>
      generateMealPlanForWeek(List<SimpleRecipe> recipes) {
    final mealPlanForWeek =
        <String, Map<DateTime, Map<String, SimpleRecipe>>>{};
    final random = Random();

    // Get the current date and time
    final now = DateTime.now();

    // Keep track of the recipes used per day
    final recipesUsedPerDay = <DateTime, List<SimpleRecipe>>{};

    // Generate meal plan for each day of the week
    for (int i = 0; i < 7; i++) {
      // Calculate the date for the current day
      final date = now.add(Duration(days: i));

      // Generate meals for the day
      final mealsForDay = <DateTime, Map<String, SimpleRecipe>>{};

      // Generate breakfast
      final breakfastRecipes =
          recipes.where((r) => r.mealType == 'breakfast').toList();
      final breakfast =
          _getUniqueRecipe(breakfastRecipes, random, recipesUsedPerDay, date);
      if (breakfast != null) {
        (recipesUsedPerDay[date] ??= []).add(breakfast);
        mealsForDay[date] = {'breakfast': breakfast};
      }

      // Generate lunch
      final lunchRecipes = recipes.where((r) => r.mealType == 'lunch').toList();
      final lunch =
          _getUniqueRecipe(lunchRecipes, random, recipesUsedPerDay, date);
      if (lunch != null) {
        (recipesUsedPerDay[date] ??= []).add(lunch);
        mealsForDay[date]!['lunch'] = lunch;
      }

      // Generate dinner
      final dinnerRecipes =
          recipes.where((r) => r.mealType == 'dinner').toList();
      final dinner =
          _getUniqueRecipe(dinnerRecipes, random, recipesUsedPerDay, date);
      if (dinner != null) {
        (recipesUsedPerDay[date] ??= []).add(dinner);
        mealsForDay[date]!['dinner'] = dinner;
      }

      // Generate an optional snack
      if (random.nextBool()) {
        final snackRecipes =
            recipes.where((r) => r.mealType == 'snack').toList();
        final snack =
            _getUniqueRecipe(snackRecipes, random, recipesUsedPerDay, date);
        if (snack != null) {
          (recipesUsedPerDay[date] ??= []).add(snack);
          mealsForDay[date]!['snack'] = snack;
        }
      }

      // Add the meals for the day to the meal plan
      mealPlanForWeek[DateFormat('EEEE').format(date)] = mealsForDay;
    }

    return mealPlanForWeek;
  }

  static SimpleRecipe? _getUniqueRecipe(
      List<SimpleRecipe> recipes,
      Random random,
      Map<DateTime, List<SimpleRecipe>> recipesUsedPerDay,
      DateTime date) {
    if (recipes.isEmpty) return null; // Return null if no recipes available

    // Shuffle the recipes to randomize the selection
    recipes.shuffle();

    // Select a random recipe that hasn't been used for the current day
    final recipesUsedToday = recipesUsedPerDay[date] ?? [];
    for (final recipe in recipes) {
      if (!recipesUsedToday.contains(recipe)) {
        return recipe;
      }
    }

    // If all recipes have been used for the current day, return the first one
    return recipes[0];
  }
}
