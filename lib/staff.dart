import 'main.dart';
import 'calc.dart';
import 'dart:math';


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

