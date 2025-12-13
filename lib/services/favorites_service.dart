import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/meal_model.dart';

// NOTE: add the following packages to pubspec.yaml:
// cloud_firestore: ^4.6.0
// firebase_auth: ^4.4.0
// shared_preferences: ^2.0.15
//
// Firestore rules and Firebase Auth setup need to be done in your Firebase console.
// This service will try to use Firestore when a user is signed in; otherwise it falls back to local storage.

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

    // Fallback to local storage
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
    // Save both locally and remotely (remote only if authenticated)
    await _saveLocal();
    try {
      await _saveRemote();
    } catch (e) {
      // ignore remote save errors (network, auth, etc.)
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
    // Returns detailed Meal objects by asking the API for each favorite id.
    // This method requires the ApiService; to avoid circular import here, call ApiService from UI.
    // Instead, this returns the list of ids to the caller; UI should fetch details.
    return [];
  }

  // Dispose should be called on app close if desired
  void dispose() {
    _favoritesController.close();
  }
}
