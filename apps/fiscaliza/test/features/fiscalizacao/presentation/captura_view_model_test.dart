import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fiscaliza/features/fiscalizacao/presentation/captura/captura_view_model.dart';

void main() {
  test('sessão de captura é descartada ao sair da tela', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final sub = container.listen(capturaViewModelProvider, (_, _) {});
    container.read(capturaViewModelProvider.notifier).toggleEditMode();
    expect(container.read(capturaViewModelProvider).isEditMode, isTrue);

    sub.close();
    await container.pump();

    final novoEstado = container.read(capturaViewModelProvider);
    expect(novoEstado.isEditMode, isFalse);
    expect(novoEstado.fotos, isEmpty);
  });
}
