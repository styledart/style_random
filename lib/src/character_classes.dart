part of 'style_random_base.dart';

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

/// A Character class
abstract class CharacterClass {
  /// A Character class
  const CharacterClass();

  /// A Character class's characters
  List<String> get characters;

  @override
  bool operator ==(Object other) {
    return runtimeType == other.runtimeType;
  }

  @override
  int get hashCode => runtimeType.hashCode;

  /// contains another class
  bool contains(CharacterClass other);
}

/// A Character class
class AllCharacters extends CharacterClass {
  AllCharacters();

  @override
  List<String> get characters => _allCharacters;

  final _allCharacters = allCharacters;

  @override
  bool contains(CharacterClass other) {
    return true;
  }
}

/// ASCII 33, 127
class AllLetters extends CharacterClass {
  /// ASCII 33, 127
  AllLetters();

  @override
  List<String> get characters => _letters;

  final _letters = letters;

  @override
  bool contains(CharacterClass other) {
    return other is LowerLetters ||
        other is UpperLetters ||
        other is AllLetters ||
        other is UrlCharacters;
  }
}

class LowerLetters extends CharacterClass {
  LowerLetters();

  @override
  List<String> get characters => _lowerCaseLetters;

  final _lowerCaseLetters = lowerCaseLetters;

  @override
  bool contains(CharacterClass other) {
    return other is LowerLetters;
  }
}

class UpperLetters extends CharacterClass {
  UpperLetters();

  @override
  List<String> get characters => _upperCaseLetters;

  final _upperCaseLetters = upperCaseLetters;

  @override
  bool contains(CharacterClass other) {
    return other is UpperLetters;
  }
}

class NumberCharacters extends CharacterClass {
  NumberCharacters();

  @override
  List<String> get characters => _numbers;

  final _numbers = numbers;

  @override
  bool contains(CharacterClass other) {
    return other is NumberCharacters;
  }
}

class SpecificCharacters extends CharacterClass {
  SpecificCharacters();

  @override
  List<String> get characters => _chars;

  final _chars = specificCharacter;

  @override
  bool contains(CharacterClass other) {
    return other is SpecificCharacters || other is UrlCharacters;
  }
}

class UrlCharacters extends CharacterClass {
  @override
  List<String> get characters => _chars;

  final _chars = ["!", "'", "(", ")", "*", "-", ".", "_"];

  @override
  bool contains(CharacterClass other) {
    return other is UrlCharacters;
  }
}
