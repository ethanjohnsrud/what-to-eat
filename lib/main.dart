import 'package:flutter/material.dart';
import 'package:mealplanning/Providers/Ingredient.dart';
import 'package:mealplanning/Providers/Settings.dart';
import 'package:mealplanning/Providers/ShoppingListProvider.dart';
import 'package:mealplanning/Widgets/Menu/MenuDisplay.dart';
// import 'package:mealplanning/Widgets/Menu/SingleMealDisplay.dart';
import 'package:mealplanning/Widgets/ShoppingList/ShoppingListDisplay.dart';
import 'package:provider/provider.dart';
import 'Providers/CatalogProvider.dart';
import 'Providers/SingleMealProvider.dart';
import 'Providers/Meal.dart';
import 'Providers/MenuProvider.dart';
import 'Providers/PantryItem.dart';
import 'Widgets/Catalog/Catalog.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized(); //Issue arrose when added multithreading with compute() https://stackoverflow.com/questions/57689492/flutter-unhandled-exception-servicesbinding-defaultbinarymessenger-was-accesse
  runApp(MealPlanning());
}

class MealPlanning extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => Settings(), //returns new instance
        ),
        ChangeNotifierProvider(
          create: (context) => CatalogProvider(), //returns new instance
        ),
        ChangeNotifierProvider(
          create: (context) => MenuProvider(), //returns new instance
        ),
        ChangeNotifierProvider(
          create: (context) => ShoppingListProvider(), //returns new instance
        ),
        ChangeNotifierProvider(
          create: (context) => SingleMealProvider(), //returns new instance
        ),
      ],
      child: MaterialApp(
          title: 'Meal Planning',
          theme: ThemeData(
              primaryColor: Colors.amber[600],
              accentColor: Colors.blue[900],
              backgroundColor: Colors.black,
              fontFamily: 'OpenSans',
              // appBarTheme: AppBarTheme(
              //     textTheme: ThemeData.light().textTheme.copyWith(
              //         title: TextStyle(fontFamily: 'OpenSans', fontSize: 22),
              //         button: TextStyle(color: Colors.white)))
              ),
          home: MenuDisplay(),
          routes: {
            Catalog.routeName: (context) => Catalog(displayType: Meal,),
            MenuDisplay.routeName: (context) => MenuDisplay(),
            ShoppingListDisplay.routeName: (context) => ShoppingListDisplay(),
            // SingleMealDisplay.routeName: (context) => SingleMealDisplay(),
          }),
    );
  }
}
