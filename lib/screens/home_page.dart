import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../services/api_service.dart';
import '../widgets/category_card.dart';
import 'random_meal_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ApiService _api = ApiService();
  List<Category> _categories = [];
  List<Category> _filtered = [];
  bool _isLoading = true;
  String _searchQuery = '';
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  void _loadCategories() async {
    final categories = await _api.getCategories();
    setState(() {
      _categories = categories;
      _filtered = categories;
      _isLoading = false;
    });
  }

  void _filter(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filtered = _categories;
      } else {
        _filtered = _categories
            .where((c) => c.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0, // remove default padding so button is full width
        leadingWidth: 180, // make leading area wider
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white, // white background
              foregroundColor: Colors.black, // text color black
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RandomMealPage()),
              );
            },
            child: const Text(
              'Random Recipe',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        title: const Text('Recipe Categories'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Search categories...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: _filter,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filtered.length,
              itemBuilder: (context, index) => CategoryCard(
                category: _filtered[index],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
