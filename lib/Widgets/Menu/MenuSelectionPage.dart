
import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:flutter/material.dart';
import 'package:mealplanning/Providers/CatalogProvider.dart';
import 'package:mealplanning/Providers/MenuItem.dart';
import 'package:mealplanning/Providers/MenuProvider.dart';
import 'package:mealplanning/Providers/Settings.dart';
import 'package:provider/provider.dart';

getMenuSectionSelection({BuildContext context, String menuId, Function selectionCallBack, Function onExitUpdate}){
showModalBottomSheet(
        context: context,
        builder: (newContext) {
         return Container(child: MenuSelectionPage(menuId: menuId, selectionCallBack: selectionCallBack, onExitUpdate: onExitUpdate,));
        });
}

class MenuSelectionPage extends StatefulWidget {
  static const routeName = '/MenuSelectionPage';
  final String menuId;
  Function onExitUpdate = () {};
  Function selectionCallBack = () {};
  List<Widget> displayList = [];
  List<double> displayHeight = [];
  List<String> selectedList = []; //state
  MenuSelectionPage({this.menuId, this.selectionCallBack, this.onExitUpdate});
  @override
  _MenuSelectionPageState createState() => _MenuSelectionPageState();
}

class _MenuSelectionPageState extends State<MenuSelectionPage> {
void initState() {super.initState();}
    bool isSelected(String id) { //optimized for efficency
    for(var i=0;i<widget.selectedList.length; i++){if(widget.selectedList[i]==id) return true;}
    return false;
  }
  void selectToggle(String id) { //optimized for efficency
    this.setState(() { 
      bool isFound= widget.selectedList.remove(id);
    if(!isFound) widget.selectedList.add(id); });
  }

ScrollController controller = ScrollController();
void recordListingHeight(int place, double height){ print('-Setting Height: \#${place} = $height');
  widget.displayHeight[place] = height;}

int getScrollSelection(double offset){ print('-Calculating Scroll: ${offset}');
  double sum = 0;
  int place = -1;
  while(offset > sum && place+1 < widget.displayHeight.length) {place++; sum += widget.displayHeight[place]; }
  return offset > sum ? -1 : place;
}

  @override
  Widget build(BuildContext context) {
    print('-> Building MenuSelectionPage');
    final settings = Provider.of<Settings>(context);
    final menuProvider = Provider.of<MenuProvider>(context);
  int count = 0;
  widget.displayList = [Container(padding: EdgeInsets.all(15), color: Colors.black,  width: double.infinity, alignment: Alignment.center,
                        child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: Text('Select Meals to Add:', style: TextStyle(fontSize: 25, color: Colors.white, fontFamily: 'Lato', )))),];
  if(widget.menuId !=null && menuProvider.getMenu(widget.menuId).menuDayList.isNotEmpty){
    menuProvider.getMenu(widget.menuId).menuDayList.forEach((day) {
      widget.displayList.add(Container(color: Theme.of(context).primaryColor, margin: EdgeInsets.only(top: 15, bottom:0), width: double.infinity, alignment: Alignment.center,
           child: SingleChildScrollView(child: Text(day.name, style: TextStyle(fontSize: 20,  fontFamily: 'OpenSans', color:Colors.grey[900], fontWeight: FontWeight.w800)))));
      count+=1; 
      if(day.menuSectionList != null && day.menuSectionList.isNotEmpty) {
          day.menuSectionList.forEach((section){if(!section.done) widget.displayList.add(
            // Text('HERE', style: TextStyle(fontSize: 20,  fontFamily: 'OpenSans', color:Colors.white, fontWeight: FontWeight.w800))));
            MenuSelectionSection(menuId: widget.menuId, dayId: day.id, sectionId: section.id, setScrollHeight: (height)=>this.recordListingHeight(count, height), 
          backgroundColor: this.isSelected(section.id) ? Colors.black : Colors.grey[800], selectionIcon: this.isSelected(section.id) ? Icons.remove_circle : Icons.add_circle,
          selectionCallBack: ()=>this.selectToggle(section.id), ));});
          count+=1;
          }
      });
    // widget.displayHeight = new List(count);
    // widget.displayHeight.forEach((element)=>element=50); // default
    } else print('ERROR :: EMPTY MENU LIST');


    return new WillPopScope(
            onWillPop: () async {if(widget.onExitUpdate != null) widget.onExitUpdate(); return true;},
          child:  Container(color: Colors.black87, 
            child: Column(
          children: [Expanded(
              child: DraggableScrollbar.rrect(
              controller: controller,
              labelTextBuilder: (double offset) {String called =  'Meal';
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
                              itemCount: widget.displayList.length,
                              itemBuilder: (context, index) => widget.displayList[index],
              ),
            ),
          ),
        Container(height: 40, width: double.infinity,  color: Theme.of(context).primaryColor, child: FlatButton(child: Text('SAVE', style: TextStyle(fontSize: 30,  fontFamily: 'OpenSans', fontWeight: FontWeight.w800, color:Colors.grey[900])),
                    onPressed: () {widget.selectionCallBack([...widget.selectedList]); Navigator.of(context).pop(); if(widget.onExitUpdate != null) widget.onExitUpdate(); }))
          ]),
      ),
    );
  }
}


class MenuSelectionSection extends StatelessWidget {
  final String menuId;
  final String dayId;  
  final String sectionId;
  final Color backgroundColor;
  final IconData selectionIcon;
  Function setScrollHeight = () {};
  Function selectionCallBack = () {};

  MenuSelectionSection({this.menuId, this.dayId, this.sectionId, this.backgroundColor = Colors.grey, this.setScrollHeight, this.selectionIcon = Icons.add_circle, this.selectionCallBack,});

  @override
  Widget build(BuildContext context) {
    print('Building -> MenuSelectionSection');
    final settings = Provider.of<Settings>(context);

    MenuSection section = Provider.of<MenuProvider>(context).getMenuSection(menuId: menuId, dayId: dayId, sectionId: sectionId);

    // this.setScrollHeight != null ? this.setScrollHeight((section.menuItemList != null && section.menuItemList.length <4) ? ((section.menuItemList.length*108.0)+226) : 500.0) : null;

    List<Widget> itemList = [];
    if(this.sectionId != null && section.menuItemList.isNotEmpty)
      section.menuItemList.forEach((item)=>itemList.add(
        // Text('HERE', style: TextStyle(fontSize: 20,  fontFamily: 'OpenSans', color:Colors.white, fontWeight: FontWeight.w800))
        simplifiedMenuItemListing(context: context, item: item, nameColor: Theme.of(context).primaryColor, tagColor: Theme.of(context).accentColor)
      ));
    
print('object');
  final Widget mealSelectionCard = Card(color: this.backgroundColor, shadowColor: Colors.white24,
        margin: EdgeInsets.symmetric(vertical: 5),
          child: Container( padding: EdgeInsets.all(7),
          child: Column(
          children: [ListTile( 
      leading: SingleChildScrollView(scrollDirection: Axis.horizontal, child: Text(section.name != null ? section.name : 'Section', style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 35, fontFamily: 'OpenSans', fontWeight: FontWeight.w700))),
  trailing: Icon(this.selectionIcon, size: 40, color: Theme.of(context).primaryColor), ),
  // Expanded(
  //   child: Container(
  //     padding: EdgeInsets.only(left: 20),
  //     child: Column(children: itemList),
  //   ),
  // ),
  ])));

  return GestureDetector( onTap: ()=>this.selectionCallBack(), child: mealSelectionCard);
  }
}

Widget simplifiedMenuItemListing({MenuItem item, BuildContext context, Color tagColor, Color nameColor}){
  final catalogProvider = Provider.of<CatalogProvider>(context);
  List<Widget> attributes = [];
    const double attributesSize = 25;
    const double attributesPadding = 1;   
    if(catalogProvider.getMeat(item.referenceType, item.referenceId)) {attributes.add(Container(width: attributesSize, height: attributesSize, padding: EdgeInsets.symmetric(horizontal: attributesPadding), child: Image.asset('assets/steak.png')));}
    if(catalogProvider.getCarb(item.referenceType, item.referenceId)){attributes.add(Container(width: attributesSize, height: attributesSize, padding: EdgeInsets.symmetric(horizontal: attributesPadding), child: Image.asset('assets/bread.png')));}
    if(catalogProvider.getVeg(item.referenceType, item.referenceId)){attributes.add(Container(width: attributesSize, height: attributesSize, padding: EdgeInsets.symmetric(horizontal: attributesPadding), child: Image.asset('assets/carrot.png')));}
    if(catalogProvider.getFruit(item.referenceType, item.referenceId)){attributes.add(Container(width: attributesSize, height: attributesSize, padding: EdgeInsets.symmetric(horizontal: attributesPadding), child: Image.asset('assets/apple.png')));}
    if(catalogProvider.getSnack(item.referenceType, item.referenceId)){attributes.add(Container(width: attributesSize, height: attributesSize, padding: EdgeInsets.symmetric(horizontal: attributesPadding), child: Image.asset('assets/apple.png')));}

double firstSpacing = 50 - (attributes.length*(attributesSize+attributesPadding+attributesPadding));
  return Expanded(
      child: Row(mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(children: attributes),
        SizedBox(width: firstSpacing), 
        Text(item.adjective != null ? item.adjective : '', style: TextStyle(fontSize: 15, color: Colors.white, fontFamily: 'Lato')), 
      SizedBox(width: 15), 
      Text(item.name != null ? item.name : 'Missing', style: TextStyle(color: nameColor, fontSize: 20, fontFamily: 'Lato',)),
      ]),
  );
}