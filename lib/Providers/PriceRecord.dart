import 'dart:convert';

class PriceRecord {
  double price;
  String store;
  String id;
  String unit;

  PriceRecord({this.id, this.store = 'Store', this.price = 0.0, this.unit = 'Package'});

  Map toJson(){

    return {
      'id' : this.id,
      'store' : this.store,
      'price' : this.price,
      'unit' : this.unit,
    };
  }

  factory PriceRecord.fromJson(Map<String, dynamic> json) {

      return new PriceRecord(
        id:  json['id'], 
        store: json['store'],
        price: double.parse(json['price']),
        unit: json['unit'],
      );
  }  
}