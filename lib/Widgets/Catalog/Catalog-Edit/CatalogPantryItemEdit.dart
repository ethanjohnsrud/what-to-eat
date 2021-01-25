
import 'package:flutter/material.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:mealplanning/Providers/CatalogProvider.dart';
import 'package:mealplanning/Providers/Ingredient.dart';
import 'package:mealplanning/Providers/Meal.dart';
import 'package:mealplanning/Providers/PantryItem.dart';
import 'package:mealplanning/Providers/Settings.dart';
import 'package:mealplanning/Widgets/Catalog/Catalog.dart';
import 'package:provider/provider.dart';

import '../../EditBlank.dart';


showPantryItemEdit({BuildContext context, String itemId, Function onExitUpdate}){
showModalBottomSheet(
        context: context,
        builder: (newContext) {
         return Container(child: EditCatalogPantryItem(itemId: itemId, onExitUpdate: onExitUpdate));
        });
}

class EditCatalogPantryItem extends StatelessWidget {
  Function onExitUpdate = () {};
  final String itemId;

  EditCatalogPantryItem({this.itemId, this.onExitUpdate});

 Widget build(BuildContext context){
   print('Building: EditCatalogIngredient-bottomSheet');
  //  final settings = Provider.of<Settings>(context);
    final catalogProvider = Provider.of<CatalogProvider>(context);
    final TextStyle tagStyle = TextStyle(fontSize: 20, color:Theme.of(context).accentColor);
    final TextStyle propertyStyle = TextStyle(fontSize: 35, color:Theme.of(context).primaryColor);
    final TextStyle smallerStyle = TextStyle(fontSize: 25, color:Theme.of(context).primaryColor);
    final TextStyle placeStyle = TextStyle(fontSize: 25, color:Theme.of(context).accentColor);

    final PantryItem item = catalogProvider.getPantryItem(this.itemId);

          return new WillPopScope(
            onWillPop: () async {if(this.onExitUpdate != null) this.onExitUpdate(); return true;},
          child: GestureDetector(
              onTap: () {}, //close?
              behavior: HitTestBehavior.opaque,
              child: Container(color: Colors.grey[900],
                child: SingleChildScrollView(scrollDirection: Axis.vertical, child: Column(children: [
                  Container(padding: EdgeInsets.all(15), color: Colors.black, width: double.infinity, alignment: Alignment.center,
                        child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: Text('Edit Pantry Item:', style: TextStyle(fontSize: 25, color: Colors.white, fontFamily: 'Lato', )))),
          DisplayConstant(property: item.id, tag: 'ID', propertyStyle: smallerStyle, tagStyle: tagStyle,),
          EditValue(value: item.name, tag: 'Title', tagStyle: tagStyle, propertyStyle: propertyStyle,  onChangeCallBack: (value)=>catalogProvider.setPantryItemName(itemId, value),),
          EditDate(date: item.expirationDate, propertyStyle: propertyStyle, tagStyle: tagStyle, callBack: (pickedDate)=>catalogProvider.setPantryItemExpirationDate(item.id, pickedDate),),

          EditReferenceType(type: item.referenceType, tag: 'Pantry Reference Type', tagStyle: tagStyle, propertyStyle: propertyStyle, options: [Meal, Ingredient], optionNames: ['Meal', 'Ingredient'], callBack: (type)=>Provider.of<CatalogProvider>(context).setPantryItemReferenceType(item.id, type,)),
          EditGetReferenceID(id: item.referenceId, type: item.referenceType, tagStyle: tagStyle, propertyStyle: propertyStyle, options: [Meal, Ingredient], optionNames: ['Meal', 'Ingredient'], callBack: (reference) {catalogProvider.setPantryItemReferenceID(item.id, reference.id, 
                                name: (item.referenceType != null && item.referenceId != null && item.referenceId != '' && reference.name != '') ? reference.name : null,); Navigator.of(context).pop();},
                                onReturn: ()=>showPantryItemEdit(context: context, itemId: this.itemId, onExitUpdate: onExitUpdate)),
          EditCount(value: item.quantity, increase: () {catalogProvider.increasePantryItemQuantity(item.id);}, decrease: () {catalogProvider.decreasePantryItemQuantity(item.id);}, tag: 'Servings', place: '${catalogProvider.getCalculatedQuantity(PantryItem, item.referenceId).toStringAsFixed(0)}',  placeStyle: placeStyle, tagStyle: tagStyle, propertyStyle: propertyStyle,),
          EditImage(id: item.id, tag: 'Image', tagStyle: tagStyle, ),
          EditValue(value: item.description, tag: 'Description', tagStyle: tagStyle, propertyStyle: smallerStyle, onChangeCallBack: (value)=>catalogProvider.setPantryItemDescription(itemId, value)),
          EditAdvanceAction(action: () {catalogProvider.removePantryItem(item.id); if(this.onExitUpdate != null) this.onExitUpdate(); else Navigator.pop(context);}, warning: 'DELETE', tag: 'Delete this Pantry Item', tagStyle: tagStyle,),
          EditButton(propertyName: 'SAVE', tag: 'Close Edit Page', propertyStyle: propertyStyle, tagStyle: tagStyle, onClick: () {if(this.onExitUpdate != null) this.onExitUpdate(); else Navigator.pop(context);},),
          ]))),
            ),
          );
  }
  }

 