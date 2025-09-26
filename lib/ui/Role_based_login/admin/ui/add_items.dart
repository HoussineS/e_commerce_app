// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:e_commerce_app/Core/models/screen_config.dart';
import 'package:e_commerce_app/ui/Role_based_login/admin/controller/add_item_controller.dart';
import 'package:e_commerce_app/ui/Role_based_login/admin/ui/admin_main_screen.dart';
import 'package:e_commerce_app/widget/my_button.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddItems extends ConsumerStatefulWidget {
  const AddItems({super.key});

  @override
  ConsumerState<AddItems> createState() => _AddItemsState();
}

class _AddItemsState extends ConsumerState<AddItems> {
  // Controllers to maintain field state
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _sizeController = TextEditingController();
  final TextEditingController _colorsController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool isDiscounted = false;
  String? itemImage;
  String? itemCategory;
  String errorMeasseg = '';

  Future<void> submitData() async {
    final notifier = ref.read(addItemProvier.notifier);
    

    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Check image path
    if (itemImage == null || itemImage!.isEmpty) {
      setState(() {
        errorMeasseg = 'image is required';
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please select an image')));
      return;
    }

    _formKey.currentState!.save();

    // Start loading
    notifier.setLoading(true);
    //set the image
    notifier.setImage(itemImage);
    // Add sizes and colors to notifier state
    final sizes = _sizeController.text
        .split(',')
        .map((e) => e.trim())
        .where((size) => size.isNotEmpty)
        .toList();
    final colors = _colorsController.text
        .split(',')
        .map((e) => e.trim())
        .where((color) => color.isNotEmpty)
        .toList();

    notifier.setSelectedCategory(itemCategory);

    // Clear old sizes/colors before adding new ones
    // (You may want to add clear methods in your notifier)
    for (var size in sizes) {
      notifier.addSize(size);
    }
    for (var color in colors) {
      notifier.addColor(color);
    }

    if (isDiscounted) {
      notifier.toogleDiscount(true);
      notifier.setDiscountPersent(_discountController.text);
    } else {
      notifier.toogleDiscount(false);
    }

    try {
      print(itemImage);
      await notifier.uploadAndSaveItem(
        _nameController.text,
        _priceController.text,
        itemImage!,
      );

      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => AdminMainScreen()));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(seconds: 2),
          content: Text(
            'item add successfuly',
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.greenAccent,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(seconds: 3),
          content: Text('Server error, please try later'),
        ),
      );
      print('❌ $e');
    } finally {
      notifier.setLoading(false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _sizeController.dispose();
    _colorsController.dispose();
    _discountController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(addItemProvier);
    final notifier = ref.read(addItemProvier.notifier);
    notifier.fetchCategorie();
    final realHeight = ScreenConfig.screenRealHeight;
    final width = ScreenConfig.screenWidth;

    return Scaffold(
      appBar: AppBar(centerTitle: true, title: Text("Add item")),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: itemImage == null
                                ? null
                                : () {
                                    setState(() {
                                      itemImage = null;
                                    });
                                  },
                            icon: Icon(Icons.restart_alt),
                          ),
                          Container(
                            height: realHeight * 0.2,
                            width: width * 0.4,
                            decoration: BoxDecoration(
                              border: Border.all(),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: itemImage != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      File(itemImage!),
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : state.isLoading
                                ? CircularProgressIndicator()
                                : GestureDetector(
                                    onTap: () async {
                                      itemImage = await notifier.pickImage();
                                    },
                                    child: Icon(Icons.camera_alt),
                                  ),
                          ),
                        ],
                      ),

                      SizedBox(height: 5),
                      if (itemImage == null)
                        Text(
                          errorMeasseg,
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                    ],
                  ),
                ),

                SizedBox(height: realHeight * 0.01),

                // Item name
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: "Item name",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Name is required';
                    }
                    return null;
                  },
                ),

                SizedBox(height: realHeight * 0.01),

                // Price
                TextFormField(
                  controller: _priceController,
                  decoration: InputDecoration(
                    labelText: 'Price',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Price is required';
                    } else if (double.tryParse(value) == null) {
                      return 'Price must be a number';
                    }
                    return null;
                  },
                ),

                SizedBox(height: realHeight * 0.01),

                // Size
                TextFormField(
                  controller: _sizeController,
                  decoration: InputDecoration(
                    labelText: 'Size (comma separated)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    // ✅ If chips already have sizes, skip text validation
                    if (state.sizes.isNotEmpty) return null;

                    // If no chip sizes, validate text input
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter at least one size';
                    }

                    final parts = value
                        .split(',')
                        .map((e) => e.trim())
                        .where((element) => element.isNotEmpty)
                        .toList();

                    for (var part in parts) {
                      if (part.isEmpty) {
                        return 'Empty size found between commas';
                      }
                      if (!RegExp(r'^[a-zA-Z]+$').hasMatch(part)) {
                        return 'Invalid size: "$part"';
                      }
                    }
                    return null;
                  },
                  onFieldSubmitted: (value) {
                    final parts = value
                        .split(',')
                        .map((e) => e.trim())
                        .toList();
                    for (var part in parts) {
                      if (part.isNotEmpty &&
                          RegExp(r'^[a-zA-Z]+$').hasMatch(part)) {
                        notifier.addSize(part);
                      }
                    }
                    _sizeController
                        .clear(); // ✅ Clear field after adding to chips
                  },
                ),
                Wrap(
                  spacing: 8,
                  children: state.sizes
                      .map(
                        (size) => Chip(
                          label: Text(size),
                          onDeleted: () => notifier.removeSize(size),
                        ),
                      )
                      .toList(),
                ),

                SizedBox(height: realHeight * 0.01),

                // Colors
                TextFormField(
                  controller: _colorsController,
                  decoration: InputDecoration(
                    labelText: 'Colors (comma separated)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (state.colors.isNotEmpty) return null;
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter at least one color';
                    }

                    final parts = value
                        .split(',')
                        .map((e) => e.trim())
                        .where((element) => element.isNotEmpty)
                        .toList();

                    for (var part in parts) {
                      if (part.isEmpty) {
                        return 'Empty color found between commas';
                      }
                      if (!RegExp(r'^[a-zA-Z\s-]+$').hasMatch(part)) {
                        return 'Invalid color: "$part"';
                      }
                    }
                    return null;
                  },
                  onFieldSubmitted: (value) {
                    final parts = value
                        .split(',')
                        .map((e) => e.trim())
                        .toList();

                    for (var part in parts) {
                      if (part.isEmpty) {
                        return;
                      }
                      if (RegExp(r'^[a-zA-Z\s-]+$').hasMatch(part)) {
                        notifier.addColor(part);
                        _colorsController.clear();
                      }
                    }
                  },
                ),
                Wrap(
                  children: state.colors
                      .map(
                        (color) => Chip(
                          label: Text(color),
                          onDeleted: () => notifier.removeColor(color),
                        ),
                      )
                      .toList(),
                ),

                Row(
                  children: [
                    Checkbox(
                      value: isDiscounted,
                      onChanged: (value) {
                        setState(() {
                          isDiscounted = value ?? false;
                        });
                      },
                    ),
                    const Text('Apply discount'),
                  ],
                ),

                if (isDiscounted) SizedBox(height: realHeight * 0.01),

                if (isDiscounted)
                  TextFormField(
                    controller: _discountController,
                    decoration: InputDecoration(
                      labelText: 'Percentage discount',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final val = double.tryParse(value);
                        if (val == null) {
                          return 'Percentage discount should be a number';
                        } else if (val > 100 || val < 1) {
                          return 'Percentage discount should be between 1 and 100';
                        }
                      }
                      return null;
                    },
                  ),

                SizedBox(height: realHeight * 0.01),

                // Category dropdown
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Categories',
                    border: OutlineInputBorder(),
                  ),
                  value: itemCategory,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Category is required';
                    }
                    return null;
                  },
                  items: state.categories
                      .map(
                        (categ) =>
                            DropdownMenuItem(value: categ, child: Text(categ)),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      itemCategory = value;
                    });
                  },
                ),

                SizedBox(height: realHeight * 0.01),

                Center(
                  child: state.isLoading
                      ? CircularProgressIndicator()
                      : MyButton(onTab: submitData, text: 'Save item'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
