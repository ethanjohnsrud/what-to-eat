import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mealplanning/LocalStorage.dart';
import 'package:mealplanning/Providers/CatalogProvider.dart';
import 'package:mealplanning/Providers/Ingredient.dart';
import 'package:mealplanning/Providers/Settings.dart';
import 'package:mealplanning/Widgets/Catalog/Catalog-Edit/CatalogIngredientEdit.dart';
import 'package:provider/provider.dart';

import 'Catalog.dart';

class IngredientListing extends StatelessWidget {
  final Ingredient ingredient;
  final Widget tail;
  final String tailTag;
  final Color backgroundColor;
  final bool indent;
  final bool showPantry;
  final bool selectionMode;
  Function setScrollHeight = () {};
  Function onSelectionClick = () {};
  String preFix = '';

  IngredientListing({this.ingredient, this.preFix = '', this.tail, this.tailTag='', this.backgroundColor = Colors.black87, this.indent = false, this.showPantry = false, this.selectionMode = false, this.setScrollHeight, this.onSelectionClick});

  getImageDisplay() async{
      File imageFile;
      await getImageFile(this.ingredient.id).then((value)=>imageFile=value);
        if(imageFile != null && new File(imageFile.path).existsSync())
          return Image.file(imageFile, fit: BoxFit.cover,);
        else
          return Image.asset('assets/food.png', fit: BoxFit.cover,);
    }

  @override
  Widget build(BuildContext context) {
    print('Building -> Ingredeint_Listing -> ${ingredient.name}');
    setScrollHeight != null ? setScrollHeight(ingredient.id, 108.0) : null;
    final settings = Provider.of<Settings>(context);
    final catalogProvider = Provider.of<CatalogProvider>(context);

    File imageFile;
    getImageFile(ingredient.id).then((value)=>imageFile=value); 
    
    List<Widget> attributes = [];
    const double attributesSize = 25;
    if(!selectionMode) {
      if(ingredient.meat) {settings.nameTags ? 
      attributes.add(Column(children: <Widget>[Container(width: attributesSize, height: attributesSize, margin: EdgeInsets.symmetric(horizontal: 10), child: Image.asset('assets/steak.png')),
        Text('Meat', style: TextStyle(fontSize: 15, color:Theme.of(context).accentColor))],))
      : attributes.add(Container(width: attributesSize, height: attributesSize, margin: EdgeInsets.symmetric(horizontal: 10), child: Image.asset('assets/steak.png')));}
      if(ingredient.carb){settings.nameTags ? 
      attributes.add(Column(children: <Widget>[Container(width: attributesSize, height: attributesSize, margin: EdgeInsets.symmetric(horizontal: 10), child: Image.asset('assets/bread.png')),
        Text('Carb', style: TextStyle(fontSize: 15, color:Theme.of(context).accentColor))],))
      : attributes.add(Container(width: attributesSize, height: attributesSize, margin: EdgeInsets.symmetric(horizontal: 10), child: Image.asset('assets/bread.png')));}
      if(ingredient.veg){settings.nameTags ? 
      attributes.add(Column(children: <Widget>[Container(width: attributesSize, height: attributesSize, margin: EdgeInsets.symmetric(horizontal: 10), child: Image.asset('assets/carrot.png')),
        Text('Veggie', style: TextStyle(fontSize: 15, color:Theme.of(context).accentColor))],))
      : attributes.add(Container(width: attributesSize, height: attributesSize, margin: EdgeInsets.symmetric(horizontal: 10), child: Image.asset('assets/carrot.png')));}
      if(ingredient.fruit){settings.nameTags ? 
      attributes.add(Column(children: <Widget>[Container(width: attributesSize, height: attributesSize, margin: EdgeInsets.symmetric(horizontal: 10), child: Image.asset('assets/apple.png')),
        Text('Fruit', style: TextStyle(fontSize: 15, color:Theme.of(context).accentColor))],))
      : attributes.add(Container(width: attributesSize, height: attributesSize, margin: EdgeInsets.symmetric(horizontal: 10), child: Image.asset('assets/apple.png')));}
      if(ingredient.snack){settings.nameTags ? 
      attributes.add(Column(children: <Widget>[Container(width: attributesSize, height: attributesSize, margin: EdgeInsets.symmetric(horizontal: 10), child: Image.asset('assets/apple.png')),
        Text('Snack', style: TextStyle(fontSize: 15, color:Theme.of(context).accentColor))],))
      : attributes.add(Container(width: attributesSize, height: attributesSize, margin: EdgeInsets.symmetric(horizontal: 10), child: Image.asset('assets/apple.png')));}
    }
      settings.nameTags ? 
      attributes.add(Container(margin: EdgeInsets.only(left: 20), child: Column(children: [this.tail, 
        Text(this.tailTag, style: TextStyle(fontSize: 15, color:Theme.of(context).accentColor))])))
      : attributes.add(this.tail);
   
    List<Widget> items = [];
    items.add(Container(
                  width: 50,
                  margin: EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).primaryColor, width: 2),
                      borderRadius: BorderRadius.circular(7)),          
                  child: FutureBuilder(future: getImageDisplay(),
                            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                                if(snapshot.connectionState == ConnectionState.done){return snapshot.data;}  
                                else{return CircularProgressIndicator();}
                          },),),
              );
    if(preFix != '' && preFix != null) items.add(Container(margin: EdgeInsets.only(right: 10), child: Text(this.preFix, style: TextStyle(fontSize: 20, color: Colors.white, fontFamily: 'Lato'))));
    this.showPantry ? items.add(Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SingleChildScrollView(scrollDirection: Axis.horizontal, child: Text(ingredient.adjective, style: TextStyle(fontSize: 20, color: Colors.white, fontFamily: 'Lato'))),
              SingleChildScrollView(scrollDirection: Axis.horizontal, child: Text(ingredient.name, style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 27, fontFamily: 'OpenSans', fontWeight: FontWeight.w700))),
              Text('Pantry: ${catalogProvider.getCalculatedQuantity(Ingredient, ingredient.id).toStringAsFixed(0)}', style: TextStyle(fontSize: 18, color: Theme.of(context).accentColor, fontFamily: 'Lato')),])))
        : items.add(Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SingleChildScrollView(scrollDirection: Axis.horizontal, child: Text(ingredient.adjective, style: TextStyle(fontSize: 20, color: Colors.white, fontFamily: 'Lato'))),
              SingleChildScrollView(scrollDirection: Axis.horizontal, child: Text(ingredient.name, style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 27, fontFamily: 'OpenSans', fontWeight: FontWeight.w700))),
             ])));
    items.add(SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: attributes)));

    return GestureDetector( onTap: () {this.selectionMode ? this.onSelectionClick != null ? this.onSelectionClick() : null : showIngredientEdit(context: context, ingredientId: ingredient.id, onExitUpdate: ()=>Navigator.of(context).pushReplacement(MaterialPageRoute(builder:(context)=>Catalog(displayType: Ingredient,))));}, 
    child:Card (
        elevation: 3,
        color: this.backgroundColor,
        shadowColor: Colors.white24,
        margin: EdgeInsets.only(left: this.indent ? 10 : 0, top: 5),
          child: Container( padding: EdgeInsets.all(10),
          child: Row(children: items)
          )
      ));
  }
}