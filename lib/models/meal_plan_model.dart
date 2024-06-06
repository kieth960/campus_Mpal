import 'simple_recipe.dart';

// Define a model for a meal plan
class MealPlanModel {
  final String day;
  final DateTime date;
  final Map<String, SimpleRecipe> recipes;

  MealPlanModel({
    required this.day,
    required this.date,
    required this.recipes,
  });

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'date': date.toIso8601String(),
      'recipes': recipes.map((key, value) => MapEntry(key, value.toJson())),
    };
  }

  static MealPlanModel fromJson(Map<String, dynamic> json) {
    return MealPlanModel(
      day: json['day'],
      date: DateTime.parse(json['date']),
      recipes: (json['recipes'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, SimpleRecipe.fromJson(value)),
      ),
    );
  }
}
