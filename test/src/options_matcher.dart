import 'package:random_dart/random_dart.dart';
import 'package:test/test.dart';

Matcher haveOption<T extends Option>() {
  return _HaveOption<T>();
}

class _HaveOption<T extends Option> extends Matcher {
  @override
  Description describe(Description description) {
    return description..add(" $T");
  }

  @override
  bool matches(item, Map matchState) {
    return (item is RandomExpression) && item.options.whereType<T>().isNotEmpty;
  }

  @override
  Description describeMismatch(
      item, Description mismatchDescription, Map matchState, bool verbose) {
    return mismatchDescription
      ..add(
          " ${item is RandomExpression ? "Have: ${item.options.map((e) => e.runtimeType).join(", ")}" : item.runtimeType}");
  }
}

Matcher optionMatcher<T extends Option>(bool Function(T option) matcher) {
  return _OptionMatch<T>(matcher);
}

class _OptionMatch<T extends Option> extends Matcher {
  _OptionMatch(this.matcher);

  bool Function(T option) matcher;

  @override
  Description describe(Description description) {
    return description..add(" $T");
  }

  @override
  bool matches(item, Map matchState) {
    if ((item is RandomExpression) && item.options.whereType<T>().isNotEmpty) {
      return matcher(item.options.whereType<T>().first);
    }
    return false;
  }

  @override
  Description describeMismatch(
      item, Description mismatchDescription, Map matchState, bool verbose) {
    if (item is RandomExpression) {
      if (item.options.whereType<T>().isNotEmpty) {
        return mismatchDescription..add("Function not match");
      } else {
        return mismatchDescription
          ..add(
              "Option $T not have ${"Have: ${item.options.map((e) => e.runtimeType).join(", ")}"}");
      }
    } else {
      return mismatchDescription..add("${item.runtimeType}");
    }
  }
}
