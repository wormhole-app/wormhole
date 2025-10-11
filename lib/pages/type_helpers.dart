import '../src/rust/api/wormhole.dart';

extension GetValue<T> on TUpdate {
  T getValue() {
    final val = value.field0;
    return val as T;
  }
}
