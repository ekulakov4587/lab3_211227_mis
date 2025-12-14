import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/meal_model.dart';

class FavoritesService {
  FavoritesService._internal();
  static final FavoritesService instance = FavoritesService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final StreamController<Set<String>> _favoritesController =
  StreamController<Set<String>>.broadcast();

  Set<String> _favorites = {};

  Stream<Set<String>> get favoritesStream => _favoritesController.stream;

  Future<void> loadFavorites() async {
    // Try to load from Firestore if we have a logged-in user
    final user = _auth.currentUser;
    if (user != null) {
      try {
        final doc = await _firestore.collection('favorites').doc(user.uid).get();
        if (doc.exists) {
          final data = doc.data();
          final List<dynamic>? ids = data?['mealIds'] as List<dynamic>?;
          _favorites = ids != null ? ids.map((e) => e.toString()).toSet() : {};
          _favoritesController.add(_favorites);
          return;
        }
      } catch (e) {
        // ignore and fallback to local storage
      }
    }

    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('favorites') ?? [];
    _favorites = saved.toSet();
    _favoritesController.add(_favorites);
  }

  Future<void> _saveLocal() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favorites', _favorites.toList());
    _favoritesController.add(_favorites);
  }

  Future<void> _saveRemote() async {
    final user = _auth.currentUser;
    if (user == null) return;
    await _firestore.collection('favorites').doc(user.uid).set({
      'mealIds': _favorites.toList(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    _favoritesController.add(_favorites);
  }

  Future<bool> isFavorite(String mealId) async {
    if (_favorites.isEmpty) {
      await loadFavorites();
    }
    return _favorites.contains(mealId);
  }

  Future<void> addFavorite(Meal meal) async {
    _favorites.add(meal.id);
    await _saveLocal();
    try {
      await _saveRemote();
    } catch (e) {
    }
    _favoritesController.add(_favorites);
  }

  Future<void> removeFavorite(String mealId) async {
    _favorites.remove(mealId);
    await _saveLocal();
    try {
      await _saveRemote();
    } catch (e) {
      // ignore remote save errors
    }
    _favoritesController.add(_favorites);
  }

  Future<List<Meal>> getFavoriteMeals() async {
    return [];
  }

  void dispose() {
    _favoritesController.close();
  }
}
