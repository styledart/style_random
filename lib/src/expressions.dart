part of 'random_dart_base.dart';

///
abstract class RandomExpression {
  ///
  RandomExpression();

  String _sample(RandomDelegate delegate, int lengthOption,
      {EndsMixin? endOption, EndsMixin? notEndOption});

  final Map<Type, Option> _options = {};

  List<Option> get options => _options.values.toList();

  LengthOption? get length {
    return _options[LengthOption] as LengthOption?;
  }

  T? option<T extends Option>() {
    return _options[T] as T?;
  }

  Map<String, dynamic> description();
}

class CharacterClassExpression extends RandomExpression {
  CharacterClassExpression({required this.charClass});

  CharacterClass charClass;

  @override
  Map<String, dynamic> description() {
    return {
      "char_class": {
        "class": charClass.runtimeType.toString(),
        "options": options.map((e) => e.description()).toList(),
      }
    };
  }

  @override
  String _sample(RandomDelegate delegate, int lengthOption,
      {EndsMixin? endOption, EndsMixin? notEndOption}) {
    return List.generate(lengthOption, (index) {
      String res;
      if (index == 0) {
        if (endOption is StartOption) {
          String? r;
          while (r == null || !endOption.availableAt(r, true)) {
            r = charClass.characters[
            delegate.nextInt(maxInt: charClass.characters.length - 1)];
          }
          res = r;
        } else if (notEndOption is NotStartOption) {
          String? r;
          while (r == null || notEndOption.availableAt(r, true)) {
            r = charClass.characters[
            delegate.nextInt(maxInt: charClass.characters.length - 1)];
          }
          res = r;
        } else {
          res = charClass.characters[
          delegate.nextInt(maxInt: charClass.characters.length - 1)];
        }
      } else if (index == lengthOption - 1) {
        if (endOption is EndOption) {
          String? r;
          while (r == null || !endOption.availableAt(r, true)) {
            r = charClass.characters[
            delegate.nextInt(maxInt: charClass.characters.length - 1)];
          }
          res = r;
        } else if (notEndOption is NotEndOption) {
          String? r;
          while (r == null || notEndOption.availableAt(r, true)) {
            r = charClass.characters[
            delegate.nextInt(maxInt: charClass.characters.length - 1)];
          }
          res = r;
        } else {
          res = charClass.characters[
          delegate.nextInt(maxInt: charClass.characters.length - 1)];
        }
      } else {
        res = charClass.characters[
        delegate.nextInt(maxInt: charClass.characters.length - 1)];
      }

      return res;
    }).join();
  }
}

///
class StaticExpression extends RandomExpression {
  ///
  StaticExpression(this.value);

  ///
  String value;

  @override
  Map<String, dynamic> description() {
    return {
      "static": {
        "value": value,
        "options": options.map((e) => e.description()).toList(),
      }
    };
  }

  @override
  String _sample(RandomDelegate delegate, int lengthOption,
      {EndsMixin? endOption, EndsMixin? notEndOption}) {
    return value;
  }
}

class CharacterGroup extends RandomExpression with ExpressionGroup {
  ///
  CharacterGroup(String expression, bool onGenerateLengthForEach)
      : _onGenerateLen = onGenerateLengthForEach {
    _parse(expression);
  }

  final bool _onGenerateLen;

  @override
  bool get global => false;

  @override
  Map<String, dynamic> description() {
    return {
      "group": {
        "expressions": expressions.map((e) => e.description()).toList(),
        "options": options.map((e) => e.description()).toList(),
      }
    };
  }

  @override
  String _sample(RandomDelegate delegate, int lengthOption,
      {EndsMixin? endOption, EndsMixin? notEndOption}) {
    _setChildrenLen(delegate);
    var l = List.from(childrenLenMatrix._childrenLenMatrix[2]).cast<int>();
    var res = StringBuffer();
    while (res.length != lengthOption) {
      var i = delegate.nextInt(maxInt: l.length - 1);
      if (l[i] > 0) {
        res.write(
          expressions[i]._sample(delegate, 1,
              endOption: res.length == 0
                  ? option<StartOption>() ?? option<NotStartOption>()
                  : null,
              notEndOption: res.length == lengthOption - 1
                  ? option<EndOption>() ?? option<NotEndOption>()
                  : null),
        );
      } else {
        continue;
      }
    }

    return res.toString();
  }

  @override
  bool get onGenerateLengthForEach => _onGenerateLen;
}
