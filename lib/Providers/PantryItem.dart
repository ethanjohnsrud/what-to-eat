import 'package:flutter/foundation.dart';

import 'Ingredient.dart';
import 'Meal.dart';

class PantryItem {
  final String id;
  String name;
  String referenceId;
  Type referenceType;
  String description='';

  int quantity = 1;
  DateTime expirationDate;

  // double servingsPerPackage = 1.0;
  // double packagePrice = 0.0;

  PantryItem({
    @required this.id,
    @required this.name,
    this.referenceId = '',
    this.referenceType = Ingredient,
    this.description = '',
    this.quantity = 1,
    // this.servingsPerPackage = 1.0,
    // this.packagePrice = 0.0,
    this.expirationDate,
    }) {if(this.expirationDate == null) this.expirationDate = DateTime.now().add(new Duration(days: 15));}

  // double get cost {
  //   try{double c = 0.0;
  //   if((this.packagePrice/this.servingsPerPackage)>0.0) return c=this.packagePrice/this.servingsPerPackage;
  //     return c;}
  //   catch(error) {return 0.0;}
  // }

    Map<String, dynamic> toJson() {
      
      return {
        'id' : this.id,
        'name' : this.name,
        'referenceId' : this.referenceId,
        'referenceType' : this.referenceType.toString(),
        'description' : this.description,
        'quantity' : this.quantity.toString(),
        // 'servingsPerPackage' : this.servingsPerPackage.toString(),
        // 'packagePrice' : this.packagePrice.toString(),
        'expirationDate' : this.expirationDate.toString(),
      };
    }
    factory PantryItem.fromJson(Map<String, dynamic> json) {
      
      return new PantryItem(
        id:  json['id'], 
        name: json['name'],
        referenceId: json['referenceId'],
        referenceType: (json['referenceId'] == 'Meal') ? Meal : Ingredient,
        description: json['description'],
        quantity: int.parse(json['quantity']),
        // servingsPerPackage: double.parse(json['servingsPerPackage']),
        // packagePrice: double.parse(json['packagePrice']), 
        expirationDate: DateTime.parse(json['expirationDate']),
        );
    }
}


// class PantryItemProvider with ChangeNotifier {
//   void setPantryItemReferenceType(PantryItem item, Type type) {item.referenceType=type; notifyListeners(); LocalStorage().writePantry(pantry);} 
//   void setPantryItemName(PantryItem item, String name) {item.name=name; }
//   void setPantryItemReferenceID(PantryItem item, String id, {String name, double servings = 1.0, double price = 0.0,}) {item.referenceId=id; if(name!= null) item.name = name;
//         item.servingsPerPackage = servings; item.packagePrice = price; notifyListeners();}
//   void setPantryItemAdjective(PantryItem item, String adjective) {item.description=adjective; }
//   void setPantryItemExpirationDate(PantryItem item, DateTime date) {item.expirationDate=date; notifyListeners();}
//   void increasePantryItemQuantity(PantryItem item) {item.quantity +=1; notifyListeners();}
//   void decreasePantryItemQuantity(PantryItem item) {if(item.quantity!=1) item.quantity -=1; notifyListeners();}
//   void setPantryItemServingsPerPackage(PantryItem item, double servings) {item.servingsPerPackage=servings; }
//   void setPantryItemPackagePrice(PantryItem item, double price) {item.packagePrice=price; }
// }

