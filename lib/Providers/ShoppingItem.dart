import 'package:flutter/foundation.dart';
import 'package:mealplanning/Providers/PantryItem.dart';
import 'Ingredient.dart';
import 'Meal.dart';

class ShoppingItem {
  final String id;
  String referenceId;
  Type referenceType;
  String description='';
  String name='';
  int servings =1;  
  bool found = false;
  double unitPrice=0.0;
  String servingUnit = 'Package';


  ShoppingItem({
    @required this.id,
    @required this.name = 'Something',
    this.referenceId = '',
    this.referenceType,
    this.description = '',
    this.servings=1,
    this.found = false,
    this.unitPrice = 0.0,
    this.servingUnit = 'Package',
    });

    Map toJson() {
    return {
      'id' : this.id,
      'name' : this.name,
      'referenceId' : this.referenceId,
      'referenceType' : this.referenceType.toString(),
      'description' : this.description,
      'servings' : this.servings.toString(),
      'found' : this.found.toString(),
      'packagePrice' : this.unitPrice.toString(),
      'servingUnits' : this.servingUnit,
    };
  }
  factory ShoppingItem.fromJson(Map<String, dynamic> json) {
     
      return new ShoppingItem(
        id:  json['id'], 
        name: json['name'],
        referenceId: json['referenceId'],
        referenceType: (json['referenceType'] == 'Meal') ? Meal : (json['referenceType'] == 'Ingredient') ? Ingredient : PantryItem,
        description: json['description'],
        servings:  int.parse(json['servings']),
        found: json['found'].toLowerCase() == 'true',
        unitPrice: double.parse(json['packagePrice']), 
        servingUnit: json['servingUnits'],
        );
    }
}



