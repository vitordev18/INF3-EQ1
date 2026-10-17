import 'dart:convert';

String repararEncoding(String texto) {
  if (texto.isEmpty) return texto;
  if (!_pareceCorrompido(texto)) return texto;

  try {
    final bytes = latin1.encode(texto);
    final reparado = utf8.decode(bytes);
    return reparado.isEmpty ? texto : reparado;
  } on FormatException {
    return texto;
  } on ArgumentError {
    return texto;
  }
}

bool _pareceCorrompido(String texto) {
  for (final unidade in texto.codeUnits) {
    if (unidade == 0xC2 || unidade == 0xC3 || unidade == 0xC5) return true;
  }
  return false;
}
