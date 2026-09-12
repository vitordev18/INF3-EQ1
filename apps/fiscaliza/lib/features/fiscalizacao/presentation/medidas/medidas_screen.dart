import 'package:fiscaliza/features/fiscalizacao/domain/perfil_peca.dart';
import 'dart:async';

import 'package:fiscaliza/design_system/components/action_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fiscaliza/design_system/theme/app_colors.dart';
import 'package:fiscaliza/design_system/dialogs/confirm_dialog.dart';
import 'package:fiscaliza/design_system/components/app_scaffold.dart';
import 'package:fiscaliza/features/dof/data/models/dof_item_model.dart';
import 'package:fiscaliza/features/fiscalizacao/presentation/captura/captura_state.dart';
import 'package:fiscaliza/features/fiscalizacao/presentation/captura/captura_view_model.dart';
import 'package:fiscaliza/features/fiscalizacao/presentation/medidas/medidas_view_model.dart';

class MedidasScreen extends ConsumerStatefulWidget {
  final DofItemModel dofItem;
  final int fotoIndex;

  const MedidasScreen({
    super.key,
    required this.dofItem,
    required this.fotoIndex,
  });

  @override
  ConsumerState<MedidasScreen> createState() => _MedidasScreenState();
}

class _MedidasScreenState extends ConsumerState<MedidasScreen> {
  DateTime? _lastErrorShown;
  bool _errorMessageVisible = false;
  Timer? _errorDismissTimer;
  static const _errorRateLimit = Duration(seconds: 2);
  static const _snackBarDuration = Duration(seconds: 1);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(medidasViewModelProvider.notifier)
          .initialize(widget.dofItem, widget.fotoIndex);
    });
  }

  @override
  void dispose() {
    _errorDismissTimer?.cancel();
    super.dispose();
  }

  Future<void> _handleBackPress() async {
    final vm = ref.read(medidasViewModelProvider.notifier);
    if (!vm.hasUnsavedFormInput) {
      Navigator.of(context).pop();
      return;
    }
    final discard = await showConfirmDialog(
      context,
      title: 'Descartar valores?',
      message:
          'Os valores preenchidos ainda não foram inseridos na tabela. '
          'Se voltar agora, eles serão perdidos.',
      confirmLabel: 'Descartar',
      variant: ConfirmDialogVariant.danger,
    );
    if (discard && mounted) Navigator.of(context).pop();
  }

  Future<void> _salvarEFechar() async {
    final vm = ref.read(medidasViewModelProvider.notifier);
    final vmState = ref.read(medidasViewModelProvider);

    if (vm.precisaConfirmarSalvarIncompleto) {
      final continuar = await showConfirmDialog(
        context,
        title: 'Medição incompleta',
        message:
            'Você mediu ${vmState.totalPecasMedidas} de ${vm.yoloCountAtual} '
            'peças nesta foto. O status da fiscalização permanecerá como '
            '"Em Andamento".',
        confirmLabel: 'Salvar',
        variant: ConfirmDialogVariant.danger,
      );
      if (!continuar || !mounted) return;
    }

    final ok = await vm.salvar();
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop();
    } else {
      _mostrarAlerta('Erro ao salvar dados.');
    }
  }

  Future<void> _adicionarNaTabelaLocal() async {
    final vm = ref.read(medidasViewModelProvider.notifier);
    final erro = await vm.adicionarNaTabelaLocal();
    if (erro != null && mounted) _mostrarAlerta(erro);
  }

  void _mostrarAlerta(String message) {
    final now = DateTime.now();
    if (_lastErrorShown != null &&
        now.difference(_lastErrorShown!) < _errorRateLimit) {
      return;
    }
    _lastErrorShown = now;
    _errorDismissTimer?.cancel();
    setState(() => _errorMessageVisible = true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        duration: _snackBarDuration,
      ),
    );
    _errorDismissTimer = Timer(_snackBarDuration, () {
      if (mounted) setState(() => _errorMessageVisible = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final vmState = ref.watch(medidasViewModelProvider);
    final vm = ref.read(medidasViewModelProvider.notifier);
    final capturaState = ref.watch(capturaViewModelProvider);
    final yoloCount = vm.yoloCountAtual;
    final pecasRestantes = vm.pecasRestantes;
    final totalFotos = capturaState.fotos.length;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _handleBackPress();
      },
      child: AppScaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          leading: IconButton(
            tooltip: 'Voltar',
            icon: const Icon(Icons.chevron_left),
            onPressed: _handleBackPress,
            iconSize: 30,
          ),
          centerTitle: true,
          title: Text(
            'Medidas — Foto ${vmState.currentFotoIndex + 1}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 19),
          ),
          backgroundColor: AppColors.green,
          foregroundColor: Colors.white,
          elevation: 0,
          actions: [
            if (totalFotos > 1) ...[
              IconButton(
                tooltip: 'Foto anterior',
                icon: const Icon(Icons.chevron_left),
                onPressed:
                    (vmState.currentFotoIndex > 0 && !vmState.isNavigating)
                    ? () => vm.irParaFoto(vmState.currentFotoIndex - 1)
                    : null,
              ),
              Center(
                child: Text(
                  '${vmState.currentFotoIndex + 1}/$totalFotos',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Próxima foto',
                icon: const Icon(Icons.chevron_right),
                onPressed:
                    (vmState.currentFotoIndex < totalFotos - 1 &&
                        !vmState.isNavigating)
                    ? () => vm.irParaFoto(vmState.currentFotoIndex + 1)
                    : null,
              ),
            ],
          ],
        ),
        body: vmState.isNavigating || vmState.isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.green),
              )
            : Column(
                children: [
                  Container(
                    color: AppColors.green,
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 8,
                      ),
                      child: Row(
                        children: [
                          _buildContador(
                            'Contadas (IA)',
                            '$yoloCount',
                            Colors.black87,
                          ),
                          _buildDivider(),
                          _buildContador(
                            'Medidas',
                            '${vmState.totalPecasMedidas}',
                            AppColors.green,
                          ),
                          _buildDivider(),
                          _buildContador(
                            'Restantes',
                            '$pecasRestantes',
                            Colors.orange.shade700,
                          ),
                          _buildDivider(),
                          _buildContador(
                            'Total Sessão',
                            '${capturaState.totalCount}',
                            Colors.blueGrey.shade600,
                          ),
                        ],
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.eco_outlined,
                              size: 14,
                              color: AppColors.green,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                vmState.especieTexto,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: perfisComuns.map((t) {
                            return GestureDetector(
                              onTap: () => vm.preencherAtalho(t),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 7,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.04,
                                      ),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                                child: Text(
                                  t.rotulo,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade800,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 14),

                        Text(
                          vmState.emEdicao ? 'Editando medida' : 'Nova medida',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: vmState.emEdicao
                                ? Colors.blue.shade700
                                : Colors.grey.shade600,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 6),

                        Row(
                          children: [
                            Expanded(
                              child: _buildField(
                                vm.comprimentoController,
                                'Comp. (cm)',
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildField(
                                vm.larguraController,
                                'Larg. (cm)',
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildField(
                                vm.alturaController,
                                'Alt. (cm)',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        Row(
                          children: [
                            SizedBox(
                              width: 100,
                              child: _buildField(
                                vm.quantidadeController,
                                'Qtd.',
                                isInt: true,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: SizedBox(
                                height: 48,
                                child: ElevatedButton.icon(
                                  onPressed:
                                      (pecasRestantes == 0 &&
                                          !vmState.emEdicao) ||
                                      _errorMessageVisible
                                      ? null
                                      : _adicionarNaTabelaLocal,
                                  icon: Icon(
                                    vmState.emEdicao
                                        ? Icons.check
                                        : Icons.add,
                                    size: 18,
                                  ),
                                  label: Text(
                                    vmState.emEdicao
                                        ? 'Atualizar'
                                        : 'Inserir na Tabela',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: vmState.emEdicao
                                        ? Colors.blue.shade700
                                        : AppColors.green,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    elevation: 0,
                                  ),
                                ),
                              ),
                            ),
                            if (vmState.emEdicao) ...[
                              const SizedBox(width: 8),
                              SizedBox(
                                height: 48,
                                width: 48,
                                child: OutlinedButton(
                                  onPressed: vm.cancelarEdicao,
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(
                                      color: Colors.grey.shade400,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: EdgeInsets.zero,
                                  ),
                                  child: Icon(
                                    Icons.close,
                                    size: 20,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 14),

                        Row(
                          children: [
                            Icon(
                              Icons.table_rows_outlined,
                              size: 14,
                              color: Colors.grey.shade500,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Cubagem desta foto',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const Spacer(),
                            if (vmState.listaMedidas.isNotEmpty)
                              Text(
                                '${vmState.listaMedidas.length} ${vmState.listaMedidas.length == 1 ? 'grupo' : 'grupos'}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  Expanded(
                    child: vmState.listaMedidas.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.straighten_outlined,
                                  size: 40,
                                  color: Colors.grey.shade300,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Nenhuma medida inserida',
                                  style: TextStyle(
                                    color: Colors.grey.shade400,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: vmState.listaMedidas.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final item = vmState.listaMedidas[index];
                              final volume = vm.calcularVolumeM3(item);
                              final exibicaoCompCm = (item.comprimentoM * 100)
                                  .toStringAsFixed(0);
                              final isEditing =
                                  vmState.indexEmEdicao == index;

                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                decoration: BoxDecoration(
                                  color: isEditing
                                      ? Colors.blue.shade50
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isEditing
                                        ? Colors.blue.shade300
                                        : Colors.grey.shade200,
                                    width: isEditing ? 1.5 : 1,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 10,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '${item.quantidade} pçs  ·  $exibicaoCompCm × ${item.larguraCm.toStringAsFixed(0)} × ${item.alturaCm.toStringAsFixed(0)} cm',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 13,
                                              ),
                                            ),
                                            const SizedBox(height: 3),
                                            Text(
                                              '${volume.toStringAsFixed(4)} m³',
                                              style: const TextStyle(
                                                color: AppColors.green,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          Icons.edit_outlined,
                                          size: 19,
                                          color: Colors.blue.shade400,
                                        ),
                                        onPressed: () =>
                                            vm.iniciarEdicao(index),
                                        visualDensity: VisualDensity.compact,
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          Icons.delete_outline,
                                          size: 19,
                                          color: Colors.red.shade400,
                                        ),
                                        onPressed: () =>
                                            vm.removerItem(index),
                                        visualDensity: VisualDensity.compact,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),

                  const SizedBox(height: 4),

                  if (totalFotos > 1)
                    _buildThumbnailStrip(capturaState, vmState, vm),

                  _buildSaveButton(vmState),
                ],
              ),
      ),
    );
  }

  Widget _buildField(
    TextEditingController controller,
    String label, {
    bool isInt = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: isInt
          ? TextInputType.number
          : const TextInputType.numberWithOptions(decimal: true),
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.green, width: 1.8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        isDense: true,
      ),
    );
  }

  Widget _buildThumbnailStrip(
    CapturaState state,
    MedidasState vmState,
    MedidasViewModel vm,
  ) {
    return Container(
      height: 56,
      color: Colors.white,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        itemCount: state.fotos.length,
        itemBuilder: (context, i) {
          final isActive = i == vmState.currentFotoIndex;
          final count = state.fotos[i].count;
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: GestureDetector(
              onTap: vmState.isNavigating ? null : () => vm.irParaFoto(i),
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: isActive
                          ? Border.all(color: AppColors.green, width: 2.5)
                          : Border.all(color: Colors.grey.shade300, width: 1),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(isActive ? 5.5 : 7),
                      child: Image.file(
                        state.fotos[i].imageFile,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.all(2),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 3,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(
                      '$count',
                      style: const TextStyle(
                        color: AppColors.green,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSaveButton(MedidasState vmState) {
    return ActionBottomBar(
      onPressed: (vmState.emEdicao || vmState.isSaving)
            ? null
            : _salvarEFechar,
      child: const Text(
        'Concluir Fiscalização',
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildContador(String label, String valor, Color corValor) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.black45,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 3),
          Text(
            valor,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: corValor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(width: 1, height: 32, color: Colors.grey.shade200);
  }
}
