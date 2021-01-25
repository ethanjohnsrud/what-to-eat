import 'package:flutter/material.dart';
import 'package:mealplanning/Data/startingIngredients.dart';
import 'package:mealplanning/Data/startingMeals.dart';
import 'package:mealplanning/Data/startingPantry.dart';
import 'package:mealplanning/Providers/CatalogProvider.dart';
import 'package:mealplanning/Providers/Ingredient.dart';
import 'package:mealplanning/Providers/Meal.dart';
import 'package:mealplanning/Providers/PantryItem.dart';
import 'package:mealplanning/Providers/Settings.dart';
import 'package:mealplanning/Widgets/Catalog/Catalog-Edit/CatalogMealEdit.dart';
import 'package:mealplanning/Widgets/Catalog/IngredientListing.dart';
import 'package:mealplanning/Widgets/Catalog/MealCard.dart';
import 'package:mealplanning/Widgets/EditBlank.dart';
import 'package:provider/provider.dart';

import 'Catalog-Edit/CatalogIngredientEdit.dart';
import 'Catalog-Edit/CatalogPantryItemEdit.dart';
import '../AppDrawer.dart';
import 'PantryItemListing.dart';

import 'package:draggable_scrollbar/draggable_scrollbar.dart';



class Catalog extends StatefulWidget {
  static const routeName = '/Catalog';
  @required Type displayType;
  final bool allowAdd;
  final bool selectionMode;
  final bool popAfterSelection;
  final bool selectionMultiple;
  Function selectionCallBack = () {};
  
  Catalog({this.displayType = Meal, this.allowAdd = true, this.selectionMode = false, this.popAfterSelection = true, this.selectionMultiple = true, this.selectionCallBack, }){
    // displayList = displayType == Meal ? startingMeals : displayType == Ingredient ? startingIngredients : displayType == PantryItem ? startingPantry : [];
    // displayHeight = displayType == Meal ? new List(startingMeals.length) : displayType == Ingredient ? new List(startingIngredients.length) : displayType == PantryItem ? new List(startingPantry.length) : [];
    // displayHeight.forEach((element)=>element=50); // default
  }
  @override
  _CatalogState createState() => _CatalogState();
}

class _CatalogState extends State<Catalog> {
  List displayList = [];
  List<double> displayHeight = [];
  List<String> selectedList = []; //state

  bool showMealsToggle = true;
  bool sortCost = true;
  bool sortPopular = true;
  bool sortRecent = true;
  bool sortQuantity = true;
  bool sortExpiration = true;
  bool sortMeat = false;
  bool sortCarb = false;
  bool sortVeg = false;
  bool sortFruit = false;
  bool sortSnack = false;
  bool sortSolo = false;

  @override
  void initState() {super.initState();
  // filterList(context);
  } //initalize, bacically constructor

 


  void filterList(BuildContext context, {@required String toggle, bool solo = false, bool reset = false}) {
    // final catalogProvider = Provider.of<CatalogProvider>(context);
    bool localSortCost = sortCost;
    bool localSortPopular = sortPopular;
    bool localSortRecent = sortRecent;
    bool localSortQuantity = sortQuantity;
    bool localSortExpiration = sortExpiration;
    bool localSortMeat = sortMeat;
    bool localSortCarb = sortCarb;
    bool localSortVeg = sortVeg;
    bool localSortFruit = sortFruit;
    bool localSortSnack = sortSnack;
    bool localSortSolo = sortSolo;

    if(solo || reset) {
        localSortCost = false;
        localSortPopular = false;
        localSortRecent = false;
        localSortQuantity = false;
        localSortExpiration = false;
        localSortMeat = false;
        localSortCarb = false;
        localSortVeg = false;
        localSortFruit = false;
        localSortSnack = false;
        localSortSolo = false;
      }
    
    if(reset) {
        localSortCost = true;
        localSortPopular = true;
        localSortRecent = true;
        localSortQuantity = true;
        localSortExpiration = true;
      }
    
    switch (toggle) {
      case 'cost': localSortCost = !localSortCost; break;
      case 'popular': localSortPopular = !localSortPopular; break;
      case 'recent': localSortRecent = !localSortRecent; break;
      case 'quantity': localSortQuantity = !localSortQuantity; break;
      case 'expiration': localSortExpiration = !localSortExpiration; break;
      case 'meat': localSortMeat = !localSortMeat; break;
      case 'carb': localSortCarb = !localSortCarb; break;
      case 'veggie': localSortVeg = !localSortVeg; break;
      case 'fruit': localSortFruit = !localSortFruit; break;
      case 'snack': localSortSnack = !localSortSnack; break;
      case 'solo': localSortSolo = !localSortSolo; break;
      default: null;
    }

    //single execute Changes
    this.setState(() {
      sortCost = localSortCost;
      sortPopular = localSortPopular;
      sortRecent = localSortRecent;
      sortQuantity = localSortQuantity;
      sortExpiration = localSortExpiration;
      sortMeat = localSortMeat;
      sortCarb = localSortCarb;
      sortVeg = localSortVeg;
      sortFruit = localSortFruit;
      sortSnack = localSortSnack;
      sortSolo = localSortSolo;
      });

    // print('Sorting with [${widget.displayType.toString()}]');
    // print('DISPLAY====LIST===BEFORE =>');
    // for(var i=0; i<displayList.length;i++){print('$i) ${displayList[i].name}');}
    // this.setState(() {displayList = catalogProvider.sortList(
    //       type: widget.displayType,
    //       cost: this.sortCost, 
    //       popularity: this.sortPopular,
    //       recent: this.sortRecent,
    //       quantity: this.sortQuantity,
    //       expiration: this.sortExpiration,
    //       meat: this.sortMeat,
    //       carb: this.sortCarb,
    //       veg: this.sortVeg,
    //       fruit: this.sortFruit,
    //       snack: this.sortSnack,
          // solo: this.sortSolo,
    //       );});
    // print('DISPLAY====LIST===AFTER =>');
    // for(var i=0; i<displayList.length;i++){print('$i) ${displayList[i].name}');}
  }

  bool isSelected(String id) { //optimized for efficency
    for(var i=0;i<selectedList.length; i++){if(selectedList[i]==id) return true;}
    return false;
  }
  void addSelected(String id) { //optimized for efficency
  bool isFound= selectedList.remove(id);
    if(!isFound) selectedList.add(id);
    this.setState(() { });
  }
  void addNewListing(context) {
    if(widget.displayType == Meal){ Meal meal = new Meal(id: Provider.of<Settings>(context).getUniqueID(context, Meal), name: 'New Meal', popularityCount: Provider.of<CatalogProvider>(context).getMedianPopularity(Meal), recentDate: Provider.of<CatalogProvider>(context).getMedianRecent(Meal)); setState(()=>Provider.of<CatalogProvider>(context).addMeal(meal));
            showMealEdit(context: context, mealId: meal.id, onExitUpdate: ()=>Navigator.of(context).pushReplacement(MaterialPageRoute(builder:(context)=>Catalog(displayType: Meal,))));}
    if(widget.displayType == Ingredient){ Ingredient ingredient = new Ingredient(id: Provider.of<Settings>(context).getUniqueID(context, Ingredient), name: 'New Ingredient', popularityCount: Provider.of<CatalogProvider>(context).getMedianPopularity(Ingredient), recentDate: Provider.of<CatalogProvider>(context).getMedianRecent(Ingredient)); setState(()=>Provider.of<CatalogProvider>(context).addIngredient(ingredient));
            showIngredientEdit(context: context, ingredientId: ingredient.id, onExitUpdate: ()=>Navigator.of(context).pushReplacement(MaterialPageRoute(builder:(context)=>Catalog(displayType: Ingredient,))));}              
    if(widget.displayType == PantryItem){PantryItem item = new PantryItem(id: Provider.of<Settings>(context).getUniqueID(context, PantryItem), name: 'New Item'); setState(()=>Provider.of<CatalogProvider>(context).addPantryItem(item));
            showPantryItemEdit(context: context, itemId: item.id, onExitUpdate: ()=>Navigator.of(context).pushReplacement(MaterialPageRoute(builder:(context)=>Catalog(displayType: PantryItem,))));}       
    // this.filterList(context);
  }

ScrollController controller = ScrollController();
void recordListingHeight(String id, double height){ print('-Setting Height: ${id} = $height');
  // for(var i=0;i<displayList.length;i++){if(displayList[i].id == id) displayHeight[i] = height;}
}
int getScrollSelection(double offset){ print('-Calculating Scroll: ${offset}');
  double sum = 0;
  int place = -1;
  while(offset > sum && place+1 < displayHeight.length) {place++; sum += displayHeight[place]; }
  return offset > sum ? -1 : place;
}
  
  @override
  Widget build(BuildContext context) {
    print('Building -> Catalog');
    // for(var i=0; i<displayList.length;i++){print('$i) ${displayList[i].name}');}
    final catalogProvider = Provider.of<CatalogProvider>(context);
    final settings = Provider.of<Settings>(context);

    // if(displayList == null || displayList.isEmpty) //Initalize List 
      displayList = catalogProvider.sortList(  //and changes in sort conditions call setState
          type: widget.displayType,
          cost: this.sortCost, 
          popularity: this.sortPopular,
          recent: this.sortRecent,
          quantity: this.sortQuantity,
          expiration: this.sortExpiration,
          meat: this.sortMeat,
          carb: this.sortCarb,
          veg: this.sortVeg,
          fruit: this.sortFruit,
          snack: this.sortSnack,
          solo: this.sortSolo,
          );

    // displayList = widget.displayType == Meal ? catalogProvider.meals : widget.displayType == Ingredient ? catalogProvider.ingredients : widget.displayType == PantryItem ? catalogProvider.pantry : [];

    // final Widget view =  widget.toggleView ?
    //           Row(children: [SortToggle(title: widget.mealView ? 'Ingredients' : 'Meals', onClick: () {this.setState(()=>{widget.mealView = !widget.mealView}); filterList(context, reset: true);}, onHold: () => filterList(context, reset: true), active: true, image: 'assets/steak.png', ),
    //           VerticalDivider(color: Colors.grey,)])
    //           : SizedBox(width:0);   
    final Widget addButton = GestureDetector(child: Icon(Icons.add_circle, color: Theme.of(context).primaryColor, size: 40,),  onTap: ()=>this.addNewListing(context), );
    final Widget addCollection = settings.nameTags ? Column(children: <Widget>[
        Container(width: 55, height:45, 
          child: addButton),
              Text('Add', style: TextStyle(fontSize: 15, color:Theme.of(context).accentColor))],) : addButton;
    final Widget viewEnd =  widget.allowAdd ? Row(children: [VerticalDivider(color: Colors.grey,),addCollection]) : SizedBox(width:1); 
    final List<Widget> sortItems = [ 
                SortToggle(title: 'Cost', onClick: () => filterList(context, toggle: 'cost'), onHold: () => filterList(context, toggle: 'cost', solo: true), active: sortCost, image: 'assets/price.png', ),
                SortToggle(title: 'Popular', onClick: () => filterList(context, toggle: 'popular'),  onHold: () => filterList(context, toggle: 'popular', solo: true), active: sortPopular, image: 'assets/popularity.png', ),
                SortToggle(title: 'Recent', onClick: () => filterList(context, toggle: 'recent'),  onHold: () => filterList(context, toggle: 'recent', solo: true), active: sortRecent, image: 'assets/recent.png', ),
                SortToggle(title: 'Quantity', onClick: () => filterList(context, toggle: 'quantity'), onHold: () => filterList(context, toggle: 'quantity', solo: true), active: sortQuantity, image: 'assets/quantity.png', ),
                SortToggle(title: 'Expiration', onClick: () => filterList(context, toggle: 'expiration'), onHold: () => filterList(context, toggle: 'expiration', solo: true), active: sortExpiration, image: 'assets/expiration.png', ),
                SortToggle(title: 'Meat', onClick: () => filterList(context, toggle: 'meat'),  onHold: () => filterList(context, toggle: 'meat', solo: true), active: sortMeat, image: 'assets/steak.png', ),
                SortToggle(title: 'Carb', onClick: () => filterList(context, toggle: 'carb'),  onHold: () => filterList(context, toggle: 'carb', solo: true), active: sortCarb, image: 'assets/bread.png', ),
                SortToggle(title: 'Veggie', onClick: () => filterList(context, toggle: 'veggie'),  onHold: () => filterList(context, toggle: 'veggie', solo: true), active: sortVeg, image: 'assets/carrot.png', ),
                SortToggle(title: 'Fruit', onClick: () => filterList(context, toggle: 'fruit'),  onHold: () => filterList(context, toggle: 'fruit', solo: true), active: sortFruit, image: 'assets/apple.png', ),
                SortToggle(title: 'Snack', onClick: () => filterList(context, toggle: 'snack'),  onHold: () => filterList(context, toggle: 'snack', solo: true), active: sortSnack, image: 'assets/snack.png', ),
              ];
      if(widget.displayType != Meal) sortItems.add(SortToggle(title: 'Solo', onClick: () => filterList(context, toggle: 'solo'),  onHold: () => filterList(context, toggle: 'solo', solo: true), active: sortSolo, image: 'assets/solo.png', ),);
    final Widget sortOptions = Container(
      margin: EdgeInsets.only(top:10),
      child: Row(children: [
      Expanded(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: sortItems),
        ),
      ),
      viewEnd,
      ]),
    );
    final List<Widget> bottomBar = [];
    if(widget.selectionMode && widget.selectionMultiple) 
      bottomBar.add(Container(height: 45, width: double.infinity,  margin: EdgeInsets.only(left: 10, right: 10, top: 10), color: Theme.of(context).primaryColor, child: FlatButton(child: Text('SAVE', style: TextStyle(fontSize: 35,  fontFamily: 'OpenSans', fontWeight: FontWeight.w800, color:Colors.grey[900])),
                onPressed: () { print('Catalog : Save-Press');
                  widget.selectionCallBack([...selectedList]); 
                  print('Catalog : list sent');
                  if(widget.popAfterSelection)
                      Navigator.of(context).pop(); 
                  }
                                      )));
    bottomBar.add(sortOptions);
    // if(settings.nameTags)
    bottomBar.add(BottomBanner(widget.displayType == Meal ? 'Meal Catalog' : widget.displayType == Ingredient ? 'Ingredient Catalog' : 'Pantry'));
//collect list children elements
// final List<Widget> listItems = [];
// displayList.forEach((item) { 
//   widget.mealView ? listItems.add(MealCard(item))
//       : !widget.selectionMode ? listItems.add(IngredientListing(ingredient: item, tailTag: 'Popularity', showPantry: true,
//                       tail: Text('${catalogProvider.getIngredientPopularityPercent(item.id)} %', style: TextStyle(fontSize: 20, color: Colors.white, fontFamily: 'Lato')),))
//       : (isSelected(item.id)) ? listItems.add(IngredientListing(ingredient: item, selectionMode: true, selectionCallBack: ()=>addSelected(item.id),))
//       : listItems.add(IngredientListing(ingredient: item, selectionMode: true, selectionIcon: Icons.add_circle, backgroundColor: Colors.grey[800], selectionCallBack: ()=>addSelected(item.id),));
// });

final Widget blankCatalogPage = Center( child: Column(children: <Widget>[SizedBox(height: 200),
                Text('Catalog Appears', style: TextStyle(fontSize: 35,  fontFamily: 'OpenSans', color:Theme.of(context).primaryColor, fontWeight: FontWeight.bold)), SizedBox(height: 10,),
                Text('Empty', style: TextStyle(fontSize: 35,  fontFamily: 'OpenSans', color:Theme.of(context).primaryColor, fontWeight: FontWeight.bold)), SizedBox(height: 40,),
                RaisedButton(child: Text(widget.selectionMode ? 'Return' : widget.displayType == Ingredient ? 'Add Ingredient' : widget.displayType == Meal ? 'Add Meal' : 'Add Item', style: TextStyle(fontSize: 25,  fontFamily: 'QuickSand', color:Theme.of(context).primaryColor, fontWeight: FontWeight.bold)), color: Colors.grey[800], elevation: 10, padding: EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                  onPressed: widget.selectionMode ? ()=>Navigator.of(context).pop() : ()=>this.addNewListing(context))],));

    return new WillPopScope(
    onWillPop: () {this.widget.selectionMode ? Navigator.of(context).pop() : Navigator.of(context).pushReplacement(MaterialPageRoute(builder:(context)=>Catalog(displayType: Meal,))); return Future.value(true);},
          child:  Scaffold( 
        backgroundColor: Colors.white10,
        drawer: AppDrawer(),
  body:   Container(margin: EdgeInsets.only(top: settings.accountForNotch ? settings.notchAdjustment : 5),
      child: displayList.isEmpty ? blankCatalogPage
        : DraggableScrollbar.rrect(
        controller: controller,
        labelTextBuilder: (double offset) {
        //   String called =  widget.displayType == Meal ? 'Meals' :  widget.displayType == Ingredient ? 'Ingredients' :  widget.displayType == PantryItem ? 'Pantry' : 'IDK';
        // final int selection = this.getScrollSelection(offset);
        // if((selection < displayList.length) && (selection >= 0)) called = (widget.displayType == Meal || widget.displayType == Ingredient) ? displayList[selection].name
        //         :  (widget.displayType ==PantryItem && displayList[selection].referenceType == Meal) ? catalogProvider.getMeal(displayList[selection].referenceId).name : (widget.displayType ==PantryItem && displayList[selection].referenceType == Ingredient) ? catalogProvider.getIngredient(displayList[selection].referenceId).name : 'Missing';
        // if(called.length > 7) called = called.substring(0,6);
        // return Text(called, style: TextStyle(color: Theme.of(context).accentColor));
        return Text('Catalog', style: TextStyle(color: Theme.of(context).accentColor));
        },
        alwaysVisibleScrollThumb: true,
        backgroundColor: Theme.of(context).primaryColor,
        padding: EdgeInsets.only(right: 2.0),
            child: ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 5),
                        // children: listItems,
                        controller: controller,
                        itemCount: displayList.length,
                        // itemExtent: 526,
                        itemBuilder: (context, index) {
                          if(index >= displayList.length) return SizedBox(height: 1);
                          if(widget.selectionMode){
                            if(widget.displayType == Meal) {if(isSelected(displayList[index].id)) return MealCard(meal: displayList[index], backgroundColor: Colors.black, selectionMode: true, selectionIcon: Icons.remove_circle, selectionCallBack: widget.selectionMultiple ? ()=>addSelected(displayList[index].id) : () {widget.selectionCallBack(displayList[index]); if(widget.popAfterSelection) Navigator.of(context).pop();}, setScrollHeight: this.recordListingHeight,);
                                else return MealCard(meal: displayList[index], backgroundColor: Colors.grey[800], selectionMode: true, selectionIcon: Icons.add_circle, selectionCallBack: widget.selectionMultiple ? ()=>addSelected(displayList[index].id) : () {widget.selectionCallBack(displayList[index]); if(widget.popAfterSelection) Navigator.of(context).pop();}, setScrollHeight: this.recordListingHeight,); }
                            if(widget.displayType == Ingredient) {if(isSelected(displayList[index].id)) return IngredientListing(ingredient: displayList[index], backgroundColor: Colors.black, setScrollHeight: this.recordListingHeight,
                                                selectionMode: true, tail: IconButton(icon: Icon(Icons.remove_circle, size: 40, color: Theme.of(context).primaryColor), onPressed: widget.selectionMultiple ? ()=>addSelected(displayList[index].id) : () {widget.selectionCallBack(displayList[index]); if(widget.popAfterSelection) Navigator.of(context).pop();}, ),);
                                else return IngredientListing(ingredient: displayList[index], backgroundColor: Colors.grey[800], setScrollHeight: this.recordListingHeight,
                                                selectionMode: true, tail: IconButton(icon: Icon(Icons.add_circle, size: 40, color: Theme.of(context).primaryColor), onPressed: widget.selectionMultiple ? ()=>addSelected(displayList[index].id) : () {widget.selectionCallBack(displayList[index]); if(widget.popAfterSelection) Navigator.of(context).pop();}, ),);}
                            if(widget.displayType == PantryItem) {if(isSelected(displayList[index].id)) return PantryItemListing(item: displayList[index], selectionMode: true, selectionIcon: Icons.remove_circle, selectionCallBack: widget.selectionMultiple ? ()=>addSelected(displayList[index].id) : () {widget.selectionCallBack(displayList[index]); if(widget.popAfterSelection) Navigator.of(context).pop();}, setScrollHeight: this.recordListingHeight,);
                                else return PantryItemListing(item: displayList[index], selectionMode: true, selectionIcon: Icons.add_circle, backgroundColor: Colors.grey[800], selectionCallBack: widget.selectionMultiple ? ()=>addSelected(displayList[index].id) : () {widget.selectionCallBack(displayList[index]); if(widget.popAfterSelection) Navigator.of(context).pop();}, setScrollHeight: this.recordListingHeight,);}
                          } else {
                                if(widget.displayType == Meal) return MealCard(meal: displayList[index], setScrollHeight: this.recordListingHeight, );
                                if(widget.displayType == Ingredient) return IngredientListing(ingredient: displayList[index], tailTag: 'Popularity', showPantry: true, tail: Text('${catalogProvider.getPopularityPercent(Ingredient, displayList[index].id)} %', style: TextStyle(fontSize: 20, color: Colors.white, fontFamily: 'Lato')), setScrollHeight: this.recordListingHeight,);
                                if(widget.displayType == PantryItem) return PantryItemListing(item: displayList[index], setScrollHeight: this.recordListingHeight,);
                          }
                        }, 
                        //  widget.selectionMultiple ? ()=>addSelected(displayList[index].id) : () {widget.selectionCallBack(displayList[index]); Navigator.of(context).pop();}
        ),
      ),
  ),
                  
            
  // bottomNavigationBar:  Container( height: (settings.nameTags && widget.selectionMode && widget.selectionMultiple) ? 150  : (!settings.nameTags && widget.selectionMode && widget.selectionMultiple) ? 125 : (settings.nameTags) ? 95 : 60,
  bottomNavigationBar:  Container( height: (settings.nameTags && widget.selectionMode && widget.selectionMultiple) ? 155  : (!settings.nameTags && widget.selectionMode && widget.selectionMultiple) ? 150 : (settings.nameTags) ? 100 : 85,
      child: Column(children: bottomBar),
        ),

      // floatingActionButtonLocation: FloatingActionButtonLocation.miniStartTop,
      // floatingActionButton: IconButton(icon: Icon(Icons.menu, color: Colors.white, size: 40), padding: EdgeInsets.only(top: 85, left: 10), onPressed: ()=>Drawer(),),

      ),
    );
  }
}


class SortToggle extends StatelessWidget {
final String title;
final bool active;
final String image;
final Function onClick;
final Function onHold;
final double sortIconSize;
final bool backgroundColorBlack;

SortToggle({this.active, this.onClick, this.onHold, this.title, this.image, this.sortIconSize = 35, this.backgroundColorBlack = false});

  @override
  Widget build(BuildContext context) {
    print('Building -> SortToggle');
    final settings = Provider.of<Settings>(context);
    Widget visualIcon;
    if(settings.nameTags && this.active) 
      visualIcon = Column(children: <Widget>[
        Container(width: sortIconSize, height: sortIconSize,  margin: EdgeInsets.symmetric(horizontal: sortIconSize/2),
          child: Image.asset(image)),
              Text(title, style: TextStyle(fontSize: 15, color:Theme.of(context).accentColor))],);
    else if(settings.nameTags && !this.active)
      visualIcon = Column(children: <Widget>[
        Container(width: sortIconSize, height: sortIconSize,  margin: EdgeInsets.symmetric(horizontal: sortIconSize/2), 
        child: ColorFiltered(
          colorFilter: ColorFilter.mode(this.backgroundColorBlack ? Colors.black : Colors.grey[900], BlendMode.color),
          child: Image.asset(image))),
              Text(title, style: TextStyle(fontSize: 15, color:Theme.of(context).accentColor))],);
    else if(!settings.nameTags && this.active)
      visualIcon = Container(width: sortIconSize, height: sortIconSize, margin: EdgeInsets.symmetric(horizontal: sortIconSize/2), 
          child: Image.asset(image));
    else
      visualIcon = Container(width: sortIconSize, height: sortIconSize,  margin: EdgeInsets.symmetric(horizontal: sortIconSize/2),
          child: ColorFiltered(
          colorFilter: ColorFilter.mode(this.backgroundColorBlack ? Colors.black : Colors.grey[900], BlendMode.color),
          child: Image.asset(image)));
    
    return GestureDetector(
      child: visualIcon,
      onTap: onClick,    
      onLongPress: onHold,  
    );
  }
}

