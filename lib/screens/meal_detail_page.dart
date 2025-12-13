import 'package:flutter/material.dart';
import '../models/meal_model.dart';
import '../services/api_service.dart';

class MealDetailPage extends StatelessWidget {
  final String mealId;
  const MealDetailPage({super.key, required this.mealId});

  @override
  Widget build(BuildContext context) {
    final ApiService api = ApiService();

    return Scaffold(
      appBar: AppBar(title: const Text('Meal Details')),
      body: FutureBuilder<MealDetail>(
        future: api.getMealDetail(mealId),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData) return const Center(child: Text('Meal not found'));

          final meal = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.network(meal.thumb),
                const SizedBox(height: 16),
                Text(meal.name, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Text('Ingredients', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                ...meal.ingredients.map((i) => Text(i)),
                const SizedBox(height: 16),
                Text('Instructions', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                Text(meal.instructions),
                if (meal.youtube != null && meal.youtube!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text('YouTube: ${meal.youtube}', style: const TextStyle(color: Colors.blue)),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
