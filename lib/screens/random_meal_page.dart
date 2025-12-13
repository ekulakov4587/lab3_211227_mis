import 'package:flutter/material.dart';
import '../models/meal_model.dart';
import '../services/api_service.dart';
import 'meal_detail_page.dart';

class RandomMealPage extends StatelessWidget {
  const RandomMealPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ApiService api = ApiService();

    return FutureBuilder<MealDetail>(
      future: api.getRandomMeal(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData) return const Center(child: Text('No meal found'));
        final meal = snapshot.data!;
        return MealDetailPage(mealId: meal.id);
      },
    );
  }
}
