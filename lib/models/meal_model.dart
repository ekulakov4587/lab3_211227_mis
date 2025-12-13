class Meal {
  final String id;
  final String name;
  final String thumb;

  Meal({required this.id, required this.name, required this.thumb});

  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      id: json['idMeal'],
      name: json['strMeal'],
      thumb: json['strMealThumb'],
    );
  }
}

class MealDetail {
  final String id;
  final String name;
  final String thumb;
  final String instructions;
  final List<String> ingredients;
  final String? youtube;

  MealDetail({
    required this.id,
    required this.name,
    required this.thumb,
    required this.instructions,
    required this.ingredients,
    this.youtube,
  });

  factory MealDetail.fromJson(Map<String, dynamic> json) {
    List<String> ingredients = [];
    for (int i = 1; i <= 20; i++) {
      final ingredient = json['strIngredient$i'];
      final measure = json['strMeasure$i'];
      if (ingredient != null && ingredient.isNotEmpty) {
        ingredients.add('$ingredient - $measure');
      }
    }

    return MealDetail(
      id: json['idMeal'],
      name: json['strMeal'],
      thumb: json['strMealThumb'],
      instructions: json['strInstructions'],
      ingredients: ingredients,
      youtube: json['strYoutube'],
    );
  }
}
