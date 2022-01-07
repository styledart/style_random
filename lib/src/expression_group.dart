part of 'style_random_base.dart';

mixin ExpressionGroup on RandomExpression {
  /// The group's expressions
  final List<RandomExpression> expressions = [];

  late _LengthMatrix _childrenLenMatrix;

  _setMatrix() {
    _childrenLenMatrix = _LengthMatrix.fromChildren(expressions);

    if (!_global) {
      if (option<LengthOption>() == null) {
        if (_childrenLenMatrix.childrenHaveLength) {
          var l = _childrenLenMatrix.getChildrenLenMerge()!;
          _options[LengthOption] = l;
          l._check(this, expressions);
        }
      }
    }

    if (_global) {
      var l = option<LengthOption>();
      if (l != null) {
        if (!l._maxBounded && _childrenLenMatrix.hasUnboundedRange) {
          throw FormatException("max unbounded");
        }
      } else {
        if (_childrenLenMatrix.hasUnboundedRange) {
          /// this unbounded check child
          throw FormatException("max unbounded");
        }
      }
    }
  }

  void _buildOptions() {
    try {
      expressions.whereType<ExpressionGroup>().forEach((element) {
        element._buildOptions();
      });

      for (var opt in options) {
        opt._check(this, expressions);
      }
      _setMatrix();
    } on Exception {
      rethrow;
    }
  }

  ///
  bool get _global;

  ///
  bool _childrenSet = false;

  /// If the range is used as the length, the generator randomly determines the
  /// lengths in these intervals when it is built.
  ///
  /// This means that all results will be of the same length. But if you want
  /// the length to be re-selected for each instance (with some performance
  /// degradation), then onGenerateLength: true should be.
  bool get onGenerateLengthForEach;

  int _getLen(RandomDelegate delegate, [int? l]) {
    int len;
    LengthOption? childrenLength;

    var thisLen = option<LengthOption>();

    if (l != null && thisLen != null) {
      thisLen.length = l;
      thisLen.min = null;
      thisLen.max = null;
    }

    if (thisLen != null) {
      childrenLength = thisLen._childrenLength!.getChildrenLenMerge();

      /// this has len
      if (thisLen.isRange) {
        /// this range
        if (childrenLength == null) {
          int max = thisLen.max ?? 1 << 32;
          int min = thisLen.min ?? 0;
          len = delegate._nextInt(maxInt: max, minInt: min);
        } else if (childrenLength.isRange) {
          /// this range, child range
          int max =
              math.min(thisLen.max ?? 1 << 32, childrenLength.max ?? 1 << 32);
          int min = math.max(thisLen.min ?? 0, childrenLength.min ?? 0);
          len = delegate._nextInt(maxInt: max, minInt: min);
        } else {
          /// this range, child fix
          len = childrenLength.length!;
        }
      } else {
        /// this fixed
        len = thisLen.length!;
      }
    } else {
      if (!_childrenLenMatrix.childrenHaveLength) {
        len = l ?? expressions.length;
      } else {
        childrenLength = _childrenLenMatrix.getChildrenLenMerge()!;

        /// children len unbounded
        if (childrenLength.isRange) {
          if (childrenLength._maxBounded) {
            len = delegate._nextInt(
                maxInt: childrenLength.max ?? 1 << 32,
                minInt: childrenLength.min ?? 0);
          } else {
            var l = 0;
            var t = 0;
            while (l < _childrenLenMatrix.length) {
              t += _childrenLenMatrix.len(l) ?? _childrenLenMatrix.max(l) ?? 0;
              l++;
            }
            len = t + _childrenLenMatrix.getNotHaveLenIndexes.length;
          }
        } else {
          len = childrenLength.length!;
        }
      }
    }

    return len;
  }

  void _setChildrenLen(RandomDelegate delegate, int? le) {
    if (onGenerateLengthForEach || !_childrenSet) {
      if (onGenerateLengthForEach) {
        _setMatrix();
      }

      /// check children have range -
      /// and have not max
      /// and this have not length or max
      /// define default max

      var len = _getLen(delegate, le);

      int total = 0;
      total = _childrenLenMatrix._setFixedLenChildren(option<LengthOption>());

      var checked = 0;
      while (total < len && _childrenLenMatrix.haveNotProcessed) {
        /// steps
        /// 1 - check ranges
        /// 2 - check all not length.

        int? firstRangeIndex = _childrenLenMatrix.getFirstNotProcessedRange;

        if (firstRangeIndex != null) {
          var mi = _childrenLenMatrix.min(firstRangeIndex);
          var ma = _childrenLenMatrix.max(firstRangeIndex);
          int _m;
          if (ma != null) {
            _m = ma;
          } else {
            _m = len - total;
          }
          if (_m > len - total) {
            _m = len - total;
          }

          if (mi != null && _m < mi) {
            mi = 0;
          }

          int le;

          if (_m == 0) {
            le = 0;
          } else {
            le = delegate._nextInt(minInt: mi, maxInt: _m);
          }

          _childrenLenMatrix.addLength(firstRangeIndex, le);
          total += le;
        } else {
          /// children not have any length
          var dif = len - total;

          var not = _childrenLenMatrix.getNotHaveLenIndexes;

          var count = not.length;

          if (count > 0) {
            var each = dif ~/ count;

            if (each < 1) {
              var a = 0;
              while (dif > 0) {
                _childrenLenMatrix.addLength(a, 1);
                a++;
                dif--;
                total++;
                if (a == not.length) {
                  a = 0;
                }
              }
            } else {
              var a = 0;
              var c = false;
              while (dif > 0) {
                var inc = (c ? 1 : each);

                _childrenLenMatrix.addLength(not[a], inc);

                dif -= inc;
                total += inc;
                a++;
                if (a == not.length) {
                  c = true;
                  a = 0;
                }
              }
            }
          }
        }
        checked++;
        if (checked == _childrenLenMatrix.rangeCount) {
          /// if total not satisfied check ranges again
          if (total != len) {
            _childrenLenMatrix._resetRangeProcessed();
            checked = 0;
          }
        }
      }

      assert(total == len, "total($total) == len($len) is not true");

      var a = 0;
      while (a < expressions.length) {
        _childrenLenMatrix._childrenLenMatrix[2][a] ??= 0;
        if (_global) {
          if (expressions[a] is ExpressionGroup) {
            if (expressions[a].option<LengthOption>() != null) {
              expressions[a].option<LengthOption>()!.max = null;
              expressions[a].option<LengthOption>()!.min = null;
              expressions[a].option<LengthOption>()!.length =
                  _childrenLenMatrix.len(a);
            }
          }
        }
        a++;
      }
      _childrenSet = true;
    }
  }

  String _generate(RandomDelegate delegate) {
    _setChildrenLen(delegate, null);
    if (_global) {
      var res = <String>[];
      var i = 0;
      while (i < expressions.length) {
        res.add(expressions[i]._sample(delegate, _childrenLenMatrix.len(i)!,
            notStartOption: i == 0 ? option<NotStartOption>() : null,
            endOption: i == expressions.length - 1 ? option<EndOption>() : null,
            startWith: i == 0 ? option<StartOption>() : null,
            notEndOption:
                i == expressions.length - 1 ? option<NotEndOption>() : null));
        i++;
      }
      return res.join();
    } else {
      throw ArgumentError("Not call here");
    }
  }

  void _parse(String rawExpression) {
    try {
      var opts = <Option>[];

      var i = 0;
      while (i < rawExpression.length) {
        var char = rawExpression[i];

        void addCharacterExpression(CharacterClass chars) {
          var expression = CharacterClassExpression(charClass: chars);
          for (var o in opts) {
            expression._options[o.runtimeType] = o;
          }
          opts.clear();
          expressions.add(expression);
          i++;
        }

        switch (char) {
          case " ":
            i++;
            break;
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
          case "[":
            var end = rawExpression.indexOf("]", i);
            if (end == -1) {
              throw FormatException("[ not closed");
            }
            var sub = rawExpression.substring(i + 1, end);

            var exp = CharacterGroup(sub, onGenerateLengthForEach);

            for (var o in opts) {
              exp._options[o.runtimeType] = o;
            }
            expressions.add(exp);
            opts.clear();
            i = end + 1;
            break;
          case "/":
            if (rawExpression.length <= i) {
              throw FormatException("option name not found");
            }
            i++;
            var name = rawExpression[i];
            List<String> params = [];
            i++;
            if (rawExpression.length > i && rawExpression[i] == "(") {
              var endParams = rawExpression.indexOf(")", i);
              if (endParams == -1) {
                throw FormatException("( not closed");
              }
              var paramString = rawExpression.substring(i + 1, endParams);

              params = paramString.split(",");
              i = endParams + 1;
            }
            opts.add(Option.from(name, params));
            break;
          case "{":
            var end = rawExpression.indexOf("}", i);
            if (end == -1) {
              throw FormatException("{ not closed");
            }
            if (opts.isNotEmpty) {
              print("WARN: RandomGenerator's static characters {} not allow"
                  "options. Options ignored and removed");
            }
            var sub = rawExpression.substring(i + 1, end);
            var exp = StaticExpression(sub);
            if (opts.isNotEmpty) {
              throw FormatException(
                  "Static Expressions not handel any options");
            }
            exp._options[LengthOption] = LengthOption(length: sub.length);
            expressions.add(exp);
            opts.clear();
            i = end + 1;
            break;
          default:
            throw FormatException("");
        }
      }
      _options.addEntries(opts.map((e) => MapEntry(e.runtimeType, e)));
    } on Exception {
      rethrow;
    }
  }
}
