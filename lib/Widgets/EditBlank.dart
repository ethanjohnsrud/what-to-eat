import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mealplanning/Providers/CatalogProvider.dart';
import 'package:mealplanning/Providers/Ingredient.dart';
import 'package:mealplanning/Providers/Meal.dart';
import 'package:mealplanning/Providers/PantryItem.dart';
import 'package:mealplanning/Providers/PriceRecord.dart';
import 'package:mealplanning/Providers/Settings.dart';
import 'package:provider/provider.dart';

import '../LocalStorage.dart';
import 'Catalog/Catalog.dart';
import 'Catalog/Catalog-Edit/CatalogIngredientEdit.dart';
import 'Catalog/Catalog-Edit/CatalogMealEdit.dart';
import 'Catalog/Catalog-Edit/CatalogPantryItemEdit.dart';

class EditValue extends StatelessWidget {
  // final TextEditingController controller;
  Function onChangeCallBack = (){};
  final TextStyle tagStyle;
  final TextStyle propertyStyle;
  final String tag;
  final bool numberType;
  final bool currency;
  final value;

  EditValue({this.value, this.onChangeCallBack, this.tagStyle, this.propertyStyle, this.tag, this.numberType = false, this.currency = false});

  @override
  Widget build(BuildContext context) {

     
    return ListTile(
        title: Container(
      margin: EdgeInsets.all(2),
      color: Colors.black,
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(tag, style: tagStyle),
        // TextField(
      // decoration: InputDecoration(labelText: tag, labelStyle: tagStyle),
      // style: propertyStyle,
      // onChanged: (value) => controller(meal, value),
      // controller: controller,
      // keyboardType: this.numberType ? TextInputType.number : TextInputType.text,
      // onSubmitted: (value) => {submitData()}, //need value passed in
            // ) 
           Row(children:[Text(this.currency ? '\$ ' : '', style: propertyStyle),
                Expanded(child: TextFormField(initialValue: this.value,
          style: propertyStyle,
          onChanged: (value) => this.onChangeCallBack(value),
          keyboardType:  this.numberType ? TextInputType.number : TextInputType.text,
        ),
                ),
             ]),
        ]),
    ));
  }
}

class EditParagraph extends StatelessWidget {
  final TextStyle tagStyle;
  final TextStyle propertyStyle;
  final String tag;
  final String value;
  Function onChangeCallBack;

  EditParagraph({this.value, this.tagStyle, this.propertyStyle, this.tag, this.onChangeCallBack});
  @override
  Widget build(BuildContext context) {
    return ListTile(
        title: Container(
      margin: EdgeInsets.all(2),
      color: Colors.black,
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
      child: SizedBox(
        height: 250,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(tag, style: tagStyle),
          Expanded(
          child: SingleChildScrollView(
              child: TextFormField(initialValue: this.value,
                style: propertyStyle,
                onChanged: (value) => this.onChangeCallBack(value),
                keyboardType: TextInputType.multiline,
                maxLines: null),
          ),
          ),
          ]),
        
      ),
    ));
  }
}

class DisplayConstant extends StatelessWidget {
  final String property;
  final TextStyle tagStyle;
  final TextStyle propertyStyle;
  final String tag;

  DisplayConstant({this.property, this.tagStyle, this.propertyStyle, this.tag});
  @override
  Widget build(BuildContext context) {
    return ListTile(
        title: Container(
      margin: EdgeInsets.all(2),
      color: Colors.black,
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(tag, style: tagStyle),
          Text(property, style: propertyStyle),
      ]),
    ));
  }
}

class EditCount extends StatelessWidget {
  final int value;
  final String place;
  final TextStyle placeStyle;
  final TextStyle tagStyle;
  final TextStyle propertyStyle;
  final String tag;
  final Function increase;
  final Function decrease;
  final Function onHold;

  EditCount(
      {this.value = 0,
      this.tagStyle,
      this.propertyStyle,
      this.tag = '',
      this.increase,
      this.decrease,
      this.place = '',
      this.placeStyle,
      this.onHold});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 6, horizontal: 20),
      color: Colors.black,
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(tag, style: tagStyle),
        ListTile(
          title:
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            Text(
              value.toString(),
              style: propertyStyle,
            ),
            Text(
              place,
              style: placeStyle,
            )
          ]),
          leading: IconButton(
            icon: Icon(Icons.remove_circle),
            onPressed: () => decrease(),
            color: Colors.grey[300],
            iconSize: 35,
          ),
          trailing: IconButton(
            icon: Icon(Icons.add_circle),
            onPressed: () {increase();},
            color: Colors.grey[300],
            iconSize: 35,
          ),
          onLongPress: () {if(this.onHold != null) this.onHold();},
        ),
      ]),
    );
  }
}

class EditBinary extends StatelessWidget {
  final bool value;
  final String trueProperty;
  final TextStyle tagStyle;
  final TextStyle propertyStyle;
  final String tag;
  final Function toggle;

  EditBinary(
      {this.value,
      this.tagStyle,
      this.propertyStyle,
      this.tag,
      this.toggle,
      this.trueProperty,
      });
  @override
  Widget build(BuildContext context) {
    final String text = value ? trueProperty : '';
    return Container(
      margin: EdgeInsets.symmetric(vertical: 6, horizontal: 20),
      color: Colors.black,
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(tag, style: tagStyle),
        ListTile(
          title:Text(
              text,
              style: propertyStyle,
            ),
          trailing: Transform.scale( scale: 1.4,
            child: Switch(value: value, 
            onChanged: (_)=>toggle(),
            activeColor: Theme.of(context).primaryColor,
            inactiveThumbColor: Colors.grey[300],
            ),
          ),
        ),
      ]),
    );
  }
}

class EditAdvanceAction extends StatefulWidget {
  final TextStyle tagStyle;
  final String tag;
  final String warning;
  final Function action;
  EditAdvanceAction({this.tagStyle, this.tag,this.action, this.warning,});
  @override
  _EditAdvanceActionState createState() => _EditAdvanceActionState();
}

class _EditAdvanceActionState extends State<EditAdvanceAction> {

  _EditAdvanceActionState();
  bool allowed = false;
  @override
  Widget build(BuildContext context) {
    final String text = allowed ? widget.warning : '';
    return Container(
      margin: EdgeInsets.symmetric(vertical: 6, horizontal: 20),
      color: Colors.black,
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(widget.tag, style: widget.tagStyle),
        ListTile(
          title:RaisedButton(onPressed: () {if(allowed){this.widget.action();}}, child: Text(text, style: TextStyle(fontSize: 30, color: Colors.black, fontFamily: 'Lato', fontWeight: FontWeight.bold)), color: allowed ? Colors.redAccent[700] : Colors.black),
          trailing: Transform.scale( scale: 1.4,
            child: Switch(value: this.allowed, 
            onChanged: (_) {this.setState(()=>this.allowed = !allowed);},
            activeColor: Theme.of(context).primaryColor,
            inactiveThumbColor: Colors.grey[300],
            ),
          ),
        ),
      ]),
    );
  }
}

class EditButton extends StatelessWidget {
  final TextStyle tagStyle;
  final TextStyle propertyStyle;
  final String propertyName;
  final String tag;
  final Function onClick;
  final IconData icon;

  EditButton({this.tagStyle, this.propertyStyle, this.tag, this.onClick, this.propertyName, this.icon = Icons.radio_button_checked});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 6, horizontal: 20),
      color: Colors.black,
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(tag, style: tagStyle),
        ListTile(
          title: OutlineButton(child: Text(propertyName, style: propertyStyle), onPressed: onClick, splashColor: Colors.white24, borderSide: BorderSide(color: Theme.of(context).primaryColor, ),), 
          trailing: Icon(icon, color: Theme.of(context).primaryColor, size: 35,),
          onTap: onClick,
        ),
      ]),
    );
  }
}

class EditDate extends StatelessWidget {
  final TextStyle propertyStyle;
  final TextStyle tagStyle;
  final String tag;
  final DateTime date;
  Function callBack = () {};

  EditDate({this.tagStyle, this.propertyStyle, this.date, this.callBack, this.tag = 'Date'});
  @override
  Widget build(BuildContext context) {
    return ListTile(
        title: Container(
      margin: EdgeInsets.all(2),
      color: Colors.black,
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(tag, style: tagStyle),
                  Container(width: double.infinity, 
                    child: RaisedButton(color: Colors.black, 
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          // Icon(Icons.edit, color: Theme.of(context).primaryColor,),
                                                Expanded(child: SingleChildScrollView(scrollDirection: Axis.horizontal,child: Text((this.date == null) ? '' : DateFormat.yMEd().format(this.date), style: propertyStyle))),
                                                  Container( 
                                                    height: 80,
                                                    width: 80,
                                                    child: GridView.count(
                                                        crossAxisCount: 2,
                                                        // padding: EdgeInsets.all(3.0),
                                                        // childAspectRatio: 8.0 / 9.0,
                                                        children: [
                                                          Container(margin: EdgeInsets.all(3), child: OutlineButton(child: Text('M', style: TextStyle(fontSize: 18, color:Theme.of(context).primaryColor)), onPressed: ()=>callBack(DateTime.now().add(new Duration(days: 30))), splashColor: Colors.white24, borderSide: BorderSide(color: Theme.of(context).primaryColor, ),)),
                                                          Container(margin: EdgeInsets.all(3), child:  OutlineButton(child: Text('3', style: TextStyle(fontSize: 18, color:Theme.of(context).primaryColor)), onPressed: ()=>callBack(DateTime.now().add(new Duration(days: 91))), splashColor: Colors.white24, borderSide: BorderSide(color: Theme.of(context).primaryColor, ),)),
                                                          Container(margin: EdgeInsets.all(3), child:  OutlineButton(child: Text('6', style: TextStyle(fontSize: 18, color:Theme.of(context).primaryColor)), onPressed: ()=>callBack(DateTime.now().add(new Duration(days: 182))), splashColor: Colors.white24, borderSide: BorderSide(color: Theme.of(context).primaryColor, ),)),
                                                          Container(margin: EdgeInsets.all(3), child:  OutlineButton(child: Text('Y', style: TextStyle(fontSize: 18, color:Theme.of(context).primaryColor)), onPressed: ()=>callBack(DateTime.now().add(new Duration(days: 365))), splashColor: Colors.white24, borderSide: BorderSide(color: Theme.of(context).primaryColor, ),)),
                                                        ]
                                                            // .map((Item) => OutlineButton(child: Text(propertyName, style: propertyStyle), onPressed: onClick, splashColor: Colors.white24, borderSide: BorderSide(color: Theme.of(context).primaryColor, ),), ).toList(),
                                                      ),
                                                  )
                                                  ]),
                      ),
                      onPressed: ()=>showDatePicker(
            context: context,
            initialDate: date == null ? DateTime.now().add(new Duration(days: 30)) : date,
            firstDate: DateTime.now().subtract(new Duration(days: 365)),
            lastDate: DateTime.now().add(new Duration(days: 365)), 
        ).then((pickedDate) {
      if (pickedDate == null) //user selected cancel
        return;
      return callBack(pickedDate);
    }), //future sends a promise immedatly, then data onsubmit, it doesn't pause app like async await
    )),]),
    ));
  }
}

class EditReferenceType extends StatelessWidget {
  final Type type;
  final TextStyle tagStyle;
  final TextStyle propertyStyle;
  final String tag;
  List<Type> options = [];
  List<String> optionNames = [];
  Function callBack = () {};

  EditReferenceType(
      {this.type,
      this.tag,
      this.tagStyle,
      this.propertyStyle,
      this.callBack,
      this.options,
      this.optionNames
      });
      get optionPlace{
        if(options==null || options.isEmpty) return 0;
        for(var i=0; i<options.length;i++){ if(this.type == options[i]) return i;}
      }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 6, horizontal: 20),
      color: Colors.black,
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(tag, style: tagStyle),
        ListTile(
          title:SingleChildScrollView(scrollDirection: Axis.horizontal,
            child: Text(
                this.optionNames[this.optionPlace],
                style: propertyStyle,
              ),
          ),
          trailing: Transform.scale( scale: 1.4,
            child: SizedBox(width: 100,
                          child: Slider(
                            value: this.optionPlace.toDouble(), 
              onChanged: (newValue) {callBack(options[newValue.toInt()]); this.build(context);},
              activeColor: Theme.of(context).primaryColor,
              inactiveColor: Colors.grey[900],
              divisions: options.length,
              min: 0,
              max: this.options.length.toDouble()-1,
              label: this.optionNames[this.optionPlace],
              
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

class EditSliderStringOptions extends StatelessWidget {
  final String selection;
  final TextStyle tagStyle;
  final TextStyle propertyStyle;
  final String tag;
  List<String> options = [];
  Function callBack = () {};

  EditSliderStringOptions(
      {this.selection,
      this.tag,
      this.tagStyle,
      this.propertyStyle,
      this.callBack,
      this.options,
      });
      get optionPlace{
        if(options==null || options.isEmpty) return 0;
        for(var i=0; i<options.length;i++){ if(this.selection == options[i]) return i;}
      }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 6, horizontal: 20),
      color: Colors.black,
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(tag, style: tagStyle),
        ListTile(
          title:SingleChildScrollView(scrollDirection: Axis.horizontal,
            child: Text(
                this.selection,
                style: propertyStyle,
              ),
          ),
          trailing: Transform.scale( scale: 1.4,
            child: SizedBox(width: 100,
                          child: Slider(
                            value: this.optionPlace.toDouble(), 
              onChanged: (newValue) {callBack(options[newValue.toInt()]); this.build(context);},
              activeColor: Theme.of(context).primaryColor,
              inactiveColor: Colors.grey[900],
              min: 0,
              max: this.options.length.toDouble()-1,
              label: this.selection,              
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

class EditGetReferenceID extends StatelessWidget {
  final TextStyle propertyStyle;
  final TextStyle tagStyle;
  final Type type;
  final String id;
  List<Type> options = [];
  List<String> optionNames = [];
  Function callBack = () {};
  Function onReturn = () {};

  get optionPlace{
        if(options==null || options.isEmpty) return 0;
        for(var i=0; i<options.length;i++){ if(this.type == options[i]) return i;}
      }

  EditGetReferenceID({this.id, this.type, this.tagStyle, this.propertyStyle, this.options, this.optionNames, this.callBack, this.onReturn});
  @override
  Widget build(BuildContext context) {
    print('Building -> GetReferenceID');
    final catalogProvider = Provider.of<CatalogProvider>(context);
    
    return  Container(
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
      color: Colors.black,
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
      child: ListTile(
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, 
      children: [Text('Link '+this.optionNames[this.optionPlace], style: tagStyle),
                  RaisedButton(color: (this.id == null || this.id == '' || this.id == 'i0'|| this.id == 'm0'|| this.id == 'p0'|| this.id == 'u0') ? Colors.red[900] : Colors.black, 
                  child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: SingleChildScrollView( scrollDirection: Axis.horizontal,
                                            child: Text((this.id == null || this.id == '') ? 'Select '+this.optionNames[this.optionPlace] : '${this.id} - ${this.type == Meal ? catalogProvider.getMeal(this.id).name : this.type == Ingredient ? catalogProvider.getIngredient(this.id).name : this.type == PantryItem ? 'pantry' : 'Missing'}',
                                    style: (this.id == null || this.id == '') ? TextStyle(fontSize: 30, color: Colors.black, fontFamily: 'Lato', fontWeight: FontWeight.bold) : propertyStyle),)
                  ), onPressed: () {Navigator.of(context).push(MaterialPageRoute(builder:(context)=>Catalog(displayType: this.type, allowAdd: false, selectionMode: true, selectionMultiple: false, selectionCallBack: (reference)=>callBack(reference))));}),
      ]),
    trailing:  IconButton(icon: Icon(Icons.edit), color: Theme.of(context).primaryColor, 
                    onPressed: (){
                      // var meal = catalogProvider.getMeal(id);
                      return (type == null || id == null || id == '' || id == 'i0' || id == 'm0' || id=='p0') ? null
                                : type == Meal ? showMealEdit(context: context, mealId: id, onExitUpdate: this.onReturn)
                                : type == Ingredient ? showIngredientEdit(context: context, ingredientId: id, onExitUpdate: this.onReturn)
                                : type == PantryItem ? showPantryItemEdit(context: context, itemId: id, onExitUpdate: this.onReturn) : null;
                    })
    ),);
  }
}

class EditImage extends StatefulWidget {
  final TextStyle tagStyle;
  final String tag;
  // final Function setImage;
  final String id;

  EditImage({this.id = '0', this.tagStyle, this.tag, });
  // {setImage();}

  // setImage()async {await getImageFile(this.id).then((value)=>imageFile = value);}  

  @override
  _EditImageState createState() => _EditImageState();
}
class _EditImageState extends State<EditImage> {
  File imageFile = null;
    @override
        void initState () {
          super.initState();
          WidgetsBinding.instance.addPostFrameCallback((_){
            setImage();
          });

        }
    void setImage()async {await getImageFile(this.widget.id).then((value)=>setState((){imageFile = value; imageCache.clear(); print('setting...'); print(value);}));}
  


  void openGallery() async {
    try{
      var pickedFileLink = await ImagePicker().getImage(source: ImageSource.gallery);
      File cachedImageFile = File(pickedFileLink.path);
        File newFile =  await writeImageFile(this.widget.id, cachedImageFile);
        // print(newFile);
        if(newFile != null && newFile.existsSync())
          setState((){ imageCache.clear(); imageFile = newFile;});
        else
          throw new Exception('File Failed to Process and returned as Null');
        print('Gallery :: File Save SUCESSFUL!!!');
    } catch(e){print('ERROR :: image Gallery Upload');
      print(e);
      return;
    }
    return;
  }

  void openCamera() async {
    try{
      var pickedFileLink = await ImagePicker().getImage(source: ImageSource.camera);
      File cachedImageFile = File(pickedFileLink.path);
        File newFile =  await writeImageFile(this.widget.id, cachedImageFile);
        // print(newFile);
        if(newFile != null && newFile.existsSync())
          setState((){ imageCache.clear(); imageFile = newFile;});
        else
          throw new Exception('File Failed to Process and returned as Null');
        print('Camera :: File Save SUCESSFUL!!!');
    } catch(e){print('ERROR :: image Camera Upload');
      print(e);
      return;
    }
    return;
  }

  getImageDisplay() async{
      if(imageFile == null || !imageFile.existsSync())
        return Icon(Icons.filter_hdr, color: Theme.of(context).primaryColor, size: 70,);
        else {
          await  imageCache.clear();
          File displayFile = File(imageFile.path);
          return Image.file(displayFile, fit: BoxFit.cover,);
        }
  }


  @override
  Widget build(BuildContext context) {
    print('build');
// print(imageFile);
    return Container(
      margin: EdgeInsets.symmetric(vertical: 6, horizontal: 20),
      color: Colors.black,
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(widget.tag, style: widget.tagStyle),
        ListTile(
          leading: IconButton(icon: Icon(Icons.camera), color: Theme.of(context).primaryColor, iconSize: 35, onPressed: ()=>openCamera(),),
          title: Container(
                  height: 75,
                  // width: 50,
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).primaryColor, width: 2),
                      borderRadius: BorderRadius.circular(5)),          
                  child:  FutureBuilder(future: getImageDisplay(),
                            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                                if(snapshot.connectionState == ConnectionState.done){return snapshot.data;}  
                                else{return CircularProgressIndicator();}
                          },),
                    ),
          trailing: IconButton(icon: Icon(Icons.collections), color: Theme.of(context).primaryColor, iconSize: 35, onPressed: ()=>openGallery(),),
        ),
      ]), 
    );
  }
}

class EditCheckStringOptions extends StatelessWidget {
  final TextStyle tagStyle;
  final TextStyle propertyStyle;
  final String tag;
  List<String> options = [];
  List<String> selected = [];
  Function onAdd = () {};
  Function onRemove = () {};

  EditCheckStringOptions(
      {this.selected,
      this.tag,
      this.tagStyle,
      this.propertyStyle,
      this.onAdd,
      this.onRemove,
      this.options,
      });

      // bool isSelected(String item){
      //   return this.options.contains(item);
      // }

  @override
  Widget build(BuildContext context) {

    return ListTile(
        title: Container(
      margin: EdgeInsets.all(2),
      color: Colors.black,
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
      child: SizedBox(
        height: 150,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(tag, style: tagStyle), 
          Expanded(
            child:  ListView.builder(
          itemCount: this.options.length,
          itemBuilder: (context, index) {
              return GestureDetector( child: ClipRRect(borderRadius: BorderRadius.circular(25),
              child: Container(color:  Colors.grey[850] , margin: EdgeInsets.all(5), 
                child: Container(margin: EdgeInsets.all(3), color: !this.selected.contains(this.options[index]) ? Colors.grey[850] : Colors.black,
                  child: Container(margin: EdgeInsets.symmetric(horizontal: 10),
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [ Text(this.options[index], style: this.propertyStyle,), 
                      Theme(data: ThemeData(unselectedWidgetColor: Theme.of(context).primaryColor), child: Transform.scale(scale: 1.5, child: Checkbox(value: this.selected.contains(this.options[index]), 
                                      onChanged: (_) => this.selected.contains(this.options[index]) ? this.onRemove(this.options[index]) : this.onAdd(this.options[index]), activeColor: Theme.of(context).primaryColor, checkColor: Colors.black,),)), 
                    ]),
                    ),
                  ),
                ),
                ),
                onTap: () => this.selected.contains(this.options[index]) ? this.onRemove(this.options[index]) : this.onAdd(this.options[index]),
              );
              },
          ),
          ),
          ]),
      ),
    ));
  }
}

class EditMapServingsPerUnit extends StatelessWidget {
  final TextStyle tagStyle;
  final TextStyle propertyStyle;
  final String tag;
  final Map<String, double> setServings;
  Function setCall;

  EditMapServingsPerUnit(
      {this.tag,
      this.tagStyle,
      this.propertyStyle,
      this.setCall,
      this.setServings,
      });

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<Settings>(context);
    // final catalogProvider = Provider.of<CatalogProvider>(context);

    List<String> unitList = settings.pricingUnits;

    return ListTile(
        title: Container(
      margin: EdgeInsets.all(2),
      color: Colors.black,
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
      child: SizedBox(
        height: 150,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(tag, style: tagStyle), 
          Expanded(
            child:  ListView.builder(
          itemCount: unitList.length,
          itemBuilder: (context, index) {
              return ClipRRect(borderRadius: BorderRadius.circular(25),
              child: Container(color:  Colors.grey[850] , margin: EdgeInsets.all(5), 
                child: Container(margin: EdgeInsets.all(3), color: Colors.black,
                  child: Container(margin: EdgeInsets.symmetric(horizontal: 10),
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [ Expanded(child: Text(unitList[index]+' :', style: this.propertyStyle,)), 
                      Container(
                          width: 100,
                          // height: 40,
                        child: TextFormField(
                                  initialValue: this.setServings.containsKey(unitList[index]) ? this.setServings[unitList[index]].toString() : '1.0',  
                                  // controller: countController,
                                  onChanged: (value) {double count=double.tryParse(value); if(count != null) this.setCall(unitList[index], count);},
                                  keyboardType: TextInputType.number,
                                  style: this.propertyStyle,
                                  decoration: InputDecoration(
                                  // hintText: 'Count',
                                  // hintStyle: this.propertyStyle,        
                                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).primaryColor)),  
                                  // focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.green),),
                                  ),
                          ),
                        ),
                    ]),
                    ),
                  ),
                ),
                );
              },
          ),
          ),
          ]),
      ),
    ));
  }
}


class EditRecordedPrices extends StatefulWidget {
  final String itemId;
  final TextStyle tagStyle;
  final TextStyle propertyStyle;
  final String tag;
  List<PriceRecord> current = [];
  Function onAdd = () {}; //send String store and double price
  Function onRemove = () {};//send ID



  EditRecordedPrices(
      {this.itemId,
      this.tag,
      this.tagStyle,
      this.propertyStyle,
      this.onAdd,
      this.onRemove,
      this.current,
      });

  @override
  _EditRecordedPricesState createState() => _EditRecordedPricesState();
}

class _EditRecordedPricesState extends State<EditRecordedPrices> {
        void initState () {
          super.initState();
          storeController.addListener(()=>this.setState(()=>store=storeController.text));
          amountController.addListener(()=>this.setState(() {amount=double.tryParse(amountController.text); if(amount == null) amount=0.0;}));
          }
 
final TextEditingController storeController = TextEditingController();
final TextEditingController amountController = TextEditingController();

  String store = '';
  int unitPlace = 0;
  double amount = 0.00;

void createNewPrice(BuildContext context){
  final settings = Provider.of<Settings>(context);
  // double amount = 0.0;
  // try{ amount = double.parse(amountValue.text);
  // } catch(e){print('EditRecordedPrices()-amount failed to parse');
  //   amount = 0.0;
  // }
  if(amount != 0.0 && store != 'Store') widget.onAdd(new PriceRecord(id: widget.itemId, store: store, price: amount, unit: settings.pricingUnits[unitPlace]));
  setState(() {
    store = '';
    unitPlace = 0;
    amount = 0.00;
    storeController.clear();
    amountController.clear();
  });
  return;
}


  @override
  Widget build(BuildContext context) {
    print('EditBlank.EditRecordedPrices()-build');
    final settings = Provider.of<Settings>(context);
    // print(this.widget.current.toString());
    // print(store);
    // print(amount);

    return ListTile(
        title: Container(
      margin: EdgeInsets.all(2),
      color: Colors.black,
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
      child: SizedBox(
        height: 150,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(widget.tag, style: widget.tagStyle), 
          Expanded(
            child:  ListView.builder(
          itemCount: this.widget.current.length+1,
          itemBuilder: (context, index) {
              return ClipRRect(borderRadius: BorderRadius.circular(25),
              child: Container(color:  Colors.grey[850] , margin: EdgeInsets.all(5), 
                child: Container(margin: EdgeInsets.all(3), color: Colors.black,
                  child: Container(margin: EdgeInsets.only(left: 10, right: 3, bottom: 0),
                    child: 
                    index == 0 ? 
                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [ 
                              SizedBox(width: 50,
                                child: OutlineButton(child: Text(settings.pricingUnits[unitPlace].substring(0,2), style: TextStyle(fontSize: 15, color: Theme.of(context).primaryColor)), splashColor: Colors.white24, borderSide: BorderSide(color: Theme.of(context).primaryColor, ),
                                      onPressed: () {setState(() {unitPlace = (unitPlace+1) % settings.pricingUnits.length;});}, ),
                              ), 
                              Expanded(
                              // margin: EdgeInsets.all(5),
                              // width: 125,
                              // height: 40,
                              child: TextField(
                                // initialValue: '', 
                                      controller: storeController,
                                      // onChanged: (value)=>this.setState(()=>store=value),
                                      keyboardType: TextInputType.text,
                                      style: widget.propertyStyle,
                                      textAlign: TextAlign.center,
                                      // autofocus: true,
                                      decoration: InputDecoration(
                                        hintText: 'Store',
                                        hintStyle: widget.propertyStyle,       
                                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).primaryColor)),  
                                        // focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.green),),
                                      ),
                              ),
                            ),
                                        Container(
                                            width: 125,
                                            // height: 40,
                                          child: Row(children: [Text('\$ ', style: widget.propertyStyle),
                                                  Expanded(
                                                    child: TextField(
                                                      // initialValue: '',  
                                                      controller: amountController,
                                                      // onChanged: (value)=>this.setState(() {amount=double.tryParse(value); if(amount == null) amount=0.0;}),
                                                      keyboardType: TextInputType.number,
                                                      style: widget.propertyStyle,
                                                      decoration: InputDecoration(
                                                      hintText: 'Price',
                                                      hintStyle: widget.propertyStyle,        
                                                      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).primaryColor)),  
                                                      // focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.green),),
                                                      ),
                                            )
                                                  ),
                                                  ])),
                                        IconButton(icon: Icon(Icons.add_circle_outline), color: Theme.of(context).primaryColor, iconSize: 30, onPressed: ()=>createNewPrice(context))
                                        ])
                  :  
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [ Text(this.widget.current[index-1].unit.substring(0,2), style: widget.propertyStyle),
                                     Text('|', style: this.widget.propertyStyle,), Text(this.widget.current[index-1].store, style: this.widget.propertyStyle,), Text('|', style: this.widget.propertyStyle,), Text('\$${this.widget.current[index-1].price.toStringAsFixed(2)}', style: this.widget.propertyStyle,), IconButton(icon: Icon(Icons.delete_forever), iconSize: 37, color: Colors.red[900], onPressed: ()=>widget.onRemove(widget.current[index-1]))]),
                    ),
                  ),
                ),
                );
              },
          ),
          ),
          ]),
      ),
    ));
  }
}

// settings.nameTags ? Column(children: [Theme(data: ThemeData(unselectedWidgetColor: Theme.of(context).primaryColor), child: Transform.scale(scale: 2, child: Checkbox(value: item.found, 
//                                       onChanged: (_) {shoppingListProvider.markItemToggle(itemId: itemId); if(shoppingListProvider.getItem(itemId).found) addToPantryCall();}, activeColor: Theme.of(context).primaryColor, checkColor: Colors.black,),
//     )), Text('Aquired', style: TextStyle(fontSize: 15, color:Theme.of(context).accentColor))]) 
//                                 : Theme(data: ThemeData(unselectedWidgetColor: Theme.of(context).primaryColor), child: Transform.scale(scale: 2,  child: Checkbox(value: item.found,  
//                                       onChanged: (_) {shoppingListProvider.markItemToggle(itemId: itemId); if(shoppingListProvider.getItem(itemId).found) addToPantryCall();}, activeColor: Theme.of(context).primaryColor, checkColor: Colors.black,),
//                                 ));




class BottomBanner extends StatelessWidget {
  final String title;
  const BottomBanner(this.title);

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<Settings>(context);

    final List<Widget> items = settings.nameTags ? [Text(settings.nameTags ? '[DRAWER]' : '', style: TextStyle(fontSize: 13,  fontFamily: 'OpenSans', fontWeight: FontWeight.w800, color:Colors.grey[900])), SizedBox(width: 20,), Icon(Icons.menu, size: 20,), SizedBox(width: 20,),] : [];
    items.add(Text(title,  style: TextStyle(fontSize: 13,  fontFamily: 'OpenSans', fontWeight: FontWeight.w800, color:Colors.grey[900])));

    return GestureDetector(onTap: ()=>Scaffold.of(context).openDrawer(),
          child: Container(height: 25, width: double.infinity,  color: Theme.of(context).primaryColor, padding: EdgeInsets.only(bottom: 2), alignment: Alignment.center,
                  child: Center(
                    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: items),
                  )),
    );
  }
}


class EditSliderOptions extends StatelessWidget {
  final String selection;
  final TextStyle tagStyle;
  final TextStyle propertyStyle;
  final String tag;
  List<String> options = [];
  Function callBack = () {};

  EditSliderOptions(
      {this.selection = 'Package',
      this.tag,
      this.tagStyle,
      this.propertyStyle,
      this.callBack,
      this.options,
      });

  @override
  Widget build(BuildContext context) {
    return Container(width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: 6, horizontal: 20),
      color: Colors.black,
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(tag, style: tagStyle),
        Transform.scale( scale: 1.2,
            child: SizedBox(width: 325,
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
            child: Slider(
                    value: this.options.contains(this.selection) ? this.options.indexOf(this.selection).toDouble() : 0.0, 
                    onChanged: (newValue) {callBack(options[newValue.toInt()]); this.build(context);},
                    activeColor: Theme.of(context).primaryColor,
                    inactiveColor: Colors.grey[900],
                    divisions: options.length,
                    min: 0.0,
                    max:  this.options.isNotEmpty ? this.options.length.toDouble()-1 : 0.0,
                    label: this.selection,
                    
                    ),
            ),
            ),
          ),
      ]),
    );
  }
}