import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/category_model.dart';
import '../models/meal_model.dart';

class ApiService {
  Future<List<Category>> getCategories() async {
    final response = await http.get(Uri.parse('https://www.themealdb.com/api/json/v1/1/categories.php'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List categories = data['categories'];
      return categories.map((json) => Category.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load categories');
    }
  }

  Future<List<Meal>> getMealsByCategory(String category) async {
    final response = await http.get(Uri.parse('https://www.themealdb.com/api/json/v1/1/filter.php?c=$category'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List meals = data['meals'];
      return meals.map((json) => Meal.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load meals');
    }
  }

  Future<List<Meal>> searchMeals(String query) async {
    final response = await http.get(Uri.parse('https://www.themealdb.com/api/json/v1/1/search.php?s=$query'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List? meals = data['meals'];
      if (meals == null) return [];
      return meals.map((json) => Meal.fromJson(json)).toList();
    } else {
      throw Exception('Failed to search meals');
    }
  }

  Future<MealDetail> getMealDetail(String id) async {
    final response = await http.get(Uri.parse('https://www.themealdb.com/api/json/v1/1/lookup.php?i=$id'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return MealDetail.fromJson(data['meals'][0]);
    } else {
      throw Exception('Failed to load meal details');
    }
  }

  Future<MealDetail> getRandomMeal() async {
    final response = await http.get(Uri.parse('https://www.themealdb.com/api/json/v1/1/random.php'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return MealDetail.fromJson(data['meals'][0]);
    } else {
      throw Exception('Failed to load random meal');
    }
  }
}
