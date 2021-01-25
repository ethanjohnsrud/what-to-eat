import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// final File defaultImage = new File('assets/food.png'); // doesn't work because not a constant

class Meal {
  final String id;
  String name='';
  String adjective='';

  // String image = 'assets/food.png';
  // File image = defaultImage;
  String recipe ='';

  int popularityCount = 0;
  DateTime recentDate;

  List<String> essentialIngredients = [];
  List<List<String>> alternativeIngredients = [];
  List<String> extraIngredients = [];

  List<String> recommendationTypes = ['Regular'];
  Map<String, double> servingsPerUnit = {'Package' : 1.0};
  // List<double> storePackagePrices = [];
  List<String> matchingItems = [];

  Meal({
    @required this.id,
    @required this.name = '',
    this.adjective ='',
    // this.image= 'assets/food.png',
    this.recipe ='',
    @required this.popularityCount,
    @required this.recentDate,
    this.recommendationTypes,
    // this.storePackagePrices,
    this.servingsPerUnit,
    this.matchingItems,
    this.essentialIngredients,
    this.alternativeIngredients,
    this.extraIngredients,
    }) {
      if(this.recommendationTypes == null) recommendationTypes = ['Regular'];
      if(this.servingsPerUnit == null) servingsPerUnit = {'Package' : 1};
      // if(this.storePackagePrices == null) storePackagePrices = [];
      if(this.essentialIngredients == null) essentialIngredients = [];
      if(this.alternativeIngredients == null) alternativeIngredients = [];
      if(this.extraIngredients == null) extraIngredients = [];
      if(this.matchingItems == null) matchingItems = [];
      // print('$name : ${recommendationTypes.toString()}');

      // if(essentialIngredientsList != null && essentialIngredientsList != []) essentialIngredientsList.forEach((i)=>this.addEssentialIngredient(i));
      // if(alternativeIngredientsList != null && alternativeIngredientsList != []) alternativeIngredientsList.forEach((i)=>this.addAlternativeIngredient(i));
      // if(extraIngredientsList != null && extraIngredientsList != []) extraIngredientsList.forEach((i)=>this.addExtraIngredient(i));
    }

    // List<String> get essentialIngredients {return [..._essentialIngredients];}  
    // List<List<String>> get alternativeIngredients {return [..._alternativeIngredients];} 
    // List<String> get extraIngredients {return [..._extraIngredients];} 

  void addEssentialIngredient(String i){this.removeIngredient(i); essentialIngredients.add(i);}
  void addAlternativeIngredient(List<String> list){ if(list != null) list.forEach((i) {this.removeIngredient(i);});
  if(alternativeIngredients == null) this.alternativeIngredients = [];  alternativeIngredients.add(list);}
  void addExtraIngredient(String i){this.removeIngredient(i);  extraIngredients.add(i);}

  void removeIngredient(String i){
    if(this.essentialIngredients != null) essentialIngredients.remove(i);
    if(this.alternativeIngredients != null) 
      for(var x=0; x<alternativeIngredients.length; x++)
        {alternativeIngredients[x].remove(i);
          if(alternativeIngredients[x].length<=1){
            alternativeIngredients.remove(alternativeIngredients[x]);
            x++;
            // break;
          }
        }
    // if(alternativeIngredients != null) alternativeIngredients.forEach((list) {list.remove(i);});  //Can't 
    if(this.extraIngredients != null) extraIngredients.remove(i);    
    }

  void clearAllIngredients() {
  if(this.essentialIngredients != null) 
  this.essentialIngredients.clear();
  if(this.alternativeIngredients != null) 
  this.alternativeIngredients.clear();
  if(this.extraIngredients != null) 
  this.extraIngredients.clear();
  print('-Cleared Meals');
  }

  bool hasIngredients() {
    bool found = false;
    if(this.essentialIngredients != null && this.essentialIngredients.isNotEmpty) found = true;
    if(this.alternativeIngredients != null && this.alternativeIngredients.isNotEmpty) found = true;
    if(this.extraIngredients != null && this.extraIngredients.isNotEmpty) found = true;
    return found;
  }
  int totalIngredients() {
    int count = 0;
    if(this.essentialIngredients != null && this.essentialIngredients.isNotEmpty) count += this.essentialIngredients.length;
    if(this.alternativeIngredients != null && this.alternativeIngredients.isNotEmpty)  
      this.alternativeIngredients.forEach((list) {if(list != null && list.isNotEmpty) count += list.length;});
    if(this.extraIngredients != null && this.extraIngredients.isNotEmpty)  count += this.extraIngredients.length;
    return count;
  }

    Map toJson() {//print('Meal.toJson()');
      String essentialList = (this.essentialIngredients != null && this.essentialIngredients.isNotEmpty) ? jsonEncode(this.essentialIngredients) : '';
      String alternativeList = '';
      if(this.alternativeIngredients != null && this.alternativeIngredients.isNotEmpty){ //convert to single string
        List<String> subList = alternativeIngredients.map((list)=>jsonEncode(list)).toList();
          // print(subList);
        alternativeList = jsonEncode(subList);
          // print(alternativeList);
      }
      String extraList = (this.extraIngredients != null && this.extraIngredients.isNotEmpty) ? jsonEncode(this.extraIngredients) : '';

      // String imageEncoded = null;
      // if(this.image != null){
      //   List<int> imageBytesList = this.image.readAsBytesSync();
      // imageEncoded = base64Encode(imageBytesList);
      //   }

      String recommendationList = (this.recommendationTypes != null && this.recommendationTypes.isNotEmpty) ? jsonEncode(this.recommendationTypes) : '';
      // String priceList = (this.storePackagePrices != null && this.storePackagePrices.isNotEmpty) ? jsonEncode(this.storePackagePrices) : '';
      String matchingItemsList = (this.matchingItems != null && this.matchingItems.isNotEmpty) ? jsonEncode(this.matchingItems) : '';
      
      return {
        'id' : this.id,
        'name' : this.name,
        'adjective' : this.adjective,
        // 'image' : this.image,
        'recipe' : this.recipe,
        'popularityCount' : this.popularityCount.toString(),
        'recentDate' : this.recentDate.toString(),
        'recommendationTypes' : recommendationList,
        'matchingItems' : matchingItemsList,
        // 'storePackagePrices' : priceList,
        'servingsPerUnit' : jsonEncode(this.servingsPerUnit),
        'essentialIngredients' : essentialList,
        'alternativeIngredients' : alternativeList,
        'extraIngredients' : extraList,
      };
    }
    // List<Map> tags =
    //     this.tags != null ? this.tags.map((i) => i.toJson()).toList() : null;

    factory Meal.fromJson(Map<String, dynamic> json) {//print('Meal.fromJson()');

      List<String> essentialList = (json['essentialIngredients'] != null && json['extraIngredients'] !='') ? List.from(jsonDecode(json['essentialIngredients'])) : [];
      
      List<List<String>> alternativeList = [];
      if(json['alternativeIngredients'] != null && json['alternativeIngredients'] != ''){ //convert back to object list
        List<String> unCombineList = List.from(jsonDecode(json['alternativeIngredients']));
          // print(unCombineList);
        List<dynamic> newList  =  unCombineList.map((list)=>jsonDecode(list)).toList();
          // print(newList);
        //match Type
        newList.forEach((sub){List<String> finalSub = [];
          sub.forEach((item) {finalSub.add(item);});
          // print(finalSub);
          alternativeList.add(finalSub);
          });
      }

      List<String> extraList = (json['extraIngredients'] != null && json['extraIngredients'] != '') ? List.from(jsonDecode(json['extraIngredients'])) : [];

    // List<int> imageBytesList = (json['image'] != null && json['image'] !='') ? List.from(base64Decode(json['image'])) : [];
    // File imageFile = null;
    // if(imageBytesList.isNotEmpty) 
    // imageFile.writeAsBytesSync(imageBytesList);
    
    List<String> recommendationList = (json['recommendationTypes'] != null && json['recommendationTypes'] !='') ? List.from(jsonDecode(json['recommendationTypes'])) : [];
    // List<double> priceList = (json['storePackagePrices'] != null && json['storePackagePrices'] !='') ? List.from(jsonDecode(json['storePackagePrices'])) : [];
    List<String> matchingItemsList = (json['matchingItems'] != null && json['matchingItems'] !='') ? List.from(jsonDecode(json['matchingItems'])) : [];
    Map<String, double>  servingsMap = (json['servingsPerUnit'] != null && json['servingsPerUnit'] !='') ? Map<String, double>.from(jsonDecode(json['servingsPerUnit'])) : {};

      return new Meal(
        id:  json['id'], 
        name: json['name'],
        adjective: json['adjective'],
        recipe: json['recipe'],
        // image: json['image'],
        popularityCount: int.parse(json['popularityCount']),
        recentDate: DateTime.parse(json['recentDate']),
        recommendationTypes: recommendationList,
        matchingItems: matchingItemsList,
        // storePackagePrices: priceList,
        servingsPerUnit: servingsMap,
        essentialIngredients: essentialList,
        alternativeIngredients: alternativeList,
        extraIngredients: extraList, 
        );
    }
}

// class MealProvider with ChangeNotifier {
//   void setMealName(Meal meal, String name) {meal.name=name; } //don't call nottifyListeners() when using TextEditingController(), which has its own listener
//   void setMealAdjective(Meal meal, String adjective) {meal.adjective=adjective; }
//   void setMealImage(Meal meal, String image) {meal.image=image; }
//   void setMealRecipe(Meal meal, String recipe) {meal.recipe=recipe; }
//   void increaseMealPopularityCount(Meal meal, {bool update = true}) {meal.popularityCount +=1; if(update) notifyListeners();}
//   void decreaseMealPopularityCount(Meal meal, {bool update = true}) {if(meal.popularityCount!=0) meal.popularityCount -=1; if(update) notifyListeners();}
//   void increaseMealRecentDate(Meal meal, {bool update = true}) {meal.recentDate=meal.recentDate.add(new Duration(days: 1)); if(update) notifyListeners();}
//   void decreaseMealRecentDate(Meal meal, {bool update = true}) {meal.recentDate=meal.recentDate.subtract(new Duration(days: 1)); if(update) notifyListeners();}
//   void setMealRecentDatePresent(Meal meal, {bool update = true}) {meal.recentDate=DateTime.now(); if(update) notifyListeners();}
//   void toggleMealPackable(Meal meal) {meal.packable =! meal.packable; notifyListeners();}
//   void addEssentialIngredient(Meal meal, String ingredientId){meal.addEssentialIngredient(ingredientId); notifyListeners(); }
//   void addAlternativeIngredient(Meal meal, List<String> list){meal.addAlternativeIngredient(list); notifyListeners(); }
//   void addExtraIngredient(Meal meal, String ingredientId){meal.addExtraIngredient(ingredientId); notifyListeners(); }
//   void removeMealIngredient(Meal meal, String ingredientId){meal.removeIngredient(ingredientId); notifyListeners(); }
//   void clearMealIngredients(Meal meal) {meal.clearAllIngredients(); notifyListeners(); }
// }

