import 'package:style_random/random_dart.dart';
import 'package:test/test.dart';

/// Check sample starting with character or character classes on
/// 1000(default) sample
Matcher startWith(
    {List<CharacterClass>? classes,
    List<String>? characters,
    int sampleCount = 1000}) {
  return _RandomEndsMatcher(
      must: true,
      start: true,
      characters: characters ?? [],
      sampleCount: sampleCount,
      classes: classes ?? []);
}

/// Check sample ending with character or character classes on
/// 1000(default) sample
Matcher endWith(
    {List<CharacterClass>? classes,
    List<String>? characters,
    int sampleCount = 1000}) {
  return _RandomEndsMatcher(
      must: true,
      start: false,
      characters: characters ?? [],
      sampleCount: sampleCount,
      classes: classes ?? []);
}

/// Check sample not starting with character or character classes on
/// 1000(default) sample
Matcher notStartWith(
    {List<CharacterClass>? classes,
    List<String>? characters,
    int sampleCount = 1000}) {
  return _RandomEndsMatcher(
      must: false,
      start: true,
      characters: characters ?? [],
      sampleCount: sampleCount,
      classes: classes ?? []);
}

/// Check sample not ending with character or character classes on
/// 1000(default) sample
Matcher notEndingWith(
    {List<CharacterClass>? classes,
    List<String>? characters,
    int sampleCount = 1000}) {
  return _RandomEndsMatcher(
      must: false,
      start: false,
      characters: characters ?? [],
      sampleCount: sampleCount,
      classes: classes ?? []);
}

class _RandomEndsMatcher extends RandomMatcher {
  _RandomEndsMatcher(
      {required this.must,
      required this.start,
      this.classes = const [],
      this.characters = const [],
      int sampleCount = 1000})
      : assert(classes.isNotEmpty || characters.isNotEmpty),
        super(sampleCount, 1);

  /// character classes
  List<CharacterClass> classes;

  /// characters
  List<String> characters;

  /// is about starting point
  bool start;

  /// is about must be
  bool must;

  @override
  String describeExpected() {
    return "${must ? "" : "Not"} ${start ? "Starting" : "Ending"}"
        " with ${classes.map((e) => e.runtimeType).join(" or ")}"
        " or $characters";
  }

  @override
  bool sampleMatches(item, Map<dynamic, dynamic> matchState) {
    if (item is String) {
      String c;

      if (start) {
        c = item[0];
      } else {
        c = item[item.length - 1];
      }

      bool contains = false;

      if (characters.contains(c)) {
        contains = true;
      }

      for (var cl in classes) {
        if (contains && !must) break;
        if (cl.characters.contains(c)) {
          contains = true;
        }
      }


      return must ? contains : !contains;
    }
    return false;
  }
}

///
Matcher lengthIs({int? max, int? min, int? len, int count = 1000}) {
  if (len != null) {
    assert(max == null && min == null);
    return RandomLengthMatcher(
        length: len, sampleCount: 1, rebuildCount: count);
  } else {
    assert(min != null && max != null);
    return RandomLengthRangeMatcher(
        max: max!, min: min!, sampleCount: 1, rebuildCount: count);
  }
}

class RandomLengthMatcher extends RandomMatcher {
  RandomLengthMatcher(
      {required this.length,
      required int sampleCount,
      required int rebuildCount})
      : super(sampleCount, rebuildCount);

  int length;

  @override
  String describeExpected() {
    return "Sample length fixed: $length";
  }

  @override
  bool sampleMatches(item, Map<dynamic, dynamic> matchState) {
    return (item is String) && item.length == length;
  }
}

class RandomLengthRangeMatcher extends RandomMatcher {
  RandomLengthRangeMatcher(
      {required this.min,
      required this.max,
      required int sampleCount,
      required int rebuildCount})
      : super(sampleCount, rebuildCount);

  int max;
  int min;

  @override
  String describeExpected() {
    return "Sample length in range: ($min - $max)";
  }

  @override
  bool sampleMatches(item, Map<dynamic, dynamic> matchState) {
    return (item is String) && item.length <= max && item.length >= min;
  }
}

abstract class RandomMatcher extends Matcher {
  RandomMatcher(this.sampleCount, this.rebuildCount);

  ///
  int sampleCount;

  int rebuildCount;

  bool sampleMatches(item, Map<dynamic, dynamic> matchState);

  @override
  Description describe(Description description) {
    return description
      ..add("${describeExpected()}"
          "\nTotal $rebuildCount build"
          " and {${rebuildCount * sampleCount}} generate.");
  }

  String describeExpected();

  @override
  bool matches(item, Map<dynamic, dynamic> matchState) {
    if (item is String) {
      RandomGenerator generator;
      try {
        generator = RandomGenerator(item);
      } on FormatException catch (e) {
        matchState["reason"] = 1;
        matchState["message"] = e.message;
        return false;
      }

      var _built = 0;
      while (_built < rebuildCount) {
        if (_built != 0) {
          generator = RandomGenerator(item);
        }

        var _sample = 0;
        while (_sample < sampleCount) {
          var s = generator.generateString();
          var r = sampleMatches(s, matchState);
          if (!r) {
            matchState["reason"] = 2;
            matchState["value"] = s;
            matchState["expected"] = describeExpected();
            return false;
          }

          _sample++;
        }

        _built++;
      }
    } else {
      matchState["reason"] = 0;
      return false;
    }
    return true;
  }

  @override
  Description describeMismatch(
      item, Description mismatchDescription, Map matchState, bool verbose) {
    if (matchState["reason"] == 0) {
      return mismatchDescription..add("Expected raw random string");
    }
    if (matchState["reason"] == 1) {
      return mismatchDescription
        ..add("Error on parsing:"
            " Format Exception: ${matchState["message"]}");
    }

    if (matchState["reason"] == 2) {
      return mismatchDescription
        ..add("mismatch on sample: (${matchState["value"]}) ."
            "Expected: ${describeExpected()}");
    }

    return super
        .describeMismatch(item, mismatchDescription, matchState, verbose);
  }
}
