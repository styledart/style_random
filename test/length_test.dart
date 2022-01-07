import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

import 'src/random_matcher.dart';

void main() {
  group("top fixed", () {
    test("#*./l(10)", () {
      expect("#*./l(10)", lengthIs(len: 10));
    });

    test("/l(2)./l(5-10)*/l(-50)#Aaaa/l(15-20)", () {
      expect(
          "/l(2)./l(5-10)*/l(-50)#Aaaa/l(15-20)", lengthIs(min: 15, max: 20));
    });

    //TODO: Add more tests
  });
}
