import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_commerce_app/ui/Role_based_login/admin/models/add_items_models.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final addItemProvier = StateNotifierProvider<AddItemNotifier, AddItemState>((
  ref,
) {
  return AddItemNotifier();
});

class AddItemNotifier extends StateNotifier<AddItemState> {
  AddItemNotifier() : super(AddItemState());
  //take items collection form fierstore
  final itemsCollection = FirebaseFirestore.instance.collection('items');
  //categoreie
  final supabaseInstane = Supabase.instance.client;
  void reload() {
    state = state;
  }

  Future<String?> pickImage() async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
      );
      return pickedFile?.path;
      // if (pickedFile != null) {
      //   state = state.copyWith(imagePath: pickedFile.path);
      // }
    } catch (e) {
      //
      return null;
    }
  }

  void setImage(String? imagePath) {
    if (imagePath != null) {
      state = state.copyWith(imagePath: imagePath);
    }
  }

  void setSelectedCategory(String? categ) {
    if (categ != null) {
      state = state.copyWith(selectedCategory: categ);
    }
  }

  //for size
  void addSize(String? size) {
    if (size != null) {
      state = state.copyWith(sizes: [...state.sizes, size]);
    }
  }

  void removeSize(String? size) {
    if (size != null) {
      state = state.copyWith(
        sizes: state.sizes.where((s) => s != size).toList(),
      );
    }
  }

  //for color
  void addColor(String? color) {
    if (color != null) {
      state = state.copyWith(colors: [...state.colors, color]);
    }
  }

  void removeColor(String? color) {
    if (color != null) {
      state = state.copyWith(
        colors: state.colors.where((s) => s != color).toList(),
      );
    }
  }

  // for discount
  void toogleDiscount(bool? isDiscounted) {
    state = state.copyWith(isDiscounted: isDiscounted);
  }

  void setDiscountPersent(String percentage) {
    state = state.copyWith(
      discountPercentage: state.isDiscounted ? percentage : null,
    );
  }

  // for loading
  void setLoading(bool isLoading) {
    state = state.copyWith(isLoading: isLoading);
  }

  Future<void> fetchCategorie() async {
    try {
      final snapshot = await supabaseInstane.from('category').select();
      List<String> categories = snapshot
          .map((categ) => categ['name'] as String)
          .toList();
      state = state.copyWith(categories: categories);
    } catch (e) {
      //
      throw Exception('❌ Erore en fetch categorie $e');
    }
  }

  Future<void> uploadAndSaveItem(
    String name,
    String price,
    String imagePath,
  ) async {
    state = state.copyWith(isLoading: true);
    try {
     
      final file = File(
        imagePath,
      ); // You must get this from `ImagePicker`, etc.
      final bytes = await file.readAsBytes();
      //get image extetion
      final imageExtention = file.path.split('.').last.toLowerCase();
      //image unique name
      final fileName =
          '${DateTime.now().microsecondsSinceEpoch}.$imageExtention';
      await supabaseInstane.storage
          .from('itemimage')
          .uploadBinary(fileName, bytes);
      final imageUrl = supabaseInstane.storage
          .from('itemimage')
          .getPublicUrl(fileName);
      // print("imageUrl $imageUrl");

      //save item to firestroe
      String uuid = FirebaseAuth.instance.currentUser!.uid;
      //this use to verifier
      // print('uuid: $uuid');
      // print('name: $name');
      // print('price: $price');
      // print('state.selectedCategory: ${state.selectedCategory}');
      // print('state.sizes ${state.sizes}');
      // print('state.discountPercentage: ${state.discountPercentage}');
      itemsCollection.add({
        'name': name,
        'price': price,
        'imageUrl': imageUrl,
        'uploadedBy': uuid,
        'category': state.selectedCategory,
        'sizes': state.sizes,
        'colors': state.colors,
        'isDiscounted': state.isDiscounted,
        'percentageDiscount': state.isDiscounted
            ? double.tryParse(state.discountPercentage!)
            : 0,
      });
      // restar the app
      state = AddItemState();
    } catch (e) {
      throw Exception('❌ Erore en upload item $e');
    } finally {
      //finish loading
      state = state.copyWith(isLoading: false);
    }
  }
}
