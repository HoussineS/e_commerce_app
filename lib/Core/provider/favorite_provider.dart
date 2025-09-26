import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FavoriteProvider extends ChangeNotifier {
  List<String> _favProductsId = [];
  final _fireStore = FirebaseFirestore.instance;
  final userId = FirebaseAuth.instance.currentUser!.uid;
  //getter
  List<String> get favProductsId => _favProductsId;
  void rest() {
    _favProductsId = [];
  }

  FavoriteProvider() {
    loadFav();
  }
  void tooglefavorite(String productId) async {
    if (_favProductsId.contains(productId)) {
      _favProductsId.remove(productId);
      await _removeFavorite(productId); // remove from fav
    } else {
      _favProductsId.add(productId);
      await _addFavorite(productId); // add to fav
    }
    notifyListeners();
  }

  //check if product is fav
  bool isFav(String productId) {
    return _favProductsId.contains(productId);
  }

  //add produt to fav
  Future<void> _addFavorite(String productId) async {
    try {
      await _fireStore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .doc(productId)
          .set({'isFavorite': true, 'productId': productId});
    } catch (e) {
      throw (e.toString());
    }
  }

  //remove produt from fav
  Future<void> _removeFavorite(String productId) async {
    try {
      await _fireStore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .doc(productId)
          .delete();
    } catch (e) {
      throw (e.toString());
    }
  }

  Future<void> loadFav() async {
    try {
      final data = await _fireStore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .get();
      if (data.docs.isNotEmpty) {
        _favProductsId = data.docs.map((doc) => doc.id).toList();
      }
    } catch (e) {
      throw (e.toString());
    }
    notifyListeners();
  }
}

final favProvider = ChangeNotifierProvider<FavoriteProvider>(
  (ref) => FavoriteProvider(),
);
