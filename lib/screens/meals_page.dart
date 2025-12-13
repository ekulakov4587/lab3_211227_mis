import 'package:flutter/material.dart';
import '../models/meal_model.dart';
import '../services/api_service.dart';
import '../widgets/meal_grid.dart';

class MealsPage extends StatefulWidget {
  final String category;
  const MealsPage({super.key, required this.category});

  @override
  State<MealsPage> createState() => _MealsPageState();
}

class _MealsPageState extends State<MealsPage> {
  final ApiService _api = ApiService();
  List<Meal> _meals = [];
  List<Meal> _filtered = [];
  bool _isLoading = true;
  String _searchQuery = '';
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMeals();
  }

  void _loadMeals() async {
    final meals = await _api.getMealsByCategory(widget.category);
    setState(() {
      _meals = meals;
      _filtered = meals;
      _isLoading = false;
    });
  }

  void _search(String query) async {
    setState(() { _searchQuery = query; });
    if (query.isEmpty) {
      setState(() { _filtered = _meals; });
    } else {
      final results = await _api.searchMeals(query);
      setState(() { _filtered = results; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.category)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Search meals...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onChanged: _search,
            ),
          ),
          Expanded(child: MealGrid(meals: _filtered)),
        ],
      ),
    );
  }
}
