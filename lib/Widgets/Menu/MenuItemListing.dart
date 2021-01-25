import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mealplanning/Providers/CatalogProvider.dart';
import 'package:mealplanning/Providers/Ingredient.dart';
import 'package:mealplanning/Providers/Meal.dart';
import 'package:mealplanning/Providers/MenuItem.dart';
import 'package:mealplanning/Providers/MenuProvider.dart';
import 'package:mealplanning/Providers/PantryItem.dart';
import 'package:mealplanning/Providers/Settings.dart';
import 'package:mealplanning/Providers/SingleMealProvider.dart';
import 'package:mealplanning/Widgets/Catalog/Catalog-Edit/CatalogIngredientEdit.dart';
import 'package:mealplanning/Widgets/Catalog/Catalog-Edit/CatalogMealEdit.dart';
import 'package:mealplanning/Widgets/Catalog/Catalog-Edit/CatalogPantryItemEdit.dart';
import 'package:provider/provider.dart';

import '../../LocalStorage.dart';

class MenuItemListing extends StatelessWidget {
  final bool singleMeal;
  final String menuId;
  final String dayId;
  final String sectionId;
  final String itemId;
  final bool sectionDone;
  final bool isRecommendation;
  Function getRecommendation = () {};
  Function onClick = () {};
  Function onCopy = () {};
  Function onRemove = () {};

  MenuItemListing({this.singleMeal = false, this.itemId, this.onClick, this.onCopy, this.onRemove, this.sectionDone, this.isRecommendation = false, this.menuId, this.dayId, this.sectionId, this.getRecommendation});

  String getDescription(BuildContext context, MenuItem item){
    String combined = '';
    if(item.selectedIngredients != null && item.selectedIngredients.isNotEmpty){
      combined = 'Includes ';
      for(int i=0; i< item.selectedIngredients.length; i++){if(i==item.selectedIngredients.length-1 && item.selectedIngredients.length>1)combined+='and ';
        combined+=Provider.of<CatalogProvider>(context).getIngredient(item.selectedIngredients[i]).adjective+' '+Provider.of<CatalogProvider>(context).getIngredient(item.selectedIngredients[i]).name+(i==item.selectedIngredients.length-1 ? '.' : ', ');}
    }
    return combined;
  }

  @override
  Widget build(BuildContext context) {
    print('Building -> MenuItemListing');
    final settings = Provider.of<Settings>(context);
    final menuProvider = Provider.of<MenuProvider>(context);
    final singleProvider = Provider.of<SingleMealProvider>(context);

    final MenuItem item = this.singleMeal ? singleProvider.getItem(itemId) : isRecommendation ? this.getRecommendation() : menuProvider.getMenuItem(menuId: menuId, dayId: dayId, sectionId: sectionId, itemId: itemId);

    getImageDisplay() async{
      File imageFile;
      if(isRecommendation)
        await getImageFile(this.getRecommendation().referenceId).then((value)=>imageFile=value);
      else 
        await getImageFile(this.itemId).then((value)=>imageFile=value);

      if(imageFile == null || !(new File(imageFile.path).existsSync())){
        if(item.referenceId != null && item.referenceId != '')
          await getImageFile(item.referenceId).then((value)=>imageFile=value);
      } 
      
      if(imageFile == null || !(new File(imageFile.path).existsSync()))
        return Image.asset('assets/food.png', fit: BoxFit.cover,);
      else
        return Image.file(imageFile, fit: BoxFit.cover,);
    }
    return Dismissible(key: ValueKey(item.id),
            direction: DismissDirection.horizontal,
            confirmDismiss: (direction) { if(this.sectionDone) return Future<bool>.value(false);
              if(direction == DismissDirection.startToEnd) {this.onRemove(); return Future<bool>.value(!this.isRecommendation);}
              else {this.onCopy(); return Future<bool>.value(false);}
            },
            
            background: Container(alignment: Alignment.centerLeft,
              margin: EdgeInsets.symmetric(vertical: 15, horizontal: 5),
              child: Icon(Icons.delete, color:Colors.red[900], size:40,),
            ),
            secondaryBackground:  Container(alignment: Alignment.centerRight,
              margin: EdgeInsets.symmetric(vertical: 15, horizontal: 5),
              child: Icon(Icons.content_copy, color:Colors.blue[900], size:40,),
            ),
    child: GestureDetector( onTap: ()=>this.sectionDone ? null : this.onClick(), 
      onLongPress: ()=>(item.referenceType == null || item.referenceId == null || item.referenceId == '' || item.referenceId == 'i0' || item.referenceId == 'm0' || item.referenceId=='p0') ? null
                                : item.referenceType == Meal ? showMealEdit(context: context, mealId: item.referenceId)
                                : item.referenceType == Ingredient ? showIngredientEdit(context: context, ingredientId: item.referenceId)
                                : item.referenceType == PantryItem ? showPantryItemEdit(context: context, itemId: item.referenceId) : null,
      child:Card (
          elevation: 3,
          shadowColor: Colors.white24,
          margin:  EdgeInsets.symmetric(vertical: 7, horizontal: 0),
            child: Stack(
          alignment: Alignment.center,
              children: [
                Container(
                        height: item.referenceType == Meal ? 170 : 125,
                        width: double.infinity,     
                        child: ColorFiltered(
          colorFilter: ColorFilter.mode(this.sectionDone ? Theme.of(context).primaryColor : Colors.transparent, BlendMode.color),
            child: FutureBuilder(future: getImageDisplay(),
                            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                                if(snapshot.connectionState == ConnectionState.done){return snapshot.data;}  
                                else{return CircularProgressIndicator();}
                          },),)),
                Positioned(
                  left: 0,
                  top: 0,
                  child: ClipRRect(borderRadius: BorderRadius.only(bottomRight: Radius.circular(25)),
                                    child: Container(color: Colors.black87, child: SingleChildScrollView(scrollDirection: Axis.horizontal, padding: EdgeInsets.only(top: 3, left: 5, right: 15, bottom: 10),
                          child: Text(item.name != null ? item.name : 'Missing', style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 25, fontFamily: 'OpenSans', fontWeight: FontWeight.w700)))),
                  ),
                  ),
                  //COST
                Positioned(
                  right: 0,
                  top: 0,
                  child: ClipRRect(borderRadius: BorderRadius.only(bottomLeft: Radius.circular(15)),
                              child: Container(color: Colors.black87, padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    child: Text('${this.isRecommendation ? '+ ':''}\$${item.cost.toStringAsFixed(2)}', style: TextStyle(fontSize: 18, color:Colors.white))),
                  ),
                  ),
                Positioned(
                  bottom: 0,
                  child: Container(color: Colors.black, padding: EdgeInsets.all(5), width: MediaQuery.of(context).size.width - (this.singleMeal ? 50 : 70), height: this.getDescription(context, item) == '' ? 0 : this.getDescription(context, item).length < 40 ? 35 : 65,
                      child: SingleChildScrollView(scrollDirection: Axis.vertical, child: Text(this.getDescription(context, item), style: TextStyle(fontSize: 18, color:Theme.of(context).accentColor), textAlign: TextAlign.center,))
                    )
                  ),
                  Container(height: item.referenceType == Meal ? 170 : 125,
                        width: double.infinity,
                    color: this.isRecommendation ? Colors.black26 : Colors.transparent,
                  child: this.isRecommendation ? Icon(Icons.add_circle, color: Colors.black54, size: 125): SizedBox(height: 1))
              ],
            )
        )),
    );
  }
}