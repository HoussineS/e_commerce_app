import 'package:e_commerce_app/ui/Role_based_login/user/models/sub_category.dart';
import 'package:e_commerce_app/Core/utils/colors.dart';
import 'package:flutter/material.dart';

class SubCategorieWidget extends StatelessWidget {
  final SubCategory subCateg;
  const SubCategorieWidget({super.key, required this.subCateg});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () {},
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 15),
            margin: EdgeInsets.all(5),
            child: CircleAvatar(
              radius: 30,
              backgroundColor: fbackroudColor2,
              backgroundImage: AssetImage(subCateg.image),
            ),
          ),
        ),
        SizedBox(height: 4),
        Text(subCateg.name),
      ],
    );
  }
}
