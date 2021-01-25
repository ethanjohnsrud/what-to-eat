import 'dart:core';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mealplanning/Data/startingIngredients.dart';
import 'package:mealplanning/Data/startingMeals.dart';
import 'package:mealplanning/Data/startingPantry.dart';
import 'package:mealplanning/Data/startingPrices.dart';
import 'package:mealplanning/LocalStorage.dart';
import 'package:mealplanning/Providers/PriceRecord.dart';
import 'package:provider/provider.dart';
import 'Ingredient.dart';
import 'Meal.dart';
import 'MenuItem.dart';
import 'PantryItem.dart';
import 'Settings.dart';


class CatalogProvider with ChangeNotifier{ 
  Map<String, Ingredient> ingredients = {};
  Map<String, Meal> meals = {};
  Map<String, PantryItem> pantry = {};
  Map<String, List<PriceRecord>> prices = {};

  CatalogProvider()  {setCatalogData();}

  void setCatalogData() async {
      await this.loadLists();
      await this.initalizeCachedDates();
      calculateByPopularity( Ingredient);
      calculateByPopularity( Meal);
      // calculateByPopularity( PantryItem);
      calculateByRecent( Ingredient);
      calculateByRecent( Meal);
      // calculateByRecent( PantryItem);
      calculateByExpiration( PantryItem); 
      calculateSearchPantry( null);
      makeList( 'optimizedPantryMeal').then((value) {optimizedPantryMeals = value; print('Cache Value set :: optimizedPantryMeal'); });
      makeList( 'optimizedPantryCost').then((value) {optimizedPantryCost = value; print('Cache Value set :: optimizedPantryCost'); });
      makeList( 'optimizedPantryQuantity').then((value) {optimizedPantryQuantity = value; print('Cache Value set :: optimizedPantryQuantity'); });
      makeList( 'optimizedPantryMeat').then((value) {optimizedPantryMeat = value; print('Cache Value set :: optimizedPantryMeat'); });
      makeList( 'optimizedPantryCarb').then((value) {optimizedPantryCarb = value; print('Cache Value set :: optimizedPantryCarb'); });
      makeList( 'optimizedPantryVeg').then((value) {optimizedPantryVeg = value; print('Cache Value set :: optimizedPantryVeg'); });
      makeList( 'optimizedPantryFruit').then((value) {optimizedPantryFruit = value; print('Cache Value set :: optimizedPantryFruit'); });
      makeList( 'optimizedPantrySnack').then((value) {optimizedPantrySnack = value; print('Cache Value set :: optimizedPantrySnack'); });
      makeList( 'optimizedMealCost').then((value) {optimizedMealCost = value; print('Cache Value set :: optimizedMealCost'); });
      makeList( 'optimizedMealQuantity').then((value) {optimizedMealQuantity = value; print('Cache Value set :: optimizedMealQuantity'); });
      makeList( 'optimizedMealMeat').then((value) {optimizedMealMeat = value; print('Cache Value set :: optimizedMealMeat'); });
      makeList( 'optimizedMealCarb').then((value) {optimizedMealCarb = value; print('Cache Value set :: optimizedMealCarb'); });
      makeList( 'optimizedMealVeg').then((value) {optimizedMealVeg = value; print('Cache Value set :: optimizedMealVeg'); });
      makeList( 'optimizedMealFruit').then((value) {optimizedMealFruit = value; print('Cache Value set :: optimizedMealFruit'); });
      makeList( 'optimizedMealSnack').then((value) {optimizedMealSnack = value; print('Cache Value set :: optimizedMealSnack'); });
      makeList( 'optimizedIngredientCost').then((value) {optimizedIngredientCost = value; print('Cache Value set :: optimizedIngredientCost'); });
      makeList( 'optimizedIngredientQuantity').then((value) {optimizedIngredientQuantity = value; print('Cache Value set :: optimizedIngredientQuantity'); });
      makeList( 'optimizedIngredientMeat').then((value) {optimizedIngredientMeat = value; print('Cache Value set :: optimizedIngredientMeat'); });
      makeList( 'optimizedIngredientCarb').then((value) {optimizedIngredientCarb = value; print('Cache Value set :: optimizedIngredientCarb'); });
      makeList( 'optimizedIngredientVeg').then((value) {optimizedIngredientVeg = value; print('Cache Value set :: optimizedIngredientVeg'); });
      makeList( 'optimizedIngredientFruit').then((value) {optimizedIngredientFruit = value; print('Cache Value set :: optimizedIngredientFruit'); });
      makeList( 'optimizedIngredientSnack').then((value) {optimizedIngredientSnack = value; print('Cache Value set :: optimizedIngredientSnack'); });
  }
    void loadLists({reset = false}) async { 
  if(!reset){
      this.pantry = await readPantry();
      this.meals = await readMeals();
      this.ingredients = await readIngredients();
      this.prices  = await readPrices();
    }
  if(reset || this.pantry == null || this.pantry.isEmpty) { this.pantry = Map.fromIterable(startingPantry, key: (v) => v.id, value: (v) => v); print('PANTRY SET TO DEFAULT');}
  if(reset || this.meals == null || this.meals.isEmpty) { this.meals = Map.fromIterable(startingMeals, key: (v) => v.id, value: (v) => v); print('MEALS SET TO DEFAULT');}
  if(reset || this.ingredients == null || this.ingredients.isEmpty) { this.ingredients = Map.fromIterable(startingIngredients, key: (v) => v.id, value: (v) => v); print('INGREDIENTTS SET TO DEFAULT');}
  if(reset || this.prices == null || this.prices.isEmpty) { 
      this.prices.clear();
      startingPrices.forEach((v) {if(prices.containsKey(v.id)) prices[v.id].insert(0, v);  else prices.addAll({v.id: [v]});});
      print('PRICES SET TO DEFAULT');}
      print('CatalogProvider() :: loadLists() ${reset ? '*RESETTING*' : ''} -Complete');
      notifyListeners();
    if(reset) this.saveLists();
    return;
  }
  void saveLists(){ //can't be compute isolate thread b/c only my isolate has device privilages-could use plugin, which creates own app in a way
    writeMeals(this.meals);
    writeIngredients( this.ingredients);
    writePantry( this.pantry);
    writePrices( this.prices); 
  print('CatalogProvider() :: saveLists() -Complete');}

  List<Ingredient> getIngredients()=>ingredients.entries.map((e) => e.value).toList();
  List<Meal> getMeals()=>meals.entries.map((e) => e.value).toList();
  List<PantryItem> getPantry()=>pantry.entries.map((e) => e.value).toList();

  void addPriceRecord(PriceRecord record){
    if(prices.containsKey(record.id)) prices[record.id].insert(0, record);
    else prices.addAll({record.id: [record]});
    notifyListeners(); writePrices( this.prices); 
    } //add new at beginning of list
  void removePriceRecord(PriceRecord record){
    if(prices.containsKey(record.id)) {prices[record.id].removeWhere((item)=> (item.id==record.id && item.store==record.store && item.price==record.price));
      if(prices[record.id].isEmpty) prices.remove(record.id);}
    notifyListeners(); writePrices( this.prices); 
  }
//call Save right before call notifyListeners()//manulally add in all calls, 
//update simotaeous, but doesn't recall import until app reloads
void updateCatalog()=>notifyListeners(); 

//Cached Values
  int ingredientMedianPopularity = 0;
  int ingredientMaxPopularity = 0;
  int mealMedianPopularity = 0;
  int mealMaxPopularity = 0;
  // int pantryMedianPopularity = 0;
  DateTime today = DateTime.now();
  DateTime ingredientMedianRecent;
  DateTime ingredientRecentOldest;
  DateTime ingredientRecentLatest;
  DateTime mealMedianRecent;
  DateTime mealRecentOldest;
  DateTime mealRecentLatest;
  // DateTime pantryMedianRecent;
  DateTime pantryExpirationOldest;
  DateTime pantryExpirationLatest;
  int pantryMaxQuantity = 0;

  void initalizeCachedDates() async {
    ingredientMedianRecent = today;
    ingredientRecentOldest = today;
    ingredientRecentLatest = today;
    mealMedianRecent = today;
    mealRecentOldest = today;
    mealRecentLatest = today;
    // pantryMedianRecent = today;
    pantryExpirationOldest = today;
    pantryExpirationLatest = today;
  }

  void calculateByPopularity(Type type) async {//Loop-logic error, getRanking uses this data for calculations
    if(type == Ingredient) {
      List list = this.getIngredients();
      if(list == null || list.isEmpty) {print('FAILED :: Cache Value setting :: calculateByPopularity : '+type.toString()); return;}
        list.forEach((i) {if(i.popularityCount > ingredientMaxPopularity) ingredientMaxPopularity = i.popularityCount; }); print('Cache Value set :: ingredientMaxPopularity : '+ingredientMaxPopularity.toString());
      list = await sortList(type: type, popularity: true, recent: false, carb: false, cost: false, expiration: false, fruit: false, meat: false, quantity: false, snack: false, solo: false, veg: false); 
        ingredientMedianPopularity=list[list.length~/2].popularityCount; print('Cache Value set :: ingredientMedianPopularity : '+ingredientMedianPopularity.toString());
    } else if(type == Meal) {
      List list = this.getMeals();
      if(list == null || list.isEmpty) {print('FAILED :: Cache Value setting :: calculateByPopularity : '+type.toString()); return;}
        list.forEach((m) {if(m.popularityCount > mealMaxPopularity) mealMaxPopularity = m.popularityCount; }); mealMaxPopularity=list[0].popularityCount; print('Cache Value set :: mealMaxPopularity : '+mealMaxPopularity.toString());
      list = await sortList(type: type, popularity: true, recent: false, carb: false, cost: false, expiration: false, fruit: false, meat: false, quantity: false, snack: false, solo: false, veg: false); 
        mealMedianPopularity=list[list.length~/2].popularityCount; print('Cache Value set :: mealMedianPopularity : '+mealMedianPopularity.toString());            
    // } else if(type == PantryItem) {
    //   pantryMedianPopularity=list[list.length~/2].popularityCount; print('Cache Value set :: pantryMedianPopularity'+pantryMedianPopularity.toString());
    }
  }
  void calculateByRecent(Type type) async {//Loop-logic error, getRanking uses this data for calculations
   if(type == Ingredient) {
     List list = this.getIngredients();
      if(list == null || list.isEmpty) {print('FAILED :: Cache Value setting :: calculateByRecent : '+type.toString()); return;}
        ingredientRecentOldest = list[0].recentDate; 
        ingredientRecentLatest = list[0].recentDate;
      list.forEach((i) {if(i.recentDate.isBefore(ingredientRecentOldest)) ingredientRecentOldest = i.recentDate; 
        if(i.recentDate.isAfter(ingredientRecentLatest)) ingredientRecentLatest = i.recentDate; });
        print('Cache Value set :: ingredientRecentOldest : '+ingredientRecentOldest.toString());      
        print('Cache Value set :: ingredientRecentLatest : '+ingredientRecentLatest.toString());
      list = await sortList(type: type, popularity: false, recent: true, carb: false, cost: false, expiration: false, fruit: false, meat: false, quantity: false, snack: false, solo: false, veg: false);
        ingredientMedianRecent=list[list.length~/2].recentDate; print('Cache Value set :: ingredientMedianRecent : '+ingredientMedianRecent.toString());
    } else if(type == Meal) {
      List list = this.getMeals();
      if(list == null || list.isEmpty) {print('FAILED :: Cache Value setting :: calculateByRecent : '+type.toString()); return;}
        mealRecentOldest = list[0].recentDate; 
        mealRecentLatest = list[0].recentDate;
      list.forEach((i) {if(i.recentDate != null && i.recentDate.isBefore(mealRecentOldest)) mealRecentOldest = i.recentDate; 
        if(i.recentDate != null && i.recentDate.isAfter(mealRecentLatest)) mealRecentLatest = i.recentDate; });
        print('Cache Value set :: mealRecentOldest : '+mealRecentOldest.toString());      
        print('Cache Value set :: mealRecentLatest : '+mealRecentLatest.toString());
      list = await sortList(type: type, popularity: false, recent: true, carb: false, cost: false, expiration: false, fruit: false, meat: false, quantity: false, snack: false, solo: false, veg: false);
       mealMedianRecent=list[list.length~/2].recentDate; print('Cache Value set :: mealMedianRecent : '+mealMedianRecent.toString());
    // } else if(type == PantryItem) {
    //   pantryMedianRecent=list[list.length~/2].recentDate; print('Cache Value set :: pantryMedianRecent');
    }
  }
  void calculateByExpiration(Type type) async { //Loop-logic error, getRanking uses this data for calculations
  List list = this.getPantry();
    if(list == null || list.isEmpty) {print('FAILED :: Cache Value setting : calculateByExpiration : '+type.toString()); return;}
    else if(type == PantryItem) {
        pantryExpirationOldest = list[0].expirationDate; 
        pantryExpirationLatest = list[0].expirationDate;
      list.forEach((p) {if(p.expirationDate != null && p.expirationDate.isBefore(pantryExpirationOldest)) pantryExpirationOldest = p.expirationDate; 
        if(p.expirationDate != null && p.expirationDate.isAfter(pantryExpirationLatest)) pantryExpirationLatest = p.expirationDate; });
        print('Cache Value set :: pantryExpirationOldest : '+pantryExpirationOldest.toString());      
        print('Cache Value set :: pantryExpirationLatest : '+pantryExpirationLatest.toString());
    }
  }
  void calculateSearchPantry(n) {
    if(pantry != null && pantry.isNotEmpty)
      pantry.forEach((key, item) {if(item.quantity > pantryMaxQuantity) pantryMaxQuantity = item.quantity;});
  }

//cached Recommendation Values
List optimizedPantryMeals = [];
List optimizedPantryCost = [];
List optimizedPantryQuantity = [];
List optimizedPantryMeat = [];
List optimizedPantryCarb = [];
List optimizedPantryVeg = [];
List optimizedPantryFruit = [];
List optimizedPantrySnack = [];
List optimizedMealCost = [];
List optimizedMealQuantity = [];
List optimizedMealMeat = [];
List optimizedMealCarb = [];
List optimizedMealVeg = [];
List optimizedMealFruit = [];
List optimizedMealSnack = [];
List optimizedIngredientCost = [];
List optimizedIngredientQuantity = [];
List optimizedIngredientMeat = [];
List optimizedIngredientCarb = [];
List optimizedIngredientVeg = [];
List optimizedIngredientFruit = [];
List optimizedIngredientSnack = [];

Future<List> makeList(String listName) async {
  if(listName == 'optimizedPantryMeal') return this.sortList(type: Meal, popularity: false, expiration: true, recent: false, quantity: true,);
  else if(listName == 'optimizedPantryCost') return this.sortList(type: PantryItem, popularity: true, expiration: true, recent: false, cost: true, quantity: false, meat: false, carb: false, veg: false, fruit: false, snack: false, solo: false);
  else if(listName == 'optimizedPantryQuantity') return this.sortList(type: PantryItem, popularity: true, expiration: true, recent: false, cost: false, quantity: true, meat: false, carb: false, veg: false, fruit: false, snack: false, solo: false);
  else if(listName == 'optimizedPantryMeat') return this.sortList(type: PantryItem, popularity: true, expiration: true, recent: false, cost: false, quantity: false, meat: true, carb: false, veg: false, fruit: false, snack: false, solo: false);
  else if(listName == 'optimizedPantryCarb') return this.sortList(type: PantryItem, popularity: true, expiration: true, recent: false, cost: false, quantity: false, meat: false, carb: true, veg: false, fruit: false, snack: false, solo: false);
  else if(listName == 'optimizedPantryVeg') return this.sortList(type: PantryItem, popularity: true, expiration: true, recent: false, cost: false, quantity: false, meat: false, carb: false, veg: true, fruit: false, snack: false, solo: false);
  else if(listName == 'optimizedPantryFruit') return this.sortList(type: PantryItem, popularity: true, expiration: true, recent: false, cost: false, quantity: false, meat: false, carb: false, veg: false, fruit: true, snack: false, solo: false);
  else if(listName == 'optimizedPantrySnack') return this.sortList(type: PantryItem, popularity: true, expiration: true, recent: false, cost: false, quantity: false, meat: false, carb: false, veg: false, fruit: false, snack: true, solo: false);
  else if(listName == 'optimizedMealCost') return this.sortList(type: Meal, popularity: true, expiration: true, recent: false, cost: true, quantity: false, meat: false, carb: false, veg: false, fruit: false, snack: false, solo: false);
  else if(listName == 'optimizedMealQuantity') return this.sortList(type: Meal, popularity: true, expiration: true, recent: false, cost: false, quantity: true, meat: false, carb: false, veg: false, fruit: false, snack: false, solo: false);
  else if(listName == 'optimizedMealMeat') return this.sortList(type: Meal, popularity: true, expiration: true, recent: false, cost: false, quantity: false, meat: true, carb: false, veg: false, fruit: false, snack: false, solo: false);
  else if(listName == 'optimizedMealCarb') return this.sortList(type: Meal, popularity: true, expiration: true, recent: false, cost: false, quantity: false, meat: false, carb: true, veg: false, fruit: false, snack: false, solo: false);
  else if(listName == 'optimizedMealVeg') return this.sortList(type: Meal, popularity: true, expiration: true, recent: false, cost: false, quantity: false, meat: false, carb: false, veg: true, fruit: false, snack: false, solo: false);
  else if(listName == 'optimizedMealFruit') return this.sortList(type: Meal, popularity: true, expiration: true, recent: false, cost: false, quantity: false, meat: false, carb: false, veg: false, fruit: true, snack: false, solo: false);
  else if(listName == 'optimizedMealSnack') return this.sortList(type: Meal, popularity: true, expiration: true, recent: false, cost: false, quantity: false, meat: false, carb: false, veg: false, fruit: false, snack: true, solo: false);
  else if(listName == 'optimizedIngredientCost') return this.sortList(type: Ingredient, popularity: true, expiration: true, recent: false, cost: true, quantity: false, meat: false, carb: false, veg: false, fruit: false, snack: false, solo: false);
  else if(listName == 'optimizedIngredientQuantity') return this.sortList(type: Ingredient, popularity: true, expiration: true, recent: false, cost: false, quantity: true, meat: false, carb: false, veg: false, fruit: false, snack: false, solo: false);
  else if(listName == 'optimizedIngredientMeat') return this.sortList(type: Ingredient, popularity: true, expiration: true, recent: false, cost: false, quantity: false, meat: true, carb: false, veg: false, fruit: false, snack: false, solo: false);
  else if(listName == 'optimizedIngredientCarb') return this.sortList(type: Ingredient, popularity: true, expiration: true, recent: false, cost: false, quantity: false, meat: false, carb: true, veg: false, fruit: false, snack: false, solo: false);
  else if(listName == 'optimizedIngredientVeg') return this.sortList(type: Ingredient, popularity: true, expiration: true, recent: false, cost: false, quantity: false, meat: false, carb: false, veg: true, fruit: false, snack: false, solo: false);
  else if(listName == 'optimizedIngredientFruit') return this.sortList(type: Ingredient, popularity: true, expiration: true, recent: false, cost: false, quantity: false, meat: false, carb: false, veg: false, fruit: true, snack: false, solo: false);
  else if(listName == 'optimizedIngredientSnack') return this.sortList(type: Ingredient, popularity: true, expiration: true, recent: false, cost: false, quantity: false, meat: false, carb: false, veg: false, fruit: false, snack: true, solo: false);   
  else return [];
}




//Pantry Operations
  PantryItem getPantryItem(String id) {
    if(pantry.containsKey(id)) return pantry[id];
    // for(var i=0;i<pantry.length;i++){
    //   if(pantry[i].id ==id) return pantry[i];
    // }
    print('CATCH => returning Empty Blank Pantry: '+id); 
    // for(var i=0;i<pantry.length;i++){print(pantry[i].id);}
    // debugPrintStack(label: 'NO_PantryItem : $id');
    return PantryItem(id: 'p0', name: 'Missing Item');
  } 

  void addPantryItem(PantryItem item) {
    // for(var i=0; i<pantry.length;i++){
    //   if(pantry[i].id == item.id){
    //     pantry[i] = item;
    //     notifyListeners(); 
    //     writePantry( this.pantry);
    //     return;
    //   }
    // }
    pantry.addAll({item.id: item}); //Map Overwrites existing
    notifyListeners(); 
    writePantry( this.pantry);
    return;
  }
  void removePantryItem(String id) {
    this.pantry.remove(id);
    writePantry( this.pantry);
    notifyListeners();
  }
  void clearPantryItem() {
    pantry.clear();
    writePantry( this.pantry);
    notifyListeners();
  }
  int getPantryQuantity(String id) {
    int count = 0;
    if(this.pantry != null && this.pantry.isNotEmpty && id != null && id != '')
      pantry.forEach((key, item) {if(item.referenceId == id || item.id ==id)  count += item.quantity;});
    return count;
  }
  double getCalculatedQuantity(Type type, String id) {
    // print('CatalogProvider.getMealCount()');
    final Type checkType = type == PantryItem ? this.getPantryItem(id).referenceType : type;
    final String checkId = type == PantryItem ? this.getPantryItem(id).referenceId : id;
    double count = 0.0;
    if(checkType == Meal ){
        Meal meal = this.getMeal(checkId);
        bool increase = true;
        bool checkedAvoided = true;  //catch for empty lists
        do{ //5-day error :: infinate Loop, when all lists empty
          // print('again... [$id]');
          increase = true;
        if(meal.essentialIngredients != null && meal.essentialIngredients != [] && meal.essentialIngredients.length>0) 
          for(var l=0; l<meal.essentialIngredients.length;l++)  {checkedAvoided = false; if(this.getPantryQuantity(meal.essentialIngredients[l]) < (count+1)) increase = false;}
        if(meal.alternativeIngredients != null && meal.alternativeIngredients != [] && meal.alternativeIngredients.length>0) 
            for(var l=0; l<meal.alternativeIngredients.length;l++) 
            { double total =0.0;
              if(meal.alternativeIngredients[l] != null && meal.alternativeIngredients[l] != [] && meal.alternativeIngredients[l].length>0) 
                for(var i=0; i<meal.alternativeIngredients[l].length; i++) {checkedAvoided = false; total+= getPantryQuantity(meal.alternativeIngredients[l][i]);}
            if(total < (count+1.0)) increase = false;
            }
          if(increase) count += 1.0;
        } while(increase && !checkedAvoided);
    }
    return count + getPantryQuantity(checkId);
  }
  DateTime getPantryEarliestExpiration(String id) { //specific for Id
    // final DateTime now = DateTime.now();
    DateTime pantryExpirationLatest = today;
    if(this.pantry != null && this.pantry.isNotEmpty && id != null && id != '') {
        pantryExpirationLatest = pantry.values.toList()[0].expirationDate;
        pantry.forEach((key, item) {if((item.id == id || item.referenceId == id) && item.expirationDate != null && item.expirationDate.isBefore(pantryExpirationLatest)) pantryExpirationLatest = item.expirationDate;});
    } else //not in pantry
        return DateTime.now().add(new Duration(days: 1825)); // five years out for sorting primarely

    return pantryExpirationLatest;
  }
  bool deductFromPantry(String id, {quantity = 1}) {
    DateTime earliestDate = this.getPantryEarliestExpiration(id);
    String matchId = null;
    if(this.pantry != null && this.pantry.isNotEmpty && id != null && id != '')
        pantry.forEach((key, item) {if(item.expirationDate != null && earliestDate == item.expirationDate) matchId = item.id; else if(matchId == null && (item.id == id || item.referenceId == id)) matchId=item.id;});
    if(matchId != null) {this.getPantryItem(matchId).quantity -= quantity; final int remaining = this.getPantryItem(matchId).quantity; if(remaining<=0) { this.removePantryItem(matchId); return this.deductFromPantry(id, quantity: 0-remaining);} notifyListeners(); return true;}
    else {notifyListeners(); return false;}
  }

  int getMedianPopularity(Type type){
    if(type == Ingredient) return ingredientMedianPopularity;
    else if(type == Meal) return mealMedianPopularity;
    // else if(type == PantryItem) return pantryMedianPopularity;
    else return 0;
    //     List list = await sortList(type: type, popularity: true, recent: false, carb: false, cost: false, expiration: false, fruit: false, meat: false, quantity: false, snack: false, solo: false, veg: false);
    // if(list == null || list.isEmpty) return 0;
    // else return list[list.length~/2].popularityCount;
  }
  DateTime getMedianRecent(Type type){
    if(type == Ingredient) return ingredientMedianRecent;
    else if(type == Meal) return mealMedianRecent;
    // else if(type == PantryItem) return pantryMedianRecent;
    else return today;
    //     List list = await this.sortList(type: type, popularity: false, recent: true, carb: false, cost: false, expiration: false, fruit: false, meat: false, quantity: false, snack: false, solo: false, veg: false);
    // if(list == null || list.isEmpty) return DateTime.now().subtract(new Duration(days: 15));
    // else return list[list.length~/2].recentDate;
  }

  void clearAllRecommendationValues() {
    this.ingredients.forEach((key, ingredient){
      ingredient.popularityCount=0; ingredient.recentDate = DateTime.now(); ingredient.matchingItems = []; 
    });
    this.meals.forEach((key, meal){
      meal.popularityCount=0; meal.recentDate = DateTime.now(); meal.matchingItems = []; 
    });
    this.saveLists();
    notifyListeners();
  }

  double getServingsPerUnit({Type type, String id, String unit = 'Package'}){
    if(type == null || id == null) return 1.0;
    if(type == Meal && this.getMeal(id).servingsPerUnit.containsKey(unit)) return this.getMeal(id).servingsPerUnit[unit];
    if(type == Ingredient && this.getIngredient(id).servingsPerUnit.containsKey(unit)) return this.getIngredient(id).servingsPerUnit[unit];
    return 1.0;
  }
  

  //pantryItem Edit
    void setPantryItemReferenceType(String itemId, Type type) {this.getPantryItem(itemId).referenceType=type; notifyListeners(); writePantry( this.pantry);} 
  void setPantryItemName(String itemId, String name) {this.getPantryItem(itemId).name=name; notifyListeners(); writePantry( this.pantry);}
  void setPantryItemDescription(String itemId, String description) {this.getPantryItem(itemId).description=description; notifyListeners(); writePantry( this.pantry);}
  void setPantryItemReferenceID(String itemId, String id, {String name}) {this.getPantryItem(itemId).referenceId=id; if(name!= null) this.getPantryItem(itemId).name = name; notifyListeners();writePantry( this.pantry);}
  void setPantryItemAdjective(String itemId, String adjective) {this.getPantryItem(itemId).description=adjective; notifyListeners();writePantry( this.pantry);}
  void setPantryItemExpirationDate(String itemId, DateTime date) {this.getPantryItem(itemId).expirationDate=date; notifyListeners();writePantry( this.pantry);}
  void increasePantryItemQuantity(String itemId) {this.getPantryItem(itemId).quantity +=1; notifyListeners();writePantry( this.pantry);}
  void decreasePantryItemQuantity(String itemId) {if(this.getPantryItem(itemId).quantity!=1) this.getPantryItem(itemId).quantity -=1; notifyListeners();writePantry( this.pantry);}

  ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//INGREDIENT OPERATIONS
  // List<Ingredient> get ingredients {return [..._ingredients];} 

  Ingredient getIngredient(String id) {
    if(this.ingredients.containsKey(id)) return this.ingredients[id];
    // for(var i=0;i<ingredients.length;i++){
    //   if(ingredients[i].id ==id) return ingredients[i];
    // }
    print('CATCH => returning Empty Blank Ingredient: '+id);
    // for(var i=0;i<ingredients.length;i++){print(ingredients[i].id);}
    // debugPrintStack(label: 'NO_Ingredient : $id');
    return Ingredient(id: 'i0', name: 'NO INGREDIENT FOUND', popularityCount: this.getMedianPopularity(Ingredient), recentDate: this.getMedianRecent(Ingredient));
  } 

  void addIngredient(Ingredient ingredient) {
    // for(var i=0; i<ingredients.length;i++){
    //   if(ingredients[i].id == ingredient.id){
    //     ingredients[i] = ingredient;
    //     notifyListeners(); 
    //     writeIngredients( this.ingredients);
    //     return;
    //   }
    // }
    ingredients.addAll({ingredient.id: ingredient});
    notifyListeners(); 
    writeIngredients( this.ingredients);
    return;
  }
  void removeIngredient(String id) {
    meals.forEach((key, meal)=>meal.removeIngredient(id));
    this.ingredients.remove(id);
    // for(var x=0; x<ingredients.length; x++){if(ingredients[x].id == id) ingredients.remove(ingredients[x]);}
    // ingredients.forEach((ingredient) {ingredient.id == id ? ingredients.remove(ingredient) : null;});
    notifyListeners();
    writeIngredients( this.ingredients);
  }
  void clearIngredients() {
    if(ingredients != null)
    ingredients.clear();
    notifyListeners();
    writeIngredients( this.ingredients);
  }

  //Ingredient Item Edit
    void setIngredientName(String ingredientId, String name) {this.getIngredient(ingredientId).name=name; notifyListeners();} //don't call nottifyListeners() when using TextEditingController(), which has its own listener
  void setIngredientAdjective(String ingredientId, String adjective) {this.getIngredient(ingredientId).adjective=adjective; notifyListeners(); writeIngredients( this.ingredients);}
  // void setIngredientImage(String ingredientId, File image) {this.getIngredient(ingredientId).image=image; notifyListeners();writeIngredients( this.ingredients);}
  void addIngredientRecommendationTypes(String ingredientId, String tag, {bool update = true}) {if(this.getIngredient(ingredientId).recommendationTypes == null || this.getIngredient(ingredientId).recommendationTypes.isEmpty) this.getIngredient(ingredientId).recommendationTypes=[]; if(!this.getIngredient(ingredientId).recommendationTypes.contains(tag)) {this.getIngredient(ingredientId).recommendationTypes.add(tag); if(update) notifyListeners(); writeIngredients( this.ingredients);}}
  void removeIngredientRecommendationTypes(String ingredientId, String tag, {bool update = true}) { if(this.getIngredient(ingredientId).recommendationTypes == null || this.getIngredient(ingredientId).recommendationTypes.isEmpty) return; this.getIngredient(ingredientId).recommendationTypes.remove(tag); if(update) notifyListeners(); writeIngredients( this.ingredients);}
  void setIngredientPriceUnit({String ingredientId, String unit, double servings, bool update = true}) {this.getIngredient(ingredientId).servingsPerUnit.addAll({unit : servings}); if(update) notifyListeners(); writeIngredients( this.ingredients);} 
  void increaseIngredientPopularityCount(String ingredientId, {bool update = true}) {this.getIngredient(ingredientId).popularityCount +=1; if(update) notifyListeners(); writeIngredients( this.ingredients);}
  void decreaseIngredientPopularityCount(String ingredientId, {bool update = true}) {if(this.getIngredient(ingredientId).popularityCount!=0) this.getIngredient(ingredientId).popularityCount -=1; if(update) notifyListeners();writeIngredients( this.ingredients);}
  void increaseIngredientRecentDate(String ingredientId, {bool update = true}) {this.getIngredient(ingredientId).recentDate=this.getIngredient(ingredientId).recentDate.add(new Duration(days: 1)); if(update) notifyListeners();writeIngredients( this.ingredients);}
  void decreaseIngredientRecentDate(String ingredientId, {bool update = true}) {this.getIngredient(ingredientId).recentDate=this.getIngredient(ingredientId).recentDate.subtract(new Duration(days: 1)); if(update) notifyListeners();writeIngredients( this.ingredients);}
  void setIngredientRecentDatePresent(String ingredientId, {bool update = true}) {this.getIngredient(ingredientId).recentDate=DateTime.now(); if(update) notifyListeners();writeIngredients( this.ingredients);}
  void toggleIngredientMeat(String ingredientId) {this.getIngredient(ingredientId).meat =! this.getIngredient(ingredientId).meat; notifyListeners();writeIngredients( this.ingredients);}
  void toggleIngredientCarb(String ingredientId) {this.getIngredient(ingredientId).carb =! this.getIngredient(ingredientId).carb; notifyListeners();writeIngredients( this.ingredients);}
  void toggleIngredientVeg(String ingredientId) {this.getIngredient(ingredientId).veg =! this.getIngredient(ingredientId).veg; notifyListeners();writeIngredients( this.ingredients);}
  void toggleIngredientFruit(String ingredientId) {this.getIngredient(ingredientId).fruit =! this.getIngredient(ingredientId).fruit; notifyListeners();writeIngredients( this.ingredients);}
  void toggleIngredientSnack(String ingredientId) {this.getIngredient(ingredientId).snack =! this.getIngredient(ingredientId).snack; notifyListeners();writeIngredients( this.ingredients);}
  // void setIngredientServingsPerPackage(String ingredientId, double servings) {this.getIngredient(ingredientId).servingsPerPackage=servings; notifyListeners();writeIngredients( this.ingredients);}
  void addIngredientMatchingItems(String ingredientId, List<String> items, {bool update = true}) {if(this.getIngredient(ingredientId).matchingItems == null) this.getIngredient(ingredientId).matchingItems = []; this.getIngredient(ingredientId).matchingItems.addAll(items); if(update) notifyListeners(); writeIngredients( this.ingredients);}
  // void setIngredientStorePackagePrice(String ingredientId, int place, double price, {bool update = true}) {if(place == null || this.getIngredient(ingredientId).storePackagePrices == null || this.getIngredient(ingredientId).storePackagePrices.isEmpty || place >= this.getIngredient(ingredientId).storePackagePrices.length) return; this.getIngredient(ingredientId).storePackagePrices[place]=price; if(update) notifyListeners(); writeIngredients( this.ingredients);}
  // void addIngredientStorePackagePrice(String ingredientId, double price, {bool update = true}) {if(this.getIngredient(ingredientId).storePackagePrices == null) this.getIngredient(ingredientId).storePackagePrices = []; this.getIngredient(ingredientId).storePackagePrices.add(price); if(update)  notifyListeners(); writeIngredients( this.ingredients);}
  // void removeIngredientStorePackagePrice(String ingredientId, int place, {bool update = true}) {if(place == null || this.getIngredient(ingredientId).storePackagePrices == null || this.getIngredient(ingredientId).storePackagePrices.isEmpty || place >= this.getIngredient(ingredientId).storePackagePrices.length) return; this.getIngredient(ingredientId).storePackagePrices.removeAt(place); if(update)  notifyListeners(); writeIngredients( this.ingredients);}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  //MEAL OPERATIONS
  // List< Meal> get meals {return [..._meals];} 
  // final Meal blankMeal = Meal(
  //   id: 'm0',
  //   name: 'Blank Meal',
  //   essentialIngredients: ['i0'],
  // );
  
  Meal getMeal(String id) {
    if(this.meals.containsKey(id)) return this.meals[id];
    // for(var i=0;i<meals.length;i++){
    //   if(meals[i].id ==id) {return meals[i];}
    // }
    print('CATCH => returning Empty Blank Meal: '+id); 
    // for(var i=0;i<meals.length;i++){print(meals[i].id);}
    // debugPrintStack(label: 'NO_Meal : $id');
    return Meal(id: 'm0', name: 'No Meal Found', popularityCount: this.getMedianPopularity(Meal), recentDate: this.getMedianRecent(Meal));
  } 

  void addMeal(Meal meal) {
    // for(var i=0; i<meals.length;i++){
    //   if(meals[i].id == meal.id){
    //     meals[i] = meal;
    //     notifyListeners(); 
    //     writeMeals(this.meals);
    //     return;
    //   }
    // }
    meals.addAll({meal.id: meal});
    notifyListeners(); 
    writeMeals(this.meals);
    return;
  }
  void removeMeal(String id) {
    meals.remove(id);
    // print('* Meal Removed: '+id);
    // for(var x=0; x<meals.length; x++){if(meals[x].id == id) meals.remove(meals[x]);}
    // meals.forEach((meal) {meal.id == id ? meals.remove(meal) : null;});
    notifyListeners();
    writeMeals(this.meals);
  }
  void clearMeals() {
    if(meals != null)
      meals.clear();
    notifyListeners();
    writeMeals(this.meals);
  }

  //MealItem Edits
   void setMealName(String mealId, String name) {this.getMeal(mealId) .name=name; notifyListeners(); writeMeals(this.meals);} //don't call nottifyListeners() when using TextEditingController(), which has its own listener
  void setMealAdjective(String mealId, String adjective) {this.getMeal(mealId).adjective=adjective; notifyListeners(); writeMeals(this.meals);}
  // void setMealImage(String mealId, String image) {this.getMeal(mealId).image=image; notifyListeners(); writeMeals(this.meals);}
  void addMealRecommendationTypes(String mealId, String tag, {bool update = true}) {if(!this.getMeal(mealId).recommendationTypes.contains(tag)) {if(this.getMeal(mealId).recommendationTypes == null || this.getMeal(mealId).recommendationTypes.isEmpty) this.getMeal(mealId).recommendationTypes = []; this.getMeal(mealId).recommendationTypes.add(tag); if(update) notifyListeners(); writeMeals(this.meals);}}
  void removeMealRecommendationTypes(String mealId, String tag, {bool update = true}) {if(this.getMeal(mealId).recommendationTypes == null || this.getMeal(mealId).recommendationTypes.isEmpty) return; this.getMeal(mealId).recommendationTypes.remove(tag); if(update) notifyListeners(); writeMeals(this.meals);}
  void setMealPriceUnit({String mealId, String unit, double servings, bool update = true}) {this.getMeal(mealId).servingsPerUnit.addAll({unit : servings}); if(update) notifyListeners(); writeMeals(this.meals);} 
  void setMealRecipe(String mealId, String recipe) {this.getMeal(mealId).recipe=recipe; notifyListeners(); writeMeals(this.meals);}
  void increaseMealPopularityCount(String mealId, {bool update = true}) {this.getMeal(mealId).popularityCount +=1; if(update) notifyListeners(); writeMeals(this.meals);}
  void decreaseMealPopularityCount(String mealId, {bool update = true}) {if(this.getMeal(mealId).popularityCount!=0) this.getMeal(mealId).popularityCount -=1; if(update) notifyListeners(); writeMeals(this.meals);}
  void increaseMealRecentDate(String mealId, {bool update = true}) {this.getMeal(mealId).recentDate=this.getMeal(mealId).recentDate.add(new Duration(days: 1)); if(update) notifyListeners(); writeMeals(this.meals);}
  void decreaseMealRecentDate(String mealId, {bool update = true}) {this.getMeal(mealId).recentDate=this.getMeal(mealId).recentDate.subtract(new Duration(days: 1)); if(update) notifyListeners(); writeMeals(this.meals);}
  void setMealRecentDatePresent(String mealId, {bool update = true}) {this.getMeal(mealId).recentDate=DateTime.now(); if(update) notifyListeners();writeMeals(this.meals);}
  void addEssentialIngredient(String mealId, String ingredientId){this.getMeal(mealId).addEssentialIngredient(ingredientId); 
        if(this.getIngredient(ingredientId).recommendationTypes != null && this.getIngredient(ingredientId).recommendationTypes.isNotEmpty) 
            this.getIngredient(ingredientId).recommendationTypes.forEach((tag)=>this.addMealRecommendationTypes(mealId, tag, update: false));  
        notifyListeners(); writeMeals(this.meals);}
  void addAlternativeIngredient(String mealId, List<String> list){this.getMeal(mealId).addAlternativeIngredient(list); notifyListeners(); writeMeals(this.meals);}
  void addExtraIngredient(String mealId, String ingredientId){this.getMeal(mealId).addExtraIngredient(ingredientId); notifyListeners(); writeMeals(this.meals);}
  void removeMealIngredient(String mealId, String ingredientId){this.getMeal(mealId).removeIngredient(ingredientId); notifyListeners(); writeMeals(this.meals);}
  void clearMealIngredients(String mealId) {this.getMeal(mealId).clearAllIngredients(); notifyListeners(); writeMeals(this.meals);}
  void addMealMatchingItems(String mealId, List<String> items, {bool update = true}) {if(this.getMeal(mealId).matchingItems == null) this.getMeal(mealId).matchingItems = []; this.getMeal(mealId).matchingItems.addAll(items); if(update) notifyListeners(); writeMeals(this.meals);}


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//Calculations & Analysis

  List sortList({
    @required Type type,
    bool meat = false,
    bool carb = false,
    bool veg = false,
    bool fruit = false,
    bool snack = false,
    bool solo = false,
    bool popularity = true,
    bool recent = true,
    bool cost = true,
    bool quantity = true,
    bool expiration = true,
  }) {List list;
    if(type == Meal)  list = this.meals.entries.map((e) => e.value).toList();
    else if(type == Ingredient) list = this.ingredients.entries.map((e) => e.value).toList();
    else if(type == PantryItem) list = this.pantry.entries.map((e) => e.value).toList();
    else {list = []; print('ERROR-ListType Not Match');}
    _sortingConditions['meat'] = meat;
    _sortingConditions['carb'] = carb;
    _sortingConditions['veg'] = veg;
    _sortingConditions['fruit'] = fruit;
    _sortingConditions['snack'] = snack;
    _sortingConditions['solo'] = solo;
    _sortingConditions['popularity'] = popularity;
    _sortingConditions['recent'] = recent;
    _sortingConditions['cost'] = cost;
    _sortingConditions['quantity'] = quantity;
    _sortingConditions['expiration'] = expiration;
    //if all false, return as if all were true
    if(!meat && !carb && !veg && !fruit && !snack && !solo && !popularity && !recent && !cost && !quantity && !expiration){ 
      _sortingConditions.forEach((key, property) {property = true; });
    }
    //Remove List with zero
      list.removeWhere((item) => (_getRanking(type, item.id) == 0));
              // for(var i=0; i<list.length;i++){print('$i] '+list[i].name + ' - ' + _getRanking(type, list[i].id).toString());}
    _mergeSort(type, list, list.length);
              // for(var i=0; i<list.length;i++){print('$i] '+list[i].name + ' - ' );
              // _sortingConditions.forEach((key, property) {
              //   if(property)
              //   switch(key) {
              //     case 'meat': print('$key => ${getMeat(type, list[i].id)}'); break;
              //     case 'carb': print('$key => ${getCarb(type, list[i].id)}'); break;
              //     case 'veg': print('$key => ${getVeg(type, list[i].id)}'); break;
              //     case 'fruit': print('$key => ${getFruit(type, list[i].id)}'); break;
              //     case 'snack': print('$key => ${getSnack(type, list[i].id)}'); break;
              // case 'solo': print('$key => ${getSolo(type, list[i].id)}'); break;
              //     case 'popularity': print('$key => ${getPopularityPercent(type, list[i].id)}'); break;
              //     case 'recent': print('$key => ${getRecentPercent(type, list[i].id)}'); break;
              //     case 'cost': print('$key => ${getCost(type, list[i].id)}'); break;
              //     case 'quantity': print('$key => ${getCalculatedQuantity(type, list[i].id)}'); break;
              //     case 'expiration': print('$key => ${getPantryEarliestExpiration(list[i].id)}'); break;
              //   }});}

      return list;
  }

  //SPECIFIC PRIVATE MEAL CALCULATION PROPERTIES
  List<String> getRecommendationTypes(Type type, String id){
    // print('getRecommendationType() $type $id');
    Type checkType = type;
    String checkId = id;
    if(checkType == PantryItem) { PantryItem item = this.getPantryItem(checkId);
        if(item.referenceType == null || item.referenceId == null || item.referenceId == '')
          return ['Regular'];
        else{
          checkType = item.referenceType;
          checkId = item.referenceId;
        }}
    if(checkType == Ingredient && (this.getIngredient(checkId).recommendationTypes != null && this.getIngredient(checkId).recommendationTypes.isNotEmpty))
        return this.getIngredient(checkId).recommendationTypes;
    else if(checkType == Meal && (this.getMeal(checkId).recommendationTypes != null && this.getMeal(checkId).recommendationTypes.isNotEmpty))
        return this.getMeal(checkId).recommendationTypes;
    print('catalogProvider.getRecommendationType - type Error: '+type.toString());
    return ['Regular']; //type Error
  }


  double getCalculatedAveragePerServingCost(String id, {Type type, String store, String unit}) {
    // print('getCost() $type $id');
    double totalPerServing = 0.0;
    int count = 0;
    if(type == Meal){ Meal meal = this.getMeal(id);
      if(meal.essentialIngredients!=null && meal.essentialIngredients.isNotEmpty)
          meal.essentialIngredients.forEach((itemId) {totalPerServing += this.getCalculatedAveragePerServingCost(itemId, type: type, store: store, unit: unit);});
      if(meal.alternativeIngredients!=null && meal.alternativeIngredients.isNotEmpty)
          meal.alternativeIngredients.forEach((list) {if(list != null && list.isNotEmpty) {var random = new Random(); totalPerServing += this.getCalculatedAveragePerServingCost(list[random.nextInt(list.length)], type: type, store: store, unit: unit);}});
    count++;}
    if(this.prices != null && this.prices.isNotEmpty){
        if(this.prices.containsKey(id)) this.prices[id].forEach((item) { 
            if((store == null || item.store == store) && (unit == null || item.unit == unit)) {
              if(type == Meal && this.getMeal(id).servingsPerUnit.containsKey(item.unit)) totalPerServing += (item.price/this.getMeal(id).servingsPerUnit[item.unit]);
              else if(type == Ingredient && this.getIngredient(id).servingsPerUnit.containsKey(item.unit)) totalPerServing += (item.price/this.getIngredient(id).servingsPerUnit[item.unit]);  
              else totalPerServing += item.price;
              count++;
          }});
    }
    // print('getCalcaulatedAveragePrice() Result for: $id $type == $totalPerServing / $count - ${this.prices[id].toString()}');
    if(totalPerServing != 0.0 && count>0) return ((totalPerServing/count * pow(10, 2)).round().toDouble() / pow(10, 2)); //removed double casting for division
     else return 0.0;
  }

  String getBestPriceUnit(String id){
    //count occurances in priceList, if none 'Pacakge'
    Map<String, int> options = {'Package': 0};
    if(this.prices != null && this.prices.isNotEmpty){
      if(this.prices.containsKey(id)) this.prices[id].forEach((item) { 
          if(options.containsKey(item.unit)) options[item.unit] += 1;
          else options.addAll({item.unit: 1});
      });
      if(options.isNotEmpty) { String maxValue = 'Package';
        options.forEach((key, value) {if(value > options[maxValue]) maxValue = key;});
        return maxValue;
      }}
    return 'Package';
  }

  List<PriceRecord> getPriceList({String id, bool combineStores = true}){ //false list all matches to id, null id returns all combined to matching ids
  print('catalogProvider.getPriceList()-$id');
    if(!this.prices.containsKey(id)) return [];
    List<PriceRecord> resultList = [];
    List<int> countList = [];

    this.prices[id].forEach((item) { 
          if(id == null || item.id == id) {bool matchFound = false;
        for(int i=0;(combineStores && i<resultList.length); i++){
          if(resultList[i].store == item.store && resultList[i].unit == item.unit){matchFound = true;
              resultList[i].price += item.price;
              countList[i]++; }}
        if(!matchFound){ resultList.add(new PriceRecord(id: item.id, price: item.price, store: item.store, unit: item.unit));  countList.add(1); }
      }});
      for(int i=0; i<resultList.length; i++){
          resultList[i].price = resultList[i].price/countList[i]; //removed double casting for division
          }
      return resultList;
  }

  bool getMeat(Type type, String id) {
    // print('getMeat() $type $id');
    if(type == Ingredient) return this.getIngredient(id).meat;
    else if(type == Meal){
    Meal meal = this.getMeal(id);
    bool isMeat = false;
    if(meal.essentialIngredients != null && meal.essentialIngredients != []) meal.essentialIngredients.forEach((i) {if(this.getIngredient(i).meat) isMeat = true;  });
    if(meal.alternativeIngredients != null && meal.alternativeIngredients != [] ) meal.alternativeIngredients.forEach((list) 
        { if(list != null) list.forEach((i) { if(this.getIngredient(i).meat) isMeat = true; });});
    if(meal.extraIngredients != null ) meal.extraIngredients.forEach((i) {if(this.getIngredient(i).meat) isMeat = true; });
    return isMeat;
    } else if(type == PantryItem && this.getPantryItem(id).referenceId != null && this.getPantryItem(id).referenceId != '' && this.getPantryItem(id).referenceType != null) {
      return this.getMeat(this.getPantryItem(id).referenceType, this.getPantryItem(id).referenceId);
    } return false;
  }
  bool getCarb(Type type, String id) {
    // print('getCarb() $type $id');
    if(type == Ingredient) return this.getIngredient(id).carb;
    else if(type == Meal){
    Meal meal = this.getMeal(id);
    bool isCarb = false;
    if(meal.essentialIngredients != null && meal.essentialIngredients != [] ) meal.essentialIngredients.forEach((i) {if(this.getIngredient(i).carb) isCarb = true;  });
    if(meal.alternativeIngredients != null && meal.alternativeIngredients != [] ) meal.alternativeIngredients.forEach((list) 
        { if(list != null) list.forEach((i) { if(this.getIngredient(i).carb) isCarb = true; });});
    if(meal.extraIngredients != null ) meal.extraIngredients.forEach((i) {if(this.getIngredient(i).carb) isCarb = true; });
    return isCarb;
    } else if(type == PantryItem && this.getPantryItem(id).referenceId != null && this.getPantryItem(id).referenceId != '' && this.getPantryItem(id).referenceType != null) {
      return this.getCarb(this.getPantryItem(id).referenceType, this.getPantryItem(id).referenceId);
    } return false;
  }
  bool getVeg(Type type, String id) {
    // print('getVeg() $type $id');
    if(type == Ingredient) return this.getIngredient(id).veg;
    else if(type == Meal){
    Meal meal = this.getMeal(id);
    bool isVeg = false;
    if(meal.essentialIngredients != null && meal.essentialIngredients != [] ) meal.essentialIngredients.forEach((i) {if(this.getIngredient(i).veg) isVeg = true;  });
    if(meal.alternativeIngredients != null && meal.alternativeIngredients != [] ) meal.alternativeIngredients.forEach((list) 
        { if(list != null) list.forEach((i) { if(this.getIngredient(i).veg) isVeg = true; });});
    if(meal.extraIngredients != null ) meal.extraIngredients.forEach((i) {if(this.getIngredient(i).veg) isVeg = true; });
    return isVeg;
    } else if(type == PantryItem && this.getPantryItem(id).referenceId != null && this.getPantryItem(id).referenceId != '' && this.getPantryItem(id).referenceType != null) {
      return this.getVeg(this.getPantryItem(id).referenceType, this.getPantryItem(id).referenceId);
    } return false;
  }
  bool getFruit(Type type, String id) {
    // print('getFruit() $type $id');
    if(type == Ingredient) return this.getIngredient(id).fruit;
    else if(type == Meal){
    Meal meal = this.getMeal(id);
    bool isFruit = false;
    if(meal.essentialIngredients != null && meal.essentialIngredients != [] ) meal.essentialIngredients.forEach((i) {if(this.getIngredient(i).fruit) isFruit = true;  });
    if(meal.alternativeIngredients != null && meal.alternativeIngredients != [] ) meal.alternativeIngredients.forEach((list) 
        { if(list != null) list.forEach((i) { if(this.getIngredient(i).fruit) isFruit = true; });});
    if(meal.extraIngredients != null ) meal.extraIngredients.forEach((i) {if(this.getIngredient(i).fruit) isFruit = true; });
    return isFruit;
    } else if(type == PantryItem && this.getPantryItem(id).referenceId != null && this.getPantryItem(id).referenceId != '' && this.getPantryItem(id).referenceType != null) {
      return this.getFruit(this.getPantryItem(id).referenceType, this.getPantryItem(id).referenceId);
    } return false;
  }
  bool getSnack(Type type, String id) {
    // print('getSnack() $type $id');
    if(type == Ingredient) return this.getIngredient(id).snack;
    else if(type == Meal){
    Meal meal = this.getMeal(id);
    bool isSnack = false;
    if(meal.essentialIngredients != null && meal.essentialIngredients != [] ) meal.essentialIngredients.forEach((i) {if(this.getIngredient(i).snack) isSnack = true;  });
    if(meal.alternativeIngredients != null && meal.alternativeIngredients != [] ) meal.alternativeIngredients.forEach((list) 
        { if(list != null) list.forEach((i) { if(this.getIngredient(i).snack) isSnack = true; });});
    if(meal.extraIngredients != null ) meal.extraIngredients.forEach((i) {if(this.getIngredient(i).snack) isSnack = true; });
    return isSnack;
    } else if(type == PantryItem && this.getPantryItem(id).referenceId != null && this.getPantryItem(id).referenceId != '' && this.getPantryItem(id).referenceType != null) {
      return this.getSnack(this.getPantryItem(id).referenceType, this.getPantryItem(id).referenceId);
    } return false;
  }
  bool getSolo(Type type, String id) {
    // print('getSolo() $type $id');
    if(type == Meal) return false;
    else if(type == Ingredient){
      List<Meal> mealList = this.meals.values.toList();
      for(var i =0; i<mealList.length; i++){
        if(mealList[i].essentialIngredients != null && mealList[i].essentialIngredients != [] )
        for(int j=0; j<mealList[i].essentialIngredients.length; j++){if(mealList[i].essentialIngredients[j] == id) return false;}

        if(mealList[i].alternativeIngredients != null && mealList[i].alternativeIngredients != [] )
        for(int j=0; j<mealList[i].alternativeIngredients.length; j++){
          if(mealList[i].alternativeIngredients[j] != null && mealList[i].alternativeIngredients[j] != [] )
            for(int k=0; k<mealList[i].alternativeIngredients[j].length; k++){if(mealList[i].alternativeIngredients[j][k] == id) return false;}
        }

        if(mealList[i].extraIngredients != null && mealList[i].extraIngredients != [] )
        for(int j=0; j<mealList[i].extraIngredients.length; j++){if(mealList[i].extraIngredients[j] == id) return false;}
      } return true;
    } else if(type == PantryItem && this.getPantryItem(id).referenceId != null && this.getPantryItem(id).referenceId != '' && this.getPantryItem(id).referenceType != null) {
      return this.getSolo(this.getPantryItem(id).referenceType, this.getPantryItem(id).referenceId);
    } return false;
  }
  int getPopularityPercent(Type type, String id, {int value}) {
    // print('getPopularityPercent() $type $id');
    final Type checkType = type == PantryItem ? this.getPantryItem(id).referenceType : type;
    final String checkId = type == PantryItem ? this.getPantryItem(id).referenceId : id;
    int max = 0;
    if(checkType == Meal ) {
      if(meals == null) return 50; //emplty list catch catch
      int val = value == null ? this.getMeal(checkId).popularityCount : value;
      // meals.forEach((meal) {if(max < meal.popularityCount) max = meal.popularityCount;});
      max = mealMaxPopularity;
      if(max == 0) return 50; //divide by zero catch
      return ((val.toDouble()/max.toDouble())*100).toInt();
    } else if(checkType == Ingredient  ) {
      if(ingredients == null) return 50; //emplty list catch catch
      int val = value == null ? this.getIngredient(checkId).popularityCount : value;
      // ingredients.forEach((ingredient) {if(max < ingredient.popularityCount) max = ingredient.popularityCount;});
      max = ingredientMaxPopularity;
      if(max == 0) return 50; //divide by zero catch
      return ((val.toDouble()/max.toDouble())*100).toInt();
    } else return 50;
  }
  int getRecentPercent(Type type, String id, {DateTime value}) {
    // print('getRecentPercent() $type $id');
    final Type checkType = type == PantryItem ? this.getPantryItem(id).referenceType : type;
    final String checkId = type == PantryItem ? this.getPantryItem(id).referenceId : id;
    // DateTime oldest = DateTime.now();
    // DateTime latest = DateTime.now();
    if(checkType == Meal ) {
      if(meals == null) { print('ERROR :: getRecentPercent = meals Empty'); return 50;} //empty list catch catch
      DateTime val = value == null ? this.getMeal(checkId).recentDate : value;
      // meals.forEach((meal) {if(this.meals[0].id == meal.id && meal.recentDate != null) {oldest = meal.recentDate; latest = meal.recentDate;} //Identify First
        // if(meal.recentDate != null && meal.recentDate.difference(oldest).inDays <= 0) oldest = meal.recentDate;
        //   if(meal.recentDate != null && meal.recentDate.difference(latest).inDays >= 0) latest = meal.recentDate;});
          if(mealRecentLatest == null || mealRecentOldest ==null || mealRecentLatest.difference(mealRecentOldest).inDays == 0) return 50; //catch for no value, average no effect
          else return (((mealRecentLatest.difference(mealRecentOldest).inDays-(mealRecentLatest.difference(val).inDays))/mealRecentLatest.difference(mealRecentOldest).inDays)*100).toInt();
    } else if(checkType == Ingredient  ) {
      if(ingredients == null) {print('ERROR :: getRecentPercent = ingredeitns Empty'); return 50; }//empty list catch catch
      DateTime val = value == null ? this.getIngredient(checkId).recentDate : value;
      // ingredients.forEach((ingred) {if(this.ingredients[0].id == ingred.id && ingred.recentDate != null) {oldest = ingred.recentDate; latest = ingred.recentDate;} //Identify First
        // if(ingred.recentDate != null && ingred.recentDate.difference(oldest).inDays <= 0) oldest = ingred.recentDate;
        //   if(ingred.recentDate != null && ingred.recentDate.difference(latest).inDays >= 0) latest = ingred.recentDate;});
          if(ingredientRecentLatest.difference(ingredientRecentOldest).inDays == 0) return 50; //catch for no value, average no effect
          else return (((ingredientRecentLatest.difference(ingredientRecentOldest).inDays-(ingredientRecentLatest.difference(val).inDays))/ingredientRecentLatest.difference(ingredientRecentOldest).inDays)*100).toInt();
    } 
    else return 50;
  }
  int getCostPercentile(String id) {//removed strict type comparison 9/2020
    // print('getCostPercentile() $type $id');
    final double cost = this.getCalculatedAveragePerServingCost(id);
    int countSmaller = 0;
    final List<PriceRecord> averagedPriceList = this.getPriceList();
    if(averagedPriceList != null && averagedPriceList.isNotEmpty)
    averagedPriceList.forEach((item) {
      if(item.price < cost) countSmaller++;
    });
    if(countSmaller>0 && averagedPriceList.isNotEmpty) return ((countSmaller/averagedPriceList.length)*100).toInt(); //removed double casting for division
    else return 50;
  }

  //SORTING
  Map<String, bool> _sortingConditions = {
    'meat': false,
    'carb' : false,
    'veg' : false,
    'fruit' : false,
    'snack' : false,
    'solo' : false,
    'popularity' : true,
    'recent' : true,
    'cost' : true,
    'quantity' : true,
    'expiration' : true,
  };

  double _getRanking(Type type, String id) {
    // print('_getRanking() $type $id');
      final Type checkType = (type == PantryItem) ? this.getPantryItem(id).referenceType : type;
      final String checkId = (type == PantryItem) ? this.getPantryItem(id).referenceId : id;
      if(checkType is Meal && (this.meals == null || this.meals.isEmpty)) return 0.0;
      else if(checkType is Ingredient && (this.ingredients == null || this.ingredients.isEmpty)) return 0.0;

      const double ratioCount = 11;
      double total = 0.0;
      if(_sortingConditions['meat'] && this.getMeat(checkType, checkId)) total += 1.0/ratioCount; 
      if(_sortingConditions['carb'] && this.getCarb(checkType, checkId)) total += 1.0/ratioCount; 
      if(_sortingConditions['veg'] && this.getVeg(checkType, checkId)) total += 1.0/ratioCount;  
      if(_sortingConditions['fruit'] && this.getFruit(checkType, checkId)) total += 1.0/ratioCount;  
      if(_sortingConditions['snack'] && this.getSnack(checkType, checkId)) total += 1.0/ratioCount;  
      if(_sortingConditions['solo']) {if(this.getSolo(checkType, checkId)) total += 1.0/ratioCount;  else return 0.0; } //exclusize Filter
      // print('attributes::(${getPantryItem(id).name}) $total');
      if(_sortingConditions['popularity']){
          total += (this.getPopularityPercent(checkType, checkId))/ratioCount;
      }
        // print('popularity::(${getPantryItem(id).name}) $total');
      if(_sortingConditions['recent']){
          total += (this.getRecentPercent(checkType, checkId))/ratioCount;
        }
        // print('recent::(${getPantryItem(id).name}) $total');
      if(_sortingConditions['cost']){
        total += (this.getCostPercentile(checkId)/100)/ratioCount;
        }
        // print('cost::(${getPantryItem(id).name}) $total');
        if(_sortingConditions['quantity'] && this.pantry != null && this.pantry.isNotEmpty){
              total += (this.getCalculatedQuantity(checkType, checkId)/pantryMaxQuantity )/ratioCount;
        }
        // print('quantity::(${getPantryItem(id).name}) $total');
        if(_sortingConditions['expiration'] && this.pantry != null && this.pantry.isNotEmpty){ //soonest === oldest :)
        //   final DateTime now = DateTime.now();
        //  DateTime soonest = now;
        //  DateTime latest = now;
          // pantry.forEach((item) {if(item.expirationDate != null && soonest == now) soonest = item.expirationDate;  if(item.expirationDate != null && latest == now) latest = item.expirationDate;  
          //   if(item.expirationDate != null && item.expirationDate.difference(soonest).inDays <= 0) soonest = item.expirationDate;
          //   if(item.expirationDate != null && item.expirationDate.difference(latest).inDays >= 0) latest = item.expirationDate;});
                        // if((this.getPantryEarliestExpiration(checkId).difference(DateTime.now()).inDays ==0) || (latest.difference(soonest).inDays == 0)) total += (0.5)/ratioCount; //catch for no value, average no effect
                        // else 
            total += ((pantryExpirationLatest.difference(this.getPantryEarliestExpiration(checkId)).inSeconds)/(pantryExpirationLatest.difference(pantryExpirationOldest).inSeconds))/ratioCount;
            // print('EXPIRATION SORT: ${id} : ${((pantryExpirationLatest.difference(this.getPantryEarliestExpiration(checkId)).inSeconds)/(pantryExpirationLatest.difference(pantryExpirationOldest).inSeconds))}');
        }
        // print('total::[${checkType.toString()}]($checkId) $total');
        return total;
  }
  void _mergeSort(Type type, List a, int n) {
    if (n < 2) {return;}
    int mid = (n ~/ 2);
    List l = new List(n);
    List r = new List(n);
    for (int i = 0; i < mid; i++) {l[i] = a[i];}
    for (int i = mid; i < n; i++) { r[i - mid] = a[i];}
    _mergeSort(type, l, mid);
    _mergeSort(type, r, n - mid);
    _mergeMeal(type, a, l, r, mid, n - mid);
}
void _mergeMeal(Type type, List a, List l, List r, int left, int right) {
    int i = 0, j = 0, k = 0;
    while (i < left && j < right) {
      if(type == SortItem){
          if (l[i].popularityPercent+l[i].recentPercent
              >= //great to less
              r[i].popularityPercent+r[i].recentPercent)
                  {a[k++] = l[i++];}
        else {a[k++] = r[j++];}
      } else {
        if (_getRanking(type, l[i].id) 
              >= //great to less
              _getRanking(type, r[j].id)) 
                  {a[k++] = l[i++];}
        else {a[k++] = r[j++];}
      }
    }
    while (i < left) {a[k++] = l[i++];}
    while (j < right) {a[k++] = r[j++];}
}

/////////////////////////////////////////////////////////////////////////////////////////
///______Recommended_Meals_Methods______________________________________________________
////////////////////////////////////////////////////////////////////////////////////////
///
/////utility
bool isInList({String id, List<SortItem> itemList, List<String> stringList}){
  // print('checking: '+id);
  if(itemList != null && itemList.isNotEmpty)
    for(int i=0; i<itemList.length;i++) {if(itemList[i].referenceId==id) return true;}
  if(stringList != null && stringList.isNotEmpty)
    for(int i=0; i<stringList.length;i++) {if(stringList[i]==id) return true;}
    // print('-> allowed');
return false;
}

bool matchRecommendationLists(List<String> checkList, List<String> ruleList) {
  // print('matchRecommendationLists()'); print(checkList); print(ruleList);
  List<String> check = checkList == null ? ['Regular'] : checkList;
  if(ruleList == null) return false;
  if(ruleList.contains('Packable') && !checkList.contains('Packable')) return false;  //higher standard - absolute
  for(int i=0; i<ruleList.length; i++){
    if(check.contains(ruleList[i])) { //print('*match-${ruleList[i]}');
     return true;}
  }
  // print('*no-match');
  return false;
}

List<SortItem> getMatchingItems(List<String> alreadyList, {List<String> requestedRecommendationTypes, bool pantryOnly = false, String goal = 'random'}){ //auto insert to top of list, max 5 == 25% of 20?
   if(alreadyList == null || alreadyList.isEmpty) return [];
    //create combinematchingList, check not inList ???=> or remove from list
  List<String> combinedMatchingList = [];
  alreadyList.forEach((id) { 
    if(id is String && id.length>0 && id.startsWith('i') && this.getIngredient(id).matchingItems != null && this.getIngredient(id).matchingItems.isNotEmpty)  //alreadylist is an ingredient
        combinedMatchingList.addAll(this.getIngredient(id).matchingItems);
    else if(id is String && id.length>0 && id.startsWith('m') && this.getMeal(id).matchingItems != null && this.getMeal(id).matchingItems.isNotEmpty) 
      combinedMatchingList.addAll(this.getMeal(id).matchingItems);
  });
    //rank combine as sortitem :: https://stackoverflow.com/questions/60721401/get-most-popular-value-in-a-list
        final folded = combinedMatchingList.fold({}, (acc, curr) { // Count occurrences of each item
          acc[curr] = (acc[curr] ?? 0) + 1;
          return acc;
        }) as Map<dynamic, dynamic>;
        // Sort the keys (your values) by its occurrences
        final  sortedIds = folded.keys.toList()..sort((a, b) => folded[b].compareTo(folded[a]));
        final List<String> sortedList = new List<String>.from(sortedIds);
    //return top 5 or less
  List<SortItem> returnTop5 = [];
  if(sortedList != null)
    for(int i=0; (i<sortedList.length && returnTop5.length<5); i++){
        if(sortedList[i] is String && sortedList[i].length>0 && sortedList[i].startsWith('i') && this.getIngredient(sortedList[i]).matchingItems != null && this.getIngredient(sortedList[i]).matchingItems.isNotEmpty)  //alreadylist is an ingredient
          returnTop5.add(new SortItem(referenceType: Ingredient, referenceId: sortedList[i], popularityPercent: this.getPopularityPercent(Ingredient, sortedList[i]), recentPercent: this.getRecentPercent(Ingredient, sortedList[i])));
      else if(sortedList[i] is String && sortedList[i].length>0 && sortedList[i].startsWith('m') && this.getMeal(sortedList[i]).matchingItems != null && this.getMeal(sortedList[i]).matchingItems.isNotEmpty) 
          returnTop5.add(new SortItem(referenceType: Meal, referenceId: sortedList[i], popularityPercent: this.getPopularityPercent(Meal, sortedList[i]), recentPercent: this.getRecentPercent(Meal, sortedList[i])));
      //reject for type matching
      try{
      if(isInList(id: returnTop5.last.referenceId, itemList: [], stringList: alreadyList) || !(this.matchRecommendationLists(this.getRecommendationTypes(returnTop5.last.referenceType, returnTop5.last.referenceId), requestedRecommendationTypes))
              || (pantryOnly && (this.getCalculatedQuantity(returnTop5.last.referenceType, returnTop5.last.referenceId) > 0)) //make sure in pantry
              || (goal=='cost' && this.getCostPercentile(returnTop5.last.referenceId)>50)
                    || (goal=='quantity' && this.getCalculatedQuantity(returnTop5.last.referenceType, returnTop5.last.referenceId)==0)
                    || (goal=='meat' && !this.getMeat(returnTop5.last.referenceType, returnTop5.last.referenceId))
                    || (goal=='carb' && !this.getCarb(returnTop5.last.referenceType, returnTop5.last.referenceId))
                    || (goal=='fruit' && !this.getFruit(returnTop5.last.referenceType, returnTop5.last.referenceId))
                    || (goal=='veg' && !this.getVeg(returnTop5.last.referenceType, returnTop5.last.referenceId))
                    || (goal=='snack' && !this.getSnack(returnTop5.last.referenceType, returnTop5.last.referenceId))
                    || (goal=='solo' && !this.getSolo(returnTop5.last.referenceType, returnTop5.last.referenceId)))
          returnTop5.removeLast();
      } catch(e) {print('CatalogProvider.getMatchingItems() - List Short Match'); print(e); }
    }
    // print('Top Matching 5: ${returnTop5.toString()}');
return returnTop5;
}

//Filter out not matching from meals and ingredients that are Not cooking Only
SortItem getRecommendation({List<String> requestedRecommendationTypes, List<SortItem> currentList, List<String> alreadyList, int varietyLimit = 100, bool pantryOnly = false,  String goal = 'random',
}){ List<SortItem> recommendationList = []; 
if(currentList != null && currentList.isNotEmpty && alreadyList.isEmpty) {currentList.forEach((item) {if(item.referenceType == Meal) recommendationList.add(item);}); }
else if(currentList != null && currentList.isNotEmpty && alreadyList.isNotEmpty){currentList.forEach((item) {if(item.referenceType != Meal) recommendationList.add(item);}); }
//SORTING LIMITATIONS
final double pantryMealMaxPercent = alreadyList.isEmpty ? 0.95 : 0.15;
final double pantryMaxPercent = alreadyList.isEmpty ? 0.10 : 0.85;
final double mealsMaxPercent = alreadyList.isEmpty ? 0.95 : 0.15;
//Ingredients Fill Options in List to Max varietyLimit
final int pantryMealMaxNewItems = pantryOnly ? 3 : 3; //must grow sucessively from currentList.length
final int pantryMaxNewItems = pantryOnly ? 5 : 5;
final int mealsMaxNewItems = pantryOnly ? 0 : 8;
final int ingredientsMaxNewItems = pantryOnly ? 0 : 10;


//pantry add upto 50% OR +10+
//first check and piortize meals with ingredients in pantry
for(int i=0; i<optimizedPantryMeals.length;i++){
  if(recommendationList.length >= varietyLimit || (recommendationList.length > (varietyLimit*pantryMealMaxPercent) && (recommendationList.length >= (currentList.length+pantryMealMaxNewItems)))) break;
    if((this.getCalculatedQuantity(Meal, optimizedPantryMeals[i].id) > 0) && !isInList(id: optimizedPantryMeals[i].id, itemList: recommendationList, stringList: alreadyList) && (this.matchRecommendationLists(this.getRecommendationTypes(Meal, optimizedPantryMeals[i].id), requestedRecommendationTypes) )){int extraPoints = 0;
        if(optimizedPantryMeals[i].essentialIngredients != null && optimizedPantryMeals[i].essentialIngredients.isNotEmpty) 
          optimizedPantryMeals[i].essentialIngredients.forEach((ingredientId){if(isInList(id: ingredientId, itemList: recommendationList, stringList: alreadyList) && (this.getCalculatedQuantity(Ingredient, ingredientId) > 0)) extraPoints++;});
      recommendationList.add(new SortItem(referenceType: Meal, referenceId: optimizedPantryMeals[i].id, popularityPercent: this.getPopularityPercent(Meal, optimizedPantryMeals[i].id)+extraPoints, recentPercent: this.getRecentPercent(Meal, optimizedPantryMeals[i].id)));}
}
List optimizedPantry = goal == 'cost' ? optimizedPantryCost : goal == 'quantity' ? optimizedPantryQuantity : goal == 'meat' ? optimizedPantryMeat : goal == 'carb' ? optimizedPantryCarb : goal == 'veg' ? optimizedPantryVeg : goal == 'fruit' ? optimizedPantryFruit : goal == 'snack' ? optimizedPantrySnack : this.getPantry();
// optimizedPantry = this.sortList(type: PantryItem, popularity: true, expiration: true, recent: false, cost: cost, quantity: quantity, meat: meat, carb: carb, veg: veg, fruit: fruit, snack: snack, solo: solo);
for(int i=0; i<optimizedPantry.length; i++){
  if(recommendationList.length >= varietyLimit || (recommendationList.length > (varietyLimit*pantryMaxPercent) && (recommendationList.length >= (currentList.length+pantryMaxNewItems)))) break;
    if(!isInList(id: optimizedPantry[i].id, itemList: recommendationList, stringList: alreadyList) && !isInList(id: optimizedPantry[i].referenceId, itemList: recommendationList, stringList: alreadyList) 
        && (this.matchRecommendationLists(this.getRecommendationTypes(PantryItem, optimizedPantry[i].id), requestedRecommendationTypes))){
      Type referenceType = optimizedPantry[i].referenceType != null ? optimizedPantry[i].referenceType : PantryItem;
      String referenceId = optimizedPantry[i].referenceId != null && optimizedPantry[i].referenceId != '' ? optimizedPantry[i].referenceId : optimizedPantry[i].id;
      int popularityPercent = (optimizedPantry[i].referenceType != null && optimizedPantry[i].referenceId != null && optimizedPantry[i].referenceId != '') ? this.getPopularityPercent(optimizedPantry[i].referenceType, optimizedPantry[i].referenceId) : this.getPopularityPercent(Meal, '', value: this.getMedianPopularity(Meal));
      int recentPercent = (optimizedPantry[i].referenceType != null && optimizedPantry[i].referenceId != null && optimizedPantry[i].referenceId != '') ? this.getRecentPercent(optimizedPantry[i].referenceType, optimizedPantry[i].referenceId) : this.getRecentPercent(Meal, '', value: this.getMedianRecent(Meal));
      // print('**Pantry Adding :: ${referenceType} - $referenceId <from : ${optimizedPantry[i].id} -> ${optimizedPantry[i].name}');
      recommendationList.add(new SortItem(referenceType: referenceType, referenceId: referenceId, popularityPercent: popularityPercent, recentPercent: recentPercent));
}}
//add Meal upto 90%
List optimizedMeals = goal == 'cost' ? optimizedMealCost : goal == 'quantity' ? optimizedMealQuantity : goal == 'meat' ? optimizedMealMeat : goal == 'carb' ? optimizedMealCarb : goal == 'veg' ? optimizedMealVeg : goal == 'fruit' ? optimizedMealFruit : goal == 'snack' ? optimizedMealSnack : this.getMeals();
// optimizedMeals = this.sortList(type: Meal, popularity: true, expiration: true, recent: false, cost: cost, quantity: quantity, meat: meat, carb: carb, veg: veg, fruit: fruit, snack: snack, solo: solo);
for(int i=0; i<optimizedMeals.length; i++){
  if(recommendationList.length >= varietyLimit || (recommendationList.length > (varietyLimit*mealsMaxPercent) && (recommendationList.length >= (currentList.length+mealsMaxNewItems)))) break;
    if(!isInList(id: optimizedMeals[i].id, itemList: recommendationList, stringList: alreadyList) && (this.matchRecommendationLists(this.getRecommendationTypes(Meal, optimizedMeals[i].id), requestedRecommendationTypes)) && (!pantryOnly || (this.getCalculatedQuantity(Meal, optimizedMeals[i].id) > 0))){int extraPoints = 0;
        if(optimizedMeals[i].essentialIngredients != null && optimizedMeals[i].essentialIngredients.isNotEmpty) 
          optimizedMeals[i].essentialIngredients.forEach((ingredientId){if(isInList(id: ingredientId, itemList: recommendationList, stringList: alreadyList) && (!pantryOnly || (this.getCalculatedQuantity(Ingredient, ingredientId) > 0))) extraPoints++;});
      recommendationList.add(new SortItem(referenceType: Meal, referenceId: optimizedMeals[i].id, popularityPercent: this.getPopularityPercent(Meal, optimizedMeals[i].id)+extraPoints, recentPercent: this.getRecentPercent(Meal, optimizedMeals[i].id)));}
}
//add Ingredient to Max
List optimizedIngredients = goal == 'cost' ? optimizedIngredientCost : goal == 'quantity' ? optimizedIngredientQuantity : goal == 'meat' ? optimizedIngredientMeat : goal == 'carb' ? optimizedIngredientCarb : goal == 'veg' ? optimizedIngredientVeg : goal == 'fruit' ? optimizedIngredientFruit : goal == 'snack' ? optimizedIngredientSnack : this.getIngredients();
// optimizedIngredients = this.sortList(type: Ingredient, popularity: true, expiration: true, recent: false, cost: cost, quantity: quantity, meat: meat, carb: carb, veg: veg, fruit: fruit, snack: snack, solo: solo);
for(int i=0; i<optimizedIngredients.length; i++){
  if((recommendationList.length >= varietyLimit) || (recommendationList.length >= (currentList.length+ingredientsMaxNewItems))) break;
  if(!isInList(id: optimizedIngredients[i].id, itemList: recommendationList, stringList: alreadyList) && (this.matchRecommendationLists(this.getRecommendationTypes(Ingredient, optimizedIngredients[i].id), requestedRecommendationTypes)))
    recommendationList.add(new SortItem(referenceType: Ingredient, referenceId: optimizedIngredients[i].id, popularityPercent: this.getPopularityPercent(Ingredient, optimizedIngredients[i].id), recentPercent: this.getRecentPercent(Ingredient, optimizedIngredients[i].id)));
}
// //optimizeRecommendation
// print('NOTICE: recommendationList.length = ${recommendationList.length} -> clip pre sort?');
 _mergeSort(SortItem, recommendationList, recommendationList.length);  //just optimizes popularity and recent
 //add Matching Items to top of list, 5 == 25%
 final List<SortItem> selectionList = this.getMatchingItems(alreadyList, requestedRecommendationTypes: requestedRecommendationTypes, pantryOnly: pantryOnly, goal: goal);
 selectionList.addAll(recommendationList.where((item)=>!this.isInList(id: item.referenceId, itemList: selectionList, stringList: null)));
//  selectionList.forEach((element) {print(element.referenceId);});
 if(selectionList.isEmpty) return new SortItem(referenceType: null, referenceId: null, popularityPercent: 0, recentPercent: 0);
else {SortItem choosen = selectionList[new Random().nextInt((selectionList.length < 20 || goal == 'random') ? selectionList.length : 20)];
// print('CHOOSEN :: '+choosen.referenceType.toString() + choosen.referenceId);
// for(int i = 0; i<selectionList.length;i++){print('$i) ${selectionList[i].referenceType} - ${selectionList[i].referenceId}');}
return choosen;
}
}

}

class SortItem {
  final Type referenceType;
  final String referenceId;
  final int popularityPercent;
  final int recentPercent;

  SortItem({@required this.referenceType, @required this.referenceId, @required this.popularityPercent, @required this.recentPercent});

}


