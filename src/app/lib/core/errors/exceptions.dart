class DofParseException implements Exception {
  final String message;
  const DofParseException(this.message);

  @override
  String toString() => 'DofParseException: $message';
}

class ModelLoadException implements Exception {
  final String message;
  const ModelLoadException(this.message);

  @override
  String toString() => 'ModelLoadException: $message';
}

class StorageException implements Exception {
  final String message;
  const StorageException(this.message);

  @override
  String toString() => 'StorageException: $message';
}
