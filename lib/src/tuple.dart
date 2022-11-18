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
