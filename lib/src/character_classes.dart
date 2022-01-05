part of 'random_dart_base.dart';

/// all lower case letters
final upperCaseLetters = asciiRange(65, 91);

/// all upper case letters
final lowerCaseLetters = asciiRange(97, 123);

/// all ascii letters
final letters = [...lowerCaseLetters, ...upperCaseLetters];

/// numbers
final numbers = asciiRange(48, 58);

/// specific character
final specificCharacter = [
  ...asciiRange(33, 48),
  ...asciiRange(58, 65),
  ...asciiRange(91, 97),
  ...asciiRange(123, 127)
];

/// All characters
final allCharacters = asciiRange(33, 127);

/// end exclude
/// start include
List<String> asciiRange(int start, int end) {
  assert(start > 32);
  assert(end < 128);
  var l = <String>[];
  var i = start;
  while (i < end) {
    l.add(String.fromCharCode(i));
    i++;
  }
  return l;
}

abstract class CharacterClass {
  const CharacterClass();

  List<String> get characters;

  @override
  bool operator ==(Object other) {
    return runtimeType == other.runtimeType;
  }

  @override
  int get hashCode => runtimeType.hashCode;

  bool contains(CharacterClass other);
}

class AllCharacters extends CharacterClass {
  const AllCharacters();

  @override
  List<String> get characters => allCharacters;

  @override
  bool contains(CharacterClass other) {
    return true;
  }
}

class AllLetters extends CharacterClass {
  const AllLetters();

  @override
  List<String> get characters => letters;

  @override
  bool contains(CharacterClass other) {
    return other is LowerLetters ||
        other is UpperLetters ||
        other is AllLetters ||
        other is UrlCharacters;
  }
}

class LowerLetters extends CharacterClass {
  const LowerLetters();

  @override
  List<String> get characters => lowerCaseLetters;

  @override
  bool contains(CharacterClass other) {
    return other is LowerLetters;
  }
}

class UpperLetters extends CharacterClass {
  const UpperLetters();

  @override
  List<String> get characters => upperCaseLetters;

  @override
  bool contains(CharacterClass other) {
    return other is UpperLetters;
  }
}

class NumberCharacters extends CharacterClass {
  const NumberCharacters();

  @override
  List<String> get characters => numbers;

  @override
  bool contains(CharacterClass other) {
    return other is NumberCharacters;
  }
}

class SpecificCharacters extends CharacterClass {
  const SpecificCharacters();

  @override
  List<String> get characters => upperCaseLetters;

  @override
  bool contains(CharacterClass other) {
    return other is SpecificCharacters || other is UrlCharacters;
  }
}

class UrlCharacters extends CharacterClass {
  @override
  List<String> get characters {
    return ["!", "'", "(", ")", "*", "-", ".", "_"];
  }

  @override
  bool contains(CharacterClass other) {
    return other is UrlCharacters;
  }
}
