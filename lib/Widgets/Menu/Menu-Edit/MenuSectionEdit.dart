
import 'package:flutter/material.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:mealplanning/Providers/CatalogProvider.dart';
import 'package:mealplanning/Providers/MenuProvider.dart';
import 'package:mealplanning/Providers/Settings.dart';
import 'package:mealplanning/Providers/SingleMealProvider.dart';
import 'package:provider/provider.dart';
import '../../EditBlank.dart';

showMenuSection({BuildContext context, bool singleMeal = false, String menuId, String dayId, String sectionId, Function onExitUpdate, Function deductPantry}){
showModalBottomSheet(
        context: context,
        builder: (newContext) {
         return Container(child: EditMenuSection(singleMeal: singleMeal, menuId: menuId, dayId: dayId, sectionId: sectionId, onExitUpdate: onExitUpdate, deductPantry: deductPantry,));
        });
}

class EditMenuSection extends StatelessWidget {
  final bool singleMeal;
  final String menuId;
  final String dayId;
  final String sectionId;
  Function deductPantry = () {};
  Function onExitUpdate = () {};

  EditMenuSection({this.singleMeal = false, this.onExitUpdate, this.menuId, this.dayId, this.sectionId, this.deductPantry});

 Widget build(BuildContext context){
   print('Building: EditMenuSection-bottomSheet');
         final settings = Provider.of<Settings>(context);
        //   final catalogProvider = Provider.of<CatalogProvider>(context);
          final menuProvider = Provider.of<MenuProvider>(context);
          final singleProvider = Provider.of<SingleMealProvider>(context);
          final TextStyle tagStyle = TextStyle(fontSize: 20, color:Theme.of(context).accentColor);
          final TextStyle propertyStyle = TextStyle(fontSize: 35, color:Theme.of(context).primaryColor);
          final TextStyle smallerStyle = TextStyle(fontSize: 25, color:Theme.of(context).primaryColor);
          final TextStyle placeStyle = TextStyle(fontSize: 25, color:Theme.of(context).accentColor);

          MenuSection section = this.singleMeal ? singleProvider.getSection() : menuProvider.getMenuSection(menuId: menuId, dayId: dayId, sectionId: sectionId);  

          return new WillPopScope(
            onWillPop: () async {if(this.onExitUpdate != null) this.onExitUpdate(); return true;},
          child: GestureDetector(
              onTap: () {}, //close?
              behavior: HitTestBehavior.opaque,
              child: Container(color: Colors.grey[900],
                child: SingleChildScrollView(scrollDirection: Axis.vertical, child: Column(children: 
                !this.singleMeal ? [
                  Container(padding: EdgeInsets.all(15), color: Colors.black, width: double.infinity, alignment: Alignment.center,
                        child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: Text('Edit Menu Meal:', style: TextStyle(fontSize: 25, color: Colors.white, fontFamily: 'Lato', )))),
                   DisplayConstant(property: section.id, tag: 'ID', propertyStyle: smallerStyle, tagStyle: tagStyle,),
                    EditValue(value: section.name, tag: 'Title', tagStyle: tagStyle, propertyStyle: propertyStyle, onChangeCallBack: (value)=>menuProvider.setMenuSectionName(menuId: menuId, dayId: dayId, sectionId: sectionId, name: value),),
                    EditCount(value: section.servings, increase: ()=>menuProvider.increaseMenuSectionServings(menuId: menuId, dayId: dayId, sectionId: sectionId), decrease: ()=>menuProvider.decreaseMenuSectionServings(menuId: menuId, dayId: dayId, sectionId: sectionId), tag: 'Servings', place: '',  placeStyle: placeStyle, tagStyle: tagStyle, propertyStyle: propertyStyle,),
                    EditCheckStringOptions(tag: 'Recommendation Types', selected: section.recommendationTypes, options: settings.recommendationTypes, propertyStyle: smallerStyle, tagStyle: tagStyle, onAdd: (tag)=>menuProvider.addMenuSectionRecommendationTypes(menuId: menuId, dayId: dayId, sectionId: sectionId, tag: tag), onRemove: (tag)=>menuProvider.removeMenuSectionRecommendationTypes(menuId: menuId, dayId: dayId, sectionId: sectionId, tag: tag)),
                    EditButton(propertyName: 'Mark Eatten', tag: 'Deduct from Pantry', icon: Icons.radio_button_unchecked, propertyStyle: propertyStyle, tagStyle: tagStyle, onClick: () {menuProvider.markMenuSectionDone(menuId: menuId, dayId: dayId, sectionId: sectionId); if(this.deductPantry != null) this.deductPantry(); if(this.onExitUpdate != null) this.onExitUpdate(); Navigator.of(context).pop();},), 
                    EditAdvanceAction(action: () {menuProvider.clearMenuSection(menuId: menuId, dayId: dayId, sectionId: sectionId); if(this.onExitUpdate != null) this.onExitUpdate();  Navigator.pop(context);}, warning: 'CLEAR', tag: 'Clear all Meal Items', tagStyle: tagStyle,),
                    EditAdvanceAction(action: () {menuProvider.removeMenuSection(menuId:  menuId, dayId: dayId, sectionId: sectionId); if(this.onExitUpdate != null) this.onExitUpdate();  Navigator.pop(context);}, warning: 'DELETE', tag: 'Delete this Meal', tagStyle: tagStyle,),
                    EditButton(propertyName: 'SAVE', tag: 'Close Edit Page', propertyStyle: propertyStyle, tagStyle: tagStyle, onClick: () {if(this.onExitUpdate != null) this.onExitUpdate();  Navigator.pop(context);},),
                ] : [
                   Container(padding: EdgeInsets.all(15), color: Colors.black, width: double.infinity, alignment: Alignment.center,
                        child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: Text('Edit Meal Properties:', style: TextStyle(fontSize: 25, color: Colors.white, fontFamily: 'Lato', )))),
                    EditCount(value: section.servings, increase: ()=>singleProvider.increaseSectionServings(), decrease: ()=>singleProvider.decreaseSectionServings(), tag: 'Servings', place: '',  placeStyle: placeStyle, tagStyle: tagStyle, propertyStyle: propertyStyle,),
                    EditCheckStringOptions(tag: 'Recommendation Types', selected: section.recommendationTypes, options: settings.recommendationTypes, propertyStyle: smallerStyle, tagStyle: tagStyle, onAdd: (tag)=>singleProvider.addSectionRecommendationTypes(tag: tag), onRemove: (tag)=>singleProvider.removeSectionRecommendationTypes(tag: tag)),
                    EditButton(propertyName: 'Mark Eatten', tag: 'Deduct from Pantry', icon: Icons.radio_button_unchecked, propertyStyle: propertyStyle, tagStyle: tagStyle, onClick: () {singleProvider.markSectionDone(); if(this.deductPantry != null) this.deductPantry(); if(this.onExitUpdate != null) this.onExitUpdate(); Navigator.of(context).pop();},), 
                    EditAdvanceAction(action: () {singleProvider.clearSection(); if(this.onExitUpdate != null) this.onExitUpdate();  Navigator.pop(context);}, warning: 'CLEAR', tag: 'Clear all Meal Items', tagStyle: tagStyle,),
                    EditButton(propertyName: 'SAVE', tag: 'Close Edit Page', propertyStyle: propertyStyle, tagStyle: tagStyle, onClick: () {if(this.onExitUpdate != null) this.onExitUpdate();  Navigator.pop(context);},),
                ]))),
            ),
          );
  }
  }

 