import 'package:flutter/material.dart';
import '../models/meal_model.dart';
import '../screens/meal_detail_page.dart';
import '../services/favorites_service.dart';

class MealGrid extends StatefulWidget {
  final List<Meal> meals;
  const MealGrid({super.key, required this.meals});

  @override
  State<MealGrid> createState() => _MealGridState();
}

class _MealGridState extends State<MealGrid> {
  final FavoritesService _favorites = FavoritesService.instance;
  // cache of favorite ids to quickly reflect UI
  Set<String> _favoriteIds = {};

  @override
  void initState() {
    super.initState();
    // load favorites initially and listen for changes
    _favorites.favoritesStream.listen((ids) {
      setState(() {
        _favoriteIds = ids;
      });
    });
    _favorites.loadFavorites(); // ensure we have initial data
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: widget.meals.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
        childAspectRatio: 200 / 244,
      ),
      itemBuilder: (context, index) {
        final meal = widget.meals[index];
        final isFav = _favoriteIds.contains(meal.id);
        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MealDetailPage(mealId: meal.id),
            ),
          ),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(color: Colors.orange.shade300, width: 2),
            ),
            child: Stack(
              children: [
                Column(
                  children: [
                    Expanded(
                      child: Image.network(
                        meal.thumb,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
                      child: Text(meal.name, style: const TextStyle(fontSize: 16)),
                    ),
                  ],
                ),
                // Favorite button overlay (top-right)
                Positioned(
                  top: 6,
                  right: 6,
                  child: GestureDetector(
                    onTap: () async {
                      // toggle favorite and update UI
                      if (isFav) {
                        await _favorites.removeFavorite(meal.id);
                      } else {
                        await _favorites.addFavorite(meal);
                      }
                      // state will be updated by stream listener
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Icon(
                        isFav ? Icons.favorite : Icons.favorite_border,
                        color: isFav ? Colors.red : Colors.grey.shade700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
