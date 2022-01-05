import 'package:style_random/random_dart.dart';
import 'package:test/expect.dart';
import 'package:test/test.dart';

Matcher haveExpression<T extends RandomExpression>() {
  return _HaveExpressionMatcher<T>();
}

class _HaveExpressionMatcher<T extends RandomExpression> extends Matcher {
  _HaveExpressionMatcher();

  @override
  Description describe(Description description) {
    return description..add(" $T");
  }

  @override
  bool matches(item, Map matchState) {
    return (item is ExpressionGroup) &&
        item.expressions.whereType<T>().isNotEmpty;
  }

  @override
  Description describeMismatch(
      item, Description mismatchDescription, Map matchState, bool verbose) {
    return mismatchDescription..add(" ${item.runtimeType}");
  }
}

Matcher indexIsExpression<T extends RandomExpression>(int index) {
  return _IndexExpressionMatcher<T>(index);
}

class _IndexExpressionMatcher<T extends RandomExpression> extends Matcher {
  _IndexExpressionMatcher(this.index);

  int index;

  @override
  Description describe(Description description) {
    return description..add(" $T");
  }

  @override
  bool matches(item, Map matchState) {
    return (item is ExpressionGroup) && item.expressions[index] is T;
  }

  @override
  Description describeMismatch(
      item, Description mismatchDescription, Map matchState, bool verbose) {
    return mismatchDescription..add(" ${item.runtimeType}");
  }
}


Matcher isCharClass<T extends CharacterClass>(){
  return _IsCharacterClass<T>();
}

class _IsCharacterClass<T extends CharacterClass> extends Matcher {
  @override
  Description describe(Description description) {
    return description..add(" $T");
  }

  @override
  bool matches(item, Map matchState) {
    return (item is CharacterClassExpression) && item.charClass is T;
  }

  @override
  Description describeMismatch(
      item, Description mismatchDescription, Map matchState, bool verbose) {
    return mismatchDescription
      ..add(
          " ${item is CharacterClassExpression ? item.charClass.runtimeType : item.runtimeType}");
  }
}
