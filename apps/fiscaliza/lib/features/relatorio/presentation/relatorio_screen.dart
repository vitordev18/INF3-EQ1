import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:fiscaliza/app/router/app_routes.dart';
import 'package:fiscaliza/design_system/components/app_scaffold.dart';
import 'package:fiscaliza/design_system/theme/app_colors.dart';
import 'package:fiscaliza/design_system/theme/app_spacing.dart';
import 'package:fiscaliza/features/relatorio/data/relatorio_providers.dart';
import 'package:fiscaliza/features/relatorio/domain/linha_relatorio.dart';

class RelatorioScreen extends ConsumerWidget {
  const RelatorioScreen({super.key});

  static const _excedenteColor = Color(0xFFD32F2F);
  static const _naoInformado = 'Não informado';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final relatorioAsync = ref.watch(relatorioSessaoAtivaProvider);

    return AppScaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Relatório',
          style: TextStyle(
            color: AppColors.black,
            fontWeight: FontWeight.bold,
            fontSize: 19,
          ),
        ),
        leading: IconButton(
          tooltip: 'Voltar',
          icon: const Icon(Icons.chevron_left, color: AppColors.black),
          onPressed: () => context.go(AppRoutes.hub),
          iconSize: 30,
        ),
      ),
      body: relatorioAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const _Mensagem('Não foi possível montar o relatório.'),
        data: (relatorio) {
          if (relatorio == null) {
            return const _Mensagem('Nenhuma fiscalização em andamento.');
          }
          if (relatorio.vazio) {
            return const _Mensagem(
              'Nenhum item importado nesta fiscalização.',
            );
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Cabecalho(relatorio.cabecalho),
                const SizedBox(height: AppSpacing.lg),
                _ListaEspecies(relatorio.blocos),
                const SizedBox(height: AppSpacing.lg),
                _Totais(relatorio),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Mensagem extends StatelessWidget {
  final String texto;

  const _Mensagem(this.texto);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
        child: Text(
          texto,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ),
    );
  }
}

class _Cabecalho extends StatelessWidget {
  final CabecalhoRelatorio cabecalho;

  const _Cabecalho(this.cabecalho);

  String _ou(String valor) =>
      valor.trim().isEmpty ? RelatorioScreen._naoInformado : valor.trim();

  String _data(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/'
      '${d.month.toString().padLeft(2, '0')}/${d.year}';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.lightGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Campo('Madeireira', _ou(cabecalho.madeireiraNome)),
          const SizedBox(height: AppSpacing.sm),
          _Campo('CNPJ', _ou(cabecalho.cnpj)),
          const SizedBox(height: AppSpacing.sm),
          _Campo('Endereço', _ou(cabecalho.endereco)),
          const SizedBox(height: AppSpacing.sm),
          _Campo('Data', _data(cabecalho.dataFiscalizacao)),
        ],
      ),
    );
  }
}

class _Campo extends StatelessWidget {
  final String rotulo;
  final String valor;

  const _Campo(this.rotulo, this.valor);

  @override
  Widget build(BuildContext context) {
    final naoInformado = valor == RelatorioScreen._naoInformado;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 92,
          child: Text(
            rotulo,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        Expanded(
          child: Text(
            valor,
            style: TextStyle(
              fontSize: 14,
              fontWeight: naoInformado ? FontWeight.normal : FontWeight.w600,
              color: naoInformado ? AppColors.grey : AppColors.black,
              fontStyle: naoInformado ? FontStyle.italic : FontStyle.normal,
            ),
          ),
        ),
      ],
    );
  }
}


String _m3(double valor) => '${valor.toStringAsFixed(3)} m³';

class _ListaEspecies extends StatelessWidget {
  final List<BlocoEspecie> blocos;

  const _ListaEspecies(this.blocos);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (int i = 0; i < blocos.length; i++) ...[
          if (i > 0) const SizedBox(height: AppSpacing.md),
          _CardEspecie(blocos[i]),
        ],
      ],
    );
  }
}

class _CardEspecie extends StatelessWidget {
  final BlocoEspecie bloco;

  const _CardEspecie(this.bloco);

  @override
  Widget build(BuildContext context) {
    final corSaldo = bloco.excedente
        ? RelatorioScreen._excedenteColor
        : AppColors.black;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: bloco.excedente
              ? RelatorioScreen._excedenteColor
              : AppColors.lightGrey,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.md,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bloco.especieCientifico,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          fontStyle: FontStyle.italic,
                          color: AppColors.black,
                        ),
                      ),
                      if (bloco.nomePopular.trim().isNotEmpty)
                        Text(
                          bloco.nomePopular,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.grey,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Flexible(
                  child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'TOTAL DOF',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: .6,
                        color: AppColors.grey,
                      ),
                    ),
                    Text(
                      _m3(bloco.totalDofM3),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.black,
                      ),
                    ),
                  ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: AppColors.lightGrey),
          if (bloco.semMedicao)
            const Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: Text(
                'Nenhuma medida registrada para esta espécie.',
                style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: AppColors.grey,
                ),
              ),
            )
          else
            for (final linha in bloco.linhas) _LinhaMedida(linha),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            decoration: const BoxDecoration(
              color: AppColors.lightWhite,
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(11),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    bloco.excedente ? 'Excedente' : 'Saldo restante',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: corSaldo,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  _m3(bloco.saldoM3),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: corSaldo,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LinhaMedida extends StatelessWidget {
  final LinhaRelatorio linha;

  const _LinhaMedida(this.linha);

  String _dimensoes() =>
      '${linha.larguraCm.toStringAsFixed(1)} × '
      '${linha.alturaCm.toStringAsFixed(1)} cm × '
      '${linha.comprimentoM.toStringAsFixed(2)} m';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.lightGrey,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'N° ${linha.numeroOrdem}',
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: AppColors.grey,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  _dimensoes(),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              Expanded(
                child: _Medida('Peças', '${linha.quantidade}'),
              ),
              Expanded(
                child: _Medida('Total físico', _m3(linha.totalFisicoM3)),
              ),
              Expanded(
                child: _Medida(
                  'Diferença',
                  _m3(linha.diferencaM3),
                  cor: linha.excedente
                      ? RelatorioScreen._excedenteColor
                      : AppColors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Medida extends StatelessWidget {
  final String rotulo;
  final String valor;
  final Color? cor;

  const _Medida(this.rotulo, this.valor, {this.cor});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          rotulo,
          style: const TextStyle(fontSize: 9, color: AppColors.grey),
        ),
        Text(
          valor,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: cor ?? AppColors.black,
          ),
        ),
      ],
    );
  }
}

class _Totais extends StatelessWidget {
  final Relatorio relatorio;

  const _Totais(this.relatorio);

  @override
  Widget build(BuildContext context) {
    final fisico = relatorio.totalFisicoGeralM3;
    final dof = relatorio.totalDofGeralM3;
    final saldo = dof - fisico;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.lightGrey),
      ),
      child: Column(
        children: [
          _LinhaTotal('Total físico apurado', '${fisico.toStringAsFixed(3)} m³'),
          const SizedBox(height: AppSpacing.sm),
          _LinhaTotal('Total declarado no DOF', '${dof.toStringAsFixed(3)} m³'),
          const Divider(height: AppSpacing.xl),
          _LinhaTotal(
            saldo < 0 ? 'Excedente' : 'Saldo não localizado',
            '${saldo.toStringAsFixed(3)} m³',
            destaque: true,
            cor: saldo < 0 ? RelatorioScreen._excedenteColor : AppColors.black,
          ),
        ],
      ),
    );
  }
}

class _LinhaTotal extends StatelessWidget {
  final String rotulo;
  final String valor;
  final bool destaque;
  final Color? cor;

  const _LinhaTotal(
    this.rotulo,
    this.valor, {
    this.destaque = false,
    this.cor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            rotulo,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              fontWeight: destaque ? FontWeight.w600 : FontWeight.normal,
              color: destaque ? AppColors.black : AppColors.grey,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          valor,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: destaque ? 16 : 14,
            fontWeight: FontWeight.w700,
            color: cor ?? AppColors.black,
          ),
        ),
      ],
    );
  }
}
