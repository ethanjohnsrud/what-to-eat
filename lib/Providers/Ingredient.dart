import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:flutter/foundation.dart';

// final File defaultImage = new File('assets/food.png'); // doesn't work because not a constant

class Ingredient {
  final String id;
  String name='';
  String adjective='';

  // String image = 'assets/images/food.png';
  // File image = defaultImage;
  // String brand = '';
  List<String> recommendationTypes = ['Regular'];
  Map<String, double> servingsPerUnit = {'Package' : 1.0};

  int popularityCount = 0;
  DateTime recentDate;

  bool meat = false;
  bool carb = false;
  bool veg = false;
  bool fruit = false;
  bool snack = false;

  // double servingsPerPackage = 1.0;
  // double packagePrice = 0.0;
  // List<double> storePackagePrices = [];
  List<String> matchingItems = [];

  Ingredient({
    @required this.id,
    @required this.name = '',
    this.adjective = '',
    // this.image = 'assets/images/food.png',
    this.recommendationTypes,
    @required this.popularityCount,
    @required this.recentDate,
    this.meat  = false,
    this.carb  = false,
    this.veg  = false,
    this.fruit  = false,
    this.snack = false,
    // this.servingsPerPackage = 1.0,
    this.servingsPerUnit,
    this.matchingItems,
    // this.storePackagePrices,
    }){
      if(this.recommendationTypes == null) recommendationTypes = ['Regular'];
      if(this.servingsPerUnit == null) servingsPerUnit = {'Package' : 1};
      if(this.matchingItems == null) matchingItems = [];
      // if(this.storePackagePrices == null) storePackagePrices = [];
      // print('$name : ${recommendationTypes.toString()}');
    }

    // double get cost {
    //   if(this.storePackagePrices !=null && this.storePackagePrices.isNotEmpty)
    //     try{double sumPackagePrices = 0.0;
    //       this.storePackagePrices.forEach((element) {sumPackagePrices+=element;});
    //       return (sumPackagePrices/(this.storePackagePrices.length as double))/this.servingsPerPackage;}
    //     catch(error) {return 0.0;}
    //   else return 0.0;
    // }

  Map toJson(){
    // String imageEncoded = null;
    //   if(this.image != null){
    //     List<int> imageBytesList = this.image.readAsBytesSync();
    //     imageEncoded = base64Encode(imageBytesList);
    //       }
    String recommendationList = (this.recommendationTypes != null && this.recommendationTypes.isNotEmpty) ? jsonEncode(this.recommendationTypes) : '';
    // String priceList = (this.storePackagePrices != null && this.storePackagePrices.isNotEmpty) ? jsonEncode(this.storePackagePrices) : '';
    String matchingItemsList = (this.matchingItems != null && this.matchingItems.isNotEmpty) ? jsonEncode(this.matchingItems) : '';

    return {
      'id' : this.id,
      'name' : this.name,
      'adjective' : this.adjective,
      'recommendationTypes' : recommendationList,
      // 'image' : this.image,
      'popularityCount' : this.popularityCount.toString(),
      'recentDate' : this.recentDate.toString(),
      'meat' : this.meat.toString(),
      'carb' : this.carb.toString(),
      'veg' : this.veg.toString(),
      'fruit' : this.fruit.toString(),
      'snack' : this.snack.toString(),
      // 'servingsPerPackage' : this.servingsPerPackage.toString(),
      'servingsPerUnit' : jsonEncode(this.servingsPerUnit),
      'matchingItems' : matchingItemsList,
      // 'storePackagePrices' : priceList,

    };
  }
  factory Ingredient.fromJson(Map<String, dynamic> json) {
    // List<int> imageBytesList = (json['image'] != null && json['image'] !='') ? List.from(base64Decode(json['image'])) : [];
    // File imageFile = null;
    // if(imageBytesList.isNotEmpty) 
    // imageFile.writeAsBytesSync(imageBytesList);

    List<String> recommendationList = (json['recommendationTypes'] != null && json['recommendationTypes'] !='') ? List.from(jsonDecode(json['recommendationTypes'])) : [];
    // List<double> priceList = (json['storePackagePrices'] != null && json['storePackagePrices'] !='') ? List.from(jsonDecode(json['storePackagePrices'])) : [];
    List<String> matchingItemsList = (json['matchingItems'] != null && json['matchingItems'] !='') ? List.from(jsonDecode(json['matchingItems'])) : [];
    Map<String, double>  servingsMap = (json['servingsPerUnit'] != null && json['servingsPerUnit'] !='') ? Map<String, double>.from(jsonDecode(json['servingsPerUnit'])) : {};

      return new Ingredient(
        id:  json['id'], 
        name: json['name'],
        adjective: json['adjective'],
        recommendationTypes: recommendationList,
        // image: json['image'],
        popularityCount: int.parse(json['popularityCount']),
        recentDate: DateTime.parse(json['recentDate']),
        meat: json['meat'].toLowerCase() == 'true',
        carb: json['carb'].toLowerCase() == 'true',
        veg: json['veg'].toLowerCase() == 'true',
        fruit: json['fruit'].toLowerCase() == 'true',
        snack: json['snack'].toLowerCase() == 'true',
        // servingsPerPackage: double.parse(json['servingsPerPackage']),
        servingsPerUnit: servingsMap,
        matchingItems: matchingItemsList,
        // storePackagePrices: priceList, 
        );
    }
}


// class IngredientProvider with ChangeNotifier {
//   void setIngredientName(Ingredient ingredient, String name) {ingredient.name=name; } //don't call nottifyListeners() when using TextEditingController(), which has its own listener
//   void setIngredientAdjective(Ingredient ingredient, String adjective) {ingredient.adjective=adjective; }
//   void setIngredientImage(Ingredient ingredient, String image) {ingredient.image=image; }
//   void setRecommendationMealType(Ingredient ingredient, String type) {ingredient.recommendationType=type; notifyListeners();}
//   void increaseIngredientPopularityCount(Ingredient ingredient, {bool update}) {ingredient.popularityCount +=1; if(update) notifyListeners();}
//   void decreaseIngredientPopularityCount(Ingredient ingredient, {bool update = true}) {if(ingredient.popularityCount!=0) ingredient.popularityCount -=1; if(update) notifyListeners();}
//   void increaseIngredientRecentDate(Ingredient ingredient, {bool update = true}) {ingredient.recentDate=ingredient.recentDate.add(new Duration(days: 1)); if(update) notifyListeners();}
//   void decreaseIngredientRecentDate(Ingredient ingredient, {bool update = true}) {ingredient.recentDate=ingredient.recentDate.subtract(new Duration(days: 1)); if(update) notifyListeners();}
//   void setIngredientRecentDatePresent(Ingredient ingredient, {bool update = true}) {ingredient.recentDate=DateTime.now(); if(update) notifyListeners();}
//   void toggleIngredientMeat(Ingredient ingredient) {ingredient.meat =! ingredient.meat; notifyListeners();}
//   void toggleIngredientCarb(Ingredient ingredient) {ingredient.carb =! ingredient.carb; notifyListeners();}
//   void toggleIngredientVeg(Ingredient ingredient) {ingredient.veg =! ingredient.veg; notifyListeners();}
//   void toggleIngredientFruit(Ingredient ingredient) {ingredient.fruit =! ingredient.fruit; notifyListeners();}
//   void toggleIngredientSnack(Ingredient ingredient) {ingredient.snack =! ingredient.snack; notifyListeners();}
//   void toggleIngredientPackable(Ingredient ingredient) {ingredient.packable =! ingredient.packable; notifyListeners();}
//   void toggleIngredientEatAsMeal(Ingredient ingredient) {ingredient.cookingIngredient =! ingredient.cookingIngredient; notifyListeners();}
//   void setIngredientServingsPerPackage(Ingredient ingredient, double servings) {ingredient.servingsPerPackage=servings; }
//   void setIngredientPackagePrice(Ingredient ingredient, double price) {ingredient.packagePrice=price;}
// }

