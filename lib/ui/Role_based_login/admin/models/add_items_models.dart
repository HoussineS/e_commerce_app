class AddItemState {
  final String? imagePath;
  final bool isLoading;
  final String? selectedCategory;
  final List<String> categories;
  final List<String> sizes;
  final List<String> colors;
  final bool isDiscounted;
  final String? discountPercentage;

  // Constructor
  AddItemState({
    this.imagePath,
    this.isLoading = false,
    this.selectedCategory,
    this.categories = const [],
    this.sizes = const [],
    this.colors = const [],
    this.isDiscounted = false,
    this.discountPercentage,
  });

  // CopyWith method
  AddItemState copyWith({
    String? imagePath,
    bool? isLoading,
    String? selectedCategory,
    List<String>? categories,
    List<String>? sizes,
    List<String>? colors,
    bool? isDiscounted,
    String? discountPercentage,
  }) {
    return AddItemState(
      imagePath: imagePath ?? this.imagePath,
      isLoading: isLoading ?? this.isLoading,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      categories: categories ?? this.categories,
      sizes: sizes ?? this.sizes,
      colors: colors ?? this.colors,
      isDiscounted: isDiscounted ?? this.isDiscounted,
      discountPercentage: discountPercentage ?? this.discountPercentage,
    );
  }
}
