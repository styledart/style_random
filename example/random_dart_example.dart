
import 'dart:convert';

import 'package:style_random/random_dart.dart';

void main() {

  //TODO: Dışta sabit varken içe baktı

  // RandomGenerator("/l(10)*/l(5-10)./l(10)#/l(26)").generateString();



  var gen = RandomGenerator("/l(20).[a#]/l(40)/s(a)/e(#)");


  print(gen.generateString());
  print(gen.generateString());
  print(gen.generateString());
  print(gen.generateString());
  print(gen.generateString());
  print(gen.generateString());
  print(gen.generateString());
}
