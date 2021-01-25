import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'Ingredient.dart';
import 'Meal.dart';
import 'PantryItem.dart';

// final File defaultImage = new File('assets/food.png'); // doesn't work because not a constant

class MenuItem {
  final String id;
  String referenceId;
  Type referenceType;
  String adjective='';
  String name='';
  // String image = 'assets/food.png';
  String instructions ='';  
  double cost = 0.00;
  // File image = defaultImage;
  List<String> selectedIngredients = [];


  MenuItem({
    @required this.id,
    @required this.name = 'Missing',
    this.referenceId = '',
    this.referenceType = Ingredient,
    this.adjective = '',
    this.instructions ='',
    this.cost = 0.0,
    // this.image = 'assets/food.png',
    this.selectedIngredients,
    });

  Map toJson(){//print('MenuItem.toJson()');
    String ingredientIdList = (this.selectedIngredients != null && this.selectedIngredients.isNotEmpty) ? jsonEncode(this.selectedIngredients) : '';

    // print(ingredientIdList);
    // String imageEncoded = null;
    //   if(this.image != null){
    //     List<int> imageBytesList = this.image.readAsBytesSync();
    //     imageEncoded = base64Encode(imageBytesList);
    //       }

    return {
      'id' : this.id,
      'name' : this.name,
      'referenceId' : this.referenceId,
      'referenceType' : this.referenceType.toString(),
      'adjective' : this.adjective,
      'instructions' : this.instructions,
      'cost' : this.cost.toString(),
      // 'image' : this.image,
      'selectedIngredients' : ingredientIdList,
    };
  }
  factory MenuItem.fromJson(Map<String, dynamic> json) {//print('MenuItem.fromJson()');
    List<String> ingredientIdList = (json['selectedIngredients'] != null && json['selectedIngredients'] !='') ? List.from(jsonDecode(json['selectedIngredients'])) : [];


    // List<int> imageBytesList = (json['image'] != null && json['image'] !='') ? List.from(base64Decode(json['image'])) : [];
    // File imageFile = null;
    // if(imageBytesList.isNotEmpty) 
    // imageFile.writeAsBytesSync(imageBytesList);

    // print(json['id']);
    //  print(json['name']);
    //  print(json['referenceId']);
    //  print((json['referenceType'] == 'Meal') ? Meal : (json['referenceType'] == 'Ingredient') ? Ingredient : PantryItem);
    //  print(json['adjective']);
    //  print(json['instructions']);
    //  print(double.parse(json['cost']));
    //  print(json['image']);
    //  print(ingredientIdList);

    return new MenuItem(
      id:  json['id'], 
      name: json['name'],
      referenceId: json['referenceId'],
      referenceType: (json['referenceType'] == 'Meal') ? Meal : (json['referenceType'] == 'Ingredient') ? Ingredient : PantryItem,
      adjective: json['adjective'],
      instructions: json['instructions'],
      cost: double.parse(json['cost']), 
      // image: json['image'],
      selectedIngredients: ingredientIdList,
      );
  }
}



