import 'dart:core';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mealplanning/Providers/ShoppingItem.dart';
import 'package:provider/provider.dart';

import '../LocalStorage.dart';
import 'CatalogProvider.dart';
import 'Ingredient.dart';


class ShoppingListProvider with ChangeNotifier{ 
  Map<String, ShoppingItem> _shoppingList = {};
  ShoppingListProvider()  {
      this.loadLists();
  }
  void loadLists({reset = false}) async {
  if(!reset){
      this._shoppingList = await readShoppingList();
    }
      if(reset || this._shoppingList == null || this._shoppingList.isEmpty) {print(this._shoppingList); this._shoppingList.clear(); print('ShoppingList CLEARED TO DEFAULT');}
      print('ShoppingListProvider() :: loadLists() ${reset ? '*RESETTING*' : ''} -Complete');
      notifyListeners();
    // this.saveLists();
  }
  void saveLists(){
    writeShoppingList( this._shoppingList); 
  print('ShoppingListProvider() :: saveLists() -Complete');}
  
  List<ShoppingItem> get shoppingList=>_shoppingList.values.toList();

  // List<ShoppingItem> get shoppingListFound=>_shoppingList.where((item) => item.found).toList();
  // List<ShoppingItem> get shoppingListUnfound=>_shoppingList.where((item) => !item.found).toList();

  void updateShoppingList()=>notifyListeners(); 
 
  ShoppingItem getItem(String id) {
     if(_shoppingList != null && _shoppingList.isNotEmpty && _shoppingList.containsKey(id)) return _shoppingList[id];
    return new ShoppingItem(id: 's0', name: 'Missing');
  } 
   void addItem(ShoppingItem item) {
     _shoppingList.addAll({item.id: item});
    writeShoppingList( this._shoppingList); 
    return;
  }

  bool addItemByReference(ShoppingItem item) {
    ShoppingItem foundItem = _shoppingList.values.firstWhere((element) => (element.referenceId == item.referenceId), orElse: ()=>null);
    if(foundItem != null) {foundItem.servings += item.servings;
      foundItem.found = false;
    } else this.addItem(item);
    notifyListeners(); 
    writeShoppingList( this._shoppingList); 
    return foundItem != null;
  }

  int getReferenceCount(String id){
    int count = 0; 
    List<ShoppingItem> list = _shoppingList.values.toList();
    for(var i=0; i<list.length; i++) {
        if(list[i].referenceId == id) count += list[i].servings;
    } return count;
  }

  int countFound({bool found = true}){ int count = 0;
    if(_shoppingList == null || _shoppingList.isEmpty) return 0;
    else return _shoppingList.values.where((item) => (item.found==found)).length;
  }

  void removeItem(String id) {_shoppingList.remove(id); notifyListeners();writeShoppingList( this._shoppingList); }
  void clearShoppingList() {_shoppingList.clear(); notifyListeners();writeShoppingList( this._shoppingList); }
  void setItemName({String itemId, String name}){this.getItem(itemId).name = name; notifyListeners();writeShoppingList( this._shoppingList); }
  void setItemDescription({String itemId, String description}){this.getItem(itemId).description = description; notifyListeners();writeShoppingList( this._shoppingList); }
  void setItemUnitPrice({String itemId, double price}){this.getItem(itemId).unitPrice = price; notifyListeners();writeShoppingList( this._shoppingList); }
  void setItemServings({String itemId, int amount}){this.getItem(itemId).servings = amount; notifyListeners();writeShoppingList( this._shoppingList); }
  void addItemServings({String itemId, int amount}){this.getItem(itemId).servings += amount; notifyListeners();writeShoppingList( this._shoppingList); }
  void increaseItemServings(String itemId){this.getItem(itemId).servings += 1; notifyListeners();writeShoppingList( this._shoppingList); }
  void decreaseItemServings(String itemId){if(this.getItem(itemId).servings > 1) this.getItem(itemId).servings -=1; notifyListeners();writeShoppingList( this._shoppingList); }
  void markItemToggle({String itemId, bool found}){if(found==null) this.getItem(itemId).found = !this.getItem(itemId).found; else this.getItem(itemId).found = found; notifyListeners();writeShoppingList( this._shoppingList); }
  void markAllShoppingListItemsFound({bool found = true}){ if(this._shoppingList.isNotEmpty)  this._shoppingList.values.forEach((item)=>item.found=found); notifyListeners();writeShoppingList( this._shoppingList); }
  void setItemPriceUnit({String itemId, String unit, bool update = true}) {this.getItem(itemId).servingUnit = unit; if(update) notifyListeners(); writeShoppingList( this._shoppingList); } 
  void setItemReferenceType({String itemId, Type type, }) {this.getItem(itemId).referenceType=type;  notifyListeners();writeShoppingList( this._shoppingList); } 
  void setItemReferenceID({String itemId, String referenceId, BuildContext context}) { this.getItem(itemId).referenceId=referenceId; notifyListeners(); writeShoppingList( this._shoppingList); }

  //Calculations & Analysis

  List sortList({
    @required BuildContext context,
    String sortMethod = 'Dept'
  }) {List<ShoppingItem> list = this._shoppingList.values.toList();
    
              // for(var i=0; i<list.length;i++){print('$i] '+list[i].name + ' - ' + _getRanking(type, list[i].id).toString());}
    _mergeSort(context, sortMethod, list, list.length);
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


  bool isEarlierOrEqual(BuildContext context, String sortMethod, ShoppingItem first, ShoppingItem second, {place = 1}) {    //==========>>>>>>>>>>>>>>>>>SAME IS TRUE
    // return((first.servings >= second.servings));
    // print('_getRanking() $type $id');
      if(first == null || second == null) return false;
      if(sortMethod == 'Dept'){
        final catalogProvider = Provider.of<CatalogProvider>(context);

        if(catalogProvider.getFruit(first.referenceType, first.referenceId) == true && catalogProvider.getFruit(second.referenceType, second.referenceId) == false) return true;
        else if(catalogProvider.getFruit(first.referenceType, first.referenceId) == false && catalogProvider.getFruit(second.referenceType, second.referenceId) == true ) return false;
        else { //same both true || both false
            if(catalogProvider.getVeg(first.referenceType, first.referenceId) == true && catalogProvider.getVeg(second.referenceType, second.referenceId) == false) return true;
            else if(catalogProvider.getVeg(first.referenceType, first.referenceId) == false && catalogProvider.getVeg(second.referenceType, second.referenceId) == true ) return false;
            else { 
              if(catalogProvider.getMeat(first.referenceType, first.referenceId) == true && catalogProvider.getMeat(second.referenceType, second.referenceId) == false) return true;
                else if(catalogProvider.getMeat(first.referenceType, first.referenceId) == false && catalogProvider.getMeat(second.referenceType, second.referenceId) == true ) return false;
                else { 
                  if(catalogProvider.getCarb(first.referenceType, first.referenceId) == true && catalogProvider.getCarb(second.referenceType, second.referenceId) == false) return true;
                  else if(catalogProvider.getCarb(first.referenceType, first.referenceId) == false && catalogProvider.getCarb(second.referenceType, second.referenceId) == true ) return false;
                  else { 
                    if(catalogProvider.getSnack(first.referenceType, first.referenceId) == true && catalogProvider.getSnack(second.referenceType, second.referenceId) == false) return true;
                  else if(catalogProvider.getSnack(first.referenceType, first.referenceId) == false && catalogProvider.getSnack(second.referenceType, second.referenceId) == true ) return false;
                  else return true; //completly the same ?????
                  } 
                } 
            }
        }
      }
      else if(sortMethod == 'Abc'){print('Comparing: ${first.name} && ${second.name} *ABC');
          if(first.name != null && first.name.length>place && second.name != null && second.name.length>place){
            if(first.name.codeUnitAt(place-1) == second.name.codeUnitAt(place-1)){print('Comparing: ${first.name.codeUnitAt(place-1)} && ${second.name.codeUnitAt(place-1)} -equal');
              return  this.isEarlierOrEqual(context, sortMethod, first, second, place: place+1);}  //recursive
            else{print('Comparing: ${first.name.codeUnitAt(place-1)} && ${second.servings}');
              return  (first.name.codeUnitAt(place-1) < second.name.codeUnitAt(place-1));}
          } else return  true;
        }
      else if(sortMethod == 'Servings'){
        print('Comparing: ${first.servings} && ${second.servings}');
          return (first.servings >= second.servings);
        }
      else return  true; //recursive Indefinate, I don't think => always true does nothing, always false reverses order.
  }

  void _mergeSort(BuildContext context, String sortMethod, List<ShoppingItem> a, int n) {
    if (n < 2) {return;}
    int mid = (n ~/ 2);
    List<ShoppingItem> l = new List<ShoppingItem>(n);
    List<ShoppingItem> r = new List<ShoppingItem>(n);
    for (int i = 0; i < mid; i++) {l[i] = a[i];}
    for (int i = mid; i < n; i++) { r[i - mid] = a[i];}
    _mergeSort(context, sortMethod, l, mid);
    _mergeSort(context, sortMethod, r, n - mid);
    _mergeMeal(context, sortMethod, a, l, r, mid, n - mid);
}
void _mergeMeal(BuildContext context, String sortMethod, List<ShoppingItem> a, List<ShoppingItem> l, List<ShoppingItem> r, int left, int right) {
    int i = 0, j = 0, k = 0;
    while (i < left && j < right) {
        // if (l[i].servings 
        //       >= //great to less
        //       r[j].servings) 
        if(isEarlierOrEqual(context, sortMethod, l[i], r[j]))
                  {a[k++] = l[i++];}
        else {a[k++] = r[j++];}
    }
    while (i < left) {a[k++] = l[i++];}
    while (j < right) {a[k++] = r[j++];}
}
}
