import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:isar/isar.dart';

import 'package:app/core/theme/app_colors.dart';
import 'package:app/features/dof/data/models/dof_item_model.dart';
import 'package:app/features/fiscalizacao/data/models/medicao_grupo_model.dart';

class MedidasScreen extends StatefulWidget {
  final DofItemModel dofItem;
  final int fotoIndex;

  const MedidasScreen({
    super.key,
    required this.dofItem,
    required this.fotoIndex,
  });

  @override
  State<MedidasScreen> createState() => _MedidasScreenState();
}

class _MedidasScreenState extends State<MedidasScreen> {
  final int totalDetectadoPelaIA = 15; 

  List<MedicaoGrupoModel> _listaMedidas = []; 
  Isar? _isar;

  final _comprimentoController = TextEditingController();
  final _larguraController = TextEditingController();
  final _alturaController = TextEditingController();
  final _quantidadeController = TextEditingController();

  String _especieTextoFixa = 'Espécie não identificada';
  int? _indexEmEdicao;

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
    _inicializarEspeciesDoDof();
    _inicializarBancoEBuscarDados();
  }

  void _inicializarBancoEBuscarDados() {
    try {
      _isar = Isar.getInstance(); // pega o banco ativo do app
      if (_isar != null) {
        _carregarMedidasDoBanco();
      }
    } catch (e) {
      debugPrint("Erro ao conectar com o Isar: $e");
    }
  }

  void _carregarMedidasDoBanco() {
    if (_isar == null) return;

    final dadosSalvos = _isar!.medicaoGrupoModels
        .filter()
        .dofItemIdEqualTo(widget.dofItem.id)
        .fotoIndexEqualTo(widget.fotoIndex)
        .findAllSync(); 

    debugPrint("Isar carregou: ${dadosSalvos.length} registros para o item ${widget.dofItem.id}");

    setState(() {
      _listaMedidas = List<MedicaoGrupoModel>.from(dadosSalvos);
    });
  }

  void _inicializarEspeciesDoDof() {
    final nomePopular = widget.dofItem.nomePopular.trim();
    final nomeCientifico = widget.dofItem.especieCientifico.trim();
    String textoExibicao = '';
    
    if (nomePopular.isNotEmpty && nomeCientifico.isNotEmpty) {
      textoExibicao = '$nomePopular ($nomeCientifico)';
    } else if (nomePopular.isNotEmpty) {
      textoExibicao = nomePopular;
    } else if (nomeCientifico.isNotEmpty) {
      textoExibicao = nomeCientifico;
    }

    if (widget.dofItem.produto.isNotEmpty) {
      textoExibicao += ' - ${widget.dofItem.produto}';
    }

    if (textoExibicao.isNotEmpty) {
      _especieTextoFixa = textoExibicao;
    }
  }

  int get pecasRestantes {
    int totalAtual = _listaMedidas.fold(0, (soma, item) => soma + item.quantidade);
    if (_indexEmEdicao != null) {
      final int qtdSendoEditada = _listaMedidas[_indexEmEdicao!].quantidade;
      return totalDetectadoPelaIA - (totalAtual - qtdSendoEditada);
    }
    return totalDetectadoPelaIA - totalAtual;
  }

  int get totalPecasMedidas {
    return _listaMedidas.fold(0, (soma, item) => soma + item.quantidade);
  }

  void _preencherAtalho(Map<String, dynamic> tamanho) {
    _comprimentoController.text = tamanho['comp'].toStringAsFixed(0);
    _larguraController.text = tamanho['larg'].toStringAsFixed(1).replaceAll('.0', '');
    _alturaController.text = tamanho['alt'].toStringAsFixed(1).replaceAll('.0', '');
    if (_quantidadeController.text.isEmpty) {
      _quantidadeController.text = '1';
    }
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

  void _salvarMedidaNaTabelaLocal() {
    final int qtdDigitada = int.tryParse(_quantidadeController.text) ?? 0;

    if (qtdDigitada <= 0) {
      _mostrarAlerta('A quantidade deve ser maior que zero.');
      return;
    }

    if (qtdDigitada > pecasRestantes) {
      _mostrarAlerta('Ação bloqueada! Restam apenas $pecasRestantes peças.');
      return;
    }

    final double compCm = double.tryParse(_comprimentoController.text) ?? 0.0;
    final double largCm = double.tryParse(_larguraController.text) ?? 0.0;
    final double altCm = double.tryParse(_alturaController.text) ?? 0.0;

    if (compCm <= 0 || largCm <= 0 || altCm <= 0) {
      _mostrarAlerta('Preencha as dimensões corretamente.');
      return;
    }

    setState(() {
      final novoItem = MedicaoGrupoModel(
        id: _indexEmEdicao != null ? _listaMedidas[_indexEmEdicao!].id : DateTime.now().microsecondsSinceEpoch.toString(), 
        dofItemId: widget.dofItem.id, 
        fotoIndex: widget.fotoIndex, 
        comprimentoM: compCm / 100, 
        larguraCm: largCm,
        alturaCm: altCm,
        quantidade: qtdDigitada,
        isPrincipal: _listaMedidas.isEmpty,
      );

      if (_indexEmEdicao != null) {
        novoItem.isarId = _listaMedidas[_indexEmEdicao!].isarId;
        _listaMedidas[_indexEmEdicao!] = novoItem;
        _indexEmEdicao = null;
      } else {
        novoItem.isarId = 0;
        _listaMedidas.add(novoItem);
      }

      _comprimentoController.clear();
      _larguraController.clear();
      _alturaController.clear();
      _quantidadeController.clear();
    });
  }

  void _persistirNoIsar() {
    if (_listaMedidas.isEmpty || _isar == null) return;

    try {
      _isar!.writeTxnSync(() {
        final antigas = _isar!.medicaoGrupoModels
            .filter()
            .dofItemIdEqualTo(widget.dofItem.id)
            .fotoIndexEqualTo(widget.fotoIndex)
            .findAllSync();
        
        for (var item in antigas) {
          _isar!.medicaoGrupoModels.deleteSync(item.isarId);
        }
        
        for (var item in _listaMedidas) {
          if (item.isarId == 0) {
            item.isarId = Isar.autoIncrement;
          }
          _isar!.medicaoGrupoModels.putSync(item);
        }
      });

      debugPrint("Isar gravou com sucesso ${_listaMedidas.length} itens!");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Medidas gravadas com sucesso no Isar!'), 
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

    } catch (e) {
      debugPrint("Erro crítico ao salvar no Isar: $e");
      _mostrarAlerta("Erro ao salvar dados localmente.");
    }
  }

  void _removerItem(int index) {
    final item = _listaMedidas[index];
    
    if (_isar != null && item.isarId != 0) {
      _isar!.writeTxnSync(() {
        _isar!.medicaoGrupoModels.deleteSync(item.isarId);
      });
    }

    setState(() {
      if (_indexEmEdicao == index) _cancelarEdicao();
      _listaMedidas.removeAt(index);
    });
  }

  double _calcularVolumeM3(MedicaoGrupoModel item) {
    return item.comprimentoM * (item.larguraCm / 100) * (item.alturaCm / 100) * item.quantidade;
  }

  void _mostrarAlerta(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red.shade700, behavior: SnackBarBehavior.floating),
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
    final bool emEdicao = _indexEmEdicao != null;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text('Medidas — Foto ${widget.fotoIndex + 1}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: AppColors.green,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 2,
              color: AppColors.green.withOpacity(0.08),
              shape: RoundedRectangleBorder(side: BorderSide(color: AppColors.green.withOpacity(0.3)), borderRadius: BorderRadius.circular(8)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildContadorStatus('Contadas (IA)', '$totalDetectadoPelaIA', Colors.black87),
                    _buildContadorStatus('Medidas', '$totalPecasMedidas', Colors.green.shade700),
                    _buildContadorStatus('Restantes', '$pecasRestantes', Colors.orange.shade800),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            const Text('Espécie Vinculada (Documento DOF):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _especieTextoFixa,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text('Preenchimento Rápido (Tamanhos Comuns):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _tamanhosComuns.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final tamanho = _tamanhosComuns[index];
                  return ActionChip(
                    label: Text('${tamanho['nome']} (${tamanho['larg'].toInt()}x${tamanho['alt']})'),
                    backgroundColor: Colors.grey.shade200,
                    onPressed: () => _preencherAtalho(tamanho),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            Text(emEdicao ? 'Editando Medida:' : 'Adicionar Medida Manual:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: emEdicao ? Colors.blue.shade700 : Colors.black87)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: TextField(controller: _comprimentoController, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Comp. (cm)', border: OutlineInputBorder(), contentPadding: EdgeInsets.all(10)))),
                const SizedBox(width: 6),
                Expanded(child: TextField(controller: _larguraController, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Larg. (cm)', border: OutlineInputBorder(), contentPadding: EdgeInsets.all(10)))),
                const SizedBox(width: 6),
                Expanded(child: TextField(controller: _alturaController, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Alt. (cm)', border: OutlineInputBorder(), contentPadding: EdgeInsets.all(10)))),
                const SizedBox(width: 6),
                Expanded(child: TextField(controller: _quantidadeController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Qtd.', border: OutlineInputBorder(), contentPadding: EdgeInsets.all(10)))),
              ],
            ),
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: pecasRestantes == 0 && !emEdicao ? null : _salvarMedidaNaTabelaLocal,
                    icon: Icon(emEdicao ? Icons.check : Icons.add),
                    label: Text(emEdicao ? 'Atualizar Medida' : 'Inserir na Tabela'),
                    style: ElevatedButton.styleFrom(backgroundColor: emEdicao ? Colors.blue.shade700 : AppColors.green, foregroundColor: Colors.white, minimumSize: const Size.fromHeight(45)),
                  ),
                ),
                if (emEdicao) ...[
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _cancelarEdicao,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade400, foregroundColor: Colors.white, minimumSize: const Size(45, 45), padding: EdgeInsets.zero),
                    child: const Icon(Icons.close),
                  ),
                ]
              ],
            ),
            const SizedBox(height: 24),

            const Text('Tabela de Cubagem Local (Padronizada em cm):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            _listaMedidas.isEmpty
                ? const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Center(child: Text('Nenhuma medida inserida para esta foto.', style: TextStyle(color: Colors.grey))))
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _listaMedidas.length,
                    itemBuilder: (context, index) {
                      final item = _listaMedidas[index];
                      final volume = _calcularVolumeM3(item);
                      final exibicaoCompCm = (item.comprimentoM * 100).toStringAsFixed(0);
                      final bool itemSendoEditado = _indexEmEdicao == index;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        color: itemSendoEditado ? Colors.blue.shade50 : Colors.white,
                        shape: RoundedRectangleBorder(side: BorderSide(color: itemSendoEditado ? Colors.blue : Colors.transparent, width: 1.5), borderRadius: BorderRadius.circular(8)),
                        child: ListTile(
                          title: Text('${item.quantidade}pçs — ${exibicaoCompCm}cm × ${item.larguraCm.toStringAsFixed(0)}cm × ${item.alturaCm.toStringAsFixed(0)}cm', style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                          subtitle: Text('Vol: ${volume.toStringAsFixed(3)} m³', style: TextStyle(color: AppColors.green, fontWeight: FontWeight.bold)),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _iniciarEdicao(index)),
                              IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: () => _removerItem(index)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: (_listaMedidas.isEmpty || emEdicao) ? null : _persistirNoIsar,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.green, disabledBackgroundColor: Colors.grey.shade300, minimumSize: const Size.fromHeight(50)),
              child: const Text('Salvar Medidas da Foto', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContadorStatus(String label, String valor, Color corValor) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54)),
        const SizedBox(height: 4),
        Text(valor, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: corValor)),
      ],
    );
  }
}