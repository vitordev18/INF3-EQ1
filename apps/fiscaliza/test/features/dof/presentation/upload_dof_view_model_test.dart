import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fiscaliza/features/dof/data/models/dof_item_model.dart';
import 'package:fiscaliza/features/dof/presentation/upload/upload_dof_view_model.dart';

void main() {
  DofItemModel item() => DofItemModel(
    id: '001',
    numero: '001',
    produto: 'Madeira serrada',
    especieCientifico: 'Goupia glabra',
    nomePopular: 'Cupiúba',
    saldoLivre: 1,
    saldoTotal: 32.13,
    unidade: 'm³',
  );

  group('UploadDofState — dados da madeireira', () {
    test('começa com os três campos vazios', () {
      const state = UploadDofState();

      expect(state.madeireiraNome, '');
      expect(state.madeireiraCnpj, '');
      expect(state.madeireiraEndereco, '');
    });

    test('copyWith altera só o campo informado', () {
      const inicial = UploadDofState(
        madeireiraNome: 'Rio Verde',
        madeireiraCnpj: '12.345.678/0001-90',
        madeireiraEndereco: 'BR-163',
      );

      final alterado = inicial.copyWith(madeireiraCnpj: '99.999.999/0001-99');

      expect(alterado.madeireiraCnpj, '99.999.999/0001-99');
      expect(alterado.madeireiraNome, 'Rio Verde');
      expect(alterado.madeireiraEndereco, 'BR-163');
    });

    test('copyWith preserva os campos quando nada é informado', () {
      const inicial = UploadDofState(
        madeireiraNome: 'Rio Verde',
        madeireiraCnpj: '12.345.678/0001-90',
        madeireiraEndereco: 'BR-163',
      );

      final copia = inicial.copyWith();

      expect(copia.madeireiraNome, 'Rio Verde');
      expect(copia.madeireiraCnpj, '12.345.678/0001-90');
      expect(copia.madeireiraEndereco, 'BR-163');
    });
  });

  group('UploadDofState.canConfirm', () {
    test('exige itens lidos e nome da madeireira', () {
      expect(const UploadDofState().canConfirm, isFalse);

      expect(
        UploadDofState(parsedItems: [item()]).canConfirm,
        isFalse,
        reason: 'sem nome da madeireira não confirma',
      );

      expect(
        const UploadDofState(madeireiraNome: 'Rio Verde').canConfirm,
        isFalse,
        reason: 'sem itens não confirma',
      );

      expect(
        UploadDofState(
          parsedItems: [item()],
          madeireiraNome: 'Rio Verde',
        ).canConfirm,
        isTrue,
      );
    });

    test('CNPJ e endereço são opcionais', () {
      final state = UploadDofState(
        parsedItems: [item()],
        madeireiraNome: 'Rio Verde',
      );

      expect(state.madeireiraCnpj, '');
      expect(state.madeireiraEndereco, '');
      expect(state.canConfirm, isTrue);
    });

    test('nome só com espaços não confirma', () {
      expect(
        UploadDofState(
          parsedItems: [item()],
          madeireiraNome: '   ',
        ).canConfirm,
        isFalse,
      );
    });

    test('não confirma enquanto importa ou salva', () {
      final base = UploadDofState(
        parsedItems: [item()],
        madeireiraNome: 'Rio Verde',
      );

      expect(base.copyWith(isImporting: true).canConfirm, isFalse);
      expect(base.copyWith(isSaving: true).canConfirm, isFalse);
    });
  });

  group('UploadDofViewModel — setters', () {
    test('cada setter atualiza o seu campo sem afetar os outros', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final vm = container.read(uploadDofViewModelProvider.notifier);

      vm.setMadeireiraNome('Rio Verde');
      vm.setMadeireiraCnpj('12.345.678/0001-90');
      vm.setMadeireiraEndereco('Rod. BR-163, km 42');

      final state = container.read(uploadDofViewModelProvider);
      expect(state.madeireiraNome, 'Rio Verde');
      expect(state.madeireiraCnpj, '12.345.678/0001-90');
      expect(state.madeireiraEndereco, 'Rod. BR-163, km 42');
    });
  });
}
