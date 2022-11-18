import 'package:rxdart/rxdart.dart';

Stream<T> flattenStream<T>(Stream<Stream<T>> source) {
  return SwitchLatestStream(source).asBroadcastStream();
}

extension ZarainiaStreamStreamExtension<T> on Stream<Stream<T>> {
  Stream<T> flatten() => flattenStream(this);
}
