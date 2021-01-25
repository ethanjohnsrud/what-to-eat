import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mealplanning/Providers/Ingredient.dart';
import 'package:mealplanning/Providers/Meal.dart';
import 'package:mealplanning/Providers/PriceRecord.dart';
import 'package:mealplanning/Providers/ShoppingItem.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'Providers/MenuProvider.dart';
import 'Providers/PantryItem.dart';

// class LocalStorage {
  Future<String> get localPath async {
    final Directory appDocDirectory = await getApplicationDocumentsDirectory();

Directory directory;
// print('Path ofgetApplicationDocumentsDirectory: '+appDocDirectory.path);
await new Directory(appDocDirectory.path+'/'+'dir').create(recursive: true)
// The created directory is returned as a Future.
    .then((Directory dir) {
  directory = dir;
});
// print(directory.listSync(recursive: true));
    return directory.path;
  }

  void deleteAppStorage() async {
    try {
      var tempDir = (await getTemporaryDirectory()).path;
      new Directory(tempDir).delete(recursive: true);
      var storageDir = (await getApplicationDocumentsDirectory()).path;
      new Directory(storageDir).delete(recursive: true);
    } catch(e){
      print('ERROR :: Failed to Delete App Storage');
      print(e);
    } return;
  }

  Future<File> getFile(String fileName) async {
    final path = await localPath;
    return new File('$path/$fileName').create(recursive: true);
  }

  Future<File> getImageFile(String id) async {
    // print('getImageFile()');
    final path = await localPath;
    // print('Testing File :: $path/$id.jpg');
    // print('Result => ${new File('$path/$id.jpg').existsSync()}');
    if(new File('$path/$id.jpg').existsSync())
      return new File('$path/$id.jpg').create(recursive: true);
    else
      return null;
  }

  Future<File> writeImageFile(String id, File file) async {
    print('writeImageFile()');
    if(file == null) return null;
    final path = await localPath;
    Map<Permission, PermissionStatus> statuses = await 
        [Permission.storage,].request();
    if (await Permission.storage.request().isGranted) {
      try {/// Different Directory ->, copy the source file and then delete it
        File origionalFile = File('$path/$id.jpg');
          if(origionalFile.existsSync()) {
              origionalFile.delete(recursive: true);
            } else print('=> new file');

        File newFile = await file.copy('$path/$id.jpg');
        await file.delete();
        print('Returning :: ${newFile.toString()}');
        return newFile;
      } catch (e) {
        print('writeImageFile()-Copy Failed, returning null');
        print(e);
        return null;
      }
    } else  {print('Read Permission :: writeImageFile() => denied');
              openAppSettings();
      }
  }

Future<Map<String, PantryItem>> readPantry() async {
    Map<Permission, PermissionStatus> statuses = await [Permission.storage,].request();
    if (await Permission.storage.request().isGranted) {
      try {
        final File file = await getFile('pantry.txt');
        // Read the file
        final dataJson = await file.readAsString();
        // print(dataJson);
        final data = json.decode(dataJson);
        // print('DECODE JSON File :: pantry');
        // print(data.toString());
        // print(data.map((i)=>PantryItem.fromJson(i)).toList());
        List<PantryItem> list = data.map<PantryItem>((i)=>PantryItem.fromJson(i)).toList();
        return Map<String, PantryItem>.fromIterable(list, key: (v) => v.id, value: (v) => v);
      } catch (e) {// If encountering an error, return 0
      print('File Reading Error :: readPantry()');
      print(e.toString());
        return {};
      }
    } else {print('Read Permission :: readPantry() => denied');
      openAppSettings();
        }
  }

  void writePantry(Map<String, PantryItem> pantry) async {
    final File file = await getFile('pantry.txt');
    final List<PantryItem> list = pantry.values.toList();
    final listJson = jsonEncode(list);
    // print('ENCONDED JSON :: pantry');
    // print(listJson);
    Map<Permission, PermissionStatus> statuses = await 
        [Permission.storage,].request();
    if (await Permission.storage.request().isGranted) {
      // print('Write Permission :: granted');
        file.writeAsString(listJson);    
      }
      else  {print('Read Permission :: writePantry() => denied');
          openAppSettings();
        }
  }

  Future<Map<String, Meal>> readMeals() async {
     Map<Permission, PermissionStatus> statuses = await [Permission.storage,].request();
    if (await Permission.storage.request().isGranted) {
      try {
        final File file = await getFile('meals.txt');
        // Read the file
        final dataJson = await file.readAsString();
        // print(dataJson);
        final data = json.decode(dataJson);
        // print('DECODE JSON File :: meals');
        // print(data.toString());
        // print(data.map((i)=>Meal.fromJson(i)).toList());
        List<Meal> list = data.map<Meal>((i)=>Meal.fromJson(i)).toList();
        return Map<String, Meal>.fromIterable(list, key: (v) => v.id, value: (v) => v);
      } catch (e) {// If encountering an error, return 0
      print('File Reading Error :: readMeals()');
      print(e.toString());
        return {};
      }
    } else {print('Read Permission :: readMeals() => denied');
      openAppSettings();
        }
  }

  void writeMeals(Map<String, Meal> meals) async {
    final File file = await getFile('meals.txt');
    final List<Meal> list = meals.values.toList();
    final listJson = jsonEncode(list);
    // print('ENCONDED JSON :: pantry');
    // print(listJson);
    Map<Permission, PermissionStatus> statuses = await 
        [Permission.storage,].request();
    if (await Permission.storage.request().isGranted) {
      // print('Write Permission :: granted');
        file.writeAsString(listJson);    
      }
      else  {print('Read Permission :: writeMeals() => denied');
                openAppSettings();
        }
  }


  Future<Map<String, Ingredient>> readIngredients() async {
    Map<Permission, PermissionStatus> statuses = await [Permission.storage,].request();
    if (await Permission.storage.request().isGranted) {
      try {
        final File file = await getFile('ingredients.txt');
        // Read the file
        final dataJson = await file.readAsString();
        // print(dataJson);
        final data = json.decode(dataJson);
        // print('DECODE JSON File :: ingredients');
        // print(data.toString());
        // print(data.map((i)=>Ingredient.fromJson(i)).toList());
        List<Ingredient> list = data.map<Ingredient>((i)=>Ingredient.fromJson(i)).toList();
        return Map<String, Ingredient>.fromIterable(list, key: (v) => v.id, value: (v) => v);
      } catch (e) {// If encountering an error, return 0
      print('File Reading Error :: readIngredients()');
      print(e.toString());
        return {};
      }
    } else {print('Read Permission :: readIngredients() => denied');
      openAppSettings();
        }
  }

  void writeIngredients(Map<String, Ingredient> ingredients) async {
    final File file = await getFile('ingredients.txt');
    final List<Ingredient> list = ingredients.values.toList();
    final listJson = jsonEncode(list);
    // print('ENCONDED JSON :: ingredients');
    // print(listJson);
    // Map<Permission, PermissionStatus> statuses = await 
        [Permission.storage,].request();
    if (await Permission.storage.request().isGranted) {
      // print('Write Permission :: granted');
        file.writeAsString(listJson);    
      }
      else  {print('Read Permission :: writeIngredients() => denied');
        openAppSettings();
        }
  }
   Future<Map<String, List<PriceRecord>>> readPrices() async {
    Map<Permission, PermissionStatus> statuses = await [Permission.storage,].request();
    if (await Permission.storage.request().isGranted) {
      try {
        final File file = await getFile('prices.txt');
        // Read the file
        final dataJson = await file.readAsString();
        // print(dataJson);
        final data = json.decode(dataJson);
        // print('DECODE JSON File :: prices');
        // print(data.toString());
        // print(data.map((i)=>PriceRecord.fromJson(i)).toList());
        List<PriceRecord> list = data.map<PriceRecord>((i)=>PriceRecord.fromJson(i)).toList();
        Map<String, List<PriceRecord>> prices = {};
        list.forEach((v) {if(prices.containsKey(v.id)) prices[v.id].add(v);  else prices.addAll({v.id: [v]});});
        return prices;
      } catch (e) {// If encountering an error, return 0
      print('File Reading Error :: readPrices()');
      print(e.toString());
        return {};
      }
    } else {print('Read Permission :: readPrices() => denied');
      openAppSettings();
        }
  }

  void writePrices(Map<String, List<PriceRecord>> prices) async {
    final File file = await getFile('prices.txt');
    final List<PriceRecord> list = [];
      prices.values.toList().forEach((v)=>list.addAll(v));
    final listJson = jsonEncode(list);
    // print('ENCONDED JSON :: ingredients');
    // print(listJson);
    // Map<Permission, PermissionStatus> statuses = await 
        [Permission.storage,].request();
    if (await Permission.storage.request().isGranted) {
      // print('Write Permission :: granted');
        file.writeAsString(listJson);    
      }
      else  {print('Read Permission :: writePrices() => denied');
        openAppSettings();
        }
  }
  Future<Map<String, ShoppingItem>> readShoppingList() async {
    Map<Permission, PermissionStatus> statuses = await [Permission.storage,].request();
    if (await Permission.storage.request().isGranted) {
      try {
        final File file = await getFile('shoppingList.txt');
        // Read the file
        final dataJson = await file.readAsString();
        // print(dataJson);
        final data = json.decode(dataJson);
        // print('D map((i)=>ShoppingItem.fromJson(i)).toList());
        List<ShoppingItem> list = data.map<ShoppingItem>((i)=>ShoppingItem.fromJson(i)).toList();
        return Map<String, ShoppingItem>.fromIterable(list, key: (v) => v.id, value: (v) => v);
      } catch (e) {
      print('File Reading Error :: readShoppingList()');
      print(e.toString());
        return {};
      }
    } else {print('Read Permission :: readShoppingList() => denied');
      openAppSettings();
        }
  }

  void writeShoppingList(Map<String, ShoppingItem> shoppingList) async {
    final File file = await getFile('shoppingList.txt');
    final List<ShoppingItem> list = shoppingList.values.toList();
    final listJson = jsonEncode(list);
    // print('ENCONDED JSON :: shoppingList');
    // print(listJson);
    Map<Permission, PermissionStatus> statuses = await 
        [Permission.storage,].request();
    if (await Permission.storage.request().isGranted) {
      // print('Write Permission :: granted');
        file.writeAsString(listJson);    
      }
      else  {print('Read Permission :: writeShoppingList() => denied');
        openAppSettings();
        }
  }
   Future<Map<String, Menu>> readMenuList() async {
    Map<Permission, PermissionStatus> statuses = await [Permission.storage,].request();
    if (await Permission.storage.request().isGranted) {
      try {
        final File file = await getFile('menuList.txt');
        // Read the file
        final dataJson = await file.readAsString();
        // print(dataJson);
        final data = json.decode(dataJson);
        // print('DECODE JSON File :: menuList');
        // print(data.toString());
        // print(data.map((i)=>Menu.fromJson(i)).toList());
        List<Menu> list = data.map<Menu>((i)=>Menu.fromJson(i)).toList();
        return Map<String, Menu>.fromIterable(list, key: (v) => v.id, value: (v) => v);
      } catch (e) {
      print('File Reading Error :: readMenuList()');
      print(e.toString());
        return {};
      }
    } else {print('Read Permission :: readMenuList() => denied');
      openAppSettings();
        }
  }

  void writeMenuList(Map<String, Menu> menuList) async {
    // final List<Menu> menuList = menuMap.entries.map((e) => e.value).toList();
    final File file = await getFile('menuList.txt');
    final List<Menu> list = menuList.values.toList();
    final listJson = jsonEncode(list);
    // print('ENCONDED JSON :: menuList');
    // print(listJson);
    Map<Permission, PermissionStatus> statuses = await 
        [Permission.storage,].request();
    if (await Permission.storage.request().isGranted) {
      // print('Write Permission :: granted');
        file.writeAsString(listJson);    
      }
      else  {print('Read Permission :: writeMenuList() => denied');
        openAppSettings();
        }
  }
        // void writeMenuList(List<Menu> menuList) async {
        //   // final List<Menu> menuList = menuMap.entries.map((e) => e.value).toList();
        //   final File file = await getFile('menuList.txt');
        //   final listJson = jsonEncode(menuList);
        //   // print('ENCONDED JSON :: menuList');
        //   // print(listJson);
        //   Map<Permission, PermissionStatus> statuses = await 
        //       [Permission.storage,].request();
        //   if (await Permission.storage.request().isGranted) {
        //     // print('Write Permission :: granted');
        //       file.writeAsString(listJson);    
        //     }
        //     else  {print('Read Permission :: writeMenuList() => denied');
        //       openAppSettings();
        //       }
        // }
  Future<Map<String, dynamic>> readSettings() async {
    print('readSettings() - called');
    Map<Permission, PermissionStatus> statuses = await [Permission.storage,].request();
    if (await Permission.storage.request().isGranted) {
      try {
        final File file = await getFile('settingsData.txt');
        // Read the file
        final dataJson = await file.readAsString();
        print(dataJson.toString());
        final data = json.decode(dataJson);
        print(data.toString());
        return data;
      } catch (e) {
      print('File Reading Error :: readSettings()');
      print(e.toString());
        return null;
      }
    } else {print('Read Permission :: readSettings() => denied');
      openAppSettings();
        }
  }

  void writeSettings(Map<String, dynamic> jsonData) async {
    print('writeSettings() - called');
    final File file = await getFile('settingsData.txt');
    print(jsonData.toString());
    final encodedJson = jsonEncode(jsonData);
    print(encodedJson.toString());
    Map<Permission, PermissionStatus> statuses = await 
        [Permission.storage,].request();
    if (await Permission.storage.request().isGranted) {
      // print('Write Permission :: granted');
        file.writeAsString(encodedJson);    
      }
      else  {print('Read Permission :: writeSettings() => denied');
        openAppSettings();
        }
  }
// }