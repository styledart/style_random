import 'package:random_dart/random_dart.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

import 'src/random_matcher.dart';

void main() {
  test("[.]/l(10)/s(#)", () {
    //TODO: Add more tests
    expect(
        "[.]/l(10)/s(#)", RandomStartWithMatcher([NumberCharacters()], 1000));
  });
}
