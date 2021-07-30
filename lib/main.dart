import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
import 'calc.dart';
import 'staff.dart';

void main () {
  SettingUp.prepare();
  runApp(MyApp());
}

int matriz = 10; // square side size (x or y)
int matrizElements () => matriz*matriz;
int nbombas = 15;
List bombas = <int> [];
List bombCart = []; 
List detecsCar = [];
List detecsInt = [];
Map revealed = <int,int>{};
int isReveal (index) => revealed[index];

Staff SettingUp = Staff();



// About Tile Label, changes, explosion and so on
class TileController {

  // really turn ON hidden tiles
  static void turnOn (id) { 
    revealed[id] = 2;
  }
  
  // test if its repeated, or a new ZERO or another number
  static void showup (id) {     
    if (isReveal(id)==2) {
      // do nothing when tile is already ON
    }
    else if (Calcs.count(id, detecsInt) == 0) {
      TileController.explode (id);
    }
    else {
      TileController.turnOn(id);
    }
  }

  // Reveal this Tile and the next Ones, if its Zero
  static void explode (n) {
    List nCart = Calcs.convToCart(n); // converting the target into Cartesian
    List toExpose = []; // lets link all the round tiles here
    for (int x = -1; x <= 1; x++) {
      for (int y = -1 ; y <= 1; y++) {
        int xax = nCart[0] + x;
        int yax = nCart[1] + y;
        List res = <int> [xax , yax];
        toExpose.add(res); // saving the round tiles
      }
    }
    for (List<int> aroundTileCart in toExpose) {
      int itsID = Calcs.convToId(aroundTileCart);
      if (aroundTileCart[0]<matriz && aroundTileCart[0]>=0){
        if (aroundTileCart[1]<matriz && aroundTileCart[1]>=0){ 
          if (itsID == n) { // turn on only the target tile
            TileController.turnOn(itsID);
          }
          else { // get all the others to be reviewed
            TileController.showup (itsID);
          }
        }
      }
    }
  }

  // return values for tiles' labels
  static dynamic label (index){
    String value; // the value for Tile Label 
    if (bombas.contains(index)==true) {
      value = 'bomb';
    }
    else {
      value = '${Calcs.count(index,detecsInt)}';
    }
    // Hidden or not
    if (isReveal(index)==2){
      return Text('$value');
    }
    else {
      return Text(' ');
    } 
  }

}


// Above is only design stuff
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Campo Minado',
      theme: ThemeData (
        primarySwatch: Colors.cyan,
      ),
      home: homepage(), 
    );
  }
}

class homepage extends StatefulWidget {
  _homepageState createState()=> _homepageState();
}

class _homepageState extends State<homepage> {
  int _counter = 10;
  Timer? _timer;
  bool _isGoing = false;

  void _startTimer() {
    if (_isGoing == false){
      _counter = 10;
      _isGoing = true;
    }
    if (_timer != null) {
      _timer?.cancel();
    }
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_counter > 0) {
	  --_counter;
	} else {
	  _timer?.cancel();
	}
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Campo Minado, time:${_counter}'),
        ),
        body: Center(
	  child:Container(
	    padding: EdgeInsets.all(20.0),
	    child:AspectRatio(
	      aspectRatio:1,
              child:GridView.count(
                childAspectRatio: (1),
	        physics: NeverScrollableScrollPhysics(),
                crossAxisSpacing: 1,
                mainAxisSpacing: 1,
                crossAxisCount: matriz,
                children:
                  List.generate(matrizElements(), (index) {
                    return ButtonTheme(	
                      height: 1.0,
                      child: RaisedButton(
                        onPressed:() {	
                          _startTimer();
			  if (isReveal(index)==0){
                            setState (() {
		              TileController.showup(index);
                            });
			  }
                        },
                      padding: EdgeInsets.all(0),
                      child: TileController.label(index),
                    ),
                  );     
               }),
             ),
	  ),
	),
      ),
    );
  }
}
       
