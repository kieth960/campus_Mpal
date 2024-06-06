import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:campus_pal/models/meal_plan_model.dart';

class MealPlanRepository {
  static const _mealPlanKey = 'mealPlan';

  Future<void> saveMealPlan(List<MealPlanModel> mealPlan) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString =
          jsonEncode(mealPlan.map((plan) => plan.toJson()).toList());
      await prefs.setString(_mealPlanKey, jsonString);
      print('Meal plan saved');
    } catch (e) {
      print('Error saving meal plan: $e');
      rethrow;
    }
  }

  Future<List<MealPlanModel>> loadMealPlan() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_mealPlanKey);
      if (jsonString == null) {
        return [];
      }
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => MealPlanModel.fromJson(json)).toList();
    } catch (e) {
      print('Error loading meal plan: $e');
      rethrow;
    }
  }

  Future<void> _loadMealPlan() async {
    try {
      final repository = MealPlanRepository();
      final mealPlanModels = await repository.loadMealPlan();
      // Handle loaded meal plan models
    } catch (e) {
      print('Error loading meal plan: $e');
    }
  }
}
