part of 'random_dart_base.dart';

class RandomGenerator extends RandomExpression with ExpressionGroup {
  ///
  RandomGenerator(this.rawExpression,
      {RandomDelegate? randomDelegate, bool onGenerateLength = false})
      : _onGenerateLen = onGenerateLength,
        _delegate = DefaultRandomDelegate(math.Random()) {
    try {
      _parse(rawExpression);
      _buildOptions();
    } on Exception {
      rethrow;
    }
  }

  final bool _onGenerateLen;

  @override
  bool get onGenerateLengthForEach => _onGenerateLen;

  final String rawExpression;

  ///
  final RandomDelegate _delegate;

  ///
  String? additionalLetters;

  ///
  String? availableCharacters;

  String generateString() {
    return _generate(_delegate);
  }

  @override
  bool get _global => true;

  @override
  Map<String, dynamic> description() {
    return {
      "generator": {
        "expressions": expressions.map((e) => e.description()).toList(),
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
    throw UnimplementedError();
  }
}
