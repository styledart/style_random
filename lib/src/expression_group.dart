part of 'random_dart_base.dart';

mixin ExpressionGroup on RandomExpression {
  final List<RandomExpression> expressions = [];

  late LengthMatrix childrenLenMatrix;

  void _buildOptions() {
    try {
      expressions.whereType<ExpressionGroup>().forEach((element) {
        element._buildOptions();
      });

      for (var opt in options) {
        opt._check(this, expressions);
      }

      childrenLenMatrix = LengthMatrix.fromChildren(expressions);


      if (!global) {
        if (length == null) {
          if (childrenLenMatrix.childrenHaveLength) {
            var l = childrenLenMatrix.getChildrenLenMerge()!;
            _options[LengthOption] = l;
            l._check(this, expressions);
          }
        }
      }

      if (global) {
        var l = length;
        if (l != null) {
          if (!l.maxBounded && childrenLenMatrix.hasUnboundedRange) {
            throw FormatException("max unbounded");
          }
        } else {
          if (childrenLenMatrix.hasUnboundedRange) {
            /// this unbounded check child
            throw FormatException("max unbounded");
          }
        }
      }
    } on Exception {
      rethrow;
    }
  }

  ///
  bool get global;

  ///
  bool _childrenSet = false;

  bool get onGenerateLengthForEach;

  int _getLen(RandomDelegate delegate) {
    int len;
    LengthOption? childrenLength;
    var thisLen = length;
    if (thisLen != null) {
      childrenLength = thisLen._childrenLength;

      /// this has len
      if (thisLen.isRange) {
        /// this range
        if (childrenLength == null) {
          int max = thisLen.max ?? 1 << 32;
          int min = thisLen.min ?? 0;
          len = delegate.nextInt(maxInt: max, minInt: min);
        } else if (childrenLength.isRange) {
          /// this range, child range
          int max =
              math.min(thisLen.max ?? 1 << 32, childrenLength.max ?? 1 << 32);
          int min = math.max(thisLen.min ?? 0, childrenLength.min ?? 0);
          len = delegate.nextInt(maxInt: max, minInt: min);
        } else {
          /// this range, child fix
          len = childrenLength.length!;
        }
      } else {
        /// this fixed
        len = thisLen.length!;
      }
    } else {
      if (!childrenLenMatrix.childrenHaveLength) {
        len = expressions.length;
      } else {
        childrenLength = childrenLenMatrix.getChildrenLenMerge()!;

        /// children len unbounded
        if (childrenLength.isRange) {
          len = delegate.nextInt(
              maxInt: childrenLength.max ?? 1 << 32,
              minInt: childrenLength.min ?? 0);
        } else {
          len = childrenLength.length!;
        }
      }
    }

    return len;
  }

  void _setChildrenLen(RandomDelegate delegate) {
    if (onGenerateLengthForEach || !_childrenSet) {
      if (_childrenSet) {
        ///check length is fixed for all
      }

      /// check children have range -
      /// and have not max
      /// and this have not length or max
      /// define default max

      var len = _getLen(delegate);

      int total = 0;

      total = childrenLenMatrix._setFixedLenChildren(length);

      var checked = 0;
      while (total < len && childrenLenMatrix.haveNotProcessed) {
        /// steps
        /// 1 - check ranges
        /// 2 - check all not length.

        int? firstRangeIndex = childrenLenMatrix.getFirstNotProcessedRange;

        if (firstRangeIndex != null) {
          var mi = childrenLenMatrix.min(firstRangeIndex);
          var ma = childrenLenMatrix.max(firstRangeIndex);
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
            le = delegate.nextInt(minInt: mi, maxInt: _m);
          }

          childrenLenMatrix.addLength(firstRangeIndex, le);
          total += le;
        } else {
          /// children not have any length
          var dif = len - total;


          var not = childrenLenMatrix.getNotHaveLenIndexes;
          var count = not.length;

          if (count > 0) {
            var each = dif ~/ count;

            if (each < 1) {
              var a = 0;
              while (dif > 0) {
                childrenLenMatrix.addLength(a, 1);
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

                childrenLenMatrix.addLength(not[a], inc);

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
        if (checked == childrenLenMatrix.rangeCount) {
          /// if total not satisfied check ranges again
          if (total != len) {
            childrenLenMatrix.resetRangeProcessed();
            checked = 0;
          }
        }
      }

      assert(total == len, "total($total) == len($len) is not true");

      _childrenSet = true;
    }
  }

  String _generate(RandomDelegate delegate) {
    _setChildrenLen(delegate);
    if (global) {
      var res = <String>[];
      var i = 0;
      while (i < expressions.length) {
        var ends = i == 0
            ? option<StartOption>()
            : i == expressions.length - 1
                ? option<EndOption>()
                : null;
        var notEnds = i == 0
            ? option<NotStartOption>()
            : i == expressions.length - 1
                ? option<NotEndOption>()
                : null;

        res.add(expressions[i]._sample(delegate, childrenLenMatrix.len(i)!,
            endOption: ends, notEndOption: notEnds));
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
            var end = rawExpression.indexOf("]");
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
