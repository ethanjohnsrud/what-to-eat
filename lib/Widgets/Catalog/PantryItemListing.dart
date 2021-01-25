import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mealplanning/LocalStorage.dart';
import 'package:mealplanning/Providers/CatalogProvider.dart';
import 'package:mealplanning/Providers/Ingredient.dart';
import 'package:mealplanning/Providers/Meal.dart';
import 'package:mealplanning/Providers/PantryItem.dart';
import 'package:mealplanning/Providers/Settings.dart';
import 'package:mealplanning/Widgets/Catalog/Catalog-Edit/CatalogPantryItemEdit.dart';
import 'package:provider/provider.dart';

import 'Catalog.dart';

class PantryItemListing extends StatelessWidget {
  final PantryItem item;
  final Color backgroundColor;
  final bool selectionMode;
  final IconData selectionIcon;
  Function selectionCallBack = () {};
  Function setScrollHeight = () {};

  PantryItemListing({this.item, this.backgroundColor = Colors.black87, this.selectionMode = false, this.selectionCallBack, this.selectionIcon = Icons.remove_circle, this.setScrollHeight});

  getImageDisplay() async{
    File imageFile;
      await getImageFile(this.item.id).then((value)=>imageFile=value);

    if(imageFile == null || !(new File(imageFile.path).existsSync())){
      if(item.referenceId != null && item.referenceId != '')
        await getImageFile(item.referenceId).then((value)=>imageFile=value);
    } 
    
    if(imageFile == null || !(new File(imageFile.path).existsSync()))
      return Image.asset('assets/food.png', fit: BoxFit.cover,);
    else
       return Image.file(imageFile, fit: BoxFit.cover,);
  }

  @override
  Widget build(BuildContext context) {
    print('Building -> Panty-ItemListing');
    setScrollHeight != null ? setScrollHeight(item.id, 126.0) : null;
    final settings = Provider.of<Settings>(context);
    final catalogProvider = Provider.of<CatalogProvider>(context);

    File imageFile;
    getImageFile(item.id).then((value)=>imageFile=value);

    String pantryUnits = '';
    settings.pricingUnits.forEach((unit) {if(item.referenceType == Meal && catalogProvider.getMeal(item.referenceId).servingsPerUnit.containsKey(unit)) {if(pantryUnits != '') pantryUnits += ' | '; pantryUnits += '${(item.quantity / catalogProvider.getMeal(item.referenceId).servingsPerUnit[unit]).toStringAsPrecision(1)} ${unit}';}
    if(item.referenceType == Ingredient && catalogProvider.getIngredient(item.referenceId).servingsPerUnit.containsKey(unit)) {if(pantryUnits != '') pantryUnits += ' | '; pantryUnits += '${(item.quantity / catalogProvider.getIngredient(item.referenceId).servingsPerUnit[unit]).toStringAsPrecision(1)} ${unit}';}});
      
    List<Widget> items = []; //master row
    items.add(Container( //Add Image
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
              //Add Description/name/quantity
              List<Widget> centerInfo = [];
              if(item.referenceType == null || item.referenceId == null || item.referenceId == '' || item.referenceId == 'm0' || item.referenceId == 'i0' || (item.referenceType == Meal && catalogProvider.getMeal(item.referenceId).id == 'm0') || (item.referenceType == Ingredient && catalogProvider.getIngredient(item.referenceId).id == 'i0'))
                centerInfo.add(Text('MISSING LINK', style: TextStyle(fontSize: 15, color: Colors.red[900], fontFamily: 'Lato')));
              centerInfo.addAll([
                SingleChildScrollView(scrollDirection: Axis.horizontal, child: Text(item.description, style: TextStyle(fontSize: 20, color: Colors.white, fontFamily: 'Lato'))),
                SingleChildScrollView(scrollDirection: Axis.horizontal, child: Text(item.name, style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 27, fontFamily: 'OpenSans', fontWeight: FontWeight.w700))),
                SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: [Text('Servings: ${item.quantity.toStringAsFixed(0)}', style: TextStyle(fontSize: 16, color: Theme.of(context).accentColor, fontFamily: 'Lato')),
                    SizedBox(width: 5), Text('[${pantryUnits}]', style: TextStyle(fontSize: 14, color: Theme.of(context).primaryColor, fontFamily: 'Lato'))])),
              ]);
              
              
      items.add(Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: centerInfo)));
    //Add Tail: selection -> expiration, add, price
    // else -> expiration, quantity +/-, price
    List<Widget> tail = [];
    const double tailMargin = 1;
    final int daysTillExpiration = (item.expirationDate != null) ? item.expirationDate.difference(DateTime.now()).inDays : 0;
    settings.nameTags ? tail.add(Container(margin: EdgeInsets.all(tailMargin), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
            Text('Expiration:  ', style: TextStyle(fontSize: 15, color:Theme.of(context).accentColor)),
            Text('${daysTillExpiration.toStringAsFixed(0)} days', style: TextStyle(fontSize: 18, color: daysTillExpiration >0 ? Theme.of(context).accentColor : Colors.red[900], fontFamily: 'Lato'))],),
    ))
      : tail.add(Container(margin: EdgeInsets.all(tailMargin), child: Text('${daysTillExpiration.toStringAsFixed(0)} days', style: TextStyle(fontSize: 18, color: daysTillExpiration >0 ? Theme.of(context).accentColor : Colors.red[900], fontFamily: 'Lato'))));
  if(selectionMode)
        tail.add(Container(margin: EdgeInsets.symmetric(horizontal: tailMargin, vertical: tailMargin*3), child: IconButton(icon: Icon(selectionIcon, size: 40, color: Theme.of(context).primaryColor), onPressed: () => selectionCallBack())));
  else
    (item.quantity <= 1) ? tail.add(Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [Container(margin: EdgeInsets.symmetric(vertical: tailMargin, horizontal: tailMargin*3), child: IconButton(icon: Icon(Icons.add_circle, color:Theme.of(context).primaryColor, size:40,), onPressed: () => catalogProvider.increasePantryItemQuantity(item.id))), 
                  Container(margin: EdgeInsets.symmetric(vertical: tailMargin, horizontal: tailMargin*3), child: IconButton(icon: Icon(Icons.delete, color:Colors.red[900], size:40,), onPressed: () => catalogProvider.removePantryItem(item.id)))]))   
      : (daysTillExpiration < 0) ? tail.add(Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [Container(margin: EdgeInsets.symmetric(vertical: tailMargin, horizontal: tailMargin*3), child: IconButton(icon: Icon(Icons.remove_circle, color:Theme.of(context).primaryColor, size:40,), onPressed: () => catalogProvider.decreasePantryItemQuantity(item.id))), 
                  Container(margin: EdgeInsets.symmetric(vertical: tailMargin, horizontal: tailMargin*3), child: IconButton(icon: Icon(Icons.delete, color:Colors.red[900], size:40,), onPressed: () => catalogProvider.removePantryItem(item.id)))]))   
      : tail.add(Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [Container(margin: EdgeInsets.symmetric(vertical: tailMargin, horizontal: tailMargin*3), child: IconButton(icon: Icon(Icons.remove_circle, color:Theme.of(context).primaryColor, size:40,), onPressed: () => catalogProvider.decreasePantryItemQuantity(item.id))), 
                  Container(margin: EdgeInsets.symmetric(vertical: tailMargin, horizontal: tailMargin*3), child: IconButton(icon: Icon(Icons.add_circle, color:Theme.of(context).primaryColor, size:40,), onPressed: () => catalogProvider.increasePantryItemQuantity(item.id)))]));

    settings.nameTags ? tail.add(Container(margin: EdgeInsets.all(tailMargin), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
            Text('Cost:  ', style: TextStyle(fontSize: 15, color:Theme.of(context).accentColor)),
            Text('\$${catalogProvider.getCalculatedAveragePerServingCost(item.referenceId, type: item.referenceType).toStringAsFixed(2)}', style: TextStyle(fontSize: 18, color: Theme.of(context).accentColor, fontFamily: 'Lato'))],),
    ))
      : tail.add(Container(margin: EdgeInsets.all(tailMargin), child: Text('\$${catalogProvider.getCalculatedAveragePerServingCost(item.referenceId, type: item.referenceType).toStringAsFixed(2)}', style: TextStyle(fontSize: 18, color: Theme.of(context).accentColor, fontFamily: 'Lato'))));

      items.add(Column(crossAxisAlignment: CrossAxisAlignment.end, children: tail,));

    return GestureDetector( onTap: () {this.selectionMode ? null : showPantryItemEdit(context: context, itemId: item.id, onExitUpdate: ()=>Navigator.of(context).pushReplacement(MaterialPageRoute(builder:(context)=>Catalog(displayType: PantryItem,))));}, 
    child:Card (
        elevation: 3,
        color: this.backgroundColor,
        shadowColor: Colors.white24,
        margin: EdgeInsets.only(top: 5),
          child: Container( padding: EdgeInsets.all(10),
          child: Row(children: items)
          )
      ));
  }
}