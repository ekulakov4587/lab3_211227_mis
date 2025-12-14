import 'package:flutter/material.dart';
import '../services/favorites_service.dart';
import '../services/api_service.dart';
import '../models/meal_model.dart';
import '../widgets/meal_grid.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final FavoritesService _favorites = FavoritesService.instance;
  final ApiService _api = ApiService();
  Set<String> _favIds = {};
  List<Meal> _meals = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _favorites.favoritesStream.listen((ids) {
      _loadMealsFromIds(ids);
    });
    _favorites.loadFavorites();
  }

  Future<void> _loadMealsFromIds(Set<String> ids) async {
    setState(() {
      _isLoading = true;
      _favIds = ids;
      _meals = [];
    });

    final results = <Meal>[];
    for (final id in ids) {
      try {
        final detail = await _api.getMealDetail(id);
        results.add(Meal(id: detail.id, name: detail.name, thumb: detail.thumb));
      } catch (e) {
      }
    }

    setState(() {
      _meals = results;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _meals.isEmpty
          ? const Center(child: Text('No favorite recipes yet'))
          : Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: MealGrid(meals: _meals),
      ),
    );
  }
}
