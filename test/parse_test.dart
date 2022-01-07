import 'package:style_random/style_random.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

import 'src/expression_matcher.dart';
import 'src/options_matcher.dart';

void main() {
  group("parse_test", () {
    group("classes", () {
      test(".", () {
        var generator = RandomGenerator(".");
        expect(generator.expressions[0], isCharClass<AllCharacters>());
      });

      test("*", () {
        var generator = RandomGenerator("*");
        expect(generator.expressions[0], isCharClass<AllLetters>());
      });

      test("l", () {
        var generator = RandomGenerator("a");
        expect(generator.expressions[0], isCharClass<LowerLetters>());
      });

      test("L", () {
        var generator = RandomGenerator("A");
        expect(generator.expressions[0], isCharClass<UpperLetters>());
      });

      test("#", () {
        var generator = RandomGenerator("#");
        expect(generator.expressions[0], isCharClass<NumberCharacters>());
      });

      test("#", () {
        var generator = RandomGenerator("w");
        expect(generator.expressions[0], isCharClass<UrlCharacters>());
      });
    });

    group("expression", () {
      test("expression: \".*[*#]{-}\"", () {
        var generator = RandomGenerator(".*[*#]{-}");
        expect(generator, indexIsExpression<CharacterClassExpression>(0));
        expect(generator.expressions[0], isCharClass<AllCharacters>());

        expect(generator, indexIsExpression<CharacterClassExpression>(1));
        expect(generator.expressions[1], isCharClass<AllLetters>());

        expect(generator, indexIsExpression<CharacterGroup>(2));

        var gr = generator.expressions[2] as CharacterGroup;

        expect(gr, indexIsExpression<CharacterClassExpression>(0));
        expect(gr.expressions[0], isCharClass<AllLetters>());
        expect(gr.expressions[1], isCharClass<NumberCharacters>());

        expect(gr, indexIsExpression<CharacterClassExpression>(1));

        expect(generator, indexIsExpression<StaticExpression>(3));
      });
      //TODO: Add more tests
    });

    group("options", () {
      group("/d and /u", () {
        test("/d and /u", () {
          var generator = RandomGenerator("/d(2)./u");
          expect(generator.expressions[0], haveOption<DuplicateOption>());
          expect(generator.expressions[0],
              optionMatcher<DuplicateOption>((opt) {
            return opt.max == 2;
          }));

          expect(generator, haveOption<DuplicateOption>());
          expect(generator, optionMatcher<DuplicateOption>((opt) {
            return opt.max == 1;
          }));
        });

        test("/d exception", () {
          expect(() {
            RandomGenerator("/d.");
          }, throwsFormatException);
        });
      });

      group("/l", () {
        group("/l syntax", () {
          test("/l syntax fixed", () {
            var generator = RandomGenerator("/l(2).");
            expect(generator.expressions[0], haveOption<LengthOption>());
            expect(generator.expressions[0], optionMatcher<LengthOption>((opt) {
              return opt.length == 2;
            }));
          });
          test("/l syntax range", () {
            var generator = RandomGenerator("/l(2-10).");
            expect(generator.expressions[0], haveOption<LengthOption>());
            expect(generator.expressions[0], optionMatcher<LengthOption>((opt) {
              return opt.min == 2 && opt.max == 10;
            }));
          });

          test("/l syntax range -max", () {
            var generator = RandomGenerator("/l(-20).");
            expect(generator.expressions[0], haveOption<LengthOption>());
            expect(generator.expressions[0], optionMatcher<LengthOption>((opt) {
              return opt.max == 20;
            }));
          });

          test("/l syntax min-max", () {
            var generator = RandomGenerator("/l(2-10).");
            expect(generator.expressions[0], haveOption<LengthOption>());
            expect(generator.expressions[0], optionMatcher<LengthOption>((opt) {
              return opt.min == 2 && opt.max == 10;
            }));
          });

          test("/l syntax multiple", () {
            var generator = RandomGenerator("/l(2)./l(5-10)*/l(-30)#");
            expect(generator.expressions[0], haveOption<LengthOption>());
            expect(generator.expressions[0], optionMatcher<LengthOption>((opt) {
              return opt.length == 2 && !opt.isRange;
            }));

            expect(generator.expressions[1], haveOption<LengthOption>());
            expect(generator.expressions[1], optionMatcher<LengthOption>((opt) {
              return opt.isRange && opt.min == 5;
            }));

            expect(generator.expressions[2], haveOption<LengthOption>());
            expect(generator.expressions[2], optionMatcher<LengthOption>((opt) {
              return opt.isRange && opt.min == 0 && opt.max == 30;
            }));
          });
        });

        group("/l top fix", () {
          test("/l children length 12 , top 6", () {
            expect(() {
              RandomGenerator("/l(2)./l(5)*/l(5)#/l(6)");
            }, throwsFormatException);
          });

          test("/l children length 12 , top 12", () {
            expect(() {
              RandomGenerator("/l(2)./l(5)*/l(5)#/l(12)");
            }, returnsNormally);
          });

          test("/l children min 7 , max inf , top 6", () {
            expect(() {
              RandomGenerator("/l(2)./l(5-)*/l(-30)#/l(6)");
            }, throwsFormatException);
          });

          test("/l children min 7, max inf, top 1000", () {
            expect(() {
              RandomGenerator("/l(2)./l(5-)*/l(-30)#/l(1000)");
            }, returnsNormally);
          });

          test("/l children min 2, max 52, top 1000", () {
            expect(() {
              RandomGenerator("/l(2)./l(-20)*/l(-30)#/l(1000)");
            }, throwsFormatException);
          });

          test("/l children min 2, max 52, top 50", () {
            expect(() {
              RandomGenerator("/l(2)./l(-20)*/l(-30)#/l(50)");
            }, returnsNormally);
          });

          test("/l children min 12, max 52, top 10-100", () {
            expect(() {
              RandomGenerator("/l(2)./l(10-20)*/l(-30)#/l(10-100)");
            }, returnsNormally);
          });

          test("/l children min 12, max 52, top 55-100", () {
            expect(() {
              RandomGenerator("/l(2)./l(10-20)*/l(-30)#/l(55-100)");
            }, throwsFormatException);
          });
        });

        group("/l top range", () {
          test("/l children length 25 , top 6-20", () {
            expect(() {
              RandomGenerator("/l(5)./l(10)*/l(10)#/l(6-20)");
            }, throwsFormatException);
          });

          test("/l children length 3 , top 6-20", () {
            expect(() {
              RandomGenerator("/l(1)./l(1)*/l(1)#/l(6-20)");
            }, throwsFormatException);
          });

          test("/l children length null , top 6-20", () {
            expect(() {
              RandomGenerator(".*#/l(6-20)");
            }, returnsNormally);
          });

          test("/l children length 15 , top -20", () {
            expect(() {
              RandomGenerator("/l(5)./l(5)*/l(5)#/l(-20)");
            }, returnsNormally);
          });

          test("/l children length -15 , top -20", () {
            expect(() {
              RandomGenerator("/l(-5)./l(-5)*/l(5)#/l(-20)");
            }, returnsNormally);
          });

          test("/l children length 10-30 , top -20", () {
            expect(() {
              RandomGenerator("/l(5-10)./l(5-10)*/l(-10)#/l(-20)");
            }, returnsNormally);
          });

          test("/l children length 10-30 , top 31-40", () {
            expect(() {
              RandomGenerator("/l( 5-10)./l(5-10 )*/l( -10)#/l(31-40)");
            }, throwsFormatException);
          });
        });

        test("/l 2-3", () {
          expect(() {
            RandomGenerator("/l(2)./l(5-)*/l(-30)#/l(-1000)");
          }, returnsNormally);
        });

        test("/l 2-4 mismatch", () {
          expect(() {
            RandomGenerator("/l(2)./l(5-)*/l(-30)#/l(-4)");
          }, throwsFormatException);
        });

        test("/l 2-5", () {
          expect(() {
            RandomGenerator("/l( 2  )./l(5-10)*/l(-30)#/l(40-)");
          }, returnsNormally);
        });

        test("/l 2-6 mismatch", () {
          expect(() {
            RandomGenerator("/l(2)./l(5-10)*/l(-30)#/l(45-)");
          }, throwsFormatException);
        });
      });

      test("ends tree", () {
        var generator = RandomGenerator("[.]/s(a)");
        expect(generator, haveOption<StartOption>());
        expect(generator.expressions[0], haveOption<StartOption>());
      });

      group("/s", () {
        test("/s correct", () {
          expect(() {
            RandomGenerator("/s(a).");
          }, returnsNormally);
        });

        test("/s wrong due intersection", () {
          expect(() {
            RandomGenerator("/s(a)#");
          }, returnsNormally);
        });

        test("/s wrong due conflict", () {
          expect(() {
            RandomGenerator("/s(a)./s(a)");
          }, throwsFormatException);
        });
      });

      group("/<", () {
        test("/< correct", () {
          expect(() {
            RandomGenerator("/<(a).");
          }, returnsNormally);
        });

        test("/< correct due intersection but must not", () {
          expect(() {
            RandomGenerator("/<(a)#");
          }, returnsNormally);
        });

        test("/< wrong due conflict", () {
          expect(() {
            RandomGenerator("/<(a)./<(a)");
          }, throwsFormatException);
        });
      });

      group("/e", () {
        test("/e correct", () {
          expect(() {
            RandomGenerator("/e(a).");
          }, returnsNormally);
        });

        test("/e wrong due intersection", () {
          expect(() {
            RandomGenerator("/e(a)#");
          }, returnsNormally);
        });

        test("/e wrong due conflict", () {
          expect(() {
            RandomGenerator("/e(a)./e(a)");
          }, throwsFormatException);
        });
      });

      group("/>", () {
        test("/> correct", () {
          expect(() {
            RandomGenerator("/>(a).");
          }, returnsNormally);
        });

        test("/> correct due intersection but must not", () {
          expect(() {
            RandomGenerator("/>(a)#");
          }, returnsNormally);
        });

        test("/> wrong due conflict", () {
          expect(() {
            RandomGenerator("/>(a)./>(a)");
          }, throwsFormatException);
        });
      });
    });
  });
}
