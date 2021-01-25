import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mealplanning/Providers/CatalogProvider.dart';
import 'package:mealplanning/Providers/Meal.dart';
import 'package:mealplanning/Providers/MenuProvider.dart';
import 'package:provider/provider.dart';

getMenuSelection({BuildContext context, Function selectionCallBack, Function onExitUpdate}){
showModalBottomSheet(
        context: context,
        builder: (newContext) {
         return Container(child: SelectMenuPage(selectionCallBack: selectionCallBack, onExitUpdate: onExitUpdate, ));
        });
}

class SelectMenuPage extends StatelessWidget {
  // static const routeName = '/MealIngredientsSelectionPage';
  Function onExitUpdate = () {};
  Function selectionCallBack = () {};
  List<double> displayHeight = [];
  SelectMenuPage({this.selectionCallBack, this.onExitUpdate});
 
ScrollController controller = ScrollController();
void recordListingHeight(int place, double height){ print('-Setting Height: \#${place} = $height');
  displayHeight[place] = height;}

int getScrollSelection(double offset){ print('-Calculating Scroll: ${offset}');
  double sum = 0;
  int place = -1;
  while(offset > sum && place+1 < displayHeight.length) {place++; sum += displayHeight[place]; }
  return offset > sum ? -1 : place;
}

  @override
  Widget build(BuildContext context) {
    print('-> Building MenuSelectionPage');
    // final settings = Provider.of<Settings>(context);
    // final catalogProvider = Provider.of<CatalogProvider>(context);
    final menuProvider = Provider.of<MenuProvider>(context);
    // final TextStyle tagStyle = TextStyle(fontSize: 20, color:Theme.of(context).accentColor);
    // final TextStyle propertyStyle = TextStyle(fontSize: 35, color:Theme.of(context).primaryColor);
    // final TextStyle smallerStyle = TextStyle(fontSize: 25, color:Theme.of(context).primaryColor);
  
    return new WillPopScope(
            onWillPop: () async {if(onExitUpdate != null) onExitUpdate(); return true;},
          child:  Container(color: Colors.black87, 
            child: DraggableScrollbar.rrect(
            controller: controller,
            labelTextBuilder: (double offset) {String called =  'Menu';
              // final int selection = this.getScrollSelection(offset);
              // if((selection < widget.displayList.length) && (selection >= 0)) called =  widget.displayList[selection].name;
              // if(called.length > 7) called = called.substring(0,6);
              return Text(called, style: TextStyle(color: Colors.white));
              },
            alwaysVisibleScrollThumb: true,
            backgroundColor: Theme.of(context).primaryColor,
            padding: EdgeInsets.all(2.0),
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 5),
                  controller: controller,
                  itemCount: menuProvider.menuList.length+1,
                  itemBuilder: (context, index) {
                      if(index==0) return Container(padding: EdgeInsets.all(15), color: Colors.black, width: double.infinity, alignment: Alignment.center,
                        child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: Text('Select Menu:', style: TextStyle(fontSize: 25, color: Colors.white, fontFamily: 'Lato', ))));
                      else return MenuListing(
                            menuId: menuProvider.menuList[index-1].id,
                            selectionCallBack: this.selectionCallBack,
                            firstDate: menuProvider.menuList[index-1].menuDayList.isNotEmpty ? menuProvider.menuList[index-1].menuDayList[0].date : null,
                            lastDate: menuProvider.menuList[index-1].menuDayList.isNotEmpty ? menuProvider.menuList[index-1].menuDayList[menuProvider.menuList[index-1].menuDayList.length-1].date : null,
                          );
                    } 
                  ),
            ),
      ),
    );
  }
}


class MenuListing extends StatelessWidget {
  final String menuId;
  final DateTime firstDate;
  final DateTime lastDate;
  Function selectionCallBack = () {};
  Function setScrollHeight = () {};


  MenuListing({this.menuId, this.setScrollHeight, this.selectionCallBack, this.firstDate, this.lastDate});

  @override
  Widget build(BuildContext context) {
    print('Building -> MenuListing');
    Menu menu = Provider.of<MenuProvider>(context).getMenu(menuId);
    // setScrollHeight != null ? setScrollHeight(menu.id, 108.0) : null;
    
    return GestureDetector( onTap: (){ selectionCallBack(menu.id); Navigator.of(context).pop();}, 
    child:Card (
        elevation: 3,
        color:Colors.black,
        shadowColor: Colors.white24,
        margin: EdgeInsets.only(top: 8),
          child: ListTile( contentPadding: EdgeInsets.all(7),
          title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SingleChildScrollView(scrollDirection: Axis.horizontal, child: Text('ID: ${menu.id}', style: TextStyle(color: Colors.grey, fontSize: 13, fontFamily: 'Lato'))),
            SingleChildScrollView(scrollDirection: Axis.horizontal, child: Text(menu.name, style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 20, fontFamily: 'QuickSand', fontWeight: FontWeight.w700))),
            SingleChildScrollView(scrollDirection: Axis.horizontal, child: Text('${DateFormat.Md().format(this.firstDate)} - ${DateFormat.yMd().format(this.lastDate)}', style: TextStyle(color: Theme.of(context).accentColor, fontSize: 15, fontFamily: 'Lato'))),
          ]),
          trailing: Icon(Icons.add_circle, color: Theme.of(context).primaryColor, size: 35),
          )
      ));
  }
}