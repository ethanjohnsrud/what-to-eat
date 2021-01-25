import 'package:flutter/material.dart';
import 'package:mealplanning/Providers/CatalogProvider.dart';
import 'package:mealplanning/Providers/Ingredient.dart';
import 'package:mealplanning/Providers/Meal.dart';
import 'package:mealplanning/Providers/PriceRecord.dart';
import 'package:mealplanning/Providers/Settings.dart';
import 'package:mealplanning/Providers/ShoppingItem.dart';
import 'package:mealplanning/Providers/ShoppingListProvider.dart';
import 'package:provider/provider.dart';
import 'ShoppingListItemEdit.dart';


class ShoppingListItem extends StatefulWidget {
  final String itemId;
  Function addToPantryCall = () {};

  ShoppingListItem({this.itemId, this.addToPantryCall});

  @override
  _ShoppingListItemState createState() => _ShoppingListItemState();
}

class _ShoppingListItemState extends State<ShoppingListItem> {
  void initState () {
          super.initState();
          displayList = true;
          storeController.addListener(()=>this.setState(()=>store=storeController.text));
          amountController.addListener(()=>this.setState(() {amount=double.tryParse(amountController.text); if(amount == null) amount=0.0;}));
          }
 
final TextEditingController storeController = TextEditingController();
final TextEditingController amountController = TextEditingController();

  String store = '';
  double amount = 0.00;
  bool displayList = true;

  Function setScrollHeight = () {};

  @override
  Widget build(BuildContext context) {
    print('Building -> ShoppingListItem');
    // setScrollHeight != null ? setScrollHeight(item.id, 126.0) : null;
    final settings = Provider.of<Settings>(context);
    final catalogProvider = Provider.of<CatalogProvider>(context);
    final shoppingListProvider = Provider.of<ShoppingListProvider>(context);

    List<String> unitOptions = settings.pricingUnits;

    final TextStyle tagStyle = TextStyle(fontSize: 20, color:Theme.of(context).accentColor);
    final TextStyle propertyStyle = TextStyle(fontSize: 35, color:Theme.of(context).primaryColor);
    final TextStyle smallerStyle = TextStyle(fontSize: 25, color:Theme.of(context).primaryColor);

  final ShoppingItem item = shoppingListProvider.getItem(this.widget.itemId);

  final List<PriceRecord> storePrices = catalogProvider.getPriceList(id: item.referenceId);
  if(storePrices.isEmpty) displayList = false; //override for empty list of prices to add only

  void createNewPrice(){print('ShoppingListItem.createNewPrice() $store ${amount.toString()}');
  if(amount != 0.0 && store != 'Store') catalogProvider.addPriceRecord(new PriceRecord(id: item.referenceId, store: store, price: amount, unit: item.servingUnit));
  setState(() {
    store = '';
    amount = 0.00;
    storeController.clear();
    amountController.clear();
    displayList = true;
  });
  return;
}

    final Widget servingsControl = Row(children: <Widget>[IconButton(icon: Icon(Icons.remove_circle, color:Theme.of(context).primaryColor, size:30,), onPressed: () =>shoppingListProvider.decreaseItemServings(this.widget.itemId)),
                              Text('${item.servings}', style: TextStyle(fontSize: 25, color: Theme.of(context).accentColor, fontFamily: 'Lato')),
                              IconButton(icon: Icon(Icons.add_circle, color:Theme.of(context).primaryColor, size:30,), onPressed: () =>shoppingListProvider.increaseItemServings(this.widget.itemId))],);

    final Widget foundCheck =  settings.nameTags ? Column(children: [Theme(data: ThemeData(unselectedWidgetColor: Theme.of(context).primaryColor), child: Transform.scale(scale: 2, child: Checkbox(value: item.found, 
                                      onChanged: (_) {shoppingListProvider.markItemToggle(itemId: widget.itemId); if(shoppingListProvider.getItem(widget.itemId).found) widget.addToPantryCall();}, activeColor: Theme.of(context).primaryColor, checkColor: Colors.black,),
    )), Text('Aquired', style: TextStyle(fontSize: 15, color:Theme.of(context).accentColor))]) 
                                : Theme(data: ThemeData(unselectedWidgetColor: Theme.of(context).primaryColor), child: Transform.scale(scale: 2,  child: Checkbox(value: item.found,  
                                      onChanged: (_) {shoppingListProvider.markItemToggle(itemId: widget.itemId); if(shoppingListProvider.getItem(widget.itemId).found) widget.addToPantryCall();}, activeColor: Theme.of(context).primaryColor, checkColor: Colors.black,),
                                ));

    final int countNeeded = ((item.servings-catalogProvider.getPantryQuantity(item.referenceId))/catalogProvider.getServingsPerUnit(type: item.referenceType, id: item.referenceId, unit: item.servingUnit)).ceil();
    final Widget buy = Text(countNeeded > 0 ? '+ ${countNeeded.toStringAsFixed(0)}' : 'X', style: TextStyle(fontSize: 25, color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Lato'));
    final Widget buyCount = settings.nameTags ? Column(children: <Widget>[Text(item.servingUnit!=null ? item.servingUnit : 'Package', style: TextStyle(fontSize: 15, color:Theme.of(context).accentColor)), buy, ],) : buy;

    final Widget cost = Text('\$${item.unitPrice.toStringAsFixed(2)}', style: TextStyle(fontSize: 20, color: Colors.white, fontFamily: 'Lato'));
    final Widget packageCost = settings.nameTags ? Column(children: <Widget>[cost, Text('Per ${item.servingUnit}', style: TextStyle(fontSize: 15, color:Theme.of(context).accentColor))],)  : cost;

    //Price Portion
    final Widget priceToggleButton = Icon(displayList ? Icons.add_circle_outline : Icons.clear_all, color: Theme.of(context).primaryColor, size: 25,);
    final Widget addCollection = settings.nameTags ? Column(children: <Widget>[
        priceToggleButton,
        Text(displayList ? 'New' : 'List', style: TextStyle(fontSize: 15, color:Theme.of(context).accentColor))],) : priceToggleButton;
    final Widget toggleEnd =  GestureDetector(child: Row(children: [VerticalDivider(color: Colors.grey,),addCollection]),  onTap: ()=>this.setState(() {displayList=!displayList;})); 

    final Widget displayStorePrices =  Expanded(child: ListView.builder(scrollDirection: Axis.horizontal, itemCount: storePrices.length, 
                                itemBuilder: (context, index) => Container(margin: EdgeInsets.symmetric(horizontal: 5), child: Column(children: [
                                      Text('\$${storePrices[index].price.toStringAsFixed(2)}', style: TextStyle(fontSize: 15, color: Theme.of(context).primaryColor,  fontFamily: 'Lato')),
                                      Text('${storePrices[index].store} [${storePrices[index].unit}]', style: TextStyle(fontSize: 15, color:Theme.of(context).accentColor)),
                                      // Text('[${storePrices[index].unit}]', style: TextStyle(fontSize: 10, color:Theme.of(context).accentColor)),
                                  ]),
                                )));

    final Widget unitSlider = 
    // Transform.scale( scale: 1, //go vertical??
            // child: 
            SizedBox( height: 20, width: 325,
                          child: SliderTheme(
      data: SliderTheme.of(context).copyWith(
        trackShape: RoundedRectSliderTrackShape(),
        trackHeight: 1.0,
        // thumbShape: RoundSliderThumbShape(enabledThumbRadius: 12.0),
        tickMarkShape: RoundSliderTickMarkShape(),
        valueIndicatorShape: PaddleSliderValueIndicatorShape(),
        valueIndicatorTextStyle: TextStyle(
          color: Colors.black, fontSize: 15,
        ),
      ),
      child: 
      Slider(
              value: unitOptions.contains(item.servingUnit) ? unitOptions.indexOf(item.servingUnit).toDouble() : 0.0, 
              onChanged: (newValue) {shoppingListProvider.setItemPriceUnit(itemId: widget.itemId, unit: unitOptions[newValue.toInt()]); shoppingListProvider.setItemUnitPrice(itemId: widget.itemId, price: (catalogProvider.getCalculatedAveragePerServingCost(item.referenceId, type: item.referenceType, unit: unitOptions[newValue.toInt()]) * (item.referenceType == Meal ? catalogProvider.getMeal(item.referenceId).servingsPerUnit.putIfAbsent(unitOptions[newValue.toInt()], () => 1.0) : item.referenceType == Ingredient ?  catalogProvider.getIngredient(item.referenceId).servingsPerUnit.putIfAbsent(unitOptions[newValue.toInt()], () => 1.0) : 1.0)));},
              activeColor: Theme.of(context).primaryColor,
              inactiveColor: Colors.grey[900],
              divisions: unitOptions.isNotEmpty ? (unitOptions.length-1) : 0,
              min: 0.0,
              max:  unitOptions.isNotEmpty ? (unitOptions.length-1).toDouble() : 0.0,
              label: settings.nameTags ? 'Units: ${item.servingUnit}' : item.servingUnit,
              ),),
            // ),
          );

    final Widget displayAddPrice = Expanded(
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [ Expanded(
                child: TextField(
                        controller: storeController,
                        keyboardType: TextInputType.text,
                        style: smallerStyle,
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          hintText: 'Store',
                          hintStyle: TextStyle(fontSize: 20, color: Colors.white, fontFamily: 'Lato', ),       
                          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).primaryColor)),  
                        ),
                ),
              ),
                          Container(
                              width: 125,
                            child: Row(children: [Text('\$ ', style: smallerStyle),
                                    Expanded(
                                      child: TextField(
                                        controller: amountController,
                                        keyboardType: TextInputType.number,
                                        style: smallerStyle,
                                        decoration: InputDecoration(
                                        hintText: 'Price',
                                        hintStyle: TextStyle(fontSize: 20, color: Colors.white, fontFamily: 'Lato', ),        
                                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).primaryColor)),  
                                        ),
                              )
                                    ),
                                    ])),
                          IconButton(icon: Icon(Icons.add_circle_outline), color: Theme.of(context).primaryColor, iconSize: 30, onPressed: ()=>createNewPrice())
                          ]),
      );

    return Dismissible(key: ValueKey(widget.itemId),
            direction: DismissDirection.horizontal,
            confirmDismiss: (direction) { 
              if(direction == DismissDirection.startToEnd) {shoppingListProvider.markItemToggle(itemId: widget.itemId); if(shoppingListProvider.getItem(widget.itemId).found) widget.addToPantryCall();}
              else {shoppingListProvider.removeItem(widget.itemId);}
            },
            background: Container(alignment: Alignment.centerLeft,
              margin: EdgeInsets.symmetric(vertical: 15, horizontal: 5),
              child: Icon(Icons.check, color:Colors.blue[900], size:40,),
            ),
            secondaryBackground:  Container(alignment: Alignment.centerRight,
              margin: EdgeInsets.symmetric(vertical: 15, horizontal: 5),
              child: Icon(Icons.delete, color:Colors.red[900], size:40,),
            ),
    child: GestureDetector(
        onTap: () {showShoppingListItemEdit(context: context, itemId: widget.itemId, onExitUpdate: () {});
      },
        child: Card (
          elevation: 3,
          color: item.found ? Colors.grey[900] : Colors.black,
          shadowColor: Colors.white24,
          margin: EdgeInsets.only(top: 3, bottom: 3),
            child: Padding(padding: EdgeInsets.all(10),
              child: Column( children: [Row(children: [
                  Column(children: [
                    settings.nameTags ? Column(children: [Text('Servings', style: TextStyle(fontSize: 15, color:Theme.of(context).accentColor)), servingsControl, ]) : servingsControl,
                    packageCost]),
                  Expanded(child: Container(margin: EdgeInsets.symmetric(horizontal: 15),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                        SingleChildScrollView(scrollDirection: Axis.horizontal, child: Text(item.description, style: TextStyle(fontSize: 20, color: Colors.white, fontFamily: 'Lato', ))),
                        SingleChildScrollView(scrollDirection: Axis.horizontal, child: Text(item.name, style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 27, fontFamily: 'OpenSans', fontWeight: FontWeight.w700))),
                        Text('Pantry: ${catalogProvider.getPantryQuantity(item.referenceId).toStringAsFixed(0)}', style: TextStyle(fontSize: 18, color: Theme.of(context).accentColor, fontFamily: 'Lato')),
                      ]),
                  ),
                  ),
                  Column(children: [
                    buyCount,
                    foundCheck,
                  ]),
                  ]
                  ),
                  unitSlider,
                  (item.referenceId != null && item.referenceId != '') ? Container(height: 45,
                     child: Row(children: [
                       displayList ? displayStorePrices : displayAddPrice,
                       toggleEnd                    
                    ]),
                  ) : SizedBox(height: 1),
                  ]
              ),
            )
            ),
      ),
    );
  }
}