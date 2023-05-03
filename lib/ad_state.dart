import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:io';

class AdState {

  Future<InitializationStatus> initialization;

  AdState(this.initialization);

  String get bannerAdUnitId => Platform.isAndroid
    ? 'ca-app-pub-3940256099942544/6300978111'
    : 'ca-app-pub-3940256099942544/6300978111';
    
}
