
import 'package:flutter/material.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:mealplanning/Providers/MenuProvider.dart';
import 'package:mealplanning/Providers/Settings.dart';
import 'package:provider/provider.dart';
import '../../EditBlank.dart';
import '../MenuDisplay.dart';
import 'MenuSectionEdit.dart';

showMenuDay({BuildContext context, String menuId, String dayId, Function remove, Function onExitUpdate}){
showModalBottomSheet(
        context: context,
        builder: (newContext) {
         return Container(child: EditMenuDay(menuId: menuId, dayId: dayId, remove: remove, onExitUpdate: onExitUpdate,));
        },
        // isScrollControlled: true,
        // fullscreenDialog: true,
        );
}

class EditMenuDay extends StatelessWidget {
  final String menuId;
  final String dayId;
  Function remove = () {};
  Function onExitUpdate = () {};

  EditMenuDay({this.menuId, this.dayId, this.remove, this.onExitUpdate});

 Widget build(BuildContext context){
   print('Building: EditMenuSection-bottomSheet' );
  final settings = Provider.of<Settings>(context);
  final menuProvider = Provider.of<MenuProvider>(context);
  final TextStyle tagStyle = TextStyle(fontSize: 20, color:Theme.of(context).accentColor);
  final TextStyle propertyStyle = TextStyle(fontSize: 35, color:Theme.of(context).primaryColor);
  final TextStyle smallerStyle = TextStyle(fontSize: 25, color:Theme.of(context).primaryColor);
  // final TextStyle placeStyle = TextStyle(fontSize: 25, color:Theme.of(context).accentColor);

MenuDay day = menuProvider.getMenuDay(menuId: menuId, dayId: dayId);
  
  return new WillPopScope(
    onWillPop: () async { if(this.onExitUpdate != null) this.onExitUpdate(); return true;},
  child: GestureDetector(
      onTap: () {}, //close?
      behavior: HitTestBehavior.opaque,
      child: Container(color: Colors.grey[900],
        child: SingleChildScrollView(scrollDirection: Axis.vertical, child: Column(children: [
            Container(padding: EdgeInsets.all(15), color: Colors.black,  width: double.infinity, alignment: Alignment.center,
                        child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: Text('Edit Menu Day:', style: TextStyle(fontSize: 25, color: Colors.white, fontFamily: 'Lato', )))),
            DisplayConstant(property: day.id, tag: 'ID', propertyStyle: smallerStyle, tagStyle: tagStyle,),
            EditValue(value: day.name, tag: 'Title', tagStyle: tagStyle, propertyStyle: propertyStyle, onChangeCallBack: (value)=>menuProvider.setMenuDayName(name: value, menuId: this.menuId, dayId: this.dayId),),
            EditDate(date: day.date == null ? DateTime.now() : day.date, tag: 'Date', propertyStyle: propertyStyle, tagStyle: tagStyle, callBack: (pickedDate)=>menuProvider.setMenuDayDate(menuId: menuId, dayId: dayId, date: pickedDate),),
            EditButton(tag: 'Add Meal', tagStyle: tagStyle, propertyName: 'NEW MEAL', icon: Icons.add_circle, propertyStyle: propertyStyle, onClick: () {final String newId = settings.getUniqueID(context, MenuSection);
              menuProvider.addMenuSection(menuId: menuId, dayId: dayId, section: new MenuSection(id: newId, name: 'Meal', menuItemList: []));
                // Navigator.of(context).pushReplacement(MaterialPageRoute(builder:(context)=>MenuDisplay()));
                showMenuSection(context: context, menuId: menuId, dayId: dayId, sectionId: newId, );}, ),
            EditAdvanceAction(action: () {menuProvider.clearMenuDay(menuId: menuId, dayId: dayId); if(this.onExitUpdate != null) this.onExitUpdate(); Navigator.pop(context);}, warning: 'CLEAR', tag: 'Clear all Meals', tagStyle: tagStyle,),
            EditAdvanceAction(action: () {remove(); if(this.onExitUpdate != null) this.onExitUpdate(); Navigator.pop(context);}, warning: 'DELETE', tag: 'Delete this Day', tagStyle: tagStyle,),
            EditButton(propertyName: 'SAVE', tag: 'Close Edit Page', propertyStyle: propertyStyle, tagStyle: tagStyle, onClick: () {if(this.onExitUpdate != null) this.onExitUpdate(); Navigator.pop(context);},),
        ]))),
    ),
  );
  }
  }

 