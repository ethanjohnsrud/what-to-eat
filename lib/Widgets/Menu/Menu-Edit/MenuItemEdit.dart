
import 'package:flutter/material.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:mealplanning/Providers/CatalogProvider.dart';
import 'package:mealplanning/Providers/Ingredient.dart';
import 'package:mealplanning/Providers/Meal.dart';
import 'package:mealplanning/Providers/MenuItem.dart';
import 'package:mealplanning/Providers/MenuProvider.dart';
import 'package:mealplanning/Providers/PantryItem.dart';
import 'package:mealplanning/Providers/Settings.dart';
import 'package:mealplanning/Providers/SingleMealProvider.dart';
import 'package:provider/provider.dart';
import '../../EditBlank.dart';
import '../../Catalog/IngredientListing.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';

showMenuItemEdit({BuildContext context, bool singleMeal = false, String menuId, String dayId, String sectionId, String itemId, Function onExitUpdate}){
showModalBottomSheet(
        context: context,
        builder: (newContext) {
         return Container(child: EditMenuItem(singleMeal: singleMeal, menuId: menuId, dayId: dayId, sectionId: sectionId, itemId: itemId, onExitUpdate: onExitUpdate,));
        });
}

class EditMenuItem extends StatelessWidget {
  final String menuId;
  final String dayId;
  final String sectionId;
  final String itemId;
  final bool singleMeal;
  Function onExitUpdate = () {};

  final ImagePicker _picker = ImagePicker();
  EditMenuItem({this.onExitUpdate, this.menuId, this.dayId, this.sectionId, this.itemId, this.singleMeal = false});



 Widget build(BuildContext context){
   print('Building: EditMenuItem-bottomSheet');
        //  final settings = Provider.of<Settings>(context);
          final catalogProvider = Provider.of<CatalogProvider>(context);
          final menuProvider = Provider.of<MenuProvider>(context);
          final singleProvider = Provider.of<SingleMealProvider>(context);
          final TextStyle tagStyle = TextStyle(fontSize: 20, color:Theme.of(context).accentColor);
          final TextStyle propertyStyle = TextStyle(fontSize: 35, color:Theme.of(context).primaryColor);
          final TextStyle smallerStyle = TextStyle(fontSize: 25, color:Theme.of(context).primaryColor);
          // final TextStyle placeStyle = TextStyle(fontSize: 25, color:Theme.of(context).accentColor);

          MenuItem item = this.singleMeal ? singleProvider.getItem(this.itemId) : menuProvider.getMenuItem(menuId: menuId, dayId: dayId, sectionId: sectionId, itemId: itemId);

      //Assemble optionList
        final List<String> optionsList = [];
        if(item.referenceType == Meal && item.referenceId != null || item.referenceId != ''){
          Meal meal = Provider.of<CatalogProvider>(context).getMeal(item.referenceId);
          if(meal.essentialIngredients != null && meal.essentialIngredients.isNotEmpty)
          optionsList.addAll(meal.essentialIngredients);
          if(meal.alternativeIngredients != null && meal.alternativeIngredients.isNotEmpty)
          meal.alternativeIngredients.forEach((list){if(list != null && list.isNotEmpty) optionsList.addAll(list);});
          if(meal.extraIngredients != null && meal.extraIngredients.isNotEmpty)
        optionsList.addAll(meal.extraIngredients); 
        }

        List<Widget> controls = [
          Container(padding: EdgeInsets.all(15), color: Colors.black,  width: double.infinity, alignment: Alignment.center,
                        child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: Text('Edit Menu Item:', style: TextStyle(fontSize: 25, color: Colors.white, fontFamily: 'Lato', )))),
          DisplayConstant(property: item.id, tag: 'ID', propertyStyle: smallerStyle, tagStyle: tagStyle,),
          EditValue(value: item.name, tag: 'Title', tagStyle: tagStyle, propertyStyle: propertyStyle, onChangeCallBack: (value)=>this.singleMeal ? singleProvider.setItemName(itemId: this.itemId, name: value) : menuProvider.setMenuItemName(menuId: this.menuId, dayId: this.dayId, sectionId: this.sectionId, itemId: this.itemId, name: value)),
          EditImage(id: item.id, tag: 'Image', tagStyle: tagStyle, ),
          EditReferenceType(type: item.referenceType, tag: 'Item Reference Type', tagStyle: tagStyle, propertyStyle: propertyStyle, options: [Meal, PantryItem, Ingredient], optionNames: ['Meal', 'Pantry Item', 'Ingredient'], callBack: (type) {this.singleMeal ? singleProvider.setItemReferenceType(itemId: this.itemId, type: type) : menuProvider.setMenuItemReferenceType(menuId: menuId, dayId: dayId, sectionId: sectionId, itemId: itemId, type: type,);}),
          EditGetReferenceID(id: item.referenceId, type: item.referenceType, tagStyle: tagStyle, propertyStyle: propertyStyle, options: [Meal, PantryItem, Ingredient], optionNames: ['Meal', 'Pantry Item', 'Ingredient'], callBack: (reference) {this.singleMeal ? singleProvider.setItemReferenceID(context: context, itemId: this.itemId, referenceId: reference.id) : menuProvider.setMenuItemReferenceID(context: context, menuId: menuId, dayId: dayId, sectionId: sectionId, itemId: itemId, referenceId: reference.id,); Navigator.of(context).pop();},
          onReturn: () {Navigator.pop(context); Navigator.pop(context); showMenuItemEdit(context: context, menuId: menuId, dayId: dayId, sectionId: sectionId, itemId: itemId,);},),
          EditValue(value: item.cost.toStringAsFixed(2), numberType: true, tag: 'Total Cost', currency: true, tagStyle: tagStyle, propertyStyle: smallerStyle, onChangeCallBack: (value)=>this.singleMeal ? singleProvider.setItemCost(itemId: this.itemId, cost: double.parse(value)) : menuProvider.setMenuItemCost(menuId: menuId, dayId: dayId, sectionId: sectionId, itemId: itemId, cost: double.parse(value)),),
        ];
          if(item.referenceType==Meal && (item.referenceId != null || item.referenceId != '') && catalogProvider.getMeal(item.referenceId).hasIngredients())  
          controls.addAll([
            EditSelectIngredientList(displayList: optionsList, selectedList: item.selectedIngredients, menuId: menuId, dayId: dayId, sectionId: sectionId, tag: 'Included Ingredients', tagStyle: tagStyle, addCallBack: (id)=>this.singleMeal ? singleProvider.addItemIngredient(itemId: this.itemId, ingredientId: id, cost: catalogProvider.getCalculatedAveragePerServingCost(id, type: Ingredient) * singleProvider.getSection().servings) : menuProvider.addMenuItemIngredient(menuId: menuId, dayId: dayId, sectionId: sectionId, itemId: itemId, ingredientId: id, cost: catalogProvider.getCalculatedAveragePerServingCost(id, type: Ingredient) * menuProvider.getMenuSection(menuId: menuId, dayId: dayId, sectionId: sectionId).servings), removeCallBack: (id)=>this.singleMeal ? singleProvider.removeItemIngredient(itemId: itemId, ingredientId: id, cost: catalogProvider.getCalculatedAveragePerServingCost(id, type: Ingredient) * singleProvider.getSection().servings) : menuProvider.removeMenuItemIngredient(menuId: menuId, dayId: dayId, sectionId: sectionId, itemId: itemId, ingredientId: id, cost: catalogProvider.getCalculatedAveragePerServingCost(id, type: Ingredient) * menuProvider.getMenuSection(menuId: menuId, dayId: dayId, sectionId: sectionId).servings),),
            EditAdvanceAction(action: ()=>this.singleMeal ? singleProvider.clearItemIngredients(itemId: this.itemId) : menuProvider.clearMenuItemIngredients(menuId: menuId, dayId: dayId, sectionId: sectionId, itemId: itemId,), warning: 'CLEAR', tag: 'Clear Selected Ingredients', tagStyle: tagStyle,),
          ]);
          controls.addAll( [
            EditParagraph(value: item.instructions, tag: 'Instructions', tagStyle: tagStyle, propertyStyle: smallerStyle, onChangeCallBack: (value)=>menuProvider.setMenuItemInstructions(menuId: menuId, dayId: dayId, sectionId: sectionId, itemId: itemId, instructions: value),),
            EditAdvanceAction(action: () {menuProvider.removeMenuItem(menuId: menuId, dayId: dayId, sectionId: sectionId, itemId: itemId); if(this.onExitUpdate != null) this.onExitUpdate();  Navigator.pop(context);}, warning: 'DELETE', tag: 'Delete this Meal', tagStyle: tagStyle,),
            EditButton(propertyName: 'SAVE', tag: 'Close Edit Page', propertyStyle: propertyStyle, tagStyle: tagStyle, onClick: () {if(this.onExitUpdate != null) this.onExitUpdate();  Navigator.pop(context);},),
            ]);

          return new WillPopScope(
            onWillPop: () async {if(this.onExitUpdate != null) this.onExitUpdate(); return true;},
          child: GestureDetector(
              onTap: () {}, //close?
              behavior: HitTestBehavior.opaque,
              child: Container(color: Colors.grey[900],
                child: SingleChildScrollView(scrollDirection: Axis.vertical, child: Column(children: controls))),
            ),
          );
      } 
  }

  
class EditSelectIngredientList extends StatelessWidget {
  final singleMeal;
  final String menuId;
  final String dayId;
  final String sectionId;  
  final String tag;
  final TextStyle tagStyle;
  Function addCallBack = () {};
  Function removeCallBack = () {};
  List<String> displayList = [];
  List<String> selectedList = []; //state

  EditSelectIngredientList({ this.singleMeal = false, this.tag, this.tagStyle, this.displayList, this.selectedList, this.addCallBack, this.removeCallBack, this.menuId, this.dayId, this.sectionId});

  bool isSelected(String id) { //optimized for efficency
  if(this.selectedList != null)
    for(var i=0;i<selectedList.length; i++){if(selectedList[i]==id) return true;}
    return false;
  }

  Widget makeTail(BuildContext context, String id){
    return GestureDetector( onTap: ()=>this.isSelected(id) ? removeCallBack(id) : addCallBack(id), 
    child: Row(children:[Icon(this.isSelected(id) ? Icons.remove_circle : Icons.add_circle, color: Theme.of(context).primaryColor, size: 35),
        Text(' \$${(Provider.of<CatalogProvider>(context).getCalculatedAveragePerServingCost(id, type: Ingredient) * (this.singleMeal ? Provider.of<SingleMealProvider>(context).getSection().servings : Provider.of<MenuProvider>(context).getMenuSection(menuId: menuId, dayId: dayId, sectionId: sectionId).servings)).toStringAsFixed(2)}', style: TextStyle(fontSize: 20, color: Colors.white, fontFamily: 'Lato')),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    print('Building -> EditSelectIngredientList');
    final catalogProvider = Provider.of<CatalogProvider>(context);
                                                                                                                                      
    return ListTile(
        title: Container(
      margin: EdgeInsets.all(2),
      color: Colors.black,
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
      child: SizedBox(
        height: 350,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(tag, style: tagStyle), 
          Expanded(
            child:  ListView.builder(
          itemCount: displayList.length,
          itemBuilder: (context, index) =>
            IngredientListing(ingredient: catalogProvider.getIngredient(displayList[index]), 
            tail: this.makeTail(context, this.displayList[index]), 
            tailTag: this.isSelected(displayList[index]) ? 'Remove' : 'Add', 
            selectionMode: true,  
            backgroundColor: this.isSelected(displayList[index]) ? Colors.grey[900] : Colors.grey[600],),
          ),
          ),
          ]),
        
      ),
    ));
  }
}
