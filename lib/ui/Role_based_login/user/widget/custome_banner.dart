import 'package:e_commerce_app/Core/models/screen_config.dart';
import 'package:e_commerce_app/Core/utils/colors.dart';
import 'package:flutter/material.dart';

class CustomeBanner extends StatelessWidget {
  const CustomeBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: ScreenConfig.screenHeight * 0.23,
      width: ScreenConfig.screenWidth,
      color: bannerColor,
      padding: EdgeInsets.only(),
      child: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'New collection',
                  style: TextStyle(
                    fontSize: 20,
                    letterSpacing: -1,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      '20',
                      style: TextStyle(
                        fontSize: 40,
                        height: 0,
                        letterSpacing: -3,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Column(
                      children: [
                        Text(
                          '%',
                          style: TextStyle(fontWeight: FontWeight.w900),
                        ),
                        Text(
                          'OFF',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -2,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                MaterialButton(
                  onPressed: () {},
                  color: Colors.black,
                  child: Text(
                    'SHOP NOW',
                    style: TextStyle(fontSize: 12, color: Colors.white),
                  ),
                ),
              ],
            ),

            Align(
              alignment: Alignment.bottomRight,
              child: Image.asset(
                'assets/images/girl.png',
                height: ScreenConfig.screenHeight * 0.3,
                // width: ScreenConfig.screenWidth * 0.45,
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
