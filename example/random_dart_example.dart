import 'package:random_dart/random_dart.dart';

void main() {

  //TODO: Dışta sabit varken içe baktı

  // RandomGenerator("/l(10)*/l(5-10)./l(10)#/l(26)").generateString();



  var gen = RandomGenerator("[.]/l(10)/s(#)");

  print(gen.description());

   print(gen.generateString());
  print(gen.generateString());
  print(gen.generateString());
  print(gen.generateString());
  print(gen.generateString());
  print(gen.generateString());
  print(gen.generateString());
}
