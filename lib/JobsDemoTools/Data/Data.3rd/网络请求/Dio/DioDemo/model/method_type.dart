enum MethodType {
  get('GET'),
  post('POST'),
  put('PUT'),
  patch('PATCH'),
  delete('DELETE'),
  upload('UPLOAD'),
  download('DOWNLOAD');

  const MethodType(this.label);

  final String label;

  static MethodType from(String value) {
    return MethodType.values.firstWhere(
      (element) => element.label == value.toUpperCase(),
      orElse: () => MethodType.get,
    );
  }
}
