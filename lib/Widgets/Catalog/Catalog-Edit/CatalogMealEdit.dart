
import 'package:flutter/material.dart';
import 'package:mealplanning/Providers/CatalogProvider.dart';
import 'package:mealplanning/Providers/Ingredient.dart';
import 'package:mealplanning/Providers/Meal.dart';
import 'package:mealplanning/Providers/PantryItem.dart';
import 'package:mealplanning/Providers/PriceRecord.dart';
import 'package:mealplanning/Providers/Settings.dart';
import 'package:mealplanning/Widgets/Catalog/Catalog-Edit/CatalogPantryItemEdit.dart';
import 'package:provider/provider.dart';

import '../Catalog.dart';
import '../../EditBlank.dart';
import '../IngredientListing.dart';


showMealEdit({BuildContext context, String mealId, Function onExitUpdate}){
showModalBottomSheet(
        context: context,
        builder: (newContext) {
         return Container(child: EditCatalogMeal(mealId: mealId, onExitUpdate: onExitUpdate));
        });
}

class EditCatalogMeal extends StatelessWidget {
  Function onExitUpdate = () {};
  final String mealId;

  EditCatalogMeal({this.mealId, this.onExitUpdate});

  final TextEditingController nameController = TextEditingController(); 
  final TextEditingController adjectiveController = TextEditingController(); 
  final TextEditingController imageController = TextEditingController(); 
  final TextEditingController recipeController = TextEditingController(); 

  void addEssentialIngredients(CatalogProvider catalogProvider, Meal meal, List<String> addList)=>addList.forEach((item)=>catalogProvider.addEssentialIngredient(meal.id, item));
  void addAlternativeIngredients(CatalogProvider catalogProvider, Meal meal, List<String> addList)=>catalogProvider.addAlternativeIngredient(meal.id, addList);
  void addExtraIngredients(CatalogProvider catalogProvider, Meal meal, List<String> addList)=>addList.forEach((item)=>catalogProvider.addExtraIngredient(meal.id, item));

 Widget build(BuildContext context){  print('Building: EditCatalogIngredient-bottomSheet');
    final settings = Provider.of<Settings>(context);
    final catalogProvider = Provider.of<CatalogProvider>(context);
    final TextStyle tagStyle = TextStyle(fontSize: 20, color:Theme.of(context).accentColor);
    final TextStyle propertyStyle = TextStyle(fontSize: 35, color:Theme.of(context).primaryColor);
    final TextStyle smallerStyle = TextStyle(fontSize: 25, color:Theme.of(context).primaryColor);
    final TextStyle placeStyle = TextStyle(fontSize: 25, color:Theme.of(context).accentColor);

    final Meal meal = catalogProvider.getMeal(mealId);

          return new WillPopScope(
            onWillPop: () async {if(this.onExitUpdate != null) this.onExitUpdate(); return true;},
          child: GestureDetector(
              onTap: () {}, //close?
              behavior: HitTestBehavior.opaque,
              child: Container(color: Colors.grey[900],
                child: SingleChildScrollView(scrollDirection: Axis.vertical, child: Column(children: [
                  Container(padding: EdgeInsets.all(15), color: Colors.black,  width: double.infinity, alignment: Alignment.center,
                        child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: Text('Edit Meal:', style: TextStyle(fontSize: 25, color: Colors.white, fontFamily: 'Lato', )))),
            DisplayConstant(property: meal.id, tag: 'ID', propertyStyle: smallerStyle, tagStyle: tagStyle,),
               EditValue(value: meal.name, tag: 'Title', tagStyle: tagStyle, propertyStyle: propertyStyle, onChangeCallBack: (value)=>catalogProvider.setMealName(mealId, value),),
               EditValue(value: meal.adjective, tag: 'Adjectives', tagStyle: tagStyle, propertyStyle: smallerStyle,  onChangeCallBack: (value)=>catalogProvider.setMealAdjective(mealId, value)),
               EditImage(id: meal.id, tag: 'Image', tagStyle: tagStyle, ),
              EditCheckStringOptions(tag: 'Recommendation Types', selected: meal.recommendationTypes, options: settings.recommendationTypes, propertyStyle: smallerStyle, tagStyle: tagStyle, onAdd: (item)=>catalogProvider.addMealRecommendationTypes(mealId, item), onRemove: (item)=>catalogProvider.removeMealRecommendationTypes(mealId, item)),
               EditIngredientList(embeded: false, meal: meal, list: meal.essentialIngredients, addOperation: (addList) {this.addEssentialIngredients(catalogProvider, meal, addList);}, 
                                dismissOperation: catalogProvider.removeMealIngredient, tag: 'Essential Ingredients', tagStyle: tagStyle, ),
              EditIngredientList(embeded: true, meal: meal, list: meal.alternativeIngredients, addOperation: (addList) {this.addAlternativeIngredients(catalogProvider, meal, addList);},
                                dismissOperation: catalogProvider.removeMealIngredient, tag: 'Alternative Ingredients', tagStyle: tagStyle, ),
              EditIngredientList(embeded: false, meal: meal, list: meal.extraIngredients, addOperation:  (addList) {this.addExtraIngredients(catalogProvider, meal, addList);},
                                dismissOperation: catalogProvider.removeMealIngredient, tag: 'Extra Ingredients', tagStyle: tagStyle,),
              EditRecordedPrices(itemId: mealId, tag: 'Price per Package', current: catalogProvider.getPriceList(id: mealId, combineStores: false), tagStyle: tagStyle, propertyStyle: smallerStyle, onAdd: (PriceRecord record)=>catalogProvider.addPriceRecord(record), onRemove: (PriceRecord record)=>catalogProvider.removePriceRecord(record),),
              EditMapServingsPerUnit(tag: 'Servings Per:', setServings: meal.servingsPerUnit, propertyStyle: smallerStyle, tagStyle: tagStyle, setCall: (unit, count)=>catalogProvider.setMealPriceUnit(mealId: this.mealId, unit: unit, servings: count),),
              EditCount(value: meal.popularityCount, increase: () {catalogProvider.increaseMealPopularityCount(meal.id);}, decrease: () {catalogProvider.decreaseMealPopularityCount(meal.id);}, tag: 'Popularity Count', place: '${catalogProvider.getPopularityPercent(Meal, meal.id).toStringAsFixed(0)}%',  placeStyle: placeStyle, tagStyle: tagStyle, propertyStyle: propertyStyle,),
              EditCount(value: DateTime.now().difference(meal.recentDate).inDays, increase: () {catalogProvider.increaseMealRecentDate(meal.id);}, decrease: () {catalogProvider.decreaseMealRecentDate(meal.id);}, tag: 'Recent Count', place: '${catalogProvider.getRecentPercent(Meal, meal.id).toStringAsFixed(0)}%',  placeStyle: placeStyle, tagStyle: tagStyle, propertyStyle: propertyStyle, onHold: ()=>catalogProvider.setMealRecentDatePresent(meal.id),),
              EditAdvanceAction(action: () {catalogProvider.clearMealIngredients(meal.id);}, warning: 'CLEAR', tag: 'Clear all Ingredients', tagStyle: tagStyle,),
              EditParagraph(value: meal.recipe, tag: 'Recipe', tagStyle: tagStyle, propertyStyle: smallerStyle, onChangeCallBack: (value)=>catalogProvider.setMealRecipe(mealId, value)),
              EditButton(tag: 'Create New Pantry Item', propertyName: 'Add to Pantry', icon: Icons.add_circle_outline, propertyStyle: propertyStyle, tagStyle: tagStyle, onClick: () {  PantryItem item = new PantryItem(id: Provider.of<Settings>(context).getUniqueID(context, PantryItem), name: meal.name, referenceType: Meal, referenceId: mealId, description: meal.adjective, ); Provider.of<CatalogProvider>(context).addPantryItem(item);
                          showPantryItemEdit(context: context, itemId: item.id, onExitUpdate: ()=>Navigator.of(context).pop());},),
              EditAdvanceAction(action: () {catalogProvider.removeMeal(meal.id); if(this.onExitUpdate != null) this.onExitUpdate(); else Navigator.pop(context);}, warning: 'DELETE', tag: 'Delete this Meal', tagStyle: tagStyle,),
              EditButton(propertyName: 'SAVE', tag: 'Close Edit Page', propertyStyle: propertyStyle, tagStyle: tagStyle, onClick: () {if(this.onExitUpdate != null) this.onExitUpdate(); else Navigator.pop(context);},),
              ]))),
            ),
          );
  }
  }

  
class EditIngredientList extends StatelessWidget {
  final List list;
  final String tag;
  final TextStyle tagStyle;
  final Function dismissOperation;
  final Function addOperation;
  final bool embeded;
  final Meal meal;

  EditIngredientList({this.meal, this.embeded, this.tagStyle, this.tag, this.list, this.dismissOperation, this.addOperation});
  @override
  Widget build(BuildContext context) {
    print('Building -> EditIngredientList');
    final catalogProvider = Provider.of<CatalogProvider>(context);
    final settings = Provider.of<Settings>(context);
    Widget listDisplay = SizedBox(height: 50); //default for empty list
    if(!embeded && list != null) {
    listDisplay = ListView.builder(
          itemCount: list.length,
          itemBuilder: (context, index) =>
            Dismissible(key: ValueKey(list[index]),
            child: IngredientListing(ingredient: catalogProvider.getIngredient(list[index]), tail: Text('\$${catalogProvider.getCalculatedAveragePerServingCost(list[index], type: Ingredient).toStringAsFixed(2)}', style: TextStyle(fontSize: 20, color: Colors.white, fontFamily: 'Lato')), tailTag: 'Cost', backgroundColor: Colors.grey[900],),
            direction: DismissDirection.horizontal,
            onDismissed: (direction) => dismissOperation(meal, list[index]),
            background: Container(
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[Icon(Icons.delete, color:Colors.red[900], size:40,), Icon(Icons.delete, color:Colors.red[900], size:40,),]),
            ),
            ),
          );
    } else if(list != null){
      final List<Widget> combineList=[];
      list.forEach((alternate) { 
              for(var i=0;i<alternate.length; i++){
                Widget ingredient = i==0 ? IngredientListing(ingredient: catalogProvider.getIngredient(alternate[i]), tail: Text('\$${catalogProvider.getCalculatedAveragePerServingCost(alternate[i],  type: Ingredient).toStringAsFixed(2)}', style: TextStyle(fontSize: 20, color: Colors.white, fontFamily: 'Lato')), tailTag: 'Cost', backgroundColor: Colors.grey[900],)
                : IngredientListing(ingredient: catalogProvider.getIngredient(alternate[i]), preFix: 'OR', tail: Text('\$${catalogProvider.getCalculatedAveragePerServingCost(alternate[i], type: Ingredient).toStringAsFixed(2)}', style: TextStyle(fontSize: 20, color: Colors.white, fontFamily: 'Lato')), tailTag: 'Cost', backgroundColor: Colors.grey[900],);
            combineList.add( Dismissible(key: ValueKey(alternate[i]),
            child: ingredient,
            direction: DismissDirection.horizontal,
            onDismissed: (direction) => dismissOperation(meal, alternate[i]),
            background: Container(
              margin: EdgeInsets.symmetric(vertical: 15, horizontal: 5),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[Icon(Icons.delete, color:Colors.red[900], size:40,), Icon(Icons.delete, color:Colors.red[900], size:40,),]),
            ) ), );
              }});
      listDisplay = ListView(children: combineList,);
    }
    List<Widget> headerTail = [IconButton(icon: Icon(Icons.control_point_duplicate), color: Theme.of(context).primaryColor, iconSize: 40, 
                        onPressed: () {Navigator.of(context).push(MaterialPageRoute(builder:(context)=>Catalog(displayType: Ingredient, allowAdd: false, selectionMode: true, selectionCallBack: (addList)=>this.addOperation(addList))));}),];
                        if(settings.nameTags) headerTail.add(Text('Add Ingredients', style: TextStyle(fontSize: 15, color:Theme.of(context).accentColor)),);

    return ListTile(
        title: Container(
      margin: EdgeInsets.all(2),
      color: Colors.black,
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
      child: SizedBox(
        height: 350,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, 
            children: [Text(tag, style: tagStyle), 
              Column(children: headerTail,)]),
          Expanded(
            child: listDisplay,
          ),
          ]),
        
      ),
    ));
  }
}



 