import 'main.dart';

class Calcs { // Math Stuff

  static List convToCart (int numero) { // Convert from Index to Cartisian
    int Valuex = numero%matriz;
    int Valuey = numero~/matriz;
    return [Valuex,Valuey];
  }

  static int convToId (List<int> ll) // Convert from Cartesian to Index
    => (ll[1]*matriz) +  ll[0];
  
  static int count (cTest, cList) { // Count number of occurrences in a list
    int i = 0;
    for (var cItem in cList) {
      if (cTest == cItem) {
        i++;
      }
    }
    return i;
  }

}
