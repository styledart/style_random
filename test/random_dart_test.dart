import 'package:style_random/style_random.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() {
  var generator = RandomGenerator("/l(30-50)[/l(1)#./l(10)*].*{-}");

  test("test_parse", () {
    expect(generator.expressions[0], isA<CharacterGroup>());
    expect(generator.expressions[0].options[0].name, "l");

    var gr = generator.expressions[0] as CharacterGroup;
    expect(gr.expressions[0], isA<CharacterClassExpression>());

    expect(gr.expressions[0].options[0], isA<LengthOption>());
    expect((gr.expressions[0].options[0] as LengthOption).length, 1);

    expect(gr.expressions[2].options[0], isA<LengthOption>());
    expect((gr.expressions[2].options[0] as LengthOption).length, 10);
    expect((gr.expressions[2].options[0] as LengthOption).max, null);

    expect(generator.expressions[1], isA<CharacterClassExpression>());
    expect((generator.expressions[1] as CharacterClassExpression).charClass,
        isA<AllCharacters>());

    expect(generator.expressions[2], isA<CharacterClassExpression>());
    expect((generator.expressions[2] as CharacterClassExpression).charClass,
        isA<AllLetters>());

    expect(generator.expressions[3], isA<StaticExpression>());
    expect((generator.expressions[3] as StaticExpression).value, "-");
  });
}
