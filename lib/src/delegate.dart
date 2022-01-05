part of 'random_dart_base.dart';

///
abstract class RandomDelegate {
  /// Max include
  int nextInt({int? minInt, int maxInt});
}

///
class DefaultRandomDelegate extends RandomDelegate {
  ///
  DefaultRandomDelegate(this.random);

  ///
  final math.Random random;

  @override
  int nextInt({int? minInt, int? maxInt}) {
    if (maxInt == null || (maxInt) > 100) throw Exception();

    ///
    var mi = minInt ?? 0;
    var ma = minInt != null ? ((maxInt) - minInt) : maxInt;
    return mi + random.nextInt(ma + 1);
  }
}
