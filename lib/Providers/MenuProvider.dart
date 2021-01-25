import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mealplanning/Providers/CatalogProvider.dart';
import 'package:mealplanning/Providers/PantryItem.dart';
import 'package:provider/provider.dart';
import '../LocalStorage.dart';
import 'Ingredient.dart';
import 'Meal.dart';
import 'MenuItem.dart';
import 'package:mealplanning/Data/startingMenu.dart';


class MenuProvider with ChangeNotifier{ 
  MenuProvider()  {
      this.loadLists();
  }
  void loadLists({reset = false}) async {
  if(!reset){
      this._menuList = await readMenuList();
    }
      if(reset || this._menuList == null || this._menuList.isEmpty) { this._menuList = Map.fromIterable(startingMenuList, key: (v) => v.id, value: (v) => v); print('MENU SET TO DEFAULT');}
      print('MenuProvider() :: loadLists() ${reset ? '*RESETTING*' : ''} -Complete');
      notifyListeners();
    // this.saveLists();
  }
  void saveLists(){
    writeMenuList( this._menuList);
  print('MenuProvider() :: saveLists() -Complete');}
  
  Map<String, Menu> _menuList = {};

  List<Menu> get menuList=>_menuList.values.toList();

  void updateMenu()=>notifyListeners(); 

  //MenuProvider Operations
  Menu getMenu(String id) {
    if(_menuList != null && _menuList.isNotEmpty && _menuList.containsKey(id)) return _menuList[id];
    print('Error :: MenuProvider.getMenu() -> Menu Look Up Failed: $id');
    return new Menu(id: 'm0', name: 'Missing');
  } 
  void setMenuName({String menuId, String name}){this.getMenu(menuId).name = name; writeMenuList( this._menuList); notifyListeners();}

   void addMenu(Menu item) {
        _menuList.addAll({item.id: item});
        notifyListeners(); 
        writeMenuList( this._menuList); 
        return;
    }

  void removeMenu(String id) {_menuList.remove(id); notifyListeners(); writeMenuList( this._menuList); }
  void clearMenu(String id) {this.getMenu(id).menuDayList.clear(); notifyListeners();writeMenuList( this._menuList); }

  //MenuDay Operations
  MenuDay getMenuDay({String menuId, String dayId}) {
     for(var m=0; m<_menuList.length;m++){
      if(_menuList.values.toList()[m].id == menuId || menuId == null || menuId == ''){
        for(var d=0; d<_menuList.values.toList()[m].menuDayList.length;d++){
          if(_menuList.values.toList()[m].menuDayList[d].id == dayId){
            return _menuList.values.toList()[m].menuDayList[d];
          }
        }
      }
    }
    return MenuDay(id: 'uD0', name: 'Missing Menu Day');
  } 
  void setMenuDayName({String menuId, String dayId, String name}){this.getMenuDay(menuId: menuId, dayId: dayId).name = name; notifyListeners(); writeMenuList( this._menuList); }
  void setMenuDayDate({String menuId, String dayId, DateTime date}){this.getMenuDay(menuId: menuId, dayId: dayId).date = date; notifyListeners(); writeMenuList( this._menuList); }

  void addMenuDay({String menuId, MenuDay day}) {
    Menu menu = this.getMenu(menuId);
        for(var d=0; d<menu.menuDayList.length;d++){
          if(menu.menuDayList[d].id == day.id){
            menu.menuDayList[d] = day;
            notifyListeners(); 
            writeMenuList( this._menuList);
            return;
          }
        }
        menu.menuDayList.add(day);
        notifyListeners(); 
        writeMenuList( this._menuList);
        return;
  }
  void removeMenuDay({String menuId, String dayId}) {this.getMenu(menuId).menuDayList.removeWhere((i) => i.id==dayId); notifyListeners();writeMenuList( this._menuList);}
  void clearMenuDay({String menuId, String dayId}) {this.getMenuDay(dayId: dayId, menuId: menuId).menuSectionList.clear(); notifyListeners();writeMenuList( this._menuList);}

 //MenuSection Operations
 MenuSection getMenuSection({String menuId, String dayId, String sectionId}) {
     for(var m=0; m<_menuList.length;m++){
      if(_menuList.values.toList()[m].id == menuId || menuId == null || menuId == ''){
        for(var d=0; d<_menuList.values.toList()[m].menuDayList.length;d++){
          if(_menuList.values.toList()[m].menuDayList[d].id == dayId || dayId == null || dayId == ''){
            for(var s=0; s<_menuList.values.toList()[m].menuDayList[d].menuSectionList.length;s++){
              if(_menuList.values.toList()[m].menuDayList[d].menuSectionList[s].id == sectionId){
                return _menuList.values.toList()[m].menuDayList[d].menuSectionList[s];
              }
            }
          }
        }
      }
    }
    return MenuSection(id: 'uM0', name: 'Missing Menu Item');
  } 

  void setMenuSectionName({String menuId, String dayId, String sectionId, String name}){this.getMenuSection(menuId: menuId, dayId: dayId, sectionId: sectionId).name = name; notifyListeners(); writeMenuList( this._menuList);}
  void markMenuSectionDone({String menuId, String dayId, String sectionId, }){this.getMenuSection(menuId: menuId, dayId: dayId, sectionId: sectionId).done = true; notifyListeners(); writeMenuList( this._menuList);}
  void addMenuSectionRecommendationTypes({String menuId, String dayId, String sectionId, String tag, bool update = true}) {if(this.getMenuSection(menuId: menuId, dayId: dayId, sectionId: sectionId).recommendationTypes == null || this.getMenuSection(menuId: menuId, dayId: dayId, sectionId: sectionId, ).recommendationTypes.isEmpty) this.getMenuSection(menuId: menuId, dayId: dayId, sectionId: sectionId, ).recommendationTypes=[]; if(!this.getMenuSection(menuId: menuId, dayId: dayId, sectionId: sectionId, ).recommendationTypes.contains(tag)) {this.getMenuSection(menuId: menuId, dayId: dayId, sectionId: sectionId).recommendationTypes.add(tag); if(update) notifyListeners(); writeMenuList( this._menuList);}}
  void removeMenuSectionRecommendationTypes({String menuId, String dayId, String sectionId, String tag, bool update = true}) { if(this.getMenuSection(menuId: menuId, dayId: dayId, sectionId: sectionId).recommendationTypes == null || this.getMenuSection(menuId: menuId, dayId: dayId, sectionId: sectionId, ).recommendationTypes.isEmpty) return; this.getMenuSection(menuId: menuId, dayId: dayId, sectionId: sectionId, ).recommendationTypes.remove(tag); if(update) notifyListeners(); writeMenuList( this._menuList);}
  void increaseMenuSectionServings({String menuId, String dayId, String sectionId, }) {MenuSection menuSection = this.getMenuSection(menuId: menuId, dayId: dayId, sectionId: sectionId);
    if(menuSection.menuItemList != null && menuSection.menuItemList.isNotEmpty)
    menuSection.menuItemList.forEach((meal) {meal.cost = (meal.cost / menuSection.servings.toDouble()) * (menuSection.servings+1);});
    menuSection.servings +=1; 
    notifyListeners(); writeMenuList( this._menuList);}
  void decreaseMenuSectionServings({String menuId, String dayId, String sectionId, }) {MenuSection menuSection = this.getMenuSection(menuId: menuId, dayId: dayId, sectionId: sectionId);
    if(menuSection.servings>1) {
      if(menuSection.menuItemList != null && menuSection.menuItemList.isNotEmpty)
      menuSection.menuItemList.forEach((meal) {meal.cost = (meal.cost / menuSection.servings.toDouble()) * (menuSection.servings-1);});
      menuSection.servings -=1; 
      notifyListeners(); writeMenuList( this._menuList);
    }}

  void addMenuSection({String menuId, String dayId, MenuSection section}) {
    MenuDay day = this.getMenuDay(menuId: menuId, dayId: dayId);
        for(var s=0; s<day.menuSectionList.length; s++){
          if(day.menuSectionList[s].id == day.id){
            day.menuSectionList[s] = section;
            notifyListeners(); 
            writeMenuList( this._menuList);
            return;
          }
        }
        day.menuSectionList.insert(0, section);
        notifyListeners(); 
        writeMenuList( this._menuList);
        return;
   
  }
  void removeMenuSection({String menuId, String dayId, String sectionId}) {this.getMenuDay(menuId: menuId, dayId: dayId).menuSectionList.removeWhere((i) => i.id==sectionId); notifyListeners();writeMenuList( this._menuList);}
  void clearMenuSection({String menuId, String dayId, String sectionId}) {this.getMenuSection(dayId: dayId, menuId: menuId, sectionId: sectionId).menuItemList.clear(); notifyListeners();writeMenuList( this._menuList);}

    //Menu Item Operations
  MenuItem getMenuItem({String menuId, String dayId, String sectionId, String itemId}) {
     for(var m=0; m<_menuList.length;m++){
      if(_menuList.values.toList()[m].id == menuId || menuId == null || menuId == ''){
        for(var d=0; d<_menuList.values.toList()[m].menuDayList.length;d++){
          if(_menuList.values.toList()[m].menuDayList[d].id == dayId || dayId == null || dayId == ''){
            for(var s=0; s<_menuList.values.toList()[m].menuDayList[d].menuSectionList.length;s++){
              if(_menuList.values.toList()[m].menuDayList[d].menuSectionList[s].id == sectionId  || sectionId == null || sectionId == ''){
                for(var i=0; i<_menuList.values.toList()[m].menuDayList[d].menuSectionList[s].menuItemList.length;i++){
                  if(_menuList.values.toList()[m].menuDayList[d].menuSectionList[s].menuItemList[i].id == itemId){
                    return _menuList.values.toList()[m].menuDayList[d].menuSectionList[s].menuItemList[i];
                  }
                }
              }
            }
          }
        }
      }
    }
    return MenuItem(id: 'uI0', name: 'Missing Menu Item');
  } 

  void addMenuItem({String menuId, String dayId, String sectionId, MenuItem item}) {
    MenuSection section = this.getMenuSection(menuId: menuId, dayId: dayId, sectionId: sectionId);
        for(var i=0; i<section.menuItemList.length; i++){
          if(section.menuItemList[i].id == section.id){
            section.menuItemList[i] = item;
            notifyListeners(); 
            writeMenuList( this._menuList);
            return;
          }
        }
        section.menuItemList.insert(0,item);
        notifyListeners(); 
        writeMenuList( this._menuList);
        return;
   
  }
  void removeMenuItem({String menuId, String dayId, String sectionId, String itemId}) {this.getMenuSection(dayId: dayId, menuId: menuId, sectionId: sectionId).menuItemList.removeWhere((i) => i.id==itemId); notifyListeners(); writeMenuList( this._menuList);}

  void setMenuItemName({String menuId, String dayId, String sectionId, String itemId, String name}) {this.getMenuItem(menuId: menuId, dayId: dayId, sectionId: sectionId, itemId: itemId).name = name;} 
  void setMenuItemReferenceType({String menuId, String dayId, String sectionId, String name, String itemId, Type type}) {this.getMenuItem(menuId: menuId, dayId: dayId, sectionId: sectionId, itemId: itemId).referenceType=type;  
        this.getMenuItem(menuId: menuId, dayId: dayId, sectionId: sectionId, itemId: itemId).selectedIngredients = []; notifyListeners(); writeMenuList( this._menuList);} //clear selected list
  void setMenuItemReferenceID({String menuId, String dayId, String sectionId, String itemId, String referenceId, BuildContext context}) {
    MenuItem item = this.getMenuItem(menuId: menuId, dayId: dayId, sectionId: sectionId, itemId: itemId);
    item.referenceId=referenceId;
    item.name = 'Missing';
    item.cost = Provider.of<CatalogProvider>(context).getCalculatedAveragePerServingCost(referenceId, type: item.referenceType) * Provider.of<MenuProvider>(context).getMenuSection(menuId: menuId, dayId: dayId, sectionId: sectionId).servings;
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
      if(item.cost == 0.0) item.cost = totalCost * Provider.of<MenuProvider>(context).getMenuSection(menuId: menuId, dayId: dayId, sectionId: sectionId).servings;
  }
  // if(item.referenceType == PantryItem){ // overrite
  //     PantryItem pan = Provider.of<CatalogProvider>(context).getPantryItem(forwardingId);
  //     item.name = pan.name;
  //     item.adjective = pan.description != null ? pan.description : '';
  //     item.cost = Provider.of<CatalogProvider>(context).getCost(PantryItem, forwardingId) * Provider.of<MenuProvider>(context).getMenuSection(menuId: menuId, dayId: dayId, sectionId: sectionId).servings;
  // }
            notifyListeners(); writeMenuList( this._menuList);}
  void setMenuItemAdjective({String menuId, String dayId, String sectionId, String itemId,  String adjective}) {this.getMenuItem(menuId: menuId, dayId: dayId, sectionId: sectionId, itemId: itemId).adjective=adjective; notifyListeners(); writeMenuList( this._menuList);}
  void setMenuItemInstructions({String menuId, String dayId, String sectionId, String itemId,  String instructions}) {this.getMenuItem(menuId: menuId, dayId: dayId, sectionId: sectionId, itemId: itemId).instructions=instructions; notifyListeners(); writeMenuList( this._menuList);}
  // void setMenuItemImage({String menuId, String dayId, String sectionId, String itemId,  String image}) {this.getMenuItem(menuId: menuId, dayId: dayId, sectionId: sectionId, itemId: itemId).image=image; notifyListeners(); writeMenuList( this._menuList);}
  void setMenuItemCost({String menuId, String dayId, String sectionId, String itemId,  double cost}) {this.getMenuItem(menuId: menuId, dayId: dayId, sectionId: sectionId, itemId: itemId).cost=cost; notifyListeners(); writeMenuList( this._menuList);}
  void addMenuItemIngredient({String menuId, String dayId, String sectionId, String itemId,  String ingredientId, double cost}) { //cost is optional
    MenuItem item = this.getMenuItem(menuId: menuId, dayId: dayId, sectionId: sectionId, itemId: itemId);
    if(item.selectedIngredients == null) item.selectedIngredients = [];
    item.selectedIngredients.remove(ingredientId);
    item.selectedIngredients.add(ingredientId);
    if(cost != null) item.cost +=cost; if(item.cost < 0) item.cost =0.0;
    notifyListeners(); writeMenuList( this._menuList);
  }
  void removeMenuItemIngredient({String menuId, String dayId, String sectionId, String itemId, String ingredientId, double cost}) {
    MenuItem item = this.getMenuItem(menuId: menuId, dayId: dayId, sectionId: sectionId, itemId: itemId);
    if(item.selectedIngredients == null) item.selectedIngredients = [];
    item.selectedIngredients.remove(ingredientId);
    if(cost != null) item.cost -=cost; if(item.cost < 0) item.cost =0.0;
    notifyListeners(); writeMenuList( this._menuList);
  }
  void clearMenuItemIngredients({String menuId, String dayId, String sectionId, String itemId}) {this.getMenuItem(dayId: dayId, menuId: menuId, sectionId: sectionId, itemId: itemId).selectedIngredients.clear(); notifyListeners(); writeMenuList( this._menuList);}
}

class Menu { 
  Menu({this.id, this.name = 'Menu', this.menuDayList}){
    if(this.menuDayList == null) menuDayList = [];
  }
  @required final String id;
  String name = 'Menu';
  List<MenuDay> menuDayList = [];

 Map toJson() {//print('Menu.toJson()');
 List<Map> dayList = (menuDayList != null && menuDayList.isNotEmpty) ?  this.menuDayList.map((i) => i.toJson()).toList() : null;
    // String dayList = (menuDayList != null && menuDayList.isNotEmpty) ? jsonEncode(menuDayList) : jsonEncode([]);
    // print(dayList.toString());
    return {
      'id' : this.id,
      'name' : this.name,
      'menuDayList' : dayList
    };
  }
  factory Menu.fromJson(Map<String, dynamic> json) {//print('Menu.fromJson()');
      var listCollection = json['menuDayList'] as List;
     List<MenuDay> dayList = (listCollection != null && listCollection.isNotEmpty) ? listCollection.map((dayJson) => MenuDay.fromJson(dayJson)).toList() : [];
    //  print(json['id']);
    //  print(json['name']);
    //  print(dayList);

      return new Menu(
        id:  json['id'], 
        name: json['name'],
        menuDayList: dayList,
        );
    }
}

class MenuDay { 
  MenuDay({this.id, this.name = 'MenuDay', this.date, this.menuSectionList}){
    if(this.menuSectionList == null) menuSectionList = [];
  }
  @required final String id;
  String name = 'MenuDay';
  DateTime date = DateTime.now();
  List<MenuSection> menuSectionList = [];

   Map toJson() {//print('MenuDay.toJson()');
   List<Map> sectionList = (menuSectionList != null && menuSectionList.isNotEmpty) ?  this.menuSectionList.map((i) => i.toJson()).toList() : null;
    // String sectionList = (menuSectionList != null && menuSectionList.isNotEmpty) ? jsonEncode(menuSectionList) : '';
    // print(menuSectionList);
    return {
      'id' : this.id,
      'name' : this.name,
      'date' : this.date.toString(),
      'menuSectionList' : sectionList
    };
  }
  factory MenuDay.fromJson(Map<String, dynamic> json) {//print('MenuDay.fromJson()');
      var listCollection = json['menuSectionList'] as List;
     List<MenuSection> sectionList = (listCollection != null && listCollection.isNotEmpty) ? listCollection.map((sectionJson) => MenuSection.fromJson(sectionJson)).toList() : [];
    //  print(json['id']);
    //  print(json['name']);
    //  print(DateTime.parse(json['date']));
    //  print(sectionList);

      return new MenuDay(
        id:  json['id'], 
        name: json['name'],
        date: DateTime.parse(json['date']),
        menuSectionList: sectionList,
        );
    }
}

class MenuSection { 
  MenuSection({this.id, this.name = 'MenuMeal', this.servings = 1, this.recommendationTypes, this.menuItemList, this.done = false}){
    if(this.recommendationTypes == null) recommendationTypes = ['Regular'];
    if(this.menuItemList == null) menuItemList = [];
    // print('$name : ${recommendationTypes.toString()}');
  }
  @required final String id;
  String name = 'MenuMeal';
  int servings = 1;
  bool done = false;
  List<String> recommendationTypes = ['Regular'];
  List<MenuItem> menuItemList = [];
  
  get cost {
    double total = 0.0;
    if(menuItemList != null)
      menuItemList.forEach((item)=>total +=item.cost);
    return total;
  }

  Map toJson() {//print('MenuSection.toJson()');
  List<Map> itemList = (menuItemList != null && menuItemList.isNotEmpty) ?  this.menuItemList.map((i) => i.toJson()).toList() : null;
  String recommendationList = (this.recommendationTypes != null && this.recommendationTypes.isNotEmpty) ? jsonEncode(this.recommendationTypes) : '';

    // String itemList = (menuItemList != null && menuItemList.isNotEmpty) ? jsonEncode(menuItemList) : '';
    // print(itemList);
    return {
      'id' : this.id,
      'name' : this.name,
      'recommendationTypes' : recommendationList,
      'servings' : this.servings.toString(),
      'done' : this.done.toString(),
      'menuItemList' : itemList
    };
  }
  factory MenuSection.fromJson(Map<String, dynamic> json) {//print('MenuSection.fromJson()');
      var listCollection = json['menuItemList'] as List;
    List<String> recommendationList = (json['recommendationTypes'] != null && json['recommendationTypes'] !='') ? List.from(jsonDecode(json['recommendationTypes'])) : [];
     List<MenuItem> itemList = (listCollection != null && listCollection.isNotEmpty) ? listCollection.map((itemJson) => MenuItem.fromJson(itemJson)).toList() : [];
    //  print(json['id']);
    //  print(json['name']);
    //  print(json['recommendationType']);
    //  print(int.parse(json['servings']));
    //  print(json['packable'].toLowerCase() == 'true');
    //  print(json['done'].toLowerCase() == 'true');
    //  print(itemList);

      return new MenuSection(
        id:  json['id'], 
        name: json['name'],
        recommendationTypes: recommendationList,
        servings:  int.parse(json['servings']),
        done: json['done'].toLowerCase() == 'true',

        menuItemList: itemList,
        );
    }

}
//String jsonTags = jsonEncode(tags);
//List<Tag> _tags = tagObjsJson.map((tagJson) => Tag.fromJson(tagJson)).toList();