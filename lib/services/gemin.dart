import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:campus_pal/models/simple_recipe.dart';

class GeminiServices {
  static final GeminiServices instance = GeminiServices._internal();
  GeminiServices._internal();

  Future<String> getNutritionalInfo(SimpleRecipe recipe) async {
    try {
      final response = await Gemini.instance.text(
        "You are a nutrition expert. Analyze the following recipe and provide nutritional information. Recipe: ${recipe.title}.\n\nIngredients:\n${recipe.ingredients.join('\n')}\n\nInstructions:\n${recipe.instructions}",
      );

      String nutritionalInfo = response!.content!.parts!.last.text!;
      return nutritionalInfo;
    } catch (e) {
      throw Exception('Error fetching nutritional information: $e');
    }
  }
}
