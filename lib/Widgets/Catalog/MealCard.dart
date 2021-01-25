import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mealplanning/LocalStorage.dart';
import 'package:mealplanning/Providers/Ingredient.dart';
import 'package:mealplanning/Providers/Meal.dart';
import 'package:mealplanning/Providers/Settings.dart';
import 'package:mealplanning/Widgets/Catalog/Catalog-Edit/CatalogMealEdit.dart';
import 'package:provider/provider.dart';
import 'package:mealplanning/Providers/CatalogProvider.dart';

import 'Catalog.dart';
import 'IngredientListing.dart';

class MealCard extends StatefulWidget {
  final Meal meal;
  final Color backgroundColor;
  final bool selectionMode;
  final IconData selectionIcon;
  Function selectionCallBack = () {};
  Function setScrollHeight = () {};

  MealCard({this.meal, this.selectionMode = false, this.selectionIcon = Icons.add_circle, this.backgroundColor = Colors.black87, this.selectionCallBack, this.setScrollHeight});

  @override
  _MealCardState createState() => _MealCardState();
}

class _MealCardState extends State<MealCard> {
  bool showIngredients = false;

  getImageDisplay() async{
    File imageFile;
      await getImageFile(this.widget.meal.id).then((value)=>imageFile=value);
      if(imageFile != null && new File(imageFile.path).existsSync())
        return Image.file(imageFile, fit: BoxFit.cover,);
      else
        return Image.asset('assets/food.png', fit: BoxFit.cover,);
  }

  @override
  Widget build(BuildContext context) {
    print('Building -> MealCard');
    widget.setScrollHeight != null ? widget.setScrollHeight(widget.meal.id, !this.showIngredients ? 226.0 : widget.meal.totalIngredients() <4 ? ((widget.meal.totalIngredients()*108.0)+226) : 500.0) : null;
    final settings = Provider.of<Settings>(context);
    final catalogProvider = Provider.of<CatalogProvider>(context);
    // final mealProvider = Provider.of<MealProvider>(context);
    List<Widget> attributes = [];
    const double attributesSize = 35;
    const double attributesPadding = 3;
    final Icon ingredientsButton = showIngredients ? Icon(Icons.arrow_drop_up) : Icon(Icons.arrow_drop_down); 
    
    if(widget.meal.hasIngredients()) {settings.nameTags ? attributes.add(Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[Container(height: 60,  child: IconButton(onPressed: () {widget.selectionMode ? null : this.setState(()=>showIngredients=!showIngredients);}, icon: ingredientsButton, iconSize: 75, color: Colors.white,)),
      Text('Ingredients', style: TextStyle(fontSize: 15, color:Theme.of(context).accentColor))],))
    : attributes.add(Container(height: 60, child: IconButton(onPressed: () {widget.selectionMode ? null : this.setState(()=>showIngredients=!showIngredients);}, icon: ingredientsButton, iconSize: 75, color: Colors.white,)));}
    if(catalogProvider.getMeat(Meal, widget.meal.id)) {settings.nameTags ? 
    attributes.add(Column(children: <Widget>[Container(width: attributesSize, height: attributesSize, padding: EdgeInsets.symmetric(horizontal: attributesPadding), child: Image.asset('assets/steak.png')),
      Text('Meat', style: TextStyle(fontSize: 15, color:Theme.of(context).accentColor))],))
    : attributes.add(Container(width: attributesSize, height: attributesSize, padding: EdgeInsets.symmetric(horizontal: attributesPadding), child: Image.asset('assets/steak.png')));}
    if(catalogProvider.getCarb(Meal, widget.meal.id)){settings.nameTags ? 
    attributes.add(Column(children: <Widget>[Container(width: attributesSize, height: attributesSize, padding: EdgeInsets.symmetric(horizontal: attributesPadding), child: Image.asset('assets/bread.png')),
      Text('Carb', style: TextStyle(fontSize: 15, color:Theme.of(context).accentColor))],))
     : attributes.add(Container(width: attributesSize, height: attributesSize, padding: EdgeInsets.symmetric(horizontal: attributesPadding), child: Image.asset('assets/bread.png')));}
    if(catalogProvider.getVeg(Meal, widget.meal.id)){settings.nameTags ? 
    attributes.add(Column(children: <Widget>[Container(width: attributesSize, height: attributesSize, padding: EdgeInsets.symmetric(horizontal: attributesPadding), child: Image.asset('assets/carrot.png')),
      Text('Veggie', style: TextStyle(fontSize: 15, color:Theme.of(context).accentColor))],))
     : attributes.add(Container(width: attributesSize, height: attributesSize, padding: EdgeInsets.symmetric(horizontal: attributesPadding), child: Image.asset('assets/carrot.png')));}
    if(catalogProvider.getFruit(Meal, widget.meal.id)){settings.nameTags ? 
    attributes.add(Column(children: <Widget>[Container(width: attributesSize, height: attributesSize, padding: EdgeInsets.symmetric(horizontal: attributesPadding), child: Image.asset('assets/apple.png')),
      Text('Fruit', style: TextStyle(fontSize: 15, color:Theme.of(context).accentColor))],))
     : attributes.add(Container(width: attributesSize, height: attributesSize, padding: EdgeInsets.symmetric(horizontal: attributesPadding), child: Image.asset('assets/apple.png')));}
    if(catalogProvider.getSnack(Meal, widget.meal.id)){settings.nameTags ? 
    attributes.add(Column(children: <Widget>[Container(width: attributesSize, height: attributesSize, padding: EdgeInsets.symmetric(horizontal: attributesPadding), child: Image.asset('assets/apple.png')),
      Text('Snack', style: TextStyle(fontSize: 15, color:Theme.of(context).accentColor))],))
     : attributes.add(Container(width: attributesSize, height: attributesSize, padding: EdgeInsets.symmetric(horizontal: attributesPadding), child: Image.asset('assets/apple.png')));}

    List<Widget> ingredients = [];
    final double mealTotalCost = catalogProvider.getCalculatedAveragePerServingCost(widget.meal.id, type: Meal);
    if(widget.meal.essentialIngredients != null)
    widget.meal.essentialIngredients.forEach((ingredientId)=>ingredients.add(widget.selectionMode ? simplifiedIngredient(ingredient: catalogProvider.getIngredient(ingredientId), color: Theme.of(context).primaryColor)
              :  IngredientListing(ingredient: catalogProvider.getIngredient(ingredientId), backgroundColor: Colors.black87, tailTag: 'Cost', tail: Text('${((catalogProvider.getCalculatedAveragePerServingCost(ingredientId, type: Ingredient)/mealTotalCost)*100).toStringAsFixed(0)} %', style: TextStyle(fontSize: 20, color: Colors.white, fontFamily: 'Lato')),)));
    if(widget.meal.alternativeIngredients != null)
    widget.meal.alternativeIngredients.forEach((list) {   for(var i=0; i<list.length;i++) {
      if(i==0) widget.selectionMode ? simplifiedIngredient(ingredient: catalogProvider.getIngredient(list[i]), color: Theme.of(context).primaryColor)
                : ingredients.add(IngredientListing(ingredient: catalogProvider.getIngredient(list[i]), backgroundColor: Colors.black87, tailTag: 'Cost', tail: Text('${((catalogProvider.getCalculatedAveragePerServingCost(list[i], type: Ingredient)/mealTotalCost)*100).toStringAsFixed(0)} %', style: TextStyle(fontSize: 20, color: Colors.white, fontFamily: 'Lato'))));
      else ingredients.add(widget.selectionMode ? simplifiedIngredient(ingredient: catalogProvider.getIngredient(list[i]), indent: 'OR  ', color: Theme.of(context).primaryColor)
                : IngredientListing(ingredient: catalogProvider.getIngredient(list[i]), preFix: 'OR', backgroundColor: Colors.black87, tailTag: 'Cost', tail: Text('${((catalogProvider.getCalculatedAveragePerServingCost(list[i], type: Ingredient)/mealTotalCost)*100).toStringAsFixed(0)} %', style: TextStyle(fontSize: 20, color: Colors.white, fontFamily: 'Lato'))));
    } });
    if(widget.meal.extraIngredients != null)
    widget.meal.extraIngredients.forEach((ingredientId)=>ingredients.add(widget.selectionMode ? simplifiedIngredient(ingredient: catalogProvider.getIngredient(ingredientId), indent: '+  ', color: Theme.of(context).primaryColor)
                  : IngredientListing(ingredient: catalogProvider.getIngredient(ingredientId), preFix: '+', backgroundColor: Colors.black87, tailTag: 'Cost', tail: Text('${((catalogProvider.getCalculatedAveragePerServingCost(ingredientId, type: Ingredient)/mealTotalCost)*100).toStringAsFixed(0)} %', style: TextStyle(fontSize: 20, color: Colors.white, fontFamily: 'Lato')))));

    List<Widget> mealCard = [Card (
        elevation: 7,
        color: widget.backgroundColor,
        shadowColor: Colors.white30,
        margin: EdgeInsets.only(top: 10),
        // child: Center( 
          child: Padding( padding: EdgeInsets.all(10),
          child: Row( 
            children: [          
            Expanded(
                        child: Column( crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                SingleChildScrollView(scrollDirection: Axis.horizontal, child: Text('ID: ${widget.meal.id}', style: TextStyle(color: Colors.grey, fontSize: 15, fontFamily: 'Lato'))),
                Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: [SingleChildScrollView(scrollDirection: Axis.horizontal, child: Text(widget.meal.adjective, style: TextStyle(fontSize: 22, color: Colors.white, fontFamily: 'Lato'))),
            SingleChildScrollView(scrollDirection: Axis.horizontal, child: Text(widget.meal.name, style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 35, fontFamily: 'OpenSans', fontWeight: FontWeight.w700))),]),
                Text('Pantry: ${catalogProvider.getCalculatedQuantity(Meal, widget.meal.id).toStringAsFixed(0)}', style: TextStyle(fontSize: 20, color: Theme.of(context).accentColor, fontFamily: 'Lato')),
                Container(margin: EdgeInsets.only(top: 0, right: 15), child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: attributes,))),
              ],),
            ),
               BadgedImage(nameTags: settings.nameTags,
                 imageId: this.widget.meal.id, popularity: '${catalogProvider.getPopularityPercent(Meal, widget.meal.id).toStringAsFixed(0)}%',
                            recent: '${catalogProvider.getRecentPercent(Meal, widget.meal.id).toStringAsFixed(0)}%',
                            cost: '${catalogProvider.getCostPercentile(widget.meal.id).toStringAsFixed(0)}%',
                            price: ' \$ ${catalogProvider.getCalculatedAveragePerServingCost(widget.meal.id, type: Meal).toStringAsFixed(2)}  ')
          ])
          )      
      )
          ];
    if(this.showIngredients)
    mealCard.add(ConstrainedBox(
        constraints: BoxConstraints(maxHeight: 300),
        child: ListView(
                    padding: EdgeInsets.symmetric(horizontal: 5),
                    shrinkWrap: true,
                    children: ingredients
                    ),
      ));


  final Widget mealSelectionCard = Card(color: widget.backgroundColor, shadowColor: Colors.white24,
        margin: EdgeInsets.only(top: 5),
          child: Container( padding: EdgeInsets.all(10),
          child: Column(
          children: [ListTile( 
      leading: Container(
                    width: 50,
                    height: 85,
                    margin: EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(
                        border: Border.all(color: Theme.of(context).primaryColor, width: 2),
                        borderRadius: BorderRadius.circular(7)),          
                    child: FutureBuilder(future: getImageDisplay(),
                            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                                if(snapshot.connectionState == ConnectionState.done){return snapshot.data;}  
                                else{return CircularProgressIndicator();}
                          },),),
  title: Column(children: [
      SingleChildScrollView(scrollDirection: Axis.horizontal, child: Text(widget.meal.adjective, style: TextStyle(fontSize: 22, color: Colors.white, fontFamily: 'Lato'))),
      SingleChildScrollView(scrollDirection: Axis.horizontal, child: Text(widget.meal.name, style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 35, fontFamily: 'OpenSans', fontWeight: FontWeight.w700))),
      
  ]),
  trailing: IconButton(icon: Icon(widget.selectionIcon, size: 40, color: Theme.of(context).primaryColor), onPressed: () => widget.selectionCallBack()),),
  Container(margin: EdgeInsets.only(left: 20), child: Column(children: ingredients)),
    ])));

  return GestureDetector( onTap: () {widget.selectionMode ? null : showMealEdit(context: context, mealId: widget.meal.id, onExitUpdate: ()=>Navigator.of(context).pushReplacement(MaterialPageRoute(builder:(context)=>Catalog(displayType: Meal,))));
    }, child: widget.selectionMode ? mealSelectionCard : Column(children: mealCard));
  }
}

Widget simplifiedIngredient({Ingredient ingredient, String indent ='', Color color}){
  return SingleChildScrollView(scrollDirection: Axis.horizontal, 
      child: Row(children: [Text(indent+ingredient.adjective, style: TextStyle(fontSize: 15, color: Colors.white, fontFamily: 'Lato')), 
    SizedBox(width: 10), 
    Text(ingredient.name, style: TextStyle(color: color, fontSize: 20, fontFamily: 'Lato',))]),
  );
}


class BadgedImage extends StatelessWidget {
  BadgedImage({
    Key key,
    @required this.imageId,
    @required this.nameTags,
    this.color, this.popularity, this.recent, this.price, this.cost,
  }) : super(key: key);

  final String imageId;
  final String popularity;
  final String recent;
  final String price;
  final String cost;
  final Color color;
  bool nameTags = true;

  getImageDisplay() async{
    File imageFile;
      await getImageFile(this.imageId).then((value)=>imageFile=value);
      if(imageFile != null && new File(imageFile.path).existsSync())
        return Image.file(imageFile, fit: BoxFit.cover,);
      else
        return Image.asset('assets/food.png', fit: BoxFit.cover,);
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> items = [];
    if(nameTags) items.add(
      Container( width: 150,
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[Text('Popular', style: TextStyle(fontSize: 15, color:Theme.of(context).accentColor)),
              Text('Recent', style: TextStyle(fontSize: 15, color:Theme.of(context).accentColor))],),
            ),   
    );
    items.add(
      Stack(
        alignment: Alignment.center,
        children: [
          Container(
                  // height: 500,
                  width: 150,
                  decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).primaryColor, width: 5),
                      borderRadius: BorderRadius.circular(7)),          
                  child: FutureBuilder(future: getImageDisplay(),
                            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                                if(snapshot.connectionState == ConnectionState.done){return snapshot.data;}  
                                else{return CircularProgressIndicator();}
                          },),),
          Positioned(
            left: -50,
            top: -50,
            child: CircleAvatar(backgroundColor: Colors.black87, radius: 50, 
                )
            ),
            Positioned(
            left: 5,
            top: 5,
            child: Text(this.popularity, style: TextStyle(fontSize: 18, color:Colors.white))
            ),
          Positioned(
            right: -50,
            top: -50,
            child: CircleAvatar(backgroundColor: Colors.black87, radius: 50, 
                )
            ),
            Positioned(
            right: 5,
            top: 5,
            child: Text(this.recent, style: TextStyle(fontSize: 18, color:Colors.white))
            ),
          Positioned(
            bottom: 0,
            child: Container(color: Colors.black87, width: 150, height: 35,
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
                  Text(this.price, style: TextStyle(fontSize: 18, color:Colors.white)),
                  Text(this.cost, style: TextStyle(fontSize: 18, color:Colors.white))
              ],)
            )
            ),
        ],
      ),
    );
    if(nameTags) items.add(
            Center(child: Text('Price   Analysis', style: TextStyle(fontSize: 15, color:Theme.of(context).accentColor))),
    );

    return Column(
          children: items,
    );
  }
}


