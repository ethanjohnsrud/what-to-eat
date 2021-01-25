import 'package:flutter/material.dart';
import 'package:mealplanning/LocalStorage.dart';
import 'package:mealplanning/Providers/CatalogProvider.dart';
import 'package:mealplanning/Providers/Ingredient.dart';
import 'package:mealplanning/Providers/Meal.dart';
import 'package:mealplanning/Providers/MenuProvider.dart';
import 'package:mealplanning/Providers/PantryItem.dart';
import 'package:mealplanning/Providers/Settings.dart';
import 'package:mealplanning/Providers/ShoppingListProvider.dart';
// import 'package:mealplanning/Widgets/Menu/SingleMealDisplay.dart';
import 'package:mealplanning/Widgets/ShoppingList/ShoppingListDisplay.dart';
import 'package:provider/provider.dart';

import 'Catalog/Catalog.dart';
import 'Menu/MenuDisplay.dart';

class AppDrawer extends StatefulWidget {
  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  bool resetAllowed = false;
  bool clearAllowed = false;
  @override
  Widget build(BuildContext context) {
    print('Building -> PageDrawer');
    final settings = Provider.of<Settings>(context);
    return Drawer(
      elevation: 25,
      child: Container(
        padding: EdgeInsets.only(top: 20, left: 15),
        color: Colors.black,
        child: Column(children: [
          Text('Meal Planning', style: TextStyle(fontSize: 30, color: Theme.of(context).primaryColor, fontFamily: 'Lato')), SizedBox(height: 20,),
          Divider(color: Colors.grey[300]),
          Expanded(child: ListView(children: [
            //Navigation
            // ListTile(contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 10), leading: Icon(Icons.local_pizza, color: Colors.white), title: Text('What to Eat?', style: TextStyle(fontSize: 20, color: Colors.white, fontFamily: 'Lato')),
            // onTap: () {Navigator.of(context).pushReplacement(MaterialPageRoute(builder:(context)=>SingleMealDisplay()));}),
            // Divider(color: Colors.grey[300]),
            ListTile(contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 10), leading: Icon(Icons.fastfood, color: Colors.white), title: Text('Menu', style: TextStyle(fontSize: 20, color: Colors.white, fontFamily: 'Lato')),
            onTap: () {Navigator.of(context).pushReplacement(MaterialPageRoute(builder:(context)=>MenuDisplay()));}),
            Divider(color: Colors.grey[300]),
            ListTile(contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 10), leading: Icon(Icons.shopping_cart, color: Colors.white), title: Text('Shopping List', style: TextStyle(fontSize: 20, color: Colors.white, fontFamily: 'Lato')),
            onTap: () {Navigator.of(context).pushReplacement(MaterialPageRoute(builder:(context)=>ShoppingListDisplay()));}),
            Divider(color: Colors.grey[300]),
            ListTile(contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 10), leading: Icon(Icons.store, color: Colors.white), title: Text('Pantry', style: TextStyle(fontSize: 20, color: Colors.white, fontFamily: 'Lato')),
            onTap: () {Navigator.of(context).pushReplacement(MaterialPageRoute(builder:(context)=>Catalog(displayType: PantryItem,))); }),
            Divider(color: Colors.grey[300]),
            ListTile(contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 10), leading: Icon(Icons.restaurant, color: Colors.white), title: Text('Meals', style: TextStyle(fontSize: 20, color: Colors.white, fontFamily: 'Lato')),
            onTap: () {Navigator.of(context).pushReplacement(MaterialPageRoute(builder:(context)=>Catalog(displayType: Meal,)));}),
            Divider(color: Colors.grey[300]),
            ListTile(contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 10), leading: Icon(Icons.restaurant_menu, color: Colors.white), title: Text('Ingredients', style: TextStyle(fontSize: 20, color: Colors.white, fontFamily: 'Lato')),
            onTap: () {Navigator.of(context).pushReplacement(MaterialPageRoute(builder:(context)=>Catalog(displayType: Ingredient,)));}),
            
              
            //settings
            Divider(color: Colors.grey[300], height: 4,),
            ListTile(contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 10), leading: Icon(settings.nameTags ? Icons.label_outline : Icons.label, color: Colors.white), title: Text(settings.nameTags ? 'Turn off Tags' : 'Turn on Tags', style: TextStyle(fontSize: 20, color: Colors.white, fontFamily: 'Lato')),
            onTap: () {settings.toggleNameTags(); }),
            Divider(color: Colors.grey[300]),
            ListTile(contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 10), leading: Icon(settings.accountForNotch ? Icons.smartphone : Icons.system_update, color: Colors.white), title: Text(settings.accountForNotch ? 'Full Screen' : 'Account for Notch', style: TextStyle(fontSize: 20, color: Colors.white, fontFamily: 'Lato')),
            onTap: () {settings.toggleAccountForNotch(); }),
            Divider(color: Colors.grey[300]),
            ListTile(contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 10), leading: Icon(Icons.linear_scale, color: Colors.white), title: Text('Recommendation Variety', style: TextStyle(fontSize: 20, color: Colors.white, fontFamily: 'Lato')), onTap: () {}),
            ListTile(contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),  onTap: () {},
            title: SizedBox(width: 50,
              child: Slider(
                value: settings.recommendationVariety.toDouble(), 
                  onChanged: (newValue) {settings.setRecommendationVariety(newValue.toInt());},
                  activeColor: Theme.of(context).primaryColor,
                  inactiveColor: Colors.grey[900],
                  min: 1,
                  max: 5,
                  label: settings.recommendationVariety.toString(),
                  ),
                ),
            ),
            Divider(color: Colors.grey[300]),
            ListTile(contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 10), leading: Icon(settings.recommendPantryOnly ? Icons.store : Icons.food_bank, color: Colors.white), title: Text(settings.recommendPantryOnly ? 'Recommend Pantry' : 'Recommend Variety', style: TextStyle(fontSize: 20, color: Colors.white, fontFamily: 'Lato')),
            onTap: () {settings.togglerecommendPantryOnly(); }),
            Divider(color: Colors.grey[300]),
            ListTile(contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 10), leading: Icon(Icons.edit_attributes, color: Colors.white), title: Text('Recommendation Types', style: TextStyle(fontSize: 20, color: Colors.white, fontFamily: 'Lato')),
            onTap: () {showTypesEdit(context: context, recommendationMode: true, onExitUpdate: () {});}),
            Divider(color: Colors.grey[300]),
            ListTile(contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 10), leading: Icon(Icons.edit_attributes, color: Colors.white), title: Text('Price Units', style: TextStyle(fontSize: 20, color: Colors.white, fontFamily: 'Lato')),
            onTap: () {showTypesEdit(context: context, recommendationMode: false, onExitUpdate: () {});}),
            Divider(color: Colors.grey[300]),
            ListTile(contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 10), leading: Icon(Icons.save_alt, color: Colors.white),
              title:Container(margin: EdgeInsets.symmetric(horizontal: 15),
                child: RaisedButton(child:  Text('Save Data', style: TextStyle(fontSize: 20, color: Colors.grey[800], fontFamily: 'Lato', fontWeight: FontWeight.bold)), color: Theme.of(context).primaryColor,
                onPressed: () { print('SAVING APPLICATION');
                  Provider.of<Settings>(context).saveData(); Provider.of<CatalogProvider>(context).saveLists(); Provider.of<MenuProvider>(context).saveLists(); Provider.of<ShoppingListProvider>(context).saveLists(); Navigator.of(context).pop();},),
              ),
            ),
            Divider(color: Colors.grey[300]),
            ListTile(contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 10), leading: Icon(Icons.autorenew, color: Colors.white),
              title:RaisedButton(child:  Text(this.clearAllowed ? 'CLEAR' : 'Clear Recommendation Values', style: TextStyle(fontSize: 17, color: Colors.white, fontFamily: 'Lato')), color: clearAllowed ? Colors.redAccent[700] : Colors.black,
              onPressed: () {if(clearAllowed){ print('CLEAR Recommendation Data'); Provider.of<CatalogProvider>(context).clearAllRecommendationValues(); this.clearAllowed=false; }},),
              trailing: SizedBox(width: 30, height: 15,
                              child: Transform.scale( scale: 1.4,
                  child: Switch(value: this.clearAllowed, 
                  onChanged: (_) {this.setState(()=>this.clearAllowed = !clearAllowed);},
                  activeColor: Colors.redAccent[700],
                  inactiveThumbColor: Colors.grey[300],
                  ),
                ),
              ),
            ),
            Divider(color: Colors.grey[300]),
            ListTile(contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 10), leading: Icon(Icons.autorenew, color: Colors.white),
              title:RaisedButton(child:  Text(this.resetAllowed ? 'RESET' : 'Reset Application', style: TextStyle(fontSize: 20, color: Colors.white, fontFamily: 'Lato')), color: resetAllowed ? Colors.redAccent[700] : Colors.black,
              onPressed: () {if(resetAllowed){ print('RESETTING APPLICATION'); deleteAppStorage(); Provider.of<Settings>(context).loadData(reset: true); Provider.of<CatalogProvider>(context).loadLists(reset: true); Provider.of<MenuProvider>(context).loadLists(reset: true); Provider.of<ShoppingListProvider>(context).loadLists(reset: true); this.resetAllowed=false; }},),
              trailing: SizedBox(width: 30,
                              child: Transform.scale( scale: 1.4,
                  child: Switch(value: this.resetAllowed, 
                  onChanged: (_) {this.setState(()=>this.resetAllowed = !resetAllowed);},
                  activeColor: Colors.redAccent[700],
                  inactiveThumbColor: Colors.grey[300],
                  ),
                ),
              ),
            ),
            Divider(color: Colors.grey[300]),

            
        ]),
          )]),
      ),
    );
  }
}


//Popup for editing Recommendation Types
showTypesEdit({BuildContext context, Function onExitUpdate, bool recommendationMode}){
showModalBottomSheet(
        context: context,
        builder: (newContext) {
         return Container(child: EditRecommendationTypes(onExitUpdate: onExitUpdate, recommendationMode: recommendationMode,));
        },
        // isScrollControlled: true,
        // fullscreenDialog: true,
        );
}

class EditRecommendationTypes extends StatefulWidget {
    Function onExitUpdate = () {};
    final bool recommendationMode; //false is priceUnits

  EditRecommendationTypes({this.onExitUpdate, this.recommendationMode = true});

  @override
  _EditRecommendationTypesState createState() => _EditRecommendationTypesState();
}

class _EditRecommendationTypesState extends State<EditRecommendationTypes> {
   void initState () {
    super.initState();
    // newTextValueController.addListener(()=>this.setState(()=>newTextValue=newTextValueController.text));
    }
 
final TextEditingController newTextValueController = TextEditingController();
  // String newTextValue = 'New Value';

 Widget build(BuildContext context){
   print('Building: AppDrawer.EditRecommendationTypes-bottomSheet' );
  final settings = Provider.of<Settings>(context);
  final TextStyle smallerStyle = TextStyle(fontSize: 25, color:Theme.of(context).primaryColor);

  List<String> list = widget.recommendationMode ? settings.recommendationTypes: settings.pricingUnits;
  if(list == null || list.isEmpty) list = [];
  // newTextValue = widget.recommendationMode ? 'New Type' : 'New Unit';


  return new WillPopScope(
    onWillPop: () async { if(this.widget.onExitUpdate != null) this.widget.onExitUpdate(); return true;},
  child: GestureDetector(
      onTap: () {}, //close?
      behavior: HitTestBehavior.opaque,
      child: Container(color: Colors.grey[900],
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(padding: EdgeInsets.all(15), color: Colors.black,  width: double.infinity, alignment: Alignment.center,
                      child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: Text(widget.recommendationMode ? 'Edit Recommendation Types:' : 'Edit Unit Types:', style: TextStyle(fontSize: 25, color: Colors.white, fontFamily: 'Lato', )))),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [ Expanded(
                            child: TextField(
                                    controller: newTextValueController,
                                    keyboardType: TextInputType.text,
                                    style: smallerStyle,
                                    textAlign: TextAlign.center,
                                    decoration: InputDecoration(
                                      hintText: widget.recommendationMode ? 'New Type' : 'New Unit',
                                      hintStyle: smallerStyle,       
                                      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).primaryColor)),  
                                    ),
                            ),
                          ),
                            IconButton(icon: Icon(Icons.add_circle_outline), color: Theme.of(context).primaryColor, iconSize: 30, onPressed: () {
                              widget.recommendationMode ? settings.addRecommendationTypes(newTextValueController.text) : settings.addPricingUnit(newTextValueController.text);
                                setState(() {newTextValueController.clear();});
                            })
                            ]),
        Expanded(
          child:  ListView.builder(
        itemCount: list.length,
        itemBuilder: (context, index) {
            return ClipRRect(borderRadius: BorderRadius.circular(25),
            child: Container(color:  Colors.grey[800] , margin: EdgeInsets.all(5), 
              child: Container(margin: EdgeInsets.all(3), color: Colors.black,
                child: Container(margin: EdgeInsets.only(left: 10, right: 3, bottom: 0),
                  child:  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [ Text(list[index], style: smallerStyle,), IconButton(icon: Icon(Icons.delete_forever), iconSize: 37, color: Colors.red[900], onPressed: ()=>widget.recommendationMode ? settings.removeRecommendationTypes(context, list[index]) : settings.removePricingUnit(context, list[index]))]),
                  ),
                ),
              ),
              );
            },
        ),
        ),
        ])),
    ),
  );
  }
}

