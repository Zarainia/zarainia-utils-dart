class Tuple2<T1, T2> {
  T1 element1;
  T2 element2;

  Tuple2(this.element1, this.element2);

  @override
  String toString() {
    return "${runtimeType}(${element1}, ${element2})";
  }

  @override
  int get hashCode => Object.hash(element1, element2);

  @override
  bool operator ==(Object other) {
    if (other is Tuple2) return element1 == other.element1 && element2 == other.element2;
    return super == other;
  }
}

class ITuple2<T1, T2> {
  final T1 element1;
  final T2 element2;

  const ITuple2(this.element1, this.element2);

  @override
  String toString() {
    return "${runtimeType}(${element1}, ${element2})";
  }

  @override
  int get hashCode => Object.hash(element1, element2);

  @override
  bool operator ==(Object other) {
    if (other is ITuple2) return element1 == other.element1 && element2 == other.element2;
    return super == other;
  }

  ITuple2<T1, T2> with_element1(T1 element1) => ITuple2(element1, element2);

  ITuple2<T1, T2> with_element2(T2 element2) => ITuple2(element1, element2);
}
