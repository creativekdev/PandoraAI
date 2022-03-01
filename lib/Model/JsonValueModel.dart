class JsonValueModel extends Comparable{
  String key;
  String value;

  JsonValueModel(this.key, this.value);

  @override
  String toString() {
    return '{ ${this.key}: ${this.value} }';
  }

  @override
  int compareTo(other) {
    int nameComp = this.key.compareTo(other.key);
    // if (nameComp == 0) {
    //   return this.key.compareTo(other.age);
    // }
    return nameComp;
  }
}