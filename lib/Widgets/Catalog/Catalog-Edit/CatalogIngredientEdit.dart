
import 'package:flutter/material.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:mealplanning/Providers/CatalogProvider.dart';
import 'package:mealplanning/Providers/Ingredient.dart';
import 'package:mealplanning/Providers/PantryItem.dart';
import 'package:mealplanning/Providers/PriceRecord.dart';
import 'package:mealplanning/Providers/Settings.dart';
import 'package:mealplanning/Widgets/Catalog/Catalog-Edit/CatalogPantryItemEdit.dart';
import 'package:mealplanning/Widgets/Catalog/Catalog.dart';
import 'package:provider/provider.dart';
import '../../EditBlank.dart';

showIngredientEdit({BuildContext context, String ingredientId, Function onExitUpdate}){
showModalBottomSheet(
        context: context,
        builder: (newContext) {
         return Container(child: EditCatalogIngredient(ingredientId: ingredientId, onExitUpdate: onExitUpdate));
        },
        // isScrollControlled: true,
        // isDismissible: true,
        );
}

class EditCatalogIngredient extends StatelessWidget {
  Function onExitUpdate = () {};
  final String ingredientId;

  EditCatalogIngredient({this.ingredientId, this.onExitUpdate});

 Widget build(BuildContext context){
   print('Building: EditCatalogIngredient-bottomSheet');
    final settings = Provider.of<Settings>(context);
    final catalogProvider = Provider.of<CatalogProvider>(context);
    final TextStyle tagStyle = TextStyle(fontSize: 20, color:Theme.of(context).accentColor);
    final TextStyle propertyStyle = TextStyle(fontSize: 35, color:Theme.of(context).primaryColor);
    final TextStyle smallerStyle = TextStyle(fontSize: 25, color:Theme.of(context).primaryColor);
    final TextStyle placeStyle = TextStyle(fontSize: 25, color:Theme.of(context).accentColor);

    final Ingredient ingredient = catalogProvider.getIngredient(this.ingredientId);
    
          return new WillPopScope(
            onWillPop: () async {if(this.onExitUpdate != null) this.onExitUpdate(); return true;},
          child: GestureDetector(
              onTap: () {}, //close?
              behavior: HitTestBehavior.opaque,
              child: Container(color: Colors.grey[900],
                child: SingleChildScrollView(scrollDirection: Axis.vertical, child: Column(children: [
            Container(padding: EdgeInsets.all(15), color: Colors.black,  width: double.infinity, alignment: Alignment.center,
                        child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: Text('Edit Ingredient:', style: TextStyle(fontSize: 25, color: Colors.white, fontFamily: 'Lato', )))),
            DisplayConstant(property: ingredient.id, tag: 'ID', propertyStyle: smallerStyle, tagStyle: tagStyle,),
             EditValue(value: ingredient.name, tag: 'Title', tagStyle: tagStyle, propertyStyle: propertyStyle, onChangeCallBack: (value)=>catalogProvider.setIngredientName(this.ingredientId, value),),
             EditValue(value: ingredient.adjective, tag: 'Adjectives', tagStyle: tagStyle, propertyStyle: smallerStyle, onChangeCallBack: (value)=>catalogProvider.setIngredientAdjective(ingredientId, value)),           
            EditImage(id: ingredient.id, tag: 'Image', tagStyle: tagStyle, ),
             EditCheckStringOptions(tag: 'Recommendation Types', selected: ingredient.recommendationTypes, options: settings.recommendationTypes, propertyStyle: smallerStyle, tagStyle: tagStyle, onAdd: (item)=>catalogProvider.addIngredientRecommendationTypes(ingredientId, item), onRemove: (item)=>catalogProvider.removeIngredientRecommendationTypes(ingredientId, item)),
            //  EditImage(id: ingredient.image, tag: 'Image', tagStyle: tagStyle, setImage: (value)=>catalogProvider.setIngredientImage(ingredientId, value)),
            //  EditValue(value: ingredient.servingsPerPackage.toStringAsFixed(0), numberType: true, tag: 'Servings per Package', tagStyle: tagStyle, propertyStyle: smallerStyle, onChangeCallBack: (value)=>catalogProvider.setIngredientServingsPerPackage(ingredientId, double.parse(value))),
             EditRecordedPrices(itemId: ingredientId, tag: 'Price per Package', current: catalogProvider.getPriceList(id: ingredientId, combineStores: false), tagStyle: tagStyle, propertyStyle: smallerStyle, onAdd: (PriceRecord record)=>catalogProvider.addPriceRecord(record), onRemove: (PriceRecord record)=>catalogProvider.removePriceRecord(record),),
             EditMapServingsPerUnit(tag: 'Servings Per:', setServings: ingredient.servingsPerUnit, propertyStyle: smallerStyle, tagStyle: tagStyle, setCall: (unit, count)=>catalogProvider.setIngredientPriceUnit(ingredientId: this.ingredientId, unit: unit, servings: count),),
             EditCount(value: ingredient.popularityCount, increase: () {catalogProvider.increaseIngredientPopularityCount(ingredient.id);}, decrease: () {catalogProvider.decreaseIngredientPopularityCount(ingredient.id);}, tag: 'Popularity Count', place: '${catalogProvider.getPopularityPercent(Ingredient, ingredient.id).toStringAsFixed(0)}%',  placeStyle: placeStyle, tagStyle: tagStyle, propertyStyle: propertyStyle,),
             EditCount(value: DateTime.now().difference(ingredient.recentDate).inDays, increase: () {catalogProvider.increaseIngredientRecentDate(ingredient.id);}, decrease: () {catalogProvider.decreaseIngredientRecentDate(ingredient.id);}, tag: 'Recent Count', place: '${catalogProvider.getRecentPercent(Ingredient, ingredient.id).toStringAsFixed(0)}%',  placeStyle: placeStyle, tagStyle: tagStyle, propertyStyle: propertyStyle, onHold: ()=>catalogProvider.setIngredientRecentDatePresent(ingredient.id),),
             EditBinary(value: ingredient.meat, toggle: () {catalogProvider.toggleIngredientMeat(ingredient.id);}, tag: 'Meat', tagStyle: tagStyle, trueProperty: 'Meat', propertyStyle: propertyStyle,),
             EditBinary(value: ingredient.carb, toggle: () {catalogProvider.toggleIngredientCarb(ingredient.id);}, tag: 'Carbohydrate', tagStyle: tagStyle, trueProperty: 'Carbohydrate', propertyStyle: propertyStyle,),
             EditBinary(value: ingredient.veg, toggle: () {catalogProvider.toggleIngredientVeg(ingredient.id);}, tag: 'Vegetable', tagStyle: tagStyle, trueProperty: 'Vegetable', propertyStyle: propertyStyle,),
             EditBinary(value: ingredient.fruit, toggle: () {catalogProvider.toggleIngredientFruit(ingredient.id);}, tag: 'Fruit', tagStyle: tagStyle, trueProperty: 'Fruit', propertyStyle: propertyStyle,),
             EditBinary(value: ingredient.snack, toggle: () {catalogProvider.toggleIngredientSnack(ingredient.id);}, tag: 'Snack', tagStyle: tagStyle, trueProperty: 'Snack', propertyStyle: propertyStyle,),
             EditButton(tag: 'Create New Pantry Item', propertyName: 'Add to Pantry', icon: Icons.add_circle_outline, propertyStyle: propertyStyle, tagStyle: tagStyle, onClick: () {  PantryItem item = new PantryItem(id: Provider.of<Settings>(context).getUniqueID(context, PantryItem), name: ingredient.name, referenceType: Ingredient, referenceId: ingredientId, description: ingredient.adjective, ); Provider.of<CatalogProvider>(context).addPantryItem(item);
                          showPantryItemEdit(context: context, itemId: item.id, onExitUpdate: ()=>Navigator.of(context).pop());},),
             EditAdvanceAction(action: () {catalogProvider.removeIngredient(ingredient.id); if(this.onExitUpdate != null) this.onExitUpdate(); else Navigator.pop(context);}, warning: 'DELETE', tag: 'Delete this Ingredient', tagStyle: tagStyle,),
            EditButton(propertyName: 'SAVE', tag: 'Close Edit Page', propertyStyle: propertyStyle, tagStyle: tagStyle, onClick: () {if(this.onExitUpdate != null) this.onExitUpdate(); else Navigator.pop(context);},),
            ]))),
            ),
          );
  }
  }

 