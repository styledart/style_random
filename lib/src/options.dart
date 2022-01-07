part of 'style_random_base.dart';

/// Expression or global option.
///
abstract class Option {
  /// Don't use
  Option();

  void _buildOption();

  /// Options from name and params
  /// E.g `"l" , ["10"]`
  factory Option.from(String name, List<String> params) {
    try {
      Option _set(Option option) {
        try {
          return option
            ..name = name
            ..params = params
            .._buildOption();
        } on Exception {
          rethrow;
        }
      }

      if (name == "d" || name == "u") {
        return _set(DuplicateOption());
      } else if (name == "l") {
        return _set(LengthOption._());
      } else if (name == "s") {
        return _set(StartOption());
      } else if (name == "e") {
        return _set(EndOption());
      } else if (name == "<") {
        return _set(NotStartOption());
      } else if (name == ">") {
        return _set(NotEndOption());
      } else if (name == "c") {
        return _set(ConsecutiveOptions());
      }

      throw FormatException("Option $name not found.");
    } on Exception {
      rethrow;
    }
  }

  /// Option name without "/"
  late final String name;

  /// Option params as List<String>
  late final List<String> params;

  /// Option description as Json
  Map<String, dynamic> description() {
    return {"option": name, "params": params};
  }

  void _check(RandomExpression? parent, List<RandomExpression>? children);
}

/// Limit duplication
/// Not built, Do not use
@experimental
class DuplicateOption extends Option {
  int? _max;

  /// Maximum duplication
  int get max => _max!;

  /// Set maximum duplication
  set max(int value) {
    if (name == "u") {
      _max = 1;
      return;
    }
    _max = value;
  }

  @override
  void _buildOption() {
    try {
      try {
        if (name == "u") {
          _max = 1;
          return;
        }

        if (params.length != 1) {
          throw Exception();
        }
        _max = int.parse(params.first);
      } on Exception {
        throw FormatException("Duplicate option allow and need 1 integer"
            "parameter");
      }
    } on Exception {
      rethrow;
    }
  }

  @override
  void _check(RandomExpression? parent, List<RandomExpression>? children) {
    if (children == null) return;

    children.whereType<ExpressionGroup>().forEach((element) {
      var _childDuplications = element.option<DuplicateOption>();
      if (_childDuplications != null) {
        if (_childDuplications.max > max) {
          _childDuplications.max = max;
        }
      } else {
        element._options[DuplicateOption] = (this);
        _check(element, element.expressions);
      }
    });
  }
}

/// Limit consecutive duplication
/// Not built, Do not use
@experimental
class ConsecutiveOptions extends Option {
  int? _max;

  /// Maximum duplication
  int get max => _max!;

  /// Set maximum duplication
  set max(int value) => _max = value;

  @override
  void _buildOption() {
    try {
      if (params.length != 1) {
        throw Exception();
      }
      _max = int.parse(params.first);
    } on Exception {
      throw FormatException("ConsecutiveOptions option allow and need 1 integer"
          "parameter");
    }
  }

  @override
  void _check(RandomExpression? parent, List<RandomExpression>? children) {
    if (children == null) return;

    children.whereType<ExpressionGroup>().forEach((element) {
      var _childConsecutive = element.option<ConsecutiveOptions>();
      if (_childConsecutive != null) {
        // child has duplication
        // and if child max is greater than
        // parent duplicate set child duplicate
        // with parent's max
        if (_childConsecutive.max > max) {
          _childConsecutive.max = max;
        }
      } else {
        element._options[ConsecutiveOptions] = (this);
        _check(element, element.expressions);
      }
    });
  }
}

/// Length matrix for children
class _LengthMatrix {
  ///
  _LengthMatrix({required List<List<int?>> matrix})
      : _childrenLenMatrix = matrix;

  factory _LengthMatrix.fromChildren(List<RandomExpression> expressions) {
    List<List<int?>> _childrenLenMatrix = List.generate(
        6, (i) => List<int?>.generate(expressions.length, (i) => null));

    var i = 0;
    for (var exp in expressions) {
      if (exp is StaticExpression) {
        _addTo(_childrenLenMatrix, i, null, null, 1);
      } else {
        var l = expressions[i].option<LengthOption>();
        _addTo(_childrenLenMatrix, i, l?.min, l?.max, l?.length);
      }
      i++;
    }
    return _LengthMatrix(matrix: _childrenLenMatrix);
  }

  @override
  String toString() {
    _printMatrix();
    return "";
  }

  void _resetRangeProcessed() {
    _childrenLenMatrix[5] = _childrenLenMatrix[5].map((e) {
      if (e == 1) return 0;
      return null;
    }).toList();
  }

  List<int> get getNotHaveLenIndexes {
    List<int> not = [];

    var ss = 0;
    while (ss < _childrenLenMatrix[4].length) {
      if (_childrenLenMatrix[4][ss] == 0) {
        not.add(ss);
      }
      ss++;
    }
    return not;
  }

  bool get childrenHaveLength {
    return _childrenLenMatrix[4].contains(1);
  }

  bool get hasUnboundedRange {
    var i = 0;
    while (i < _childrenLenMatrix[0].length) {
      if (_childrenLenMatrix[4][i] == 1 &&
          _childrenLenMatrix[3][i] == 1 &&
          _childrenLenMatrix[1][i] == null) {
        return true;
      }
      i++;
    }
    return false;
  }

  bool get haveNotProcessed {
    return _childrenLenMatrix[2].contains(null) ||
        _childrenLenMatrix[5].contains(0) ||
        _childrenLenMatrix[5].contains(null);
  }

  int? get getFirstNotProcessedRange {
    int? firstRangeIndex;
    var s = 0;
    while (firstRangeIndex == null && s < length) {
      if (_childrenLenMatrix[4][s] == 1 &&
          _childrenLenMatrix[3][s] == 1 &&
          _childrenLenMatrix[5][s] != 1) {
        firstRangeIndex = s;
      }
      s++;
    }
    return firstRangeIndex;
  }

  int? min(int index) {
    return _childrenLenMatrix[0][index];
  }

  int? max(int index) {
    return _childrenLenMatrix[1][index];
  }

  int? len(int index) {
    return _childrenLenMatrix[2][index];
  }

  void addLength(int index, int count) {
    _childrenLenMatrix[2][index] = (_childrenLenMatrix[2][index] ?? 0) + count;
    _childrenLenMatrix[5][index] = 1;
  }

  bool isRange(int index) {
    return _childrenLenMatrix[3][index] == 1;
  }

  bool hasLengthOption(int index) {
    return _childrenLenMatrix[4][index] == 1;
  }

  bool isProcessed(int index) {
    return _childrenLenMatrix[5][index] == 1;
  }

  int get length {
    return _childrenLenMatrix[0].length;
  }

  int _setFixedLenChildren(LengthOption? lengthOption) {
    int i = 0;
    var total = 0;

    while (i < length) {
      if (!hasLengthOption(i)) {
        /// hasn't length option
        if (lengthOption == null) {
          _childrenLenMatrix[2][i] = 1;
        }
        /*else if (lengthOption.length != null){

        } */
        /*     else {
          _childrenLenMatrix[0][i] = 1;
          _childrenLenMatrix[1][i] = lengthOption.max;
          _childrenLenMatrix[4][i] = 1;
        }*/
      }

      if (len(i) != null) {
        total += len(i)!;
      }

      if (lengthOption == null && min(i) != null) {
        _childrenLenMatrix[2][i] = min(i);
        total += min(i)!;
      }

      i++;
    }
    return total;
  }

  void _printMatrix([String? prefix]) {
    if (prefix != null) {
      print(prefix);
    }

    var l = _childrenLenMatrix[0].length;
    var i = 0;

    while (i < l) {
      print("[ ${_fl("${_childrenLenMatrix[0][i]}", 6)} ,"
          " ${_fl("${_childrenLenMatrix[1][i]}", 6)} ,"
          "${_fl("${_childrenLenMatrix[2][i]}", 6)} ,"
          "${_fl("${_childrenLenMatrix[3][i]}", 6)} ,"
          "${_fl("${_childrenLenMatrix[4][i]}", 6)} ,"
          "${_fl("${_childrenLenMatrix[5][i]}", 6)} ]");
      i++;
    }
  }

  String _fl(String e, int l) {
    var r = e;
    var s = true;
    while (r.length < l) {
      if (s) {
        r = " " + r;
      } else {
        r = r + " ";
      }
      s = !s;
    }
    return r;
  }

  LengthOption? getChildrenLenMerge() {
    int? _len, _min, _max;

    var maxInf = false;
    var haveNotHaveLength = false;
    var haveRange = false;

    int i = 0;
    while (i < length) {
      if (hasLengthOption(i)) {
        if (isRange(i)) {
          haveRange = true;
          _min ??= 0;
          _min = _min + (min(i) ?? 0);

          if (max(i) == null) {
            maxInf = true;
          } else {
            _max ??= 0;
            _max += max(i)!;
          }
        } else {
          _min ??= 0;
          _min += len(i)!;
          _len ??= 0;
          _len += len(i)!;
          _max ??= 0;
          _max += len(i)!;
        }
      } else {
        haveNotHaveLength = true;
      }
      i++;
    }

    return LengthOption(
        length: haveRange || haveNotHaveLength ? null : _len,
        min: haveRange || haveNotHaveLength ? (_min ?? 0) : null,
        max: haveRange
            ? haveNotHaveLength || maxInf
                ? null
                : _max
            : null);
  }

  int get rangeCount {
    var i = 0;
    var t = 0;

    while (i < length) {
      if (hasLengthOption(i) && isRange(i)) {
        t++;
      }

      i++;
    }
    return t;
  }

  static void _addTo(List<List<int?>> _childrenLenMatrix, int i, int? _min,
      int? _max, int? _len) {
    _childrenLenMatrix[0][i] = _min;
    _childrenLenMatrix[1][i] = _max;
    _childrenLenMatrix[2][i] = _len;
    _childrenLenMatrix[3][i] = _len != null ? 0 : 1;
    _childrenLenMatrix[4][i] =
        _len == null && _min == null && _max == null ? 0 : 1;
  }

  ///   0     1    2       3         4            5
  /// [min , max, len, haveRange, haveLen, rangeProcessed]
  List<List<int?>> _childrenLenMatrix;
}

/// Length option expression
class LengthOption extends Option {
  LengthOption._();

  /// Do not use
  LengthOption({int? length, int? min, int? max}) {
    name = "l";
    params = [];
    if (length != null) {
      this.length = length;
      params.add(length.toString());
    } else {
      if (min == null && max == null) {
        throw ArgumentError();
      }
      params.add("${min ?? ""}-${max ?? ""}");
      this.min = min ?? 0;
      this.max = max;
    }
  }

  _LengthMatrix? _childrenLength;

  bool get _maxBounded {
    return length != null || max != null;
  }

  @override
  void _check(RandomExpression? parent, List<RandomExpression>? children) {
    try {
      ///1

      if (children == null) {
        _childrenLength = null;
      } else {
        _childrenLength = _LengthMatrix.fromChildren(children);
      }
      var _childrenTotal = _childrenLength!.getChildrenLenMerge();

      ///e1

      ///2
      try {
        if (isRange) {
          if (_childrenLength != null) {
            if (_childrenTotal!.isRange) {
              if (((_childrenTotal.min ?? 0) > (max ?? double.infinity))) {
                throw FormatException(
                    "children min(${_childrenTotal.min ?? 0}) > "
                    "parent max(${max ?? double.infinity})");
              }

              if (((_childrenTotal.max ?? double.infinity) < (min ?? 0))) {
                throw FormatException(
                    "children max(${_childrenTotal.max ?? double.infinity})"
                    " < parent min(${(min ?? 0)})");
              }
            }

            ///------------
            else {
              var cLen = _childrenTotal.length!;
              if (cLen > (max ?? double.infinity)) {
                throw FormatException("children length($cLen) >"
                    " parent max(${max ?? double.infinity})");
              }

              if (cLen < (min ?? 0)) {
                if (!_childrenLength!.getNotHaveLenIndexes.isNotEmpty) {
                  throw FormatException("children length($cLen)"
                      " < parent min(${min ?? 0})");
                }
              }
            }
          }
        } else {
          var len = length!;
          if (_childrenTotal != null) {
            if (_childrenTotal.isRange) {
              if ((_childrenTotal.max ?? double.infinity) < len) {
                throw FormatException("parent length($len) >"
                    " children max(${_childrenTotal.max ?? double.infinity})");
              }

              if (len < (_childrenTotal.min ?? 0)) {
                throw FormatException("parent length($len) <"
                    " children min(${_childrenTotal.min ?? 0})");
              }
            } else {
              if (_childrenTotal.length != length) {
                if (_childrenLength!.getNotHaveLenIndexes.isEmpty) {
                  throw FormatException("parent length($length) != "
                      "children length(${_childrenTotal.length})");
                }
              }
            }
          }
        }
      } on Exception {
        rethrow;
      }

      ///e2
    } on Exception {
      rethrow;
    }
  }

  /// Max length
  int? max;

  /// Min length
  int? min;

  /// Fixed length
  int? length;

  /// The option is range option
  bool get isRange => max != null || min != null;

  @override
  void _buildOption() {
    try {
      if (params.length != 1) {
        throw Exception();
      }

      if (params.first.contains("-")) {
        var minMax = params.first.split("-");
        if (minMax[0].replaceAll(" ", "").isNotEmpty) {
          min = int.parse(minMax[0]);
        } else {
          min = 0;
        }
        if (minMax[1].replaceAll(" ", "").isNotEmpty) {
          max = int.parse(minMax[1]);
        }
        if (min != null && max != null && max! < min!) {
          throw FormatException(
              "min greater than max : min : $min  max:  $max");
        }
      } else {
        length = int.parse(params.first.replaceAll(" ", ""));
      }
    } on Exception catch (e) {
      print(e);
      throw FormatException("Length option allow and need 1 param."
          "Param should integer or range expression");
    }
  }
}

/// End options
mixin _EndsMixin on Option {
  List<CharacterClass>? _classes;

  List<String>? _characters;

  _build() {
    if (params.isEmpty) {
      throw FormatException("NotStart option need at least 1 parameter");
    }

    var cl = <CharacterClass>[];
    var ch = <String>[];
    for (var param in params) {
      var res = param;

      while (res[0] == (" ")) {
        res = res.substring(1);
      }

      while (res[res.length - 1] == " ") {
        res = res.substring(0, res.length - 1);
      }

      if (res.startsWith("{") && res.endsWith("}")) {
        ch.addAll(res.substring(1, res.length - 1).split(""));
      } else {
        void addCharacterExpression(CharacterClass chars) {
          cl.add(chars);
        }

        if (res.length > 1) {
          throw FormatException("split with \",\" character classes "
              "on <,  >,  s,  e, options");
        }

        switch (res) {
          case ".":
            addCharacterExpression(AllCharacters());
            break;
          case "#":
            addCharacterExpression(NumberCharacters());
            break;
          case "*":
            addCharacterExpression(AllLetters());
            break;
          case "a":
            addCharacterExpression(LowerLetters());
            break;
          case "A":
            addCharacterExpression(UpperLetters());
            break;
          case "s":
            addCharacterExpression(SpecificCharacters());
            break;
          case "w":
            addCharacterExpression(UrlCharacters());
            break;
          default:
            throw FormatException("Character clas not found");
        }
      }
    }

    if (cl.isNotEmpty) {
      _classes = cl;
    }

    if (ch.isNotEmpty) {
      _characters = ch;
    }
  }

  bool get _isStartOption;

  bool get _must;

  bool contains(String char) {
    assert(char.length == 1);
    if (_characters != null) {
      return _characters!.contains(char);
    }

    for (var cl in _classes!) {
      if (cl.characters.contains(char)) return true;
    }

    return false;
  }

  bool availableAt(String char, bool start) {
    bool? res;
    if (start && _isStartOption) {
      res = contains(char.split("").first);
    }
    if (!start && !_isStartOption) {
      res = contains(char.split("").last);
    }

    if (res != null) {
      if (_must) {
        return res;
      } else {
        return !res;
      }
    }

    return true;
  }

  void _c(RandomExpression? parent, List<RandomExpression>? children) {
    if (children == null) return;

    if (children.isEmpty) throw FormatException("Children is empty");

    RandomExpression child;

    if (_isStartOption) {
      child = children.first;
    } else {
      child = children.last;
    }

    var childHaveSame = child._options.values
        .where((e) =>
            e is _EndsMixin &&
            (_isStartOption ? e._isStartOption : !e._isStartOption))
        .isNotEmpty;
    if (childHaveSame) {
      throw FormatException("There is end option on parent already");
    }

    var con = false;

    if (child is ExpressionGroup) {
      for (var exp in child.expressions) {
        if (exp is CharacterClassExpression) {
          for (var cl in _classes ?? <CharacterClass>[]) {
            if (!(con) && _must) {
              if (exp.charClass.contains(cl)) {
                con = true;
              }
            } else {
              con = true;
            }
          }

          for (var ch in _characters ?? <String>[]) {
            if (!(con) && _must) {
              if (exp.charClass.characters.contains(ch)) {
                con = true;
              }
            } else {
              con = true;
            }
          }
        }
      }
    } else if (child is CharacterClassExpression) {
      for (var cl in _classes ?? <CharacterClass>[]) {
        if (!con && _must) {
          if (child.charClass.contains(cl)) {
            con = true;
          }
        } else {
          con = true;
        }
      }

      for (var ch in _characters ?? <String>[]) {
        if (!con && _must) {
          if (child.charClass.characters.contains(ch)) {
            con = true;
          }
        } else {
          con = true;
        }
      }
    }
    if (!con && _must) {
      throw FormatException("Classes not "
          "contains in a group or expression. So starting with"
          " is impossible");
    }

    if (child is ExpressionGroup) {
      child._options[runtimeType] = (this);
      _check(child, child.expressions);
    }
  }
}

/// Expression not start with option
class NotStartOption extends Option with _EndsMixin {
  @override
  void _buildOption() {
    _build();
  }

  @override
  void _check(RandomExpression? parent, List<RandomExpression>? children) {
    return _c(parent, children);
  }

  @override
  bool get _isStartOption => true;

  @override
  bool get _must => false;
}

/// Expression not end with option
class NotEndOption extends Option with _EndsMixin {
  @override
  void _buildOption() {
    _build();
  }

  @override
  void _check(RandomExpression? parent, List<RandomExpression>? children) {
    return _c(parent, children);
  }

  @override
  bool get _isStartOption => false;

  @override
  bool get _must => false;
}

/// Expression start with option
class StartOption extends Option with _EndsMixin {
  @override
  void _buildOption() {
    _build();
  }

  @override
  void _check(RandomExpression? parent, List<RandomExpression>? children) {
    return _c(parent, children);
  }

  @override
  bool get _isStartOption => true;

  @override
  bool get _must => true;
}

/// Expression end with option
class EndOption extends Option with _EndsMixin {
  @override
  void _buildOption() {
    _build();
  }

  @override
  void _check(RandomExpression? parent, List<RandomExpression>? children) {
    return _c(parent, children);
  }

  @override
  bool get _isStartOption => false;

  @override
  bool get _must => false;
}
