import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
import 'dart:core';
import 'calc.dart';
import 'staff.dart';

void main () {
  SettingUp.prepare();
  runApp(MyApp());
}

int matriz = 10; // square side size (x or y)
int nbombas = 15;
List bombas = <int> [];
List bombCart = []; 
List detecsCar = [];
List detecsInt = [];
List markedFlag = [];
Map revealed = <int,int>{};
bool gameOverBool = false;
bool victoryBool = false; // maybe dispensable

int matrizElements () => matriz*matriz;
int isReveal (index) => revealed[index];

void victoryCheck () {
  if (remaingBombs() == 0 ) {
    victoryBool = true;
    gameOverBool = true;
    print('You won');
  }
}

void gameOver () {
  gameOverBool = true;
  TileController.revealAllBombs();
}
// working fine
int remaingBombs () {
  return nbombas - Calcs.count(1,revealed.values);
}
// working fine
int remaingTiles () {
  return matrizElements() - nbombas - Calcs.count(2,revealed.values);
} 

Staff SettingUp = Staff();


// About Tile Label, changes, explosion and so on
class TileController {

  // really turn ON hidden tiles
  static void turnOn (id) { 
    revealed[id] = 2;
  }
  
  static void flagIt (id) {
    if (isReveal(id) == 1) {
      revealed[id] = 0;
    }
    else if (isReveal(id) == 0) {
      revealed[id] = 1;
    }
  }
  
  static void revealAllBombs() {
    for (int x in bombas) {
      revealed[x] = 2;
    }
  }
  // test if its repeated, or a new ZERO or another number
  static void showup (id, bool flag) {
    int isRev = isReveal(id);  
    if (isRev  !=  2) {
      // do nothing when tile is already ON
      if ( flag == true ) {
        flagIt(id);
      }
      else {
        if (Calcs.count(id, detecsInt) == 0) {
          TileController.explode (id);
        }
        else if (bombas.contains(id) == true) {
          gameOver();
          TileController.turnOn(id);
        }
        else {
          TileController.turnOn(id);
        }
      }
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
            TileController.showup (itsID, false);
          }
        }
      }
    }
  }

  // return values for tiles' labels
  static dynamic label (index){
    dynamic value; // the value for Tile Label 
    if (bombas.contains(index)==true) {
      value = Icon(Icons.local_fire_department);
    }
    else if (Calcs.count(index,detecsInt)==0) {
      value = Icon(Icons.offline_pin_outlined,
      color: Color.fromRGBO (255,255,255,0.5),
      );
    }
    else {
      value = Text('${Calcs.count(index,detecsInt)}');
    }
    // Hidden or not
    if (isReveal(index)==2){
      return value;
    }
    else if (isReveal(index)==1) {
      return Icon(Icons.flag);
      print('isrev');
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
  int _counter = 0;
  Timer? _timer;
  bool _isGoing = false;

  void _startTimer() {
    if (_isGoing == false){
      _counter = 0;
      _isGoing = true;
    }
    if (_timer != null) {
      _timer?.cancel();
    }
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (gameOverBool == false) {
	  ++_counter;
	} else {
	  _timer?.cancel();
	}
      });
    });
  }
// Icons.assistant_photo gesture gavel hardware landscape map parkreplay restart_alt
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
	  leading: Icon(Icons.hiking),
          title: Text('Campo Minado'),
	  actions: [
	    Padding(
	      padding: EdgeInsets.all(10.0),
	      child: Row (
	        children: [
		  Icon(Icons.warning),
	          Center (child:Text ('${remaingBombs()}'),),
		],),
	    ),
	    Padding(
	      padding: EdgeInsets.all(10.0),
	      child: Row (
	        children: [
		  Icon(Icons.map),
	          Center (child: Text ('${remaingTiles()}'),),
		],),
	    ),
            Padding(
	      padding: EdgeInsets.all(10.0),
	      child: Row (
	        children: [
	          Icon (Icons.access_time,),
	          Center(
	            child:Text(
	              '${_counter}',
	            ),
	          ),
		],),
	    ),
	    Padding(
	      padding: EdgeInsets.all(10.0),		    
	      child: IconButton(
	        icon:Icon(Icons.restart_alt),
		onPressed: () {
		  _counter = 0;
		  _isGoing = false;
		  setState(() {
		    SettingUp.prepare();
		  },);
		},
	      ),
	    ),
	  ], 
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
                    return ButtonTheme(	// buttonTheme is deprecated, change it as fast as possible
		      //color: Color.fromRGBO(255,255,255,0),
                      height: 1.0,
                      child: ElevatedButton(
                        onPressed:() {
			  if (gameOverBool == false) {	
                            _startTimer();
			    if (isReveal(index) != 2) {
                              setState (() {
		                TileController.showup(index, false);
                              });
			    }
			    victoryCheck();
			  }
			  else {
			    print('locked');
			  }
                        },
		        onLongPress: () {
			  setState ( () {
			    TileController.showup(index,true);
			  });
	                },
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
       
