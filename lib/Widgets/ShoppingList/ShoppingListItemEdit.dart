
import 'package:flutter/material.dart';
import 'package:mealplanning/Providers/CatalogProvider.dart';
import 'package:mealplanning/Providers/Ingredient.dart';
import 'package:mealplanning/Providers/Meal.dart';
import 'package:mealplanning/Providers/PantryItem.dart';
import 'package:mealplanning/Providers/PriceRecord.dart';
import 'package:mealplanning/Providers/Settings.dart';
import 'package:mealplanning/Providers/ShoppingItem.dart';
import 'package:mealplanning/Providers/ShoppingListProvider.dart';
import 'package:provider/provider.dart';

import '../EditBlank.dart';

showShoppingListItemEdit({BuildContext context,String itemId, Function onExitUpdate}){
showModalBottomSheet(
        context: context,
        builder: (newContext) {
         return Container(child: ShoppingListItemEdit(itemId: itemId, onExitUpdate: onExitUpdate,));
        });
}

class ShoppingListItemEdit extends StatelessWidget {
  final String itemId;
  Function onExitUpdate = () {};

  ShoppingListItemEdit({this.onExitUpdate, this.itemId});

 Widget build(BuildContext context){
   print('Building: ShoppingListItemEdit-bottomSheet');
         final settings = Provider.of<Settings>(context);
          final catalogProvider = Provider.of<CatalogProvider>(context);
          final shoppingListProvider = Provider.of<ShoppingListProvider>(context);
          final TextStyle tagStyle = TextStyle(fontSize: 20, color:Theme.of(context).accentColor);
          final TextStyle propertyStyle = TextStyle(fontSize: 35, color:Theme.of(context).primaryColor);
          final TextStyle smallerStyle = TextStyle(fontSize: 25, color:Theme.of(context).primaryColor);

          ShoppingItem item = shoppingListProvider.getItem(itemId);
         
          return new WillPopScope(
            onWillPop: () async {if(this.onExitUpdate != null) this.onExitUpdate(); return true;},
          child: GestureDetector(
              onTap: () {}, //close?
              behavior: HitTestBehavior.opaque,
              child: Container(color: Colors.grey[900],
                child: SingleChildScrollView(scrollDirection: Axis.vertical, 
                  child: Column(children: [
                    Container(padding: EdgeInsets.all(15), color: Colors.black,  width: double.infinity, alignment: Alignment.center,
                        child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: Text('Edit Shopping Item:', style: TextStyle(fontSize: 25, color: Colors.white, fontFamily: 'Lato', )))),
                    DisplayConstant(property: item.id, tag: 'ID', propertyStyle: smallerStyle, tagStyle: tagStyle,),
                    EditValue(value: item.name, tag: 'Title', tagStyle: tagStyle, propertyStyle: propertyStyle, onChangeCallBack: (value)=>shoppingListProvider.setItemName(itemId: this.itemId, name: value), ),
                    EditReferenceType(type: item.referenceType, tag: 'Item Reference Type', tagStyle: tagStyle, propertyStyle: propertyStyle, options: [Meal, PantryItem, Ingredient], optionNames: ['Meal', 'Pantry Item', 'Ingredient'], callBack: (type) {shoppingListProvider.setItemReferenceType(itemId: itemId, type: type,);}),
                    EditGetReferenceID(id: item.referenceId, type: item.referenceType, tagStyle: tagStyle, propertyStyle: propertyStyle, options: [Meal, PantryItem, Ingredient], optionNames: ['Meal', 'Pantry Item', 'Ingredient'], callBack: (reference) {shoppingListProvider.setItemReferenceID(context: context, itemId: itemId, referenceId: reference.id,); shoppingListProvider.setItemName(itemId: itemId, name: reference.name);
                            shoppingListProvider.setItemDescription(itemId: itemId, description: item.referenceType == Meal ? catalogProvider.getMeal(reference.id).adjective : item.referenceType == Ingredient ? catalogProvider.getIngredient(reference.id).adjective : item.referenceType == PantryItem ? catalogProvider.getPantryItem(reference.id).description : ''); 
                            shoppingListProvider.setItemUnitPrice(itemId: itemId, price: catalogProvider.getCalculatedAveragePerServingCost(reference.id, type: item.referenceType, unit: item.servingUnit));
                            shoppingListProvider.setItemPriceUnit(itemId: itemId, unit: catalogProvider.getBestPriceUnit(reference.id));
                            Navigator.pop(context); },
                            onReturn: () { },),
                    EditValue(value: item.description, tag: 'Description', tagStyle: tagStyle, propertyStyle: smallerStyle, onChangeCallBack: (value)=>shoppingListProvider.setItemDescription(itemId: itemId, description: value),),
                    EditBinary(value: item.found, tag: 'Item Aquired', trueProperty: 'Added To Pantry', propertyStyle: propertyStyle, tagStyle: tagStyle, toggle: ()=>shoppingListProvider.markItemToggle(itemId: itemId),),
                    EditCount(value: item.servings, increase: ()=>shoppingListProvider.increaseItemServings(itemId), decrease: ()=>shoppingListProvider.decreaseItemServings(itemId), tag: 'Servings', place: '',  placeStyle: tagStyle, tagStyle: tagStyle, propertyStyle: propertyStyle,),
                    EditValue(value: item.unitPrice.toString(), numberType: true,  currency: true, tag: 'Expected Per ${item.servingUnit} Price', tagStyle: tagStyle, propertyStyle: smallerStyle, onChangeCallBack: (value)=>shoppingListProvider.setItemUnitPrice(itemId: itemId, price: double.parse(value)),),
                    EditSliderOptions(selection: item.servingUnit, tag: 'Servings Per: ${item.servingUnit}', tagStyle: tagStyle, propertyStyle: smallerStyle, options: settings.pricingUnits, callBack: (value) {shoppingListProvider.setItemPriceUnit(itemId: itemId, unit: value,); shoppingListProvider.setItemUnitPrice(itemId: itemId, price: (catalogProvider.getCalculatedAveragePerServingCost(item.referenceId, type: item.referenceType, unit: value) * (item.referenceType == Meal ? catalogProvider.getMeal(item.referenceId).servingsPerUnit.putIfAbsent(value, () => 1.0) : item.referenceType == Ingredient ?  catalogProvider.getIngredient(item.referenceId).servingsPerUnit.putIfAbsent(value, () => 1.0) : 1.0)));}),
                    EditRecordedPrices(itemId: item.referenceId, tag: 'Historic Package Prices', current: catalogProvider.getPriceList(id: item.referenceId, combineStores: false), tagStyle: tagStyle, propertyStyle: smallerStyle, onAdd: (PriceRecord record)=>catalogProvider.addPriceRecord(record), onRemove: (PriceRecord record)=>catalogProvider.removePriceRecord(record),),
                    EditAdvanceAction(action: () {shoppingListProvider.removeItem(itemId); if(this.onExitUpdate != null) this.onExitUpdate();  Navigator.pop(context);}, warning: 'DELETE', tag: 'Delete this Meal', tagStyle: tagStyle,),
                    EditButton(propertyName: 'SAVE', tag: 'Close Edit Page', propertyStyle: propertyStyle, tagStyle: tagStyle, onClick: () {if(this.onExitUpdate != null) this.onExitUpdate();  Navigator.pop(context);},),
                  ]))),
            ),
          );
      } 
  }
