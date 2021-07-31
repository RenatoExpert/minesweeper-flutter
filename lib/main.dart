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

int matrizElements () => matriz*matriz;
int isReveal (index) => revealed[index];

// working fine
int remaingBombs () {
  return nbombas - Calcs.count(1,revealed.values);
}
// working fine
int remaingTiles () {
  return matrizElements() - nbombas - Calcs.count(2,revealed.values);
} 

Staff SettingUp = Staff();

void gameOver () {
  gameOverBool = true;
  TileController.revealAllBombs();
}

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
    } //Icons.map notifications online_prediction
    // Hidden or not
    if (isReveal(index)==2){
      return value;
    }
    else if (isReveal(index)==1) {
      return Icon(Icons.online_prediction);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
	  leading: Icon(Icons.hiking),
          title: Text('Campo Minado'),
	  actions: [
	    Text ('remaing bombs:${remaingBombs()}' 
	          ' remaning tiles:${remaingTiles()}'),
	    Icon (Icons.access_time,),
            Padding(
	      padding: EdgeInsets.all(10.0),
	      child: Center(
	        child:Text(
	          '${_counter}',
	  	  //style: DefaultTextStyle.of(context).style.apply(fontSizeFactor: 1.0),		    
	        ),
	      ),
	    ),
	    Padding(
	      padding: EdgeInsets.all(10.0),		    
	      child: IconButton(
	        icon:Icon(Icons.refresh), // or Icons.loop
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
                    return ButtonTheme(	
                      height: 1.0,
                      child: RaisedButton(
                        onPressed:() {
			  if (gameOverBool == false) {	
                            _startTimer();
			    if (isReveal(index) != 2) {
                              setState (() {
		                TileController.showup(index, false);
                              });
			    }
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
       
