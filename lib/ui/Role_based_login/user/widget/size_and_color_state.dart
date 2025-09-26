import 'package:e_commerce_app/Core/models/screen_config.dart';
import 'package:flutter/material.dart';

class SizeAndColorState extends StatefulWidget {
  final List<Color> colors;
  final List<String> sizes;
  final int selectedColorIndex;
  final int selectedSizeIndex;
  final Function(int) onColorsSelected;
  final Function(int) onSizeSelected;
  const SizeAndColorState({
    super.key,
    required this.colors,
    required this.sizes,
    required this.onColorsSelected,
    required this.onSizeSelected,
    required this.selectedColorIndex,
    required this.selectedSizeIndex,
  });

  @override
  State<SizeAndColorState> createState() => _SizeAndColorStateState();
}

class _SizeAndColorStateState extends State<SizeAndColorState> {
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //FOR COLORS
        SizedBox(
          width: ScreenConfig.screenWidth / 2.4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Colors',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: widget.colors.asMap().entries.map((e) {
                    final index = e.key;
                    final color = e.value;
                    return Padding(
                      padding: EdgeInsetsGeometry.all(8),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: color == Colors.white
                                ? Colors.black12
                                : Colors.transparent,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: color,
                          child: InkWell(
                            onTap: () {
                              widget.onColorsSelected(index);
                            },
                            child: Icon(
                              Icons.check,
                              color: widget.selectedColorIndex == index
                                  ? color == Colors.white
                                        ? Colors.black
                                        : Colors.white
                                  : Colors.transparent,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          width: ScreenConfig.screenWidth / 2.4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //FOR Size
              Text(
                'Size',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: widget.sizes.asMap().entries.map((e) {
                    final index = e.key;
                    final size = e.value;
                    return GestureDetector(
                      onTap: () {
                        widget.onSizeSelected(index);
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 10, top: 5),
                        padding: EdgeInsets.all(8),
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: widget.selectedSizeIndex == index
                                ? Colors.black
                                : Colors.black12,
                          ),
                          shape: BoxShape.circle,
                          color: widget.selectedSizeIndex == index
                              ? Colors.black
                              : Colors.white,
                        ),
                        child: Center(
                          child: Text(
                            size,
                            style: TextStyle(
                              color: widget.selectedSizeIndex == index
                                  ? Colors.white
                                  : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
