import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import 'package:app/core/theme/app_colors.dart';
import 'package:app/core/utils/formatting_converter.dart';
import 'package:app/features/dof/data/models/dof_item_model.dart';
import 'package:app/features/fiscalizacao/data/models/fiscalizacao_registro_model.dart';
import 'package:app/features/fiscalizacao/data/models/medicao_grupo_model.dart';
import 'package:app/features/fiscalizacao/domain/entities/status_fiscalizacao.dart';
import 'package:app/features/fiscalizacao/presentation/providers/fiscalizacao_providers.dart';

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
  List<MedicaoGrupoModel> _listaMedidas = [];
  int? _indexEmEdicao;
  bool _isSaving = false;
  bool _isNavigating = false;
  late int _currentFotoIndex;

  final _comprimentoController = TextEditingController();
  final _larguraController = TextEditingController();
  final _alturaController = TextEditingController();
  final _quantidadeController = TextEditingController();

  String _especieTextoFixa = 'Espécie não identificada';

  final List<Map<String, dynamic>> _tamanhosComuns = [
    {'nome': 'Prancha', 'comp': 300.0, 'larg': 30.0, 'alt': 5.0},
    {'nome': 'Viga', 'comp': 300.0, 'larg': 15.0, 'alt': 5.0},
    {'nome': 'Caibro', 'comp': 300.0, 'larg': 5.0, 'alt': 5.0},
    {'nome': 'Tábua', 'comp': 300.0, 'larg': 30.0, 'alt': 2.5},
    {'nome': 'Ripa', 'comp': 300.0, 'larg': 5.0, 'alt': 1.5},
  ];

  @override
  void initState() {
    super.initState();
    _currentFotoIndex = widget.fotoIndex;
    _inicializarEspeciesDoDof();
    WidgetsBinding.instance.addPostFrameCallback((_) => _carregarMedidas());
  }

  Future<void> _carregarMedidas() async {
    final ds = ref.read(fiscalizacaoLocalDatasourceProvider);
    final salvos = await ds.getMedicoesDaFoto(widget.dofItem.id, _currentFotoIndex);
    if (!mounted) return;
    setState(() {
      _listaMedidas = List<MedicaoGrupoModel>.from(salvos);
    });
  }

  void _inicializarEspeciesDoDof() {
    final nomePopular = widget.dofItem.nomePopular.trim();
    final nomeCientifico = widget.dofItem.especieCientifico.trim();
    String texto = '';
    if (nomePopular.isNotEmpty && nomeCientifico.isNotEmpty) {
      texto = '$nomePopular ($nomeCientifico)';
    } else if (nomePopular.isNotEmpty) {
      texto = nomePopular;
    } else if (nomeCientifico.isNotEmpty) {
      texto = nomeCientifico;
    }
    if (widget.dofItem.produto.isNotEmpty) {
      texto += ' - ${widget.dofItem.produto}';
    }
    if (texto.isNotEmpty) _especieTextoFixa = texto;
  }

  int _yoloCountFor(CapturaState capturaState) {
    return _currentFotoIndex < capturaState.fotos.length
        ? capturaState.fotos[_currentFotoIndex].count
        : 0;
  }

  int get _totalPecasMedidas =>
      _listaMedidas.fold(0, (soma, item) => soma + item.quantidade);

  int _pecasRestantesFor(int yoloCount) {
    final total = _listaMedidas.fold(0, (soma, item) => soma + item.quantidade);
    if (_indexEmEdicao != null) {
      final qtdEditando = _listaMedidas[_indexEmEdicao!].quantidade;
      return yoloCount - (total - qtdEditando);
    }
    return yoloCount - total;
  }

  void _preencherAtalho(Map<String, dynamic> tamanho) {
    _comprimentoController.text = tamanho['comp'].toStringAsFixed(0);
    _larguraController.text = tamanho['larg'].toStringAsFixed(1).replaceAll('.0', '');
    _alturaController.text = tamanho['alt'].toStringAsFixed(1).replaceAll('.0', '');
    if (_quantidadeController.text.isEmpty) _quantidadeController.text = '1';
  }

  void _iniciarEdicao(int index) {
    final item = _listaMedidas[index];
    setState(() {
      _indexEmEdicao = index;
      _comprimentoController.text = (item.comprimentoM * 100).toStringAsFixed(0);
      _larguraController.text = item.larguraCm.toStringAsFixed(1).replaceAll('.0', '');
      _alturaController.text = item.alturaCm.toStringAsFixed(1).replaceAll('.0', '');
      _quantidadeController.text = item.quantidade.toString();
    });
  }

  void _cancelarEdicao() {
    setState(() {
      _indexEmEdicao = null;
      _comprimentoController.clear();
      _larguraController.clear();
      _alturaController.clear();
      _quantidadeController.clear();
    });
  }

  // Snapshot obrigatório: evita ConcurrentModificationError se setState mutar
  // _listaMedidas enquanto o writeTxn do Isar está suspenso num await interno.
  Future<void> _persistirMedidas() async {
    try {
      final ds = ref.read(fiscalizacaoLocalDatasourceProvider);
      final snapshot = List<MedicaoGrupoModel>.from(_listaMedidas);
      await ds.saveMedicoesDaFoto(widget.dofItem.id, _currentFotoIndex, snapshot);
    } catch (e) {
      debugPrint('[Medidas] Erro ao persistir: $e');
      if (mounted) _mostrarAlerta('Erro ao salvar medida.');
    }
  }

  Future<void> _adicionarNaTabelaLocal(int yoloCount) async {
    final pecasRestantes = _pecasRestantesFor(yoloCount);
    final qtd = int.tryParse(_quantidadeController.text) ?? 0;
    if (qtd <= 0) {
      _mostrarAlerta('A quantidade deve ser maior que zero.');
      return;
    }
    if (qtd > pecasRestantes) {
      _mostrarAlerta('Ação bloqueada! Restam apenas $pecasRestantes peças.');
      return;
    }
    final compCm = double.tryParse(_comprimentoController.text) ?? 0.0;
    final largCm = double.tryParse(_larguraController.text) ?? 0.0;
    final altCm = double.tryParse(_alturaController.text) ?? 0.0;
    if (compCm <= 0 || largCm <= 0 || altCm <= 0) {
      _mostrarAlerta('Preencha as dimensões corretamente.');
      return;
    }

    setState(() {
      final novoItem = MedicaoGrupoModel(
        id: _indexEmEdicao != null
            ? _listaMedidas[_indexEmEdicao!].id
            : const Uuid().v4(),
        dofItemId: widget.dofItem.id,
        fotoIndex: _currentFotoIndex,
        comprimentoM: compCm / 100,
        larguraCm: largCm,
        alturaCm: altCm,
        quantidade: qtd,
        isPrincipal: _listaMedidas.isEmpty,
      );

      if (_indexEmEdicao != null) {
        novoItem.isarId = _listaMedidas[_indexEmEdicao!].isarId;
        _listaMedidas[_indexEmEdicao!] = novoItem;
        _indexEmEdicao = null;
      } else {
        final compM = compCm / 100;
        final idxExistente = _listaMedidas.indexWhere((m) =>
            (m.comprimentoM - compM).abs() < 1e-6 &&
            (m.larguraCm - largCm).abs() < 1e-6 &&
            (m.alturaCm - altCm).abs() < 1e-6);
        if (idxExistente != -1) {
          final existente = _listaMedidas[idxExistente];
          final merged = MedicaoGrupoModel(
            id: existente.id,
            dofItemId: existente.dofItemId,
            fotoIndex: existente.fotoIndex,
            comprimentoM: existente.comprimentoM,
            larguraCm: existente.larguraCm,
            alturaCm: existente.alturaCm,
            quantidade: existente.quantidade + qtd,
            isPrincipal: existente.isPrincipal,
          )..isarId = existente.isarId;
          _listaMedidas[idxExistente] = merged;
        } else {
          _listaMedidas.add(novoItem);
        }
      }

      _comprimentoController.clear();
      _larguraController.clear();
      _alturaController.clear();
      _quantidadeController.clear();
    });

    // Persiste imediatamente após a mutação
    await _persistirMedidas();
  }

  Future<void> _removerItem(int index) async {
    setState(() {
      if (_indexEmEdicao == index) _cancelarEdicao();
      _listaMedidas.removeAt(index);
    });
    await _persistirMedidas();
  }

  Future<void> _irParaFoto(int novoIndex) async {
    if (_isNavigating || novoIndex == _currentFotoIndex) return;
    setState(() => _isNavigating = true);

    // Já persistido a cada mutação, só recarrega a nova foto
    final ds = ref.read(fiscalizacaoLocalDatasourceProvider);
    final salvos = await ds.getMedicoesDaFoto(widget.dofItem.id, novoIndex);

    if (!mounted) return;
    setState(() {
      _currentFotoIndex = novoIndex;
      _listaMedidas = List.from(salvos);
      _indexEmEdicao = null;
      _comprimentoController.clear();
      _larguraController.clear();
      _alturaController.clear();
      _quantidadeController.clear();
      _isNavigating = false;
    });
  }

  Future<void> _salvarEFechar() async {
    if (_isSaving) return;

    final capturaState = ref.read(capturaNotifierProvider);
    final yoloCount = _yoloCountFor(capturaState);

    if (_totalPecasMedidas < yoloCount) {
      final continuar = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Medição incompleta'),
          content: Text(
            'Você mediu $_totalPecasMedidas de $yoloCount peças nesta foto. '
            'O status da fiscalização permanecerá como "Em Andamento".\n\n'
            'Deseja salvar assim mesmo?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(
                'Salvar assim mesmo',
                style: TextStyle(color: Colors.orange.shade700),
              ),
            ),
          ],
        ),
      );
      if (continuar != true || !mounted) return;
    }

    setState(() => _isSaving = true);

    try {
      final ds = ref.read(fiscalizacaoLocalDatasourceProvider);

      // Medidas já persistidas — só atualiza o registro de fiscalização
      final existing = await ds.getByDofItemId(widget.dofItem.id);
      if (existing != null) {
        final todosMedicoes = await ds.getMedicoesByDofItem(widget.dofItem.id);
        final volumeTotal = todosMedicoes.fold<double>(
          0.0,
          (sum, m) => sum + FormattingConverter.calcularVolume(
            larguraCm: m.larguraCm,
            alturaCm: m.alturaCm,
            comprimentoM: m.comprimentoM,
            quantidade: m.quantidade,
          ),
        );

        final totalMedido = todosMedicoes.fold(0, (s, m) => s + m.quantidade);
        final todosMediados = totalMedido >= existing.contagemTotal;

        final StatusFiscalizacao novoStatus;
        if (!todosMediados || volumeTotal == 0.0) {
          novoStatus = StatusFiscalizacao.emAndamento;
        } else if (volumeTotal <= widget.dofItem.saldoTotal) {
          novoStatus = StatusFiscalizacao.concluido;
        } else {
          novoStatus = StatusFiscalizacao.excedente;
        }

        final atualizado = FiscalizacaoRegistroModel(
          id: existing.id,
          dofItemId: existing.dofItemId,
          contagemTotal: existing.contagemTotal,
          fotoPaths: existing.fotoPaths,
          dataCaptura: existing.dataCaptura,
          status: novoStatus,
          detecoesPorFoto: existing.detecoesPorFoto,
          volumeTotalM3: volumeTotal,
        );
        atualizado.isarId = existing.isarId;
        await ds.saveRegistro(atualizado);

        ref.invalidate(registroPorItemProvider(widget.dofItem.id));
        await ref.read(registroPorItemProvider(widget.dofItem.id).future);
      }

      if (mounted) context.pop();
    } catch (e) {
      debugPrint('[Medidas] Erro ao salvar: $e');
      if (mounted) _mostrarAlerta('Erro ao salvar dados.');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  double _calcularVolumeM3(MedicaoGrupoModel item) =>
      item.comprimentoM * (item.larguraCm / 100) * (item.alturaCm / 100) * item.quantidade;

  void _mostrarAlerta(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _comprimentoController.dispose();
    _larguraController.dispose();
    _alturaController.dispose();
    _quantidadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final capturaState = ref.watch(capturaNotifierProvider);
    final bool emEdicao = _indexEmEdicao != null;
    final yoloCount = _yoloCountFor(capturaState);
    final pecasRestantes = _pecasRestantesFor(yoloCount);
    final totalFotos = capturaState.fotos.length;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Medidas — Foto ${_currentFotoIndex + 1}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        backgroundColor: AppColors.green,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (totalFotos > 1) ...[
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: (_currentFotoIndex > 0 && !_isNavigating)
                  ? () => _irParaFoto(_currentFotoIndex - 1)
                  : null,
            ),
            Center(
              child: Text(
                '${_currentFotoIndex + 1}/$totalFotos',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: (_currentFotoIndex < totalFotos - 1 && !_isNavigating)
                  ? () => _irParaFoto(_currentFotoIndex + 1)
                  : null,
            ),
          ],
        ],
      ),
      body: _isNavigating
          ? const Center(child: CircularProgressIndicator(color: AppColors.green))
          : Column(
              children: [
                // ─── Contadores ──────────────────────────────────────────
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
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                    child: Row(
                      children: [
                        _buildContador('Contadas (IA)', '$yoloCount', Colors.black87),
                        _buildDivider(),
                        _buildContador('Medidas', '$_totalPecasMedidas', AppColors.green),
                        _buildDivider(),
                        _buildContador('Restantes', '$pecasRestantes', Colors.orange.shade700),
                        _buildDivider(),
                        _buildContador('Total Sessão', '${capturaState.totalCount}', Colors.blueGrey.shade600),
                      ],
                    ),
                  ),
                ),

                // ─── Área scrollável: espécie + atalhos + formulário ──────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Espécie
                      Row(
                        children: [
                          Icon(Icons.eco_outlined, size: 14, color: AppColors.green),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              _especieTextoFixa,
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

                      // Atalhos
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: _tamanhosComuns.map((t) {
                          return GestureDetector(
                            onTap: () => _preencherAtalho(t),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.grey.shade300),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.04),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: Text(
                                '${t['nome']} ${(t['larg'] as double).toInt()}×${t['alt']}',
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade800),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 14),

                      // Label do formulário
                      Text(
                        emEdicao ? 'Editando medida' : 'Nova medida',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: emEdicao ? Colors.blue.shade700 : Colors.grey.shade600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Campos dimensões (linha 1)
                      Row(
                        children: [
                          Expanded(child: _buildField(_comprimentoController, 'Comp. (cm)')),
                          const SizedBox(width: 8),
                          Expanded(child: _buildField(_larguraController, 'Larg. (cm)')),
                          const SizedBox(width: 8),
                          Expanded(child: _buildField(_alturaController, 'Alt. (cm)')),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Quantidade + botão (linha 2)
                      Row(
                        children: [
                          SizedBox(
                            width: 100,
                            child: _buildField(_quantidadeController, 'Qtd.', isInt: true),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: SizedBox(
                              height: 48,
                              child: ElevatedButton.icon(
                                onPressed: (pecasRestantes == 0 && !emEdicao)
                                    ? null
                                    : () => _adicionarNaTabelaLocal(yoloCount),
                                icon: Icon(emEdicao ? Icons.check : Icons.add, size: 18),
                                label: Text(
                                  emEdicao ? 'Atualizar' : 'Inserir na Tabela',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: emEdicao ? Colors.blue.shade700 : AppColors.green,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  elevation: 0,
                                ),
                              ),
                            ),
                          ),
                          if (emEdicao) ...[
                            const SizedBox(width: 8),
                            SizedBox(
                              height: 48,
                              width: 48,
                              child: OutlinedButton(
                                onPressed: _cancelarEdicao,
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: Colors.grey.shade400),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: EdgeInsets.zero,
                                ),
                                child: Icon(Icons.close, size: 20, color: Colors.grey.shade600),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Cabeçalho tabela
                      Row(
                        children: [
                          Icon(Icons.table_rows_outlined, size: 14, color: Colors.grey.shade500),
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
                          if (_listaMedidas.isNotEmpty)
                            Text(
                              '${_listaMedidas.length} ${_listaMedidas.length == 1 ? 'grupo' : 'grupos'}',
                              style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // ─── Tabela scrollável ────────────────────────────────────
                Expanded(
                  child: _listaMedidas.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.straighten_outlined, size: 40, color: Colors.grey.shade300),
                              const SizedBox(height: 8),
                              Text(
                                'Nenhuma medida inserida',
                                style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _listaMedidas.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final item = _listaMedidas[index];
                            final volume = _calcularVolumeM3(item);
                            final exibicaoCompCm = (item.comprimentoM * 100).toStringAsFixed(0);
                            final isEditing = _indexEmEdicao == index;

                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              decoration: BoxDecoration(
                                color: isEditing ? Colors.blue.shade50 : Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isEditing ? Colors.blue.shade300 : Colors.grey.shade200,
                                  width: isEditing ? 1.5 : 1,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
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
                                            style: TextStyle(
                                              color: AppColors.green,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.edit_outlined, size: 19, color: Colors.blue.shade400),
                                      onPressed: () => _iniciarEdicao(index),
                                      visualDensity: VisualDensity.compact,
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete_outline, size: 19, color: Colors.red.shade400),
                                      onPressed: () => _removerItem(index),
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

                // ─── Thumbnail strip ──────────────────────────────────────
                if (totalFotos > 1) _buildThumbnailStrip(capturaState),

                // ─── Botão salvar fixo ────────────────────────────────────
                _buildSaveButton(),
              ],
            ),
    );
  }

  Widget _buildField(TextEditingController controller, String label, {bool isInt = false}) {
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

  Widget _buildThumbnailStrip(CapturaState state) {
    return Container(
      height: 56,
      color: Colors.white,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        itemCount: state.fotos.length,
        itemBuilder: (context, i) {
          final isActive = i == _currentFotoIndex;
          final count = state.fotos[i].count;
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: GestureDetector(
              onTap: _isNavigating ? null : () => _irParaFoto(i),
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
                      child: Image.file(state.fotos[i].imageFile, fit: BoxFit.cover),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.all(2),
                    padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
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

  Widget _buildSaveButton() {
    final emEdicao = _indexEmEdicao != null;
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      child: ElevatedButton(
        onPressed: (emEdicao || _isSaving) ? null : _salvarEFechar,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.green,
          disabledBackgroundColor: Colors.grey.shade200,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: _isSaving
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : const Text(
                'Salvar Medidas da Foto',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
      ),
    );
  }

  Widget _buildContador(String label, String valor, Color corValor) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 10, color: Colors.black45, height: 1.2),
              textAlign: TextAlign.center),
          const SizedBox(height: 3),
          Text(
            valor,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: corValor),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(width: 1, height: 32, color: Colors.grey.shade200);
  }
}
