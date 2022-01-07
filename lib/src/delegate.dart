part of 'style_random_base.dart';

///
abstract class RandomDelegate {
  /// use [DefaultRandomDelegate]
  RandomDelegate();

  /// Get new random number with max
  int nextInt(int max);

  /// Max include
  int _nextInt({int? minInt, int? maxInt}) {
    if (maxInt == null || (maxInt) > 10000) throw Exception();

    ///
    var mi = minInt ?? 0;
    var ma = minInt != null ? ((maxInt) - minInt) : maxInt;
    return mi + nextInt(ma + 1);
  }
}

///
class DefaultRandomDelegate extends RandomDelegate {
  ///
  DefaultRandomDelegate(this.random) : super();

  ///
  final math.Random random;

  @override
  int nextInt(int max) {
    return random.nextInt(max);
  }
}
