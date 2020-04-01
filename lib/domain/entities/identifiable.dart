abstract class Identifiable {
  String get id;
}

class UniqueId {
  final String value;

  UniqueId(this.value);

  const UniqueId._(this.value);
}
