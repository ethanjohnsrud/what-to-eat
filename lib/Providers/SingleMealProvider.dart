import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mealplanning/Providers/CatalogProvider.dart';
import 'package:mealplanning/Providers/MenuProvider.dart';
import 'package:mealplanning/Providers/PantryItem.dart';
import 'package:provider/provider.dart';
import 'Ingredient.dart';
import 'Meal.dart';
import 'MenuItem.dart';


class SingleMealProvider with ChangeNotifier{ 

  // final MenuSection _singleMealSection = new MenuSection(id: 'localSection');
  final MenuSection _singleMealSection = new MenuSection(id: 'uM4', name: 'Dinner', 
                  menuItemList: [
                    MenuItem(id: 'uI16',
                    name: 'Salad',
                    adjective: 'Garden',
                    referenceType: Meal,
                    referenceId: 'm2',
                    selectedIngredients: ['i1', 'i4', 'i2'],
                    cost: 0.89,
                    ),
                    MenuItem(id: 'uI7',
                    name: 'potato',
                    adjective: 'Peeled',
                    referenceType: Ingredient,
                    referenceId: 'i12',
                    cost: 0.89,
                    ),
                  ]);

  void updateMeal()=>this.notifyListeners();

 //MenuSection Operations
 MenuSection getSection() {
    return _singleMealSection;
  } 

  void setSectionName(String name){this.getSection().name = name; notifyListeners(); }
  void markSectionDone(){this.getSection().done = true; notifyListeners(); }
  void addSectionRecommendationTypes({String tag, bool update = true}) {if(this.getSection().recommendationTypes == null || this.getSection().recommendationTypes.isEmpty) this.getSection().recommendationTypes=[]; if(!this.getSection().recommendationTypes.contains(tag)) {this.getSection().recommendationTypes.add(tag); if(update) notifyListeners(); }}
  void removeSectionRecommendationTypes({String tag, bool update = true}) { if(this.getSection().recommendationTypes == null || this.getSection().recommendationTypes.isEmpty) return; this.getSection().recommendationTypes.remove(tag); if(update) notifyListeners(); }
  void increaseSectionServings() {MenuSection menuSection = this.getSection();
    if(menuSection.menuItemList != null && menuSection.menuItemList.isNotEmpty)
    menuSection.menuItemList.forEach((meal) {meal.cost = (meal.cost / menuSection.servings.toDouble()) * (menuSection.servings+1);});
    menuSection.servings +=1; 
    notifyListeners(); }
  void decreaseSectionServings() {MenuSection menuSection = this.getSection();
    if(menuSection.servings>1) {
      if(menuSection.menuItemList != null && menuSection.menuItemList.isNotEmpty)
      menuSection.menuItemList.forEach((meal) {meal.cost = (meal.cost / menuSection.servings.toDouble()) * (menuSection.servings-1);});
      menuSection.servings -=1; 
      notifyListeners(); 
    }}

   void clearSection() {this.getSection().menuItemList.clear(); notifyListeners();}

    //Menu Item Operations
  MenuItem getItem(String itemId) {
    if(_singleMealSection.menuItemList != null && _singleMealSection.menuItemList.isNotEmpty){
      for(var i=0; i<_singleMealSection.menuItemList.length;i++){
        if(_singleMealSection.menuItemList[i].id == itemId){
          return _singleMealSection.menuItemList[i];
        }
      }
    }
    return MenuItem(id: 'uI0', name: 'Missing Menu Item');
  } 

  void addItem(MenuItem item) {
    MenuSection section = this.getSection();
        for(var i=0; i<section.menuItemList.length; i++){
          if(section.menuItemList[i].id == section.id){
            section.menuItemList[i] = item;
            notifyListeners(); 
            return;
          }
        }
        section.menuItemList.insert(0,item);
        notifyListeners(); 
        return;
   
  }
  void removeItem(String itemId) {this.getSection().menuItemList.removeWhere((i) => i.id==itemId); notifyListeners(); }

  void setItemName({String itemId, String name}) {this.getItem(itemId).name = name;} 
  void setItemReferenceType({String itemId, Type type}) {this.getItem(itemId).referenceType=type;  
        this.getItem(itemId).selectedIngredients = []; notifyListeners(); } //clear selected list
  void setItemReferenceID({String itemId, String referenceId, BuildContext context}) {
    MenuItem item = this.getItem(itemId);
    item.referenceId=referenceId;
    item.name = 'Missing';
    item.cost = Provider.of<CatalogProvider>(context).getCalculatedAveragePerServingCost(referenceId, type: item.referenceType) * getSection().servings;
    String forwardingId = referenceId != null ? referenceId : '';
    Type forwardingType = item.referenceType;
    if(forwardingType == PantryItem){
        PantryItem pan = Provider.of<CatalogProvider>(context).getPantryItem(forwardingId);
        item.name = pan.name;
        item.adjective = pan.description;
        
      if(pan.referenceId != null || pan.referenceId != '') { //forward Info
          forwardingId = pan.referenceId != null ? pan.referenceId : '';
          forwardingType = pan.referenceType;
      }
    } 
    if(forwardingType == Ingredient){
      Ingredient ingredient = Provider.of<CatalogProvider>(context).getIngredient(forwardingId);
      if(item.name == 'Missing') item.name = ingredient.name != null ? ingredient.name : 'Missing';
      if(item.name == '') item.adjective = ingredient.adjective != null ? ingredient.adjective : '';
      // item.image = (ingredient.image != null || ingredient.image != '') ? ingredient.image : 'assets/food.png';
  } 
  if(forwardingType == Meal){
      Meal meal = Provider.of<CatalogProvider>(context).getMeal(forwardingId);
      if(item.name == 'Missing') item.name = meal.name != null ? meal.name : 'Missing';
      if(item.name == '') item.adjective = meal.adjective != null ? meal.adjective : '';
      // item.cost = Provider.of<CatalogProvider>(context).getCost(Meal, forwardingId) * servings;
      // item.image = (meal.image != null || meal.image != '') ? meal.image : 'assets/food.png';
      item.instructions = meal.recipe != null ? meal.recipe : '';
      if(item.selectedIngredients == null) item.selectedIngredients = [];
      if(meal.essentialIngredients != null && meal.essentialIngredients.isNotEmpty) item.selectedIngredients.addAll(meal.essentialIngredients);
      if(meal.alternativeIngredients != null && meal.alternativeIngredients.isNotEmpty) meal.alternativeIngredients.forEach((alt) {
        if(alt != null && alt.isNotEmpty){
          var random = new Random(); 
          item.selectedIngredients.add(alt[random.nextInt(alt.length)]);
        }            
       });
       double totalCost = 0.0;
      if(item.selectedIngredients != null && item.selectedIngredients.isNotEmpty){
        item.selectedIngredients.forEach((i)=>totalCost+=Provider.of<CatalogProvider>(context).getCalculatedAveragePerServingCost(i, type: Meal));
      } 
      if(item.cost == 0.0) item.cost = totalCost * getSection().servings;
  }
  // if(item.referenceType == PantryItem){ // overrite
  //     PantryItem pan = Provider.of<CatalogProvider>(context).getPantryItem(forwardingId);
  //     item.name = pan.name;
  //     item.adjective = pan.description != null ? pan.description : '';
  //     item.cost = Provider.of<CatalogProvider>(context).getCost(PantryItem, forwardingId) * Provider.of<MenuProvider>(context).getSection().servings;
  // }
            notifyListeners(); }
  void setItemAdjective({String itemId,  String adjective}) {this.getItem(itemId).adjective=adjective; notifyListeners(); }
  void setItemInstructions({String itemId,  String instructions}) {this.getItem(itemId).instructions=instructions; notifyListeners(); }
  // void setItemImage({String itemId,  String image}) {this.getItem().image=image; notifyListeners(); }
  void setItemCost({String itemId,  double cost}) {this.getItem(itemId).cost=cost; notifyListeners(); }
  void addItemIngredient({String itemId,  String ingredientId, double cost}) { //cost is optional
    MenuItem item = this.getItem(itemId);
    if(item.selectedIngredients == null) item.selectedIngredients = [];
    item.selectedIngredients.remove(ingredientId);
    item.selectedIngredients.add(ingredientId);
    if(cost != null) item.cost +=cost; if(item.cost < 0) item.cost =0.0;
    notifyListeners(); 
  }
  void removeItemIngredient({String itemId, String ingredientId, double cost}) {
    MenuItem item = this.getItem(itemId);
    if(item.selectedIngredients == null) item.selectedIngredients = [];
    item.selectedIngredients.remove(ingredientId);
    if(cost != null) item.cost -=cost; if(item.cost < 0) item.cost =0.0;
    notifyListeners(); 
  }
  void clearItemIngredients({String itemId}) {this.getItem(itemId).selectedIngredients.clear(); notifyListeners(); }
}
