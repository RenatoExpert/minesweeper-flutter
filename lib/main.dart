import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
import 'calc.dart';

void main () {
  SettingUp.prepare();
  runApp(MyApp());
}

Clock GameClock = Clock();
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

class Staff {
  void prepare () { // setting up the game
    this.sorteando(); // choosing random different numbers
    this.listingBombs(); // convert bombs index to cartesian 
    this.mapeando(); // giving revealed false values to all IDs
    this.distribute(); // making detecsCar and Int for tile detections
  }
  void sorteando(){
    for (int i = 0; i < nbombas;) {
      int bomba = new Random().nextInt((matrizElements()-1));
      if (bombas.contains(bomba)==false) {
        bombas.add(bomba);
        i++;
      }
    }
  }
  void listingBombs () {
    for (var i in bombas){
      bombCart.add(Calcs.convToCart(i));
    }
  }
  void mapeando(){
    for (int i = 0; i < matrizElements(); i++) {
      revealed[i]=0;
    }
  }
  void distribute () {
    for (List bmb in bombCart) {
      for (var x = -1; x <= 1; x++) {
        for (var y = -1 ; y <= 1; y++) {
          int xax = bmb[0] + x;
          int yax = bmb[1] + y;
          List res = <int> [xax , yax];
          detecsCar.add(res);
        }
      }
    }
    for (List<int> dc in detecsCar) {
      if (dc[0]<matriz && dc[1]<matriz){
        int intver = Calcs.convToId(dc);
        detecsInt.add(intver);
      }
    }
    print('Ready to play!');
  }
}



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


class Clock {

  int timevar = 0;
  int active = 0;
  int get time {
    return timevar;
  }
  void runn () async {
//    while (this.active==1) {
//      await Future.delayed(const Duration(seconds: 1),
//        () { return ++timevar; },
//      ).then((value) { print(value);
//      });
//    }
  }
  void stop () {
    this.active = 0;
  }
  void reset() {
    this.timevar = 0;
  }
  void startTimer (){
    this.active = 1;
    this.runn();
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
  void _startTimer() {
    _counter = 10;
    if (_timer != null) {
      _timer?.cancel();
    }
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_counter > 0) {
	  _counter--;
	} else {
	  _timer?.cancel();
	}
      });
    });
    }
  void isRunning () {
    _timer == null ? false : _timer!.isActive;
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
       
