class SimpleRecipe {
  String id;
  String dishImage;
  String title;
  String duration;
  String nutrition;
  String mealType;
  List<String> ingredients;
  List<String> instructions;
  String?
      source; // Made optional to handle cases where the source might be absent

  SimpleRecipe({
    required this.id,
    required this.dishImage,
    required this.title,
    required this.duration,
    required this.nutrition,
    required this.mealType,
    required this.ingredients,
    required this.instructions,
    this.source,
  });

  factory SimpleRecipe.fromJson(Map<String, dynamic> json) {
    return SimpleRecipe(
      id: json['id'] as String,
      dishImage: json['dishImage'] as String,
      title: json['title'] as String,
      duration: json['duration'] as String,
      nutrition: json['nutrition'] as String,
      mealType: json['mealType'] as String,
      ingredients: List<String>.from(json['ingredients'] as List<dynamic>),
      instructions: List<String>.from(json['instructions'] as List<dynamic>),
      source: json['source'] as String?, // Optional field
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dishImage': dishImage,
      'title': title,
      'duration': duration,
      'nutrition': nutrition,
      'mealType': mealType,
      'ingredients': ingredients,
      'instructions': instructions,
      'source': source, // Optional field
    };
  }
}
