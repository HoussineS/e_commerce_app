import 'package:flutter/material.dart';

Color getColorFromName(String colorName) {
  switch (colorName.toLowerCase()) {
    case 'red':
      return Colors.red;
    case 'green':
      return Colors.green;
    case 'pink':
      return Colors.pink;
    case 'bluegrey':
      return Colors.blueGrey;
    case 'blueaccent':
      return Colors.blueAccent;
    case 'blue':
      return Colors.blue;
    case 'black':
      return Colors.black;
    case 'white':
      return Colors.white;
    case 'yellow':
      return Colors.yellow;
    case 'orange':
      return Colors.orange;
    case 'purple':
      return Colors.purple;
    case 'brown':
      return Colors.brown;

    case 'cyan':
      return Colors.cyan;
    case 'teal':
      return Colors.teal;
    case 'lime':
      return Colors.lime;
    case 'indigo':
      return Colors.indigo;
    case 'amber':
      return Colors.amber;
    case 'deeporange':
      return Colors.deepOrange;
    case 'deeppurple':
      return Colors.deepPurple;
    case 'lightblue':
      return Colors.lightBlue;
    case 'lightgreen':
      return Colors.lightGreen;
    case 'grey':
      return Colors.grey;

    default:
      return Colors.blue[100]!; // Default if not recognized
  }
}

String colorToName(Color color) {
  switch (color) {
    case Colors.red:
      return 'red';
    case Colors.green:
      return 'green';
    case Colors.pink:
      return 'pink';
    case Colors.blueGrey:
      return 'bluegrey';
    case Colors.blueAccent:
      return 'blueaccent';
    case Colors.blue:
      return 'blue';
    case Colors.black:
      return 'black';
    case Colors.white:
      return 'white';
    case Colors.yellow:
      return 'yellow';
    case Colors.orange:
      return 'orange';
    case Colors.purple:
      return 'purple';
    case Colors.brown:
      return 'brown';
    case Colors.cyan:
      return 'cyan';
    case Colors.teal:
      return 'teal';
    case Colors.lime:
      return 'lime';
    case Colors.indigo:
      return 'indigo';
    case Colors.amber:
      return 'amber';
    case Colors.deepOrange:
      return 'deeporange';
    case Colors.deepPurple:
      return 'deeppurple';
    case Colors.lightBlue:
      return 'lightblue';
    case Colors.lightGreen:
      return 'lightgreen';
    case Colors.grey:
      return 'grey';
    default:
      return 'blue'; // Fallback
  }
}
