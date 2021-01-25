import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mealplanning/Providers/MenuProvider.dart';
import 'package:mealplanning/Providers/Settings.dart';
import 'package:provider/provider.dart';

import '../../EditBlank.dart';

class MenuEdit extends StatelessWidget {
  final String menuId;
  Function setNewMenu;
  Function deleteCurrentMenu = () {};
  Function newMenuCallBack = () {};

  MenuEdit({this.menuId, this.setNewMenu, this.deleteCurrentMenu, this.newMenuCallBack});

  final TextEditingController nameController = TextEditingController();
  
  @override
  Widget build(BuildContext context) {
    print('Building: EditMenuSection-bottomSheet');
    // final settings = Provider.of<Settings>(context);
    final menuProvider = Provider.of<MenuProvider>(context);
    final TextStyle tagStyle = TextStyle(fontSize: 20, color:Theme.of(context).accentColor);
    final TextStyle propertyStyle = TextStyle(fontSize: 35, color:Theme.of(context).primaryColor);
    final TextStyle smallerStyle = TextStyle(fontSize: 25, color:Theme.of(context).primaryColor);
    // final TextStyle placeStyle = TextStyle(fontSize: 25, color:Theme.of(context).accentColor);
    
    Menu menu = menuProvider.getMenu(menuId);

    List<Widget> menuEditControls = [];
    if(menuId != null && menuProvider.getMenu(menuId) != null){
    nameController.text = menu.name;
    nameController.addListener(()=>menuProvider.setMenuName(menuId: menuId, name: nameController.text));
      menuEditControls.addAll([
        DisplayConstant(property: menu.id, tag: 'ID', propertyStyle: smallerStyle, tagStyle: tagStyle,),
        EditValue(value: menu.name, tag: 'Title', tagStyle: tagStyle, propertyStyle: propertyStyle, onChangeCallBack: (value)=>menuProvider.setMenuName(menuId: this.menuId, name: value),),
        EditAdvanceAction(action: ()=>deleteCurrentMenu(), warning: 'DELETE', tag: 'Delete this MENU', tagStyle: tagStyle,),
        Divider(thickness: 5, color: Colors.grey[800],),
      ]);
    }
    menuEditControls.addAll([
      SelectMenuList(currentMenuId: menuId == null ? null : menu.id, tagStyle: tagStyle, loadMenu: (id)=>setNewMenu(id),),
      EditButton(propertyName: 'New Menu', propertyStyle: propertyStyle, tag: 'Add Menu', icon: Icons.add_circle, tagStyle: tagStyle, 
      onClick: ()=>showNewMenu(context: context, callBack: newMenuCallBack),)
    ]);

    return SingleChildScrollView(scrollDirection: Axis.vertical, child: Column(children: menuEditControls));
  }
}

  
class SelectMenuList extends StatelessWidget {
  final String currentMenuId;
  final TextStyle tagStyle;
  Function loadMenu = () {};


  SelectMenuList({ this.tagStyle, this.currentMenuId, this.loadMenu});

  @override
  Widget build(BuildContext context) {
    print('Building -> SelectMenuList');
    final menuProvider = Provider.of<MenuProvider>(context);
                                                                                                                                      
    return ListTile(
        title: Container(
      margin: EdgeInsets.all(2),
      color: Colors.black,
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
      child: SizedBox(
        height: 350,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Select Menu', style: tagStyle), 
          Expanded(
            child:  ListView.builder(
          itemCount: menuProvider.menuList.length,
          itemBuilder: (context, index) =>
            MenuListing(
              menuId: menuProvider.menuList[index].id,
              selected: (menuProvider.menuList[index].id == currentMenuId),
              loadMenu: (id)=>loadMenu(id),
              firstDate: menuProvider.menuList[index].menuDayList.isNotEmpty ? menuProvider.menuList[index].menuDayList[0].date : null,
              lastDate: menuProvider.menuList[index].menuDayList.isNotEmpty ? menuProvider.menuList[index].menuDayList[menuProvider.menuList[index].menuDayList.length-1].date : null,
            ),
          ),
          ),
          ]),
        
      ),
    ));
  }
}


class MenuListing extends StatelessWidget {
  final String menuId;
  final bool selected;
  final DateTime firstDate;
  final DateTime lastDate;
  Function loadMenu = () {};
  Function setScrollHeight = () {};


  MenuListing({this.menuId, this.setScrollHeight, this.loadMenu, this.selected = false, this.firstDate, this.lastDate});

  @override
  Widget build(BuildContext context) {
    print('Building -> MenuListing');
    Menu menu = Provider.of<MenuProvider>(context).getMenu(menuId);
    // setScrollHeight != null ? setScrollHeight(menu.id, 108.0) : null;
    
    return GestureDetector( onTap: (){ loadMenu(menu.id);}, 
    child:Card (
        elevation: 3,
        color: this.selected ? Colors.black : Colors.grey[900],
        shadowColor: Colors.white24,
        margin: EdgeInsets.only(top: 8),
          child: ListTile( contentPadding: EdgeInsets.all(7),
          title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SingleChildScrollView(scrollDirection: Axis.horizontal, child: Text('ID: ${menu.id}', style: TextStyle(color: Colors.grey, fontSize: 13, fontFamily: 'Lato'))),
            SingleChildScrollView(scrollDirection: Axis.horizontal, child: Text(menu.name, style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 20, fontFamily: 'QuickSand', fontWeight: FontWeight.w700))),
            SingleChildScrollView(scrollDirection: Axis.horizontal, child: Text('${DateFormat.Md().format(this.firstDate)} - ${DateFormat.yMd().format(this.lastDate)}', style: TextStyle(color: Theme.of(context).accentColor, fontSize: 15, fontFamily: 'Lato'))),
          ]),
          trailing: Icon(this.selected ? Icons.radio_button_checked : Icons.radio_button_unchecked, color: Theme.of(context).primaryColor, size: 35),
          )
      ));
  }
}


showNewMenu({BuildContext context, Function callBack}){
showModalBottomSheet(
        context: context,
        builder: (newContext) {
         return Container(child: NewMenu(callBack: callBack));
        });
}

class NewMenu extends StatefulWidget {
  Function callBack = () {};
 

  NewMenu({this.callBack});

  @override
  _NewMenuState createState() => _NewMenuState();
}

class _NewMenuState extends State<NewMenu> {
  // final TextEditingController nameController = TextEditingController(text: 'New Menu'); 
  @override
  void initState() {
    super.initState();
  }//Declare and Initalize State Items Here not in parent class for stateful widgets, otherwisw rebuilds and resets everything; not totally sure why
  String title = 'New Menu';
  int days = 7;
  int sections = 3;
  DateTime startDate = DateTime.now();

  void generateMenu(BuildContext context){
    final List<MenuDay> menuList = [];
    final List<String> uncheckedIDs = [];
    for(int i=0; i<days; i++){
        String dayId = Provider.of<Settings>(context).getUniqueID(context, MenuDay, extraList: uncheckedIDs);
        uncheckedIDs.add(dayId);
        List<MenuSection> sectionList = [];
        for(int j=0; j<sections; j++){
           String sectionId = Provider.of<Settings>(context).getUniqueID(context, MenuSection, extraList: uncheckedIDs);
            uncheckedIDs.add(sectionId); String sectionName = configureMealName(j+1, sections);
            sectionList.add(new MenuSection(id: sectionId, menuItemList: [], name: sectionName, recommendationTypes: (sectionName == 'Breakfast' || sectionName == 'Snack') ? [sectionName] : ['Regular']));
        }
        menuList.add(new MenuDay(id: dayId, name: DateFormat.E().format(startDate.add(new Duration(days: i))), date: startDate.add(new Duration(days: i)), menuSectionList: sectionList));
    }final String newId = Provider.of<Settings>(context).getUniqueID(context, Menu, extraList: uncheckedIDs);
    Provider.of<MenuProvider>(context).addMenu(new Menu(id: newId, name: title, menuDayList: menuList));
    Navigator.pop(context);
    widget.callBack(newId);
  }

  String configureMealName(int place, int length){
      switch(length){
        case 1: return 'Dinner';
        case 2:
          if(place == 1) return 'Lunch';
          return 'Dinner';
        default:
          if(place == 1) return 'Breakfast';
          else if(place == 2) return 'Lunch';
          else if(place == 3) return 'Dinner';
          return 'Snack';
      }
  }

 Widget build(BuildContext context){
   print('Building: NewMenu-bottomSheet');
   print(DateFormat.E().format(startDate));
    // final settings = Provider.of<Settings>(context);
    // final menuProvider = Provider.of<MenuProvider>(context);
    final TextStyle tagStyle = TextStyle(fontSize: 20, color:Theme.of(context).accentColor);
    final TextStyle propertyStyle = TextStyle(fontSize: 35, color:Theme.of(context).primaryColor);
    // final TextStyle smallerStyle = TextStyle(fontSize: 25, color:Theme.of(context).primaryColor);
    // final TextStyle placeStyle = TextStyle(fontSize: 25, color:Theme.of(context).accentColor);
    // nameController.addListener(()=>widget.title=nameController.text);

    return GestureDetector(
      onTap: () {}, //close?
      behavior: HitTestBehavior.opaque,
      child: Container(color: Colors.grey[900],
        child: SingleChildScrollView(scrollDirection: Axis.vertical, child: Column(children: [
            ListTile(
        title: Container(
      margin: EdgeInsets.all(2),
      color: Colors.black,
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(padding: EdgeInsets.all(15), color: Colors.black,  width: double.infinity, alignment: Alignment.center,
                        child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: Text('Set New Menu Conditions:', style: TextStyle(fontSize: 25, color: Colors.white, fontFamily: 'Lato', )))),
          Text('Title', style: tagStyle),
          TextFormField(initialValue: title,
        style: propertyStyle,
        onChanged: (value) => setState(()=>title=value),
        keyboardType: TextInputType.text,
      ),
      ]),
    )),
    ListTile(
        title: Container(
      margin: EdgeInsets.all(2),
      color: Colors.black,
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Starting Date', style: tagStyle),
                  Container(width: double.infinity, 
                    child: RaisedButton(color: Colors.black, 
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [SingleChildScrollView(scrollDirection: Axis.horizontal,child: Text(DateFormat.yMEd().format(startDate), style: propertyStyle)),
                                                  Icon(Icons.edit, color: Theme.of(context).primaryColor,)]),
                      ),
                      onPressed: ()=>showDatePicker(
            context: context,
            initialDate: startDate ,
            firstDate: DateTime.now().subtract(new Duration(days: 365)),
            lastDate: DateTime.now().add(new Duration(days: 365))
        ).then((pickedDate) {
      if (pickedDate == null) //user selected cancel
        return;
      this.setState(()=>startDate=pickedDate);
    }), //future sends a promise immedatly, then data onsubmit, it doesn't pause app like async await
    )),]),
    )),
            // EditDate(date: widget.startDate, tag: 'Starting Date', tagStyle: tagStyle, propertyStyle: propertyStyle, callBack: (pickedDate)=>this.setState(()=>widget.startDate=pickedDate),),
            EditCount(value: days, tag: 'Set Days', tagStyle: tagStyle, propertyStyle: propertyStyle, placeStyle: propertyStyle, increase: ()=>this.setState(()=>days+=1), decrease: () {if(days > 0) this.setState(()=>days-=1);},),
            EditCount(value: sections, tag: 'Set Meals per Day', tagStyle: tagStyle, propertyStyle: propertyStyle, placeStyle: propertyStyle, increase: ()=>this.setState(()=>sections+=1), decrease: () {if(sections > 0) this.setState(()=>sections-=1);},),
            EditButton(tag: 'New Menu', propertyName: 'GENERATE', icon: Icons.add_circle, tagStyle: tagStyle, propertyStyle: propertyStyle, onClick: ()=>this.generateMenu(context),)
        ]))),
    );
  }
}

 
