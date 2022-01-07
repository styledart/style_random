part of 'random_dart_base.dart';

///
abstract class RandomExpression {
  ///
  RandomExpression();

  String _sample(RandomDelegate delegate, int lengthOption,
      {StartOption? startWith,
      NotStartOption? notStartOption,
      EndOption? endOption,
      NotEndOption? notEndOption});

  final Map<Type, Option> _options = {};

  /// Expression options
  List<Option> get options => _options.values.toList();

  /// [option] by type.
  /// If option not exists returns null
  T? option<T extends Option>() {
    return _options[T] as T?;
  }

  /// Expression built description as Json
  Map<String, dynamic> description();
}

/// `.` any character. *(ASCII 33-126)* <br>
/// `#` any number from 0 to 9. *9 include* <br>
/// `*` any letter. *(ASCII 65-90 and 97-122)* <br>
/// `l` lover case letters. *(ASCII 65-90)* <br>
/// `L` upper case letters. *(ASCII 97-122)* <br>
/// `s` any specific character *(ASCII 33-47, 58-64, 91-96, 123-126)* <br>
/// `w` any specific character exclude url specific characters
class CharacterClassExpression extends RandomExpression {
  /// Use [CharacterClass] for the constructor
  CharacterClassExpression({required this.charClass});

  /// This expression's character class
  CharacterClass charClass;

  @override
  Map<String, dynamic> description() {
    return {
      "type": "char_class",
      "char_class": {
        "class": charClass.runtimeType.toString(),
        "options": options.map((e) => e.description()).toList(),
      }
    };
  }

  bool _getAvailableForEnd(EndOption? end, NotEndOption? notEnd) {
    for (var c in charClass.characters) {
      if (end?.contains(c) == true) {
        return true;
      }
      if (notEnd?.contains(c) == false) {
        return true;
      }
    }
    return false;
  }

  bool _cStart(
      String char, StartOption? startWith, NotStartOption? notStartOption) {
    if (startWith == null && notStartOption == null) return true;
    return (startWith?.availableAt(char, true) ?? false) ||
        (notStartOption?.availableAt(char, true) ?? false);
  }

  bool _cEnd(String char, EndOption? end, NotEndOption? notEnd) {
    if (end == null && notEnd == null) return false;
    return (end?.availableAt(char, false) ?? false) ||
        (notEnd?.availableAt(char, false) ?? false);
  }

  String _getOneForStart(RandomDelegate delegate, StartOption? startWith,
      NotStartOption? notStartOption) {
    String? r;
    var i = 0;
    while (r == null || !_cStart(r, startWith, notStartOption)) {
      if (i > math.pow(charClass.characters.length, 2)) {
        throw ArgumentError("There maybe is infinity loop."
            "Maybe not possible generate a character with"
            " ${startWith != null ? "Start: ${startWith.params}" : null} "
            " ${startWith != null ? "Not Start: ${startWith.params}" : null}.");
      }
      r = charClass.characters[
          delegate.nextInt(maxInt: charClass.characters.length - 1)];
      i++;
    }
    return r;
  }

  String _getOneForBoth(RandomDelegate delegate, StartOption? startWith,
      NotStartOption? notStartOption, EndOption? end, NotEndOption? notEnd) {
    String? r;
    var i = 0;
    while (r == null ||
        ((startWith != null && !_cStart(r, startWith, notStartOption)) ||
            _cEnd(r, end, notEnd))) {
      if (i > math.pow(charClass.characters.length, 2)) {
        throw ArgumentError("There maybe is infinity loop."
            "Maybe not possible generate a character with\n"
            "This: $runtimeType\n"
            "${startWith != null ? "Start: ${startWith.params}\n" : ""}"
            "${notStartOption != null ? "Not Start: ${notStartOption.params}\n" : ""}"
            "${end != null ? "End: ${end.params}\n" : ""}"
            "${notEnd != null ? "Not End: ${notEnd.params}" : ""}.\n"
            "on ${charClass.runtimeType}\n");
      }
      r = charClass.characters[
          delegate.nextInt(maxInt: charClass.characters.length - 1)];
      i++;
    }
    return r;
  }

  String _getOneForEnd(
      RandomDelegate delegate, EndOption? endWith, NotEndOption? notEndWith) {
    String? r;
    var i = 0;
    while (r == null || _cEnd(r, endWith, notEndWith)) {
      if (i > math.pow(charClass.characters.length, 2)) {
        throw ArgumentError("There maybe is infinity loop."
            "Maybe not possible generate a character with\n"
            "This: $charClass\n"
            " ${endWith != null ? "End: ${endWith.params}" : null} "
            " ${notEndWith != null ? "Not End: ${notEndWith.params}" : null}.");
      }
      r = charClass.characters[
          delegate.nextInt(maxInt: charClass.characters.length - 1)];
      i++;
    }
    return r;
  }

  @override
  String _sample(RandomDelegate delegate, int lengthOption,
      {StartOption? startWith,
      NotStartOption? notStartOption,
      EndOption? endOption,
      NotEndOption? notEndOption}) {
    return List.generate(lengthOption, (index) {
      StartOption? _s = option<StartOption>() ?? startWith;
      EndOption? _e = option<EndOption>() ?? endOption;
      NotStartOption? _ns = option<NotStartOption>() ?? notStartOption;
      NotEndOption? _ne = option<NotEndOption>() ?? notEndOption;

      bool isStart = index == 0 && (_s != null || _ns != null);
      bool isEnd = index == lengthOption - 1 && (_e != null || _ne != null);

      if (isStart) {
        if (isEnd) {
          return _getOneForBoth(delegate, _s, _ns, _e, _ne);
        } else {
          return _getOneForStart(delegate, _s, _ns);
        }
      } else if (isEnd) {
        return _getOneForEnd(delegate, _e, _ne);
      } else {
        return charClass.characters[
            delegate.nextInt(maxInt: charClass.characters.length - 1)];
      }
    }).join();
  }
}

/// Static characters are expressed with `{}`. Static expressions instantiate the contents as they are.
///
/// E.g. `{-}` , `{42}` , `{xyz}`
class StaticExpression extends RandomExpression {
  /// Don't use {} for the constructor
  StaticExpression(this.value);

  /// Static value
  String value;

  @override
  Map<String, dynamic> description() {
    return {
      "static": {
        "type": "static",
        "value": value,
        "options": options.map((e) => e.description()).toList(),
      }
    };
  }

  @override
  String _sample(RandomDelegate delegate, int lengthOption,
      {StartOption? startWith,
      NotStartOption? notStartOption,
      EndOption? endOption,
      NotEndOption? notEndOption}) {
    return value;
  }
}

/// `[<cl><cl>]` character class group. No sorting is done within the group.
///
/// `[a #]`  lower case letters or numbers
class CharacterGroup extends RandomExpression with ExpressionGroup {
  ///
  CharacterGroup(String expression, bool onGenerateLengthForEach)
      : _onGenerateLen = onGenerateLengthForEach {
    _parse(expression);
  }

  final bool _onGenerateLen;

  @override
  bool get _global => false;

  @override
  Map<String, dynamic> description() {
    return {
      "type": "group",
      "expressions": expressions.map((e) => e.description()).toList(),
      "options": options.map((e) => e.description()).toList(),
    };
  }

  @override
  String _sample(RandomDelegate delegate, int lengthOption,
      {StartOption? startWith,
      NotStartOption? notStartOption,
      EndOption? endOption,
      NotEndOption? notEndOption}) {
    _setChildrenLen(delegate, lengthOption);

    var l = List.from(_childrenLenMatrix._childrenLenMatrix[2]).cast<int>();
    var res = StringBuffer();
    var count = 0;
    String? end;
    while ((res.length + (end != null ? 1 : 0)) != lengthOption) {
      count++;
      var i = delegate.nextInt(maxInt: l.length - 1);
      if (count > math.pow(lengthOption, 2)) {
        throw ArgumentError(
            "There may is a infinity loop. Check your conditions possibilities."
            " And if you think this loop is unnecessary create issue:");
      }

      var _s = res.length == 0 ? option<StartOption>() : null;
      var _ns = res.length == 0 ? option<NotStartOption>() : null;

      if ((res.length == 0) &&
          end == null &&
          (option<NotEndOption>() != null || option<EndOption>() != null)) {
        if (l[i] > 0) {
          // print("AVAILABLE: ${(expressions[i] as CharacterClassExpression).charClass} : ${(expressions[i] as CharacterClassExpression).getAvailableForEnd(
          //     option<EndOption>(), option<NotEndOption>())}");
          if ((expressions[i] as CharacterClassExpression)._getAvailableForEnd(
              option<EndOption>(), option<NotEndOption>())) {
            if (lengthOption == 1) {
              end = (expressions[i] as CharacterClassExpression)._getOneForBoth(
                  delegate,
                  _s,
                  _ns,
                  option<EndOption>(),
                  option<NotEndOption>());
            } else {
              end = (expressions[i] as CharacterClassExpression)._getOneForEnd(
                  delegate, option<EndOption>(), option<NotEndOption>());
            }
            l[i]--;
          }
        } else {
          l.removeAt(i);
          continue;
        }
      } else {
        if (l[i] > 0) {
          res.write(
            expressions[i]._sample(
              delegate,
              1,
              startWith: _s,
              notStartOption: _ns,
            ),
          );
          l[i]--;
        } else {
          l.removeAt(i);
          continue;
        }
      }
      if (end != null && res.length == lengthOption - 1) {
        res.write(end);
        break;
      }
    }

    return res.toString();
  }

  @override
  bool get onGenerateLengthForEach => _onGenerateLen;
}
