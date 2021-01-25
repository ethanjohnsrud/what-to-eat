
import 'dart:math';

import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:flutter/material.dart';
import 'package:mealplanning/Providers/CatalogProvider.dart';
import 'package:mealplanning/Providers/Ingredient.dart';
import 'package:mealplanning/Providers/Meal.dart';
import 'package:mealplanning/Providers/Settings.dart';
import 'package:mealplanning/Widgets/Catalog/IngredientListing.dart';
import 'package:provider/provider.dart';

import '../EditBlank.dart';

getMealIngredientsSelection({BuildContext context, String mealId, Function selectionCallBack, Function onExitUpdate}){
showModalBottomSheet(
        context: context,
        builder: (newContext) { final List<String> preSelectedList = []; final List<String> displayList = [];
       //Assemble optionList
        Meal meal = Provider.of<CatalogProvider>(newContext).getMeal(mealId);
        if(meal.essentialIngredients != null && meal.essentialIngredients.isNotEmpty){
        displayList.addAll(meal.essentialIngredients);   preSelectedList.addAll(meal.essentialIngredients);}
        if(meal.alternativeIngredients != null && meal.alternativeIngredients.isNotEmpty)
        meal.alternativeIngredients.forEach((list){if(list != null && list.isNotEmpty) displayList.addAll(list);});
        if(meal.extraIngredients != null && meal.extraIngredients.isNotEmpty)
      displayList.addAll(meal.extraIngredients); 
      
      //Call
         return Container(child: MealIngredientsSelectionPage(mealId: mealId, selectionCallBack: selectionCallBack, onExitUpdate: onExitUpdate, selectedList: preSelectedList, displayList: displayList,));
        });
}

class MealIngredientsSelectionPage extends StatefulWidget {
  // static const routeName = '/MealIngredientsSelectionPage';
  final String mealId;
  Function onExitUpdate = () {};
  Function selectionCallBack = () {};
  List<double> displayHeight = [];
  List<String> displayList = [];
  List<String> selectedList = []; //state
  MealIngredientsSelectionPage({this.mealId, this.selectionCallBack, this.selectedList, this.displayList, this.onExitUpdate});
  @override
  _MealIngredientsSelectionPageState createState() => _MealIngredientsSelectionPageState();
}

class _MealIngredientsSelectionPageState extends State<MealIngredientsSelectionPage> {
void initState() {
  super.initState();}

  bool isSelected(String id) { //optimized for efficency
    for(var i=0;i<widget.selectedList.length; i++){if(widget.selectedList[i]==id) return true;}
    return false;
  }
  void selectToggle(String id) { //optimized for efficency
    this.setState(() { 
      bool isFound= widget.selectedList.remove(id);
    if(!isFound) widget.selectedList.add(id); });
  }

ScrollController controller = ScrollController();
void recordListingHeight(int place, double height){ print('-Setting Height: \#${place} = $height');
  widget.displayHeight[place] = height;}

int getScrollSelection(double offset){ print('-Calculating Scroll: ${offset}');
  double sum = 0;
  int place = -1;
  while(offset > sum && place+1 < widget.displayHeight.length) {place++; sum += widget.displayHeight[place]; }
  return offset > sum ? -1 : place;
}

  @override
  Widget build(BuildContext context) {
    print('-> Building MenuSelectionPage');
    final settings = Provider.of<Settings>(context);
    final catalogProvider = Provider.of<CatalogProvider>(context);
    final TextStyle tagStyle = TextStyle(fontSize: 20, color:Theme.of(context).accentColor);
    final TextStyle propertyStyle = TextStyle(fontSize: 35, color:Theme.of(context).primaryColor);
    final TextStyle smallerStyle = TextStyle(fontSize: 25, color:Theme.of(context).primaryColor);
  
    return new WillPopScope(
            onWillPop: () async {if(widget.onExitUpdate != null) widget.onExitUpdate(); return true;},
          child:  Container(color: Colors.black87, 
            child: Column(
          children: [Expanded(
              child: DraggableScrollbar.rrect(
              controller: controller,
              labelTextBuilder: (double offset) {String called =  'Meal';
                // final int selection = this.getScrollSelection(offset);
                // if((selection < widget.displayList.length) && (selection >= 0)) called =  widget.displayList[selection].name;
                // if(called.length > 7) called = called.substring(0,6);
                return Text(called, style: TextStyle(color: Colors.white));
                },
              alwaysVisibleScrollThumb: true,
              backgroundColor: Theme.of(context).primaryColor,
              padding: EdgeInsets.all(2.0),
                  child: ListView.builder(
                              padding: EdgeInsets.symmetric(horizontal: 5),
                              controller: controller,
                              itemCount: widget.displayList.length+1,
                              itemBuilder: (context, index) {
                                  if(index==0) return Container(padding: EdgeInsets.all(15), color: Colors.black,
                                   child: Column(crossAxisAlignment: CrossAxisAlignment.center,  children: [
                                      SingleChildScrollView(scrollDirection: Axis.horizontal, child: Text('Select Ingredients to Include:', style: TextStyle(fontSize: 25, color: Colors.white, fontFamily: 'Lato', ))),
                                      SingleChildScrollView(scrollDirection: Axis.horizontal, child: Text(catalogProvider.getMeal(widget.mealId).name, style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 23, fontFamily: 'OpenSans', fontWeight: FontWeight.w700))),
                                      // Text('Pantry: ${catalogProvider.getPantryQuantity(item.referenceId).toStringAsFixed(0)}', style: TextStyle(fontSize: 18, color: Theme.of(context).accentColor, fontFamily: 'Lato')),
                                   ]));
                                  else return IngredientListing(ingredient: catalogProvider.getIngredient(widget.displayList[index-1]), 
                                  tail: Row(children:[Icon(this.isSelected(widget.displayList[index-1]) ? Icons.remove_circle : Icons.add_circle, color: Theme.of(context).primaryColor, size: 35),
                                                    Text(' \$${(Provider.of<CatalogProvider>(context).getCalculatedAveragePerServingCost(widget.displayList[index-1], type: Ingredient)).toStringAsFixed(2)}', style: TextStyle(fontSize: 20, color: Colors.white, fontFamily: 'Lato')),
                                                  ]), 
                                  tailTag: this.isSelected(widget.displayList[index-1]) ? 'Remove' : 'Add', 
                                  selectionMode: true,  
                                  backgroundColor: this.isSelected(widget.displayList[index-1]) ? Colors.grey[900] : Colors.grey[600],
                                  onSelectionClick: ()=>selectToggle(widget.displayList[index-1]),
                                  );
                              }
                              ),
              ),
            ),
        Container(height: 40, width: double.infinity,  color: Theme.of(context).primaryColor, child: FlatButton(child: Text('SAVE', style: TextStyle(fontSize: 30,  fontFamily: 'OpenSans', fontWeight: FontWeight.w800, color:Colors.grey[900])),
                    onPressed: () {widget.selectionCallBack([...widget.selectedList]); Navigator.of(context).pop(); if(widget.onExitUpdate != null) widget.onExitUpdate(); }))
          ]),
      ),
    );
  }
}