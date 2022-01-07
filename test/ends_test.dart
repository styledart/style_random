import 'package:style_random/random_dart.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

import 'src/random_matcher.dart';

void main() {
  test("[.]/l(20)/s(#)/e(#)", () {
    //TODO: Add more tests
    expect("[.]/l(20)/s(#)", startWith(classes: [NumberCharacters()]));
    expect(
        "[.]/l(20)/s(#)/e(#)",
        allOf(endWith(classes: [NumberCharacters()]),
            startWith(classes: [NumberCharacters()])));

    expect("/s(#)[.]/l(20)", startWith(classes: [NumberCharacters()]));
    expect(
        "/s(#)/e(#)./l(20)",
        allOf(endWith(classes: [NumberCharacters()]),
            startWith(classes: [NumberCharacters()])));

    expect("./l(20)/s(#)", startWith(classes: [NumberCharacters()]));
    expect(
        "./l(20)/s(#)/e(#)",
        allOf(endWith(classes: [NumberCharacters()]),
            startWith(classes: [NumberCharacters()])));
    expect("/s(#)./l(20)", startWith(classes: [NumberCharacters()]));
    expect(
        "/s(#)/e(#)./l(20)",
        allOf(endWith(classes: [NumberCharacters()]),
            startWith(classes: [NumberCharacters()])));

    expect(
        "/l(20).[a#][a#]/l(40)/s(a)/e(#)",
        allOf(endWith(classes: [NumberCharacters()]),
            startWith(classes: [LowerLetters()]), lengthIs(len: 40)));
  });
}
