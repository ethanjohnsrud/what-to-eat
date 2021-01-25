import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mealplanning/LocalStorage.dart';
import 'package:mealplanning/Providers/Ingredient.dart';
import 'package:mealplanning/Providers/MenuProvider.dart';
import 'package:mealplanning/Providers/PantryItem.dart';
import 'package:provider/provider.dart';
import 'package:mealplanning/Providers/CatalogProvider.dart';

import 'Meal.dart';
import 'MenuItem.dart';
import 'ShoppingItem.dart';

class Settings with ChangeNotifier {
  Settings()  {
      this.loadData();
  }
  void loadData({reset = false}) async {
  if(!reset){
      Map<String, dynamic> jsonData = await readSettings(); //returns already decoded
      if(jsonData == null) reset = true;
      else {
      List<String> recommendationList = (jsonData['recommendationTypes'] != null && jsonData['recommendationTypes'] !='') ? List.from(jsonDecode(jsonData['recommendationTypes'])) : [];
      List<String> unitList = (jsonData['unitList'] != null && jsonData['unitList'] !='') ? List.from(jsonDecode(jsonData['unitList'])) : [];
        this.nameTags = jsonData['nameTags'].toLowerCase() == 'true';
        this.accountForNotch = jsonData['accountForNotch'].toLowerCase() == 'true';
        this.notchAdjustment = double.parse(jsonData['notchAdjustment']);
        this.recommendationVariety = int.parse(jsonData['recommendationVariety']);
        this.recommendPantryOnly = jsonData['recommendPantryOnly'].toLowerCase() == 'true';
        this.recommendationTypes = recommendationList;
        this.pricingUnits = unitList;
      }
    } 
    if(reset) {
      this.nameTags = true;
      this.accountForNotch = true;
      this.notchAdjustment = 30;
      this.recommendationVariety = 3;
      this.recommendPantryOnly = false;
      this.recommendationTypes = ['Regular', 'Packable', 'Breakfast', 'Snack', 'Cooking Ingredient'];
      this.pricingUnits = ['Package', 'Each', 'lbs', 'Pint'];
      print('MENU SET TO DEFAULT');}
    print('Settings() :: loadData() ${reset ? '*RESETTING*' : ''} -Complete');
    notifyListeners();
    // this.saveData();
  }
  void saveData(){
    String recommendationList = (this.recommendationTypes != null && this.recommendationTypes.isNotEmpty) ? jsonEncode(this.recommendationTypes) : '';
    String unitList = (this.pricingUnits != null && this.pricingUnits.isNotEmpty) ? jsonEncode(this.pricingUnits) : '';

    Map<String, dynamic> jsonData = {
      'nameTags' : this.nameTags.toString(),
      'accountForNotch' : this.accountForNotch.toString(),
      'notchAdjustment' : this.notchAdjustment.toString(),
      'recommendationVariety' : this.recommendationVariety.toString(),
      'recommendationTypes' : recommendationList,
      'recommendPantryOnly' : recommendPantryOnly.toString(),
      'unitList' : unitList,
    };

    compute(writeSettings, jsonData);
  print('Settings() :: saveData() -Complete');}

  bool nameTags = true;
  void toggleNameTags() {this.nameTags = !this.nameTags; notifyListeners(); this.saveData();}

  bool accountForNotch = true;
  double notchAdjustment = 30;
  void toggleAccountForNotch() {this.accountForNotch = !this.accountForNotch; notifyListeners(); this.saveData();}

  int recommendationVariety = 3;
  void setRecommendationVariety(int newValue) {this.recommendationVariety = newValue; print('Variety Value is :: $recommendationVariety'); notifyListeners(); this.saveData();}

  bool recommendPantryOnly = false;
  void togglerecommendPantryOnly() {this.recommendPantryOnly = !this.recommendPantryOnly; notifyListeners(); this.saveData();}

  List<String> recommendationTypes = ['Regular', 'Packable', 'Breakfast', 'Snack', 'Cooking Ingredient'];
  void addRecommendationTypes(String tag) {if(this.recommendationTypes == null) this.recommendationTypes = []; if(!this.recommendationTypes.contains(tag)) {if(this.recommendationTypes.contains('Regular')) this.recommendationTypes.insert(1,tag); else this.recommendationTypes.insert(0,tag); notifyListeners(); this.saveData();}}
  void removeRecommendationTypes(BuildContext context, String tag) {if(tag == 'Regular'){print('ERROR :: \'Regular\' Tag CANNOT be DELETED'); return;} if(tag == 'Packable'){print('ERROR :: \'Packable\' Tag CANNOT be DELETED'); return;} if(this.recommendationTypes == null) this.recommendationTypes = [];
    final List<Meal> meals  = Provider.of<CatalogProvider>(context).getMeals();
    final List<Ingredient> ingredients  = Provider.of<CatalogProvider>(context).getIngredients();
    // final List menuList  = Provider.of<MenuProvider>(context).menuList;
    if(meals != null && meals.isNotEmpty) meals.forEach((meal) {if(meal.recommendationTypes != null && meal.recommendationTypes.isNotEmpty) meal.recommendationTypes.remove(tag); });
    if(ingredients != null && ingredients.isNotEmpty) ingredients.forEach((ingredient) {if(ingredient.recommendationTypes != null && ingredient.recommendationTypes.isNotEmpty) ingredient.recommendationTypes.remove(tag); });
    this.recommendationTypes.remove(tag); notifyListeners(); this.saveData();}

  List<String> pricingUnits = ['Package', 'Each', 'lbs', 'Pint'];
  void addPricingUnit(String unit) {if(this.pricingUnits == null) this.pricingUnits = []; if(!this.pricingUnits.contains(unit)) {this.pricingUnits.insert(0,unit); notifyListeners(); this.saveData();}}
  void removePricingUnit(BuildContext context, String unit) {if(unit == 'Package'){print('ERROR :: \'Package\' Unit CANNOT be DELETED'); return;} if(unit == 'Packable'){print('ERROR :: \'Packable\' Tag CANNOT be DELETED'); return;} if(this.pricingUnits == null) this.pricingUnits = [];
    final List<Meal> meals  = Provider.of<CatalogProvider>(context).getMeals();
    final List<Ingredient> ingredients  = Provider.of<CatalogProvider>(context).getIngredients();
    // final List menuList  = Provider.of<MenuProvider>(context).menuList;
    if(meals != null && meals.isNotEmpty) meals.forEach((meal) {if(meal.servingsPerUnit.containsKey(unit)) meal.servingsPerUnit.remove(unit); });
    if(ingredients != null && ingredients.isNotEmpty) ingredients.forEach((ingredient) {if(ingredient.servingsPerUnit.containsKey(unit)) ingredient.servingsPerUnit.remove(unit); });
    this.pricingUnits.remove(unit); notifyListeners(); this.saveData();}

//Utility Method
  String getUniqueID(context, Type type, {List<String> extraList}){
    bool match = false;
    final List meals  = Provider.of<CatalogProvider>(context).getMeals();
    final List ingredients  = Provider.of<CatalogProvider>(context).getIngredients();
    final List pantry  = Provider.of<CatalogProvider>(context).getPantry();
    final List menuList  = Provider.of<MenuProvider>(context).menuList;
    
    String attempt = '00';
    int maxAttempts = 100;
    do {
      maxAttempts -=1;
      attempt = type == Meal ? 'm' 
          : type == Ingredient ? 'i' 
          : type == PantryItem ? 'p' 
          : type == Menu ? 'u' 
          : type == MenuDay ? 'uD' 
          : type == MenuSection ? 'uM'
          : type == MenuItem ? 'uI'
          : type == ShoppingItem ? 's'
          : '?';
      String randomNumbers = DateTime.now().microsecondsSinceEpoch.toString();
      attempt += randomNumbers.substring(randomNumbers.length-8, randomNumbers.length-1);
      if(meals != null) for(var i=0;i<meals.length;i++){
          if(meals[i].id == attempt) match = true;
      }
      if(ingredients != null) for(var i=0;i<ingredients.length;i++){
          if(ingredients[i].id == attempt) match = true;
      }
      if(pantry != null) for(var i=0;i<pantry.length;i++){
          if(pantry[i].id == attempt) match = true;
      }
      if(menuList != null) for(var i=0;i<menuList.length;i++){
          if(menuList[i].id == attempt) match = true; 
          if(menuList[i].menuDayList != null) for(var x=0;x<menuList[i].menuDayList.length;x++){
                  if(menuList[i].menuDayList[x].id == attempt) match = true; 
                  if(menuList[i].menuDayList != null) for(var y=0;y<menuList[i].menuDayList[x].menuSectionList.length;y++){
                          if(menuList[i].menuDayList[x].menuSectionList[y].id == attempt) match = true;
                  }
          }
       }
       if(extraList != null) for(var i=0;i<extraList.length;i++){
          if(extraList[i] == attempt) match = true;
      }
    } while (match || maxAttempts<=0);
    // print('New ID: '+ attempt);
    return attempt;
  }


}
