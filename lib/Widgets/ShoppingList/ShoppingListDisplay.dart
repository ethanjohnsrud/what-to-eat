import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mealplanning/Providers/CatalogProvider.dart';
import 'package:mealplanning/Providers/Ingredient.dart';
import 'package:mealplanning/Providers/Meal.dart';
import 'package:mealplanning/Providers/MenuProvider.dart';
import 'package:mealplanning/Providers/PantryItem.dart';
import 'package:mealplanning/Providers/Settings.dart';
import 'package:mealplanning/Providers/ShoppingItem.dart';
import 'package:mealplanning/Providers/ShoppingListProvider.dart';
import 'package:mealplanning/Widgets/AppDrawer.dart';
import 'package:mealplanning/Widgets/Catalog/Catalog.dart';
import 'package:mealplanning/Widgets/EditBlank.dart';
import 'package:mealplanning/Widgets/ShoppingList/ShoppingListItem.dart';
import 'package:provider/provider.dart';

import 'MealIngredientsSelectionPage.dart';
import 'SelectMenuPage.dart';
import 'ShoppingListItemEdit.dart';

class ShoppingListDisplay extends StatefulWidget {
  static const routeName = '/ShoppingList';

  @override
  _ShoppingListDisplayState createState() => _ShoppingListDisplayState();
}

class _ShoppingListDisplayState extends State<ShoppingListDisplay> {
  void initState () {
    super.initState();
    sortSelection = 'Dept';
    // displayList = Provider.of<ShoppingListProvider>(context).sortList(context: context, sortMethod: sortSelection);
  }
  String sortSelection = 'Dept';
  final List<String> sortOptions = ['Dept', 'Abc', 'Servings',];  //Hard coded

  List<ShoppingItem> sortedList = [];
  
  final menuController = PageController(viewportFraction: 1, initialPage: 0);

  void addToPantry({BuildContext context, String itemId}){
    ShoppingItem item = Provider.of<ShoppingListProvider>(context).getItem(itemId);
    final String newId = Provider.of<Settings>(context).getUniqueID(context, PantryItem);
    Provider.of<CatalogProvider>(context).addPantryItem(new PantryItem(id: newId,
              name: item.name,
              description: item.description,
              referenceType: item.referenceType,
              referenceId: item.referenceId,
              quantity: item.servings-Provider.of<CatalogProvider>(context).getPantryQuantity(item.referenceId),
    ));
    print('Finished_addingToPentry');
    // showPantryItemEdit(context: context, item: Provider.of<CatalogProvider>(context).getPantryItem(newId), onExitUpdate: () {});
  }

  @override
  Widget build(BuildContext context) {
    print('Building -> ShoppingListDisplay');
    final shoppingListProvider = Provider.of<ShoppingListProvider>(context);
    final catalogProvider = Provider.of<CatalogProvider>(context);
    final settings = Provider.of<Settings>(context);

    String getNewId(Type type)=>settings.getUniqueID(context, type);

    if(this.sortedList == null || this.sortedList == [] || this.sortedList.isEmpty) 
        this.sortedList = Provider.of<ShoppingListProvider>(context).sortList(context: context, sortMethod: sortSelection); //attempt for inital setup

    final Widget topRow = Expanded(child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        FlatButton(child: Text('Add Meal',style: TextStyle(fontSize: 18,  fontFamily: 'OpenSans', color:Theme.of(context).primaryColor)),
            onPressed: () {setState(() {
              Navigator.of(context).push(MaterialPageRoute(builder:(context)=>Catalog(displayType: Meal, allowAdd: false, selectionMode: true, selectionMultiple: false, popAfterSelection: false,
            selectionCallBack: (Meal meal) { Navigator.of(context).pop();
              getMealIngredientsSelection(context: context, mealId: meal.id, selectionCallBack: (List<String> ingredientList) { 
                if(ingredientList != null && ingredientList.isNotEmpty) ingredientList.forEach((ingredientId){ Ingredient ingredient = catalogProvider.getIngredient(ingredientId);
                        shoppingListProvider.addItemByReference(new ShoppingItem(id: getNewId(ShoppingItem), name: ingredient.name, referenceType: Ingredient, referenceId: ingredientId, description: ingredient.adjective, 
                        unitPrice: catalogProvider.getCalculatedAveragePerServingCost(meal.id, type: Meal),
                        servingUnit: catalogProvider.getBestPriceUnit(ingredientId)));
                }); else { shoppingListProvider.addItemByReference(new ShoppingItem(id: getNewId(ShoppingItem), name: meal.name, referenceType: Meal, referenceId: meal.id, description: meal.adjective, 
                        unitPrice: catalogProvider.getCalculatedAveragePerServingCost(meal.id, type: Meal),
                        servingUnit: catalogProvider.getBestPriceUnit(meal.id)));
                } }, onExitUpdate: () {});
            })));});}
        ),
        FlatButton(child: Text('Add Pantry',style: TextStyle(fontSize: 18,  fontFamily: 'OpenSans', color:Theme.of(context).primaryColor)),
            onPressed: () {setState(() {
              Navigator.of(context).push(MaterialPageRoute(builder:(context)=>Catalog(displayType: PantryItem, allowAdd: false, selectionMode: true, selectionMultiple: false, popAfterSelection: false,
            selectionCallBack: (PantryItem item) { Navigator.of(context).pop(); 
                  shoppingListProvider.addItemByReference(new ShoppingItem(id: settings.getUniqueID(context, ShoppingItem), name: item.name, referenceType: item.referenceType == null ? PantryItem : item.referenceType, referenceId: item.referenceId == null ? item.id : item.referenceId, description: item.description, 
                  unitPrice: item.referenceType == Ingredient ? ((Provider.of<CatalogProvider>(context).getCalculatedAveragePerServingCost(item.referenceId, type: Ingredient))* pow(10, 2).round()) / pow(10, 2) : catalogProvider.getCalculatedAveragePerServingCost(item.referenceId, type: item.referenceType),
                  servingUnit: catalogProvider.getBestPriceUnit(item.referenceId)));
            })));});}
        ),
        FlatButton(child: Text('Add Ingredient',style: TextStyle(fontSize: 18,  fontFamily: 'OpenSans', color:Theme.of(context).primaryColor)),
            onPressed: () { setState(() {
              Navigator.of(context).push(MaterialPageRoute(builder:(context)=>Catalog(displayType: Ingredient, allowAdd: false, selectionMode: true, popAfterSelection: true, selectionMultiple: true,
            selectionCallBack: (List addList) {if(addList != null && addList.isNotEmpty) addList.forEach((ingredientId){Ingredient ingredient = catalogProvider.getIngredient(ingredientId);
                shoppingListProvider.addItemByReference(new ShoppingItem(id: settings.getUniqueID(context, ShoppingItem), name: ingredient.name, referenceType: Ingredient, referenceId: ingredientId, description: ingredient.adjective, 
                unitPrice: ((Provider.of<CatalogProvider>(context).getCalculatedAveragePerServingCost(ingredient.id, type: Ingredient))* pow(10, 2).round()) / pow(10, 2),
                servingUnit: catalogProvider.getBestPriceUnit(ingredientId)));
                  //getMealIngredientsSelection
            });}
            )));});}
        ),
      ]),
    );

    final Widget sortSlider = Transform.scale( scale: 1,
            child: SizedBox( height: 20, 
                          child: SliderTheme(
      data: SliderTheme.of(context).copyWith(
        trackShape: RoundedRectSliderTrackShape(),
        trackHeight: 5.0,
        // thumbShape: RoundSliderThumbShape(enabledThumbRadius: 12.0),
        tickMarkShape: RoundSliderTickMarkShape(),
        valueIndicatorShape: PaddleSliderValueIndicatorShape(),
        valueIndicatorTextStyle: TextStyle(
          color: Colors.black, fontSize: 20,
        ),
      ),
      child: Slider(
              value: this.sortOptions.indexOf(this.sortSelection).toDouble(), 
              onChanged: (newValue) {setState(() {this.sortSelection=this.sortOptions[newValue.toInt()];  this.sortedList = shoppingListProvider.sortList(context: context, sortMethod: sortSelection);});},
              activeColor: Theme.of(context).primaryColor,
              inactiveColor: Colors.grey[900],
              divisions: this.sortOptions.length-1,
              min: 0.0,
              max: this.sortOptions.isNotEmpty ? (this.sortOptions.length-1).toDouble() : 0.0,
              label: settings.nameTags ? 'Sort by: ${this.sortSelection}' : this.sortSelection,
              ),),
            ),
          );

    final Widget bottomRow = Expanded(child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,   children: [
        FlatButton(child: Text('CLEAR',style: TextStyle(fontSize: 18,  fontFamily: 'OpenSans', fontWeight: FontWeight.w600, color:Colors.red[900])),
            onPressed: () {shoppingListProvider.clearShoppingList(); this.setState(() {sortedList = [];});},
        ),
        FlatButton(child: Text('Add Menu',style: TextStyle(fontSize: 18,  fontFamily: 'OpenSans', fontWeight: FontWeight.w800, color:Colors.grey[900])), color:Theme.of(context).primaryColor, shape: RoundedRectangleBorder(borderRadius:BorderRadius.only(topLeft: Radius.circular(10.0), topRight: Radius.circular(10.0)),  ),
            onPressed: () {setState(() {getMenuSelection(context: context, onExitUpdate: () {}, selectionCallBack: (id) {Menu menu = Provider.of<MenuProvider>(context).getMenu(id);
                if(menu!=null && id != null && menu.menuDayList!=null && menu.menuDayList.isNotEmpty)
                    menu.menuDayList.forEach((day) {
                      if(day.menuSectionList!= null && day.menuSectionList.isNotEmpty)
                          day.menuSectionList.forEach((section) { 
                              if(section.menuItemList!=null && section.menuItemList.isNotEmpty)
                                  section.menuItemList.forEach((item) {// print('adding'+item.name);
                                      if((catalogProvider.getPantryQuantity(item.referenceId) < (shoppingListProvider.getReferenceCount(item.referenceId)+1)) && (item.referenceType == Meal && item.selectedIngredients.isNotEmpty))
                                        item.selectedIngredients.forEach((ingredientId) { Ingredient ingredient = catalogProvider.getIngredient(ingredientId);
                                          shoppingListProvider.addItemByReference(new ShoppingItem(id: settings.getUniqueID(context, ShoppingItem), name: ingredient.name, referenceType: Ingredient, referenceId: ingredientId, description: ingredient.adjective, servings: section.servings,
                                            unitPrice: ((Provider.of<CatalogProvider>(context).getCalculatedAveragePerServingCost(ingredientId, type: Ingredient))* pow(10, 2).round()) / pow(10, 2)  as double,
                                            servingUnit: catalogProvider.getBestPriceUnit(ingredientId)));
                                        });
                                      else
                                        shoppingListProvider.addItemByReference(new ShoppingItem(id: settings.getUniqueID(context, ShoppingItem), name: item.name, referenceType: item.referenceType == null ? PantryItem : item.referenceType, referenceId: item.referenceId == null || item.referenceId == '' ? item.id : item.referenceId, description: item.adjective, servings: section.servings,
                                            unitPrice: item.referenceType == Ingredient ? ((Provider.of<CatalogProvider>(context).getCalculatedAveragePerServingCost(item.referenceId, type: Ingredient))* pow(10, 2).round()) / pow(10, 2)  as double : ((item.cost/section.servings)*4) as double,
                                            servingUnit: catalogProvider.getBestPriceUnit(item.referenceId)));
                                  });
                          });
                    });                 
                });             
            });}
        ),
        FlatButton(child: settings.nameTags ? Text('Add Custom',style: TextStyle(fontSize: 18,  fontFamily: 'OpenSans', color:Theme.of(context).primaryColor)) : Icon(Icons.add, color: Theme.of(context).primaryColor),
            onPressed: () {setState(() {
              final String newId = settings.getUniqueID(context, ShoppingItem);
              shoppingListProvider.addItem(new ShoppingItem(id:  newId, name: 'Custom Entry', referenceType: PantryItem, referenceId: ''));
              showShoppingListItemEdit(context: context, itemId: newId, onExitUpdate: () {});
            });}
        ),
      ]),
    );

//Make Two Lists
List<ShoppingListItem> foundList = [];
List<ShoppingListItem> unFoundList = [];
// shoppingListProvider.shoppingList.forEach((item) {
  this.sortedList.forEach((item) {
    if(item.found)
      foundList.add(ShoppingListItem(itemId: item.id, addToPantryCall: ()=>this.addToPantry(context: context, itemId: item.id)));
    else
      unFoundList.add(ShoppingListItem(itemId: item.id, addToPantryCall: ()=>this.addToPantry(context: context, itemId: item.id)));
 });

 List <Widget> displayList = [];
      displayList.addAll(unFoundList);
      displayList.add(Divider(thickness: 3, color: Colors.grey[700], height: 30,));
      displayList.addAll(foundList);

    final List<Widget> bottomBar = [ sortSlider, topRow, bottomRow];
    // if(settings.nameTags)
    bottomBar.add(BottomBanner('SHOPPING LIST'));

    return Scaffold(
      backgroundColor: Colors.grey[900],
      drawer: AppDrawer(),
      bottomNavigationBar:  Container( height: 125, color: Colors.grey[900],
      child: Column(mainAxisAlignment: MainAxisAlignment.end, children: bottomBar),
        ),

      body: 
         Container(margin: EdgeInsets.only(top: settings.accountForNotch ? settings.notchAdjustment : 5),
                  child: ListView(
            padding: EdgeInsets.all(2),
            children: displayList,



          //Attempt Failed to derive correct index for each item from master list
              // int countUnFound = 0;
              //   shoppingListProvider.shoppingList.forEach((item){if(!item.found)countUnFound++;});
              // if(index<countUnFound) {
              //   int skips = 0;
              //   for(int i=0; i<index; i++){if(shoppingListProvider.shoppingList[i].found)skips +=1;}
              //   for(int i=(index+skips+1); i<shoppingListProvider.shoppingList.length; i++){
              //     if(!shoppingListProvider.shoppingList[i].found){ 
              //       print('unFound-> '+i.toString());
              //           return ShoppingListItem(itemId: shoppingListProvider.shoppingList[i].id, addToPantryCall: ()=>this.addToPantry(context: context, itemId: shoppingListProvider.shoppingList[i].id));
              //     }
              //   }
              // } else if(index==countUnFound)
              //     return Divider(thickness: 3, color: Colors.grey[700], height: 30,);
              // else //index>countUnFound
              // // return SizedBox(height: 1);
              // {
              // int skips = 0;
              // int countAtLastFound = 0;
              // for(int i=0; i<index; i++){if(!shoppingListProvider.shoppingList[i].found){skips +=1;} else countAtLastFound=i;}
              // for(int i=countAtLastFound-skips+1; i<shoppingListProvider.shoppingList.length; i++){
              //     if(shoppingListProvider.shoppingList[i].found){ 
              //       print('Found-> '+i.toString());
              //           return ShoppingListItem(itemId: shoppingListProvider.shoppingList[i].id, addToPantryCall: ()=>this.addToPantry(context: context, itemId: shoppingListProvider.shoppingList[i].id));
              //     }
              //   }
              // }

              // {
              //   int foundCount = shoppingListProvider.shoppingList.length-countUnFound;
              //   int soFar = 0;
              //   for(int i=0; i<index-1; i++){if(shoppingListProvider.shoppingList[i].found)soFar +=1;}
              //   for(int i=soFar; i<shoppingListProvider.shoppingList.length; i++){
              //         if(shoppingListProvider.shoppingList[i].found)
              //           return ShoppingListItem(itemId: shoppingListProvider.shoppingList[i].id, addToPantryCall: ()=>this.addToPantry(context: context, itemId: shoppingListProvider.shoppingList[i].id));
              //   }
              // }    

              //Origional build error out of range when item removed from one list and added to other
                      //       Container(margin: EdgeInsets.only(top: settings.accountForNotch ? settings.notchAdjustment : 5),
                      //           child: ListView.builder(
                      //     padding: EdgeInsets.all(2),
                      //     itemCount: shoppingListProvider.shoppingListFound.length + shoppingListProvider.shoppingListUnfound.length + 1,
                      //     itemBuilder: (context, index) {
                      //       if(index < shoppingListProvider.shoppingListUnfound.length)
                      //         return ShoppingListItem(itemId: shoppingListProvider.shoppingListUnfound[index].id, addToPantryCall: ()=>this.addToPantry(context: context, itemId: shoppingListProvider.shoppingListUnfound[index].id));
                      //       else if(index == shoppingListProvider.shoppingListUnfound.length) 
                      //         return Divider(thickness: 3, color: Colors.grey[700], height: 30,);
                      //       else
                      //         return ShoppingListItem(itemId: shoppingListProvider.shoppingListFound[index-(shoppingListProvider.shoppingListUnfound.length+1)].id, addToPantryCall: ()=>this.addToPantry(context: context, itemId: shoppingListProvider.shoppingListFound[index-(shoppingListProvider.shoppingListUnfound.length+1)].id));             
                      //     },
                      //   ),
                      // ),         
            // },
          ),
        ),                  
    );
  }
}