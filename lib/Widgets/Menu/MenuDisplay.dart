import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mealplanning/Providers/CatalogProvider.dart';
import 'package:mealplanning/Providers/Ingredient.dart';
import 'package:mealplanning/Providers/Meal.dart';
import 'package:mealplanning/Providers/MenuItem.dart';
import 'package:mealplanning/Providers/MenuProvider.dart';
import 'package:mealplanning/Providers/PantryItem.dart';
import 'package:mealplanning/Providers/Settings.dart';
import 'package:mealplanning/Widgets/AppDrawer.dart';
import 'package:mealplanning/Widgets/Catalog/Catalog.dart';
import 'package:mealplanning/Widgets/EditBlank.dart';
import 'package:mealplanning/Widgets/Menu/MenuItemListing.dart';
import 'package:mealplanning/Widgets/Menu/Menu-Edit/MenuSectionEdit.dart';
import 'package:provider/provider.dart';

import 'Menu-Edit/MenuDayEdit.dart';
import 'Menu-Edit/MenuItemEdit.dart';
import 'Menu-Edit/MenuMenuEdit.dart';
import 'MenuSelectionPage.dart';

List<MenuItem> copyToMenu({@required BuildContext context, @required String menuId, List<String> sections, itemsList, @required Type type}){
      print('Menu :: copyToMenu()');
      // print('TYPE => ${type.toString()}');
      // debugPrintStack(maxFrames: 15, label: 'STACKING');
      List<MenuItem> newItems = [];
      if(type == MenuItem && itemsList.isNotEmpty && itemsList[0].id !='c0')
        newItems = itemsList;
      else if(type == PantryItem || type == Ingredient || type == Meal)
        itemsList.forEach((id) {
          String referenceId = id;
          Type referenceType = type;
          double cost = Provider.of<CatalogProvider>(context).getCalculatedAveragePerServingCost(id, type: type);
          String desctription = '';
          String name = 'Missing';
          if(type == PantryItem) { PantryItem item = Provider.of<CatalogProvider>(context).getPantryItem(referenceId); 
          desctription = item.description;
          name = item.name;
            if(item.referenceType == null || item.referenceId == null || item.referenceId == '')
              newItems.add(new MenuItem(id: Provider.of<Settings>(context).getUniqueID(context, MenuItem), name: (item.name != null && item.name !='') ? item.name : 'Missing', adjective: (item.description != null) ? item.description : '', referenceType: PantryItem, referenceId: id != null ? id : '', cost:  cost, selectedIngredients: [])); 
            else{referenceId = item.referenceId; referenceType = item.referenceType;}  }
          if(referenceType == Ingredient) { Ingredient ingredient = Provider.of<CatalogProvider>(context).getIngredient(referenceId); 
            if(name == 'Missing') name = ingredient.name;
            if(desctription == '') desctription = ingredient.adjective;
            newItems.add(new MenuItem(id: Provider.of<Settings>(context).getUniqueID(context, MenuItem), name: name, adjective: desctription, referenceType: Ingredient, referenceId: ingredient.id,  cost:  cost, selectedIngredients: [])); 
            Provider.of<CatalogProvider>(context).increaseIngredientPopularityCount(ingredient.id, update: false); Provider.of<CatalogProvider>(context).setIngredientRecentDatePresent(ingredient.id, update: false);
            }
          else if(referenceType == Meal) { Meal meal = Provider.of<CatalogProvider>(context).getMeal(referenceId); List<String> combineIngredients = [];
            if(name == 'Missing') name = meal.name;
            if(desctription == '') desctription = meal.adjective;
          if(meal.essentialIngredients != null && meal.essentialIngredients.isNotEmpty) meal.essentialIngredients.forEach((ingredId) {combineIngredients.add(ingredId); 
              Provider.of<CatalogProvider>(context).increaseIngredientPopularityCount(ingredId, update: false); Provider.of<CatalogProvider>(context).setIngredientRecentDatePresent(ingredId, update: false);
              });
          if(meal.alternativeIngredients != null && meal.alternativeIngredients.isNotEmpty) meal.alternativeIngredients.forEach((list) {if(list != null && list.length >=1) { 
            int randomSelection = new Random().nextInt(list.length);
            for(int i = 0; i<list.length; i++){if(Provider.of<CatalogProvider>(context).getPantryQuantity(list[i])>0) {randomSelection = i; break;}} //try optimize for pantry
            combineIngredients.add(list[randomSelection]); 
            Provider.of<CatalogProvider>(context).increaseIngredientPopularityCount(list[randomSelection], update: false); Provider.of<CatalogProvider>(context).setIngredientRecentDatePresent(list[randomSelection], update: false);
            }}); 
            newItems.add(new MenuItem(id: Provider.of<Settings>(context).getUniqueID(context, MenuItem), name: name, adjective: desctription, referenceType: Meal, referenceId: meal.id, instructions: meal.recipe, cost: cost, selectedIngredients: combineIngredients)); 
            Provider.of<CatalogProvider>(context).increaseMealPopularityCount(meal.id, update: false); Provider.of<CatalogProvider>(context).setMealRecentDatePresent(meal.id, update: false);
            }  
        });
      else 
        print('INVALID TYPE :: copyToMenu() => '+type.toString());
      if(menuId != null && type!=null && Provider.of<MenuProvider>(context).getMenu(menuId).menuDayList.isNotEmpty && newItems.isNotEmpty)
        Provider.of<MenuProvider>(context).getMenu(menuId).menuDayList.forEach((day) {
          if(day.menuSectionList != null && day.menuSectionList.isNotEmpty)
            day.menuSectionList.forEach((sec){
              if(sections!=null && sections.isNotEmpty)
                sections.forEach((id) {
                  if(id == sec.id && !sec.done) 
                    for(int i=0; i<newItems.length; i++) {Provider.of<MenuProvider>(context).addMenuItem(menuId: menuId, dayId: day.id, sectionId: sec.id, item: newItems[i]);}
                });
            });
        });
       newItems.forEach((element) {print(element.name);}) ;
      if(newItems.isEmpty) return [new MenuItem(id: 'c0', name: '-')];
      else return newItems;
    }

class MenuDisplay extends StatefulWidget {
  static const routeName = '/Menu';
  String menuId = null;

  String leftName = '';
   String centerName = 'Menu Edit';
  String rightName = '';
  int currentDayPlace = 0;

  MenuDisplay(){
  //   if(menuId != null && menuId.menuDayList.length>=2){
  //     leftName = 'Edit';
  //     centerName ='${menuId.menuDayList[0].name} (${DateFormat.Md().format(menuId.menuDayList[0].date)})';
  //     rightName = '${menuId.menuDayList[1].name.length > 3 ? menuId.menuDayList[1].name.substring(0,3): menuId.menuDayList[1].name} (${DateFormat.d().format(menuId.menuDayList[1].date)})';
  //   } else if(menuId != null && menuId.menuDayList.length==1){
  //     leftName = 'Edit';
  //     centerName ='${menuId.menuDayList[0].name} (${DateFormat.Md().format(menuId.menuDayList[0].date)})';
  //     rightName = 'Add';
  //   } else {
  //     leftName = '';
  //     centerName ='Menu Edit';
  //     rightName = 'Add';
  //   }
  }


  @override
  _MenuDisplayState createState() => _MenuDisplayState();
}

class _MenuDisplayState extends State<MenuDisplay> {
   void initState() {super.initState();} 

  final menuController = PageController(viewportFraction: 1, initialPage: 0);

  List<MenuItem> sendToMenu({List<String> sections, itemsList, @required Type type})=>copyToMenu(context: context, menuId: widget.menuId, sections: sections, itemsList: itemsList, type: type);

  @override
  Widget build(BuildContext context) {
    final menuProvider = Provider.of<MenuProvider>(context);
    final settings = Provider.of<Settings>(context);

  void setHeader(int pageValue){ //call insedeSetState for Rebuild update
          if(widget.menuId!=null && pageValue > 1) widget.leftName = '${menuProvider.getMenu(widget.menuId).menuDayList[pageValue-2].name.length > 3 ? menuProvider.getMenu(widget.menuId).menuDayList[pageValue-2].name.substring(0,3): menuProvider.getMenu(widget.menuId).menuDayList[pageValue-2].name} (${DateFormat.d().format(menuProvider.getMenu(widget.menuId).menuDayList[pageValue-2].date)})';
          else if(pageValue == 1) widget.leftName = 'Edit';
          else widget.leftName = '';
          widget.centerName = pageValue == 0 ? 'Menu Edit' : ((widget.menuId==null && pageValue == 1) || pageValue == menuProvider.getMenu(widget.menuId).menuDayList.length-1 + 2) ? 'Add Day' :'${menuProvider.getMenu(widget.menuId).menuDayList[pageValue-1].name} (${DateFormat.Md().format(menuProvider.getMenu(widget.menuId).menuDayList[pageValue-1].date)})';
          if(widget.menuId!=null && pageValue < (menuProvider.getMenu(widget.menuId).menuDayList.length)) widget.rightName = '${menuProvider.getMenu(widget.menuId).menuDayList[pageValue].name.length > 3 ? menuProvider.getMenu(widget.menuId).menuDayList[pageValue].name.substring(0,3): menuProvider.getMenu(widget.menuId).menuDayList[pageValue].name} (${DateFormat.d().format(menuProvider.getMenu(widget.menuId).menuDayList[pageValue].date)})';
          else if((widget.menuId==null && pageValue == 0) || (widget.menuId!=null && pageValue == menuProvider.getMenu(widget.menuId).menuDayList.length)) widget.rightName = 'Add';
          else widget.rightName = '';
    }

  //Temporary
      // widget.menu.menuDayList = widget.menu.menuDayList;
    // if(widget.menu.menuDayList != null && widget.menu.menuDayList.isNotEmpty) widget.centerName = '${widget.menu.menuDayList[0].name} (${DateFormat.Md().format(widget.menu.menuDayList[0].date)})';
    // if(widget.menu.menuDayList != null && widget.menu.menuDayList.length>1) widget.rightName = '${widget.menu.menuDayList[1].name.length > 3 ? widget.menu.menuDayList[1].name.substring(0,3): widget.menu.menuDayList[1].name} (${DateFormat.Md().format(widget.menu.menuDayList[1].date)})';

    final addDayPage = Column(children: <Widget>[SizedBox(height: 200),
                Text('Extend Menu', style: TextStyle(fontSize: 35,  fontFamily: 'OpenSans', color:Theme.of(context).primaryColor, fontWeight: FontWeight.bold)), SizedBox(height: 20,),
                RaisedButton(child: Text('Add Day', style: TextStyle(fontSize: 25,  fontFamily: 'QuickSand', color:Theme.of(context).primaryColor, fontWeight: FontWeight.bold)), color: Colors.grey[800], elevation: 10, padding: EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                  onPressed: (){if(this.widget.menuId != null) {final String newId = settings.getUniqueID(context, MenuDay);
                    menuProvider.addMenuDay(menuId: widget.menuId, day: new MenuDay(id: newId, name: 'New Day', date: (widget.menuId != null && menuProvider.getMenu(widget.menuId).menuDayList.isNotEmpty) ? menuProvider.getMenu(widget.menuId).menuDayList[menuProvider.getMenu(widget.menuId).menuDayList.length-1].date.add(new Duration(days: 1)) : DateTime.now(), menuSectionList: [new MenuSection(id: settings.getUniqueID(context, MenuSection), name: 'Meal', menuItemList: [])]));
                  // Navigator.of(context).pushReplacement(MaterialPageRoute(builder:(context)=>MenuDisplay()));
                  setState(()=>showMenuDay(context: context, menuId: widget.menuId, dayId: newId, remove: ()=>menuProvider.removeMenuDay(menuId: widget.menuId, dayId: newId), onExitUpdate: () {
                    //Navigator.of(context).pushReplacement(MaterialPageRoute(builder:(context)=>MenuDisplay())); 
                  menuController.jumpToPage(menuProvider.getMenu(widget.menuId).menuDayList.length);}));}})],);

    final List<Widget> bottomBar = [];
    if(!(widget.menuId==null || widget.menuId=='' || widget.menuId=='u0'))
    bottomBar.addAll( [Expanded(child: Row(children: [
        FlatButton(child: Text('Add Meal',style: TextStyle(fontSize: 18,  fontFamily: 'OpenSans', color:Theme.of(context).primaryColor)),
            onPressed: () { 
              Navigator.of(context).push(MaterialPageRoute(builder:(context)=>Catalog(displayType: Meal, allowAdd: false, selectionMode: true, popAfterSelection: false, selectionMultiple: true,
            selectionCallBack: (addList) {Navigator.of(context).pop();
              getMenuSectionSelection(context: context, menuId: widget.menuId, selectionCallBack: (sectionList) {
                sendToMenu(itemsList: addList, sections: sectionList, type: Meal);}, onExitUpdate: () {
                  // Navigator.of(context).pushReplacement(MaterialPageRoute(builder:(context)=>MenuDisplay()))
                }
                );}
            )));}
        ),
        FlatButton(child: Text('Add Pantry',style: TextStyle(fontSize: 18,  fontFamily: 'OpenSans', color:Theme.of(context).primaryColor)),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder:(context)=>Catalog(displayType: PantryItem, allowAdd: false, selectionMode: true, popAfterSelection: false, selectionMultiple: true,
            selectionCallBack: (addList) {Navigator.of(context).pop();
              getMenuSectionSelection(context: context, menuId: widget.menuId, selectionCallBack: (sectionList) {
                sendToMenu(itemsList: addList, sections: sectionList, type: PantryItem);}, onExitUpdate: () {Navigator.of(context).pop();
                  // Navigator.of(context).pushReplacement(MaterialPageRoute(builder:(context)=>MenuDisplay()))
                }
                );}
            )));}
        ),
        FlatButton(child: Text('Add Ingredient',style: TextStyle(fontSize: 18,  fontFamily: 'OpenSans', color:Theme.of(context).primaryColor)),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder:(context)=>Catalog(displayType: Ingredient, allowAdd: false, selectionMode: true, popAfterSelection: false, selectionMultiple: true,
            selectionCallBack: (addList) {Navigator.of(context).pop();
              getMenuSectionSelection(context: context, menuId: widget.menuId, selectionCallBack: (sectionList) {
                sendToMenu(itemsList: addList, sections: sectionList, type: Ingredient);}, onExitUpdate: () {Navigator.of(context).pop();
                  // Navigator.of(context).pushReplacement(MaterialPageRoute(builder:(context)=>MenuDisplay()))
                }                
                );}
            )));}
        ),
      ]),
    )]);
    // if(settings.nameTags)
    bottomBar.add(BottomBanner('MENU'));

    return Scaffold(
      backgroundColor: Colors.grey[900],
      drawer: AppDrawer(),
      appBar: PreferredSize( preferredSize: Size(double.infinity, 35),
         child: Container(color: Theme.of(context).primaryColor, margin: EdgeInsets.only(top: settings.accountForNotch ? settings.notchAdjustment : 5), height: double.infinity,
           child: 
           Row(mainAxisAlignment: MainAxisAlignment.spaceBetween ,
                  children: [
                      GestureDetector(child: Row(children: [Icon(widget.leftName == '' ? null : Icons.arrow_back, color:Colors.grey[900]),Text(widget.leftName, style: TextStyle(fontSize: 18,  fontFamily: 'OpenSans', color:Colors.grey[900])),]),
                          onTap: () {print('<- left'); menuController.previousPage(duration: Duration(milliseconds: 500), curve: Curves.easeInOut);},
                      ),
                      GestureDetector(child: settings.nameTags ? Row (children: [SingleChildScrollView(child: Text(widget.centerName, style: TextStyle(fontSize: 20,  fontFamily: 'OpenSans', color:Colors.grey[900], fontWeight: FontWeight.w800))), Icon(Icons.edit, color: Theme.of(context).accentColor)])
                                  : SingleChildScrollView(child: Text(widget.centerName, style: TextStyle(fontSize: 20,  fontFamily: 'OpenSans', color:Colors.grey[900], fontWeight: FontWeight.w800))),
                          onTap: ()=>showMenuDay(context: context, menuId: widget.menuId, dayId: menuProvider.getMenu(widget.menuId).menuDayList[widget.currentDayPlace].id, remove: ()=>menuProvider.removeMenuDay(menuId: widget.menuId, dayId: menuProvider.getMenu(widget.menuId).menuDayList[widget.currentDayPlace].id), onExitUpdate: () {
                            this.reassemble();
                            menuController.jumpToPage(widget.currentDayPlace+1);
                            // Navigator.of(context).pushReplacement(MaterialPageRoute(builder:(context)=>MenuDisplay())); 
                            }),
                      ),
                      GestureDetector(child: Row(children: [Text(widget.rightName, style: TextStyle(fontSize: 18,  fontFamily: 'OpenSans', color:Colors.grey[900])), Icon(widget.rightName == '' ? null : Icons.arrow_forward, color:Colors.grey[900]),]),
                          onTap: () {print('right ->'); menuController.nextPage(duration: Duration(milliseconds: 500), curve: Curves.easeInOut);},),
                  ]),
        )),

      bottomNavigationBar:  Container( height: !(widget.menuId==null || widget.menuId=='' || widget.menuId=='u0') ? 75 
                                                  : 25 ,
                                      color: Colors.grey[900],
      child: Column(children: bottomBar),
        ),

      body: 
        PageView.builder(scrollDirection: Axis.horizontal,
        controller: menuController,
        itemCount: (widget.menuId==null || menuProvider.getMenu(widget.menuId) == null || menuProvider.getMenu(widget.menuId).menuDayList == null)? 1 : menuProvider.getMenu(widget.menuId).menuDayList.length + 2,
        onPageChanged: (value) {
          // print('****value'+value.toString());
          setState(() {
            widget.currentDayPlace = value -1;
          setHeader(value);
        }); },
        itemBuilder: (context, index){
          if(index == 0) return MenuEdit(menuId: widget.menuId, deleteCurrentMenu: () {menuProvider.removeMenu(widget.menuId); setState(()=>widget.menuId = null);},
          setNewMenu: (id) {setState(() {widget.menuId = id; setHeader(1);}); menuController.jumpToPage(1);}, newMenuCallBack: (id) {setState(() {widget.menuId = id; setHeader(1);}); menuController.jumpToPage(1);});
          else if(widget.menuId != null && index == menuProvider.getMenu(widget.menuId).menuDayList.length-1 + 2) return addDayPage;
          else return MenuDayPage(callBackToPage: ()=>menuController.jumpToPage(index), dayId: menuProvider.getMenu(widget.menuId).menuDayList[index-1].id, menuId: widget.menuId, menuItemAdd: null,);
        }
        ),           
    );
  }
}

class MenuDayPage extends StatelessWidget {
  final Function callBackToPage;
  final String dayId;
  final String menuId;
  Function menuItemAdd;
  MenuDayPage({this.dayId, this.menuItemAdd, this.menuId, this.callBackToPage});
  @override
  Widget build(BuildContext context) {
    final menuProvider = Provider.of<MenuProvider>(context);
    return ListView.builder(
      itemCount: menuProvider.getMenuDay(menuId: menuId, dayId: dayId).menuSectionList.length,
      itemBuilder: (context, index) => MenuMealSection(callBackToPage: callBackToPage, menuId: this.menuId, dayId: dayId, sectionId: menuProvider.getMenuDay(menuId: menuId, dayId: dayId).menuSectionList[index].id, menuItemAdd: null, )
    );
  }
}

class MenuMealSection extends StatefulWidget { 
  final Function callBackToPage;
  final String dayId;
  final String menuId;
  final String sectionId;
  Function menuItemAdd;

  MenuMealSection({this.sectionId, this.menuItemAdd, this.menuId, this.dayId, this.callBackToPage});

  @override
  _MenuMealSectionState createState() => _MenuMealSectionState();
}

class _MenuMealSectionState extends State<MenuMealSection> {
  bool getMeat(context){
    if(Provider.of<MenuProvider>(context).getMenuSection(menuId: widget.menuId, dayId: widget.dayId, sectionId: widget.sectionId).menuItemList != null)
      for(var i=0; i< Provider.of<MenuProvider>(context).getMenuSection(menuId: widget.menuId, dayId: widget.dayId, sectionId: widget.sectionId).menuItemList.length; i++){if(Provider.of<CatalogProvider>(context).getMeat(Provider.of<MenuProvider>(context).getMenuSection(menuId: widget.menuId, dayId: widget.dayId, sectionId: widget.sectionId).menuItemList[i].referenceType, Provider.of<MenuProvider>(context).getMenuSection(menuId: widget.menuId, dayId: widget.dayId, sectionId: widget.sectionId).menuItemList[i].referenceId)) return true;}
    return false;}

  bool getCarb(context){
    if(Provider.of<MenuProvider>(context).getMenuSection(menuId: widget.menuId, dayId: widget.dayId, sectionId: widget.sectionId).menuItemList != null)
      for(var i=0; i< Provider.of<MenuProvider>(context).getMenuSection(menuId: widget.menuId, dayId: widget.dayId, sectionId: widget.sectionId).menuItemList.length; i++){if(Provider.of<CatalogProvider>(context).getCarb(Provider.of<MenuProvider>(context).getMenuSection(menuId: widget.menuId, dayId: widget.dayId, sectionId: widget.sectionId).menuItemList[i].referenceType, Provider.of<MenuProvider>(context).getMenuSection(menuId: widget.menuId, dayId: widget.dayId, sectionId: widget.sectionId).menuItemList[i].referenceId)) return true;}
    return false;}

  bool getVeg(context){
    if(Provider.of<MenuProvider>(context).getMenuSection(menuId: widget.menuId, dayId: widget.dayId, sectionId: widget.sectionId).menuItemList != null)
      for(var i=0; i< Provider.of<MenuProvider>(context).getMenuSection(menuId: widget.menuId, dayId: widget.dayId, sectionId: widget.sectionId).menuItemList.length; i++){if(Provider.of<CatalogProvider>(context).getVeg(Provider.of<MenuProvider>(context).getMenuSection(menuId: widget.menuId, dayId: widget.dayId, sectionId: widget.sectionId).menuItemList[i].referenceType, Provider.of<MenuProvider>(context).getMenuSection(menuId: widget.menuId, dayId: widget.dayId, sectionId: widget.sectionId).menuItemList[i].referenceId)) return true;}
    return false;}

  bool getFruit(context){
    if(Provider.of<MenuProvider>(context).getMenuSection(menuId: widget.menuId, dayId: widget.dayId, sectionId: widget.sectionId).menuItemList != null)
      for(var i=0; i< Provider.of<MenuProvider>(context).getMenuSection(menuId: widget.menuId, dayId: widget.dayId, sectionId: widget.sectionId).menuItemList.length; i++){if(Provider.of<CatalogProvider>(context).getFruit(Provider.of<MenuProvider>(context).getMenuSection(menuId: widget.menuId, dayId: widget.dayId, sectionId: widget.sectionId).menuItemList[i].referenceType, Provider.of<MenuProvider>(context).getMenuSection(menuId: widget.menuId, dayId: widget.dayId, sectionId: widget.sectionId).menuItemList[i].referenceId)) return true;}
    return false;}

  bool getSnack(context){
    if(Provider.of<MenuProvider>(context).getMenuSection(menuId: widget.menuId, dayId: widget.dayId, sectionId: widget.sectionId).menuItemList != null)
      for(var i=0; i< Provider.of<MenuProvider>(context).getMenuSection(menuId: widget.menuId, dayId: widget.dayId, sectionId: widget.sectionId).menuItemList.length; i++){if(Provider.of<CatalogProvider>(context).getSnack(Provider.of<MenuProvider>(context).getMenuSection(menuId: widget.menuId, dayId: widget.dayId, sectionId: widget.sectionId).menuItemList[i].referenceType, Provider.of<MenuProvider>(context).getMenuSection(menuId: widget.menuId, dayId: widget.dayId, sectionId: widget.sectionId).menuItemList[i].referenceId)) return true;}
    return false;}

    void deductAllFromPantry(BuildContext context){
      if(widget.sectionId == null || Provider.of<MenuProvider>(context).getMenuSection(menuId: widget.menuId, dayId: widget.dayId, sectionId: widget.sectionId).menuItemList.isEmpty || Provider.of<CatalogProvider>(context).pantry == null || Provider.of<CatalogProvider>(context).pantry.isEmpty) return;
      Provider.of<MenuProvider>(context).getMenuSection(menuId: widget.menuId, dayId: widget.dayId, sectionId: widget.sectionId).menuItemList.forEach((item)=>Provider.of<CatalogProvider>(context).deductFromPantry(item.referenceId, quantity: Provider.of<MenuProvider>(context).getMenuSection(menuId: widget.menuId, dayId: widget.dayId, sectionId: widget.sectionId).servings));  //return true/false sucessful; don't think needed here, because item.id isn't related to pantry
    }

    void addMatchingItems(BuildContext context, List<MenuItem> menuItemList){
      //create matching list
      List<String> matchingList = [];
      menuItemList.forEach((item) {if((item.referenceType == Ingredient || item.referenceType == Meal) && item.referenceId!=null && item.referenceId!='' ) matchingList.add(item.referenceId);});
      //distribute matching list
      menuItemList.forEach((item) {if(item.referenceType == Ingredient) {Provider.of<CatalogProvider>(context).addIngredientMatchingItems(item.referenceId, matchingList.where((id)=>(id!=item.referenceId && !Provider.of<CatalogProvider>(context).getIngredient(item.referenceId).matchingItems.contains(id))).toList(), update: false); }
                  else if(item.referenceType == Meal)  {Provider.of<CatalogProvider>(context).addMealMatchingItems(item.referenceId, matchingList.where((id)=>id!=item.referenceId && !Provider.of<CatalogProvider>(context).getMeal(item.referenceId).matchingItems.contains(id)).toList(), update: false); }
                  });
    }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<Settings>(context);
    final catalogProvider = Provider.of<CatalogProvider>(context);
    final menuProvider = Provider.of<MenuProvider>(context);

    final MenuSection section = menuProvider.getMenuSection(menuId: widget.menuId, dayId: widget.dayId, sectionId: widget.sectionId);                         

  final Widget totalCost = Text('\$${section.cost.toStringAsFixed(2)}', style: TextStyle(fontSize: 20, color: Colors.white, fontFamily: 'Lato'));
  final Widget totalCount = Text('(${section.menuItemList.length})', style: TextStyle(fontSize: 20, color: Colors.white, fontFamily: 'Lato'));
  final Widget addCustom = IconButton(icon: Icon(Icons.add, color:Theme.of(context).primaryColor, size:30,), onPressed: () {final String newId = settings.getUniqueID(context, MenuItem);   MenuItem item = new MenuItem(id: newId, name: 'Custom Meal');
                            menuProvider.addMenuItem(menuId: widget.menuId, dayId: widget.dayId, sectionId: widget.sectionId, item: item);      showMenuItemEdit(context: context, menuId: widget.menuId, dayId: widget.dayId, sectionId: widget.sectionId, itemId: newId, onExitUpdate: () {//Navigator.of(context).pushReplacement(MaterialPageRoute(builder:(context)=>MenuDisplay())); 
                                  widget.callBackToPage();}); } ); //add cutum meal with bottom popup
  final Widget editServings = Row(children: <Widget>[IconButton(icon: Icon(Icons.remove_circle, color:Theme.of(context).primaryColor, size:30,), onPressed: () =>menuProvider.decreaseMenuSectionServings(menuId: widget.menuId, dayId: widget.dayId, sectionId: widget.sectionId)),
                              Text('${menuProvider.getMenuSection(menuId: widget.menuId, dayId: widget.dayId, sectionId: widget.sectionId).servings}', style: TextStyle(fontSize: 25, color: Theme.of(context).accentColor, fontFamily: 'Lato')),
                              IconButton(icon: Icon(Icons.add_circle, color:Theme.of(context).primaryColor, size:30,), onPressed: () =>menuProvider.increaseMenuSectionServings(menuId: widget.menuId, dayId: widget.dayId, sectionId: widget.sectionId))],);


  //Calculate / generate Recommendations
  bool itemInSection(String id){ for(int i=0; i<menuProvider.getMenuSection(menuId: widget.menuId, dayId: widget.dayId, sectionId: widget.sectionId).menuItemList.length; i++){
      if(menuProvider.getMenuSection(menuId: widget.menuId, dayId: widget.dayId, sectionId: widget.sectionId).menuItemList[i].referenceId == id) return true;} return false; }//Check already in List
  int getVariation() {int variation =0;
  if(widget.menuId != null && menuProvider.getMenu(widget.menuId).menuDayList.isNotEmpty)variation += menuProvider.getMenu(widget.menuId).menuDayList.length;
  menuProvider.getMenu(widget.menuId).menuDayList.forEach((day) {
    if(day.menuSectionList != null && day.menuSectionList.isNotEmpty)variation += day.menuSectionList.length;
  });
  return (variation~/2)*settings.recommendationVariety;
  }
  List<String> getAlreadyList(){List<String> alreadyList = [];
  menuProvider.getMenuSection(menuId: widget.menuId, dayId: widget.dayId, sectionId: widget.sectionId).menuItemList.forEach((item) {alreadyList.add(item.referenceId); if(item.referenceType==Meal && item.selectedIngredients != null && item.selectedIngredients.isNotEmpty) alreadyList.addAll(item.selectedIngredients);});//Assemble Avoid List
  return alreadyList;
  }
  List<SortItem> getCurrentList(){List<SortItem> currentList = [];
  if(widget.menuId != null && menuProvider.getMenu(widget.menuId).menuDayList.isNotEmpty){
  menuProvider.getMenu(widget.menuId).menuDayList.forEach((day) {
    if(day.menuSectionList != null && day.menuSectionList.isNotEmpty){
        day.menuSectionList.forEach((sec) {
          if(sec.menuItemList != null && sec.menuItemList.isNotEmpty) // && sec.recommendationType==section.recommendationType)
            sec.menuItemList.forEach((item) {
              if(item.referenceType != null && item.referenceId != null && item.referenceId != '' && !itemInSection(item.referenceId) && catalogProvider.matchRecommendationLists(item.referenceType == Meal ? catalogProvider.getMeal(item.referenceId).recommendationTypes : item.referenceType == Ingredient ? catalogProvider.getIngredient(item.referenceId).recommendationTypes : [], section.recommendationTypes)){
                currentList.add(new SortItem(referenceType: item.referenceType, referenceId: item.referenceId, popularityPercent: catalogProvider.getPopularityPercent(item.referenceType, item.referenceId), recentPercent: catalogProvider.getRecentPercent(item.referenceType, item.referenceId)));
                if(item.referenceType == Meal && item.selectedIngredients!=null && item.selectedIngredients.isNotEmpty)
                  item.selectedIngredients.forEach((ingredientId) {
                    if(catalogProvider.matchRecommendationLists(catalogProvider.getIngredient(ingredientId).recommendationTypes, section.recommendationTypes))
                    currentList.add(new SortItem(referenceType: Ingredient, referenceId: ingredientId, popularityPercent: catalogProvider.getPopularityPercent(Ingredient, ingredientId), recentPercent: catalogProvider.getRecentPercent(Ingredient, ingredientId))); });
  }});});}});}
  return currentList;
  }

final double attributeSize = 20;
    return Column(
      children: [GestureDetector(
            onTap: ()=>menuProvider.getMenuSection(menuId: widget.menuId, dayId: widget.dayId, sectionId: widget.sectionId).done ? null : showMenuSection(context: context, menuId: widget.menuId, dayId: widget.dayId, sectionId: widget.sectionId, deductPantry: ()=>this.deductAllFromPantry(context),
              onExitUpdate: () {
              // Navigator.of(context).pushReplacement(MaterialPageRoute(builder:(context)=>MenuDisplay())); 
              widget.callBackToPage();}),
            onLongPress: () {
              getMenuSectionSelection(context: context, menuId: widget.menuId, selectionCallBack: (sectionList) {
              copyToMenu(context: context, menuId: widget.menuId, itemsList: [...section.menuItemList], sections: sectionList, type: MenuItem); }, onExitUpdate: () {//Navigator.of(context).pushReplacement(MaterialPageRoute(builder:(context)=>MenuDisplay()));
              });},
          child:  ClipRRect(borderRadius: BorderRadius.circular(15),
          child: Container(color: Colors.black,
          child: Column(children: [Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.center, children: [
            settings.nameTags ? Column(children: [editServings, Text('Servings', style: TextStyle(fontSize: 15, color:Theme.of(context).accentColor))]) : editServings,
            Expanded(
                          child: SingleChildScrollView(scrollDirection: Axis.horizontal,child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                settings.nameTags ? section.recommendationTypes.contains('Packable') ? Column(children: [Icon(Icons.shopping_basket, color: Theme.of(context).primaryColor,), Text('Packable', style: TextStyle(fontSize: 15, color:Theme.of(context).accentColor))]) : SizedBox(height: 1) : section.recommendationTypes.contains('Packable') ? Icon(Icons.shopping_basket, color: Theme.of(context).primaryColor,) : SizedBox(height: 1),
              settings.nameTags ? Column(children: [Text(section.name, style: TextStyle(fontSize: 35, color: Theme.of(context).primaryColor, fontFamily: 'OpenSans', fontWeight: FontWeight.w500)),
                                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Icon(Icons.edit, color: Theme.of(context).accentColor), SizedBox(width: 20,), Icon(Icons.content_copy, color: Theme.of(context).accentColor)])])
               : Text(section.name, style: TextStyle(fontSize: 35, color: Theme.of(context).primaryColor, fontFamily: 'OpenSans', fontWeight: FontWeight.w500)),
               SizedBox(width: 10,),
              settings.nameTags ? Column(children: [totalCost, Text('Cost', style: TextStyle(fontSize: 15, color:Theme.of(context).accentColor))]) : totalCost,
              SizedBox(width: 10,),
              settings.nameTags ? Column(children: [totalCount, Text('Total', style: TextStyle(fontSize: 15, color:Theme.of(context).accentColor))]) : totalCount,
              ])),
            ),
            settings.nameTags ? Column(children: [addCustom, Text('Add', style: TextStyle(fontSize: 15, color:Theme.of(context).accentColor))]) : addCustom,
          ]),
            Container(
              width: double.infinity,
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: <Widget>[
                settings.nameTags ? Column(children: [Theme(data: ThemeData(unselectedWidgetColor: Theme.of(context).primaryColor), child: Transform.scale(scale: 1.5,  child: Checkbox(value: section.done, onChanged: (_) {this.addMatchingItems(context, section.menuItemList); this.deductAllFromPantry(context); menuProvider.markMenuSectionDone(menuId: widget.menuId, dayId: widget.dayId, sectionId: widget.sectionId,);}, activeColor: Theme.of(context).primaryColor, checkColor: Colors.black,))), Text('Done', style: TextStyle(fontSize: 15, color:Theme.of(context).accentColor))]) : Theme(data: ThemeData(unselectedWidgetColor: Theme.of(context).primaryColor), child: Transform.scale(scale: 1.5,  child: Checkbox(value: section.done==null ? false : section.done, onChanged: (_) {this.addMatchingItems(context, section.menuItemList); this.deductAllFromPantry(context); menuProvider.markMenuSectionDone(menuId: widget.menuId, dayId: widget.dayId, sectionId: widget.sectionId);}, activeColor: Theme.of(context).primaryColor, checkColor: Colors.black,))),
                SortToggle(title: 'Meat', image: 'assets/steak.png', backgroundColorBlack: true, sortIconSize: attributeSize, active: this.getMeat(context),),
                SortToggle(title: 'Carb', image: 'assets/bread.png', backgroundColorBlack: true, sortIconSize: attributeSize, active: this.getCarb(context),),
                SortToggle(title: 'Veggie', image: 'assets/carrot.png', backgroundColorBlack: true, sortIconSize: attributeSize, active: this.getVeg(context),),
                SortToggle(title: 'Fruit', image: 'assets/apple.png', backgroundColorBlack: true, sortIconSize: attributeSize, active: this.getFruit(context),),
                SortToggle(title: 'Snack', image: 'assets/snack.png', backgroundColorBlack: true, sortIconSize: attributeSize, active: this.getSnack(context),),
              ],),
            )
          ]),
        ),
        ),
      ),
        Container(height: MediaQuery.of(context).size.height*0.6+1, margin: EdgeInsets.symmetric(horizontal: 40),
          child:  ListView.builder(
    itemCount: section.done ? section.menuItemList.length : (section.menuItemList.length + 3),  //account for recommendations 
    itemBuilder: (context, i) {int index = i;
      if(section.done) index += 1;
      if(index == 0) {
        return MenuItemRecommendationListing(getNewRecommendation: () { SortItem recommendation = catalogProvider.getRecommendation(requestedRecommendationTypes: section.recommendationTypes, currentList: getCurrentList(), alreadyList: getAlreadyList(), varietyLimit: getVariation(), pantryOnly: settings.recommendPantryOnly, goal: section.menuItemList.length>5 ? 'snack' : !getMeat(context) ? 'meat' : !getCarb(context) ? 'carb' : !getVeg(context) ? 'veg' : !getFruit(context) ? 'fruit' : 'random');
          return copyToMenu(context: context, menuId: widget.menuId, sections: [], itemsList: [recommendation.referenceId], type: recommendation.referenceType)[0];}, menuItemAdd: (){}, menuId: widget.menuId, dayId: widget.dayId, sectionId: widget.sectionId);
      }else if (index <= section.menuItemList.length)      
        return MenuItemListing(menuId: widget.menuId, dayId: widget.dayId, sectionId: widget.sectionId, itemId: section.menuItemList[index-1].id, sectionDone: section.done, 
            onClick: (){showMenuItemEdit(context: context, menuId: widget.menuId, dayId: widget.dayId, sectionId: widget.sectionId, itemId: section.menuItemList[index-1].id, onExitUpdate: () {
              menuProvider.updateMenu();
              //Navigator.of(context).pushReplacement(MaterialPageRoute(builder:(context)=>MenuDisplay())); 
            widget.callBackToPage();});},
            onRemove: ()=>menuProvider.removeMenuItem(menuId: widget.menuId, dayId: widget.dayId, sectionId: widget.sectionId, itemId: section.menuItemList[index-1].id),
            onCopy: ()=>getMenuSectionSelection(context: context, menuId: widget.menuId, selectionCallBack: (sectionList)=>copyToMenu(context: context, menuId: widget.menuId, itemsList: [...section.menuItemList], sections: sectionList, type: MenuItem), onExitUpdate: () { //Navigator.of(context).pushReplacement(MaterialPageRoute(builder:(context)=>MenuDisplay()));
            }),
            );
      else if(index == section.menuItemList.length+1) return MenuItemRecommendationListing(getNewRecommendation: () { SortItem recommendation = catalogProvider.getRecommendation(requestedRecommendationTypes: section.recommendationTypes, currentList: getCurrentList(), alreadyList: getAlreadyList(), varietyLimit: getVariation(), pantryOnly: settings.recommendPantryOnly, goal: section.menuItemList.length<=3 ? 'quantity' : 'cost');
          return copyToMenu(context: context, menuId: widget.menuId, sections: [], itemsList: [recommendation.referenceId], type: recommendation.referenceType)[0];},
           menuItemAdd: (){}, menuId: widget.menuId, dayId: widget.dayId, sectionId: section.id,);
      else return MenuItemRecommendationListing(getNewRecommendation: () { SortItem recommendation = catalogProvider.getRecommendation(requestedRecommendationTypes: section.recommendationTypes, currentList: getCurrentList(), alreadyList: getAlreadyList(), varietyLimit: getVariation(), pantryOnly: settings.recommendPantryOnly, goal: 'random');
          return copyToMenu(context: context, menuId: widget.menuId, sections: [], itemsList: [recommendation.referenceId], type: recommendation.referenceType)[0];},
           menuItemAdd: (){}, menuId: widget.menuId, dayId: widget.dayId, sectionId: section.id,);
      // else return SizedBox(height: 1);

    },
        ),
        ),
      ]);
  }
}

class MenuItemRecommendationListing extends StatefulWidget {
  MenuItem item;
  final Function getNewRecommendation;
  final Function menuItemAdd;
  final String menuId;
  final String dayId;
  final String sectionId;
  MenuItemRecommendationListing({this.getNewRecommendation, this.menuItemAdd, this.sectionId, this.menuId, this.dayId, })
  {item = getNewRecommendation();}

  @override
  _MenuItemRecommendationListingState createState() => _MenuItemRecommendationListingState();
}

class _MenuItemRecommendationListingState extends State<MenuItemRecommendationListing> {

  @override
  Widget build(BuildContext context) {
if(widget.item.id == 'c0') { //print('Making MenuItemListingRecommendation-Fail'); print(widget.item.name); 
        return SizedBox(height: 1); }
 else   { //print('Making MenuItemListingRecommendation-Success');  print(widget.item.name); 
   return MenuItemListing(menuId: widget.menuId, dayId: widget.dayId, sectionId: widget.sectionId, itemId: null, sectionDone: false, isRecommendation:  true, getRecommendation: ()=>widget.item,
          onClick: (){
            copyToMenu(context: context, menuId: widget.menuId, itemsList: [widget.item], sections: [widget.sectionId], type: MenuItem); 
          // Navigator.of(context).pushReplacement(MaterialPageRoute(builder:(context)=>MenuDisplay()));
          },
          onRemove: ()=>setState(()=>widget.item = widget.getNewRecommendation()),
          onCopy: ()=>getMenuSectionSelection(context: context, menuId: widget.menuId,  selectionCallBack: (sectionList)=>copyToMenu(context: context, menuId: widget.menuId, itemsList: [widget.item], sections: sectionList, type: MenuItem), onExitUpdate: () {}),
          );}
  }
}





