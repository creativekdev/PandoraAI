extension MapEntryEx<K, V> on List<MapEntry<K, V>> {
  Map<K, V> toMap() {
    Map<K, V> map = {};
    this.forEach((element) {
      map[element.key] = element.value;
    });
    return map;
  }
}
