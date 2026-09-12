import 'package:fiscaliza/app/router/app_routes.dart';
import 'package:fiscaliza/design_system/theme/app_colors.dart';
import 'package:fiscaliza/design_system/components/app_icon.dart';
import 'package:fiscaliza/design_system/components/app_scaffold.dart';
import 'package:fiscaliza/design_system/components/fiscaliza_bottom_nav.dart';
import 'package:fiscaliza/design_system/components/fiscaliza_list_tile.dart';
import 'package:fiscaliza/features/fiscalizacao/data/models/fiscalizacao_sessao_model.dart';
import 'package:fiscaliza/features/fiscalizacao/domain/entities/status_fiscalizacao.dart';
import 'package:fiscaliza/features/fiscalizacao/data/fiscalizacao_providers.dart';
import 'package:fiscaliza/design_system/components/status_pill.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const _warningBg = Color(0xFFFFF3E0);
  static const _warningColor = Color(0xFFF57C00);
  static const _textDark = Color(0xFF333333);
  static const _textGrey = Color(0xFF757575);

  String _formatData(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    return '$dd/$mm/${d.year}';
  }

  String _formatVolume(double v) {
    return '${v.toStringAsFixed(1).replaceAll('.', ',')} m³ fiscalizados';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessaoAtiva = ref.watch(sessaoAtivaProvider).value;
    final progresso = ref.watch(progressoSessaoAtivaProvider).value;
    final sessoesRecentes =
        ref.watch(sessoesRecentesProvider).value ?? const [];

    return AppScaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: _buildHeader(),
                  ),
                  if (sessaoAtiva != null) ...[
                    const SizedBox(height: 18),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildBannerAndamento(
                        context,
                        sessaoAtiva,
                        progresso?.$1 ?? 0,
                        progresso?.$2 ?? 0,
                      ),
                    ),
                  ],
                  const SizedBox(height: 18),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildCtaPrimaria(context),
                  ),
                  const SizedBox(height: 6),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Importa uma nova planilha DOF',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 10, color: _textGrey),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildSectionHeader(context),
                  ),
                  const SizedBox(height: 14),
                  _buildLista(sessoesRecentes),
                ],
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(bottom: 50, top: 6),
            child: Center(
              child: FiscalizaBottomNav(active: FiscalizaNavTab.inicio),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(
          'assets/icons/Logomarca.png',
          width: 40,
          fit: BoxFit.contain,
        ),
        const SizedBox(width: 10),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'FISCALIZA',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 18,
                color: _textDark,
                letterSpacing: 0.3,
              ),
            ),
            Text(
              'Fiscalização Florestal Digital',
              style: TextStyle(fontSize: 9.5, color: _textGrey),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBannerAndamento(
    BuildContext context,
    FiscalizacaoSessaoModel sessao,
    int concluidos,
    int total,
  ) {
    return Material(
      color: _warningBg,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => context.push(AppRoutes.hub),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 2),
                child: AppSvgIcon(
                  AppIcon.history,
                  size: 24,
                  color: _warningColor,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            'Fiscalização em andamento',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: _textDark,
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Continuar ›',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: _warningColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      sessao.madeireiraNome,
                      style: const TextStyle(fontSize: 16, color: _textDark),
                    ),
                    const SizedBox(height: 40),
                    Text(
                      '$concluidos de $total itens concluídos',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF5F5F5F),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCtaPrimaria(BuildContext context) {
    return SizedBox(
      height: 64,
      child: Material(
        color: AppColors.green,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => context.push(AppRoutes.uploadDof),
          child: const Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppSvgIcon(AppIcon.upload, size: 24, color: AppColors.white),
                SizedBox(width: 8),
                Text(
                  'Iniciar Nova Fiscalização',
                  style: TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          'Últimas Fiscalizações',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: _textDark,
          ),
        ),
        InkWell(
          onTap: () => context.push(AppRoutes.historico),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Ver tudo',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.green,
                ),
              ),
              SizedBox(width: 2),
              AppSvgIcon(
                AppIcon.chevronRight,
                size: 11,
                color: AppColors.green,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLista(List<FiscalizacaoSessaoModel> sessoes) {
    if (sessoes.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 28),
        child: Center(
          child: Text(
            'Nenhuma fiscalização concluída ainda',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ),
      );
    }
    return Column(
      children: [
        for (int i = 0; i < sessoes.length; i++)
          _buildSessaoTile(sessoes[i], showDivider: i != sessoes.length - 1),
      ],
    );
  }

  Widget _buildSessaoTile(
    FiscalizacaoSessaoModel sessao, {
    required bool showDivider,
  }) {
    final status = (sessao.itensExcedentesSnapshot ?? 0) > 0
        ? StatusFiscalizacao.excedente
        : StatusFiscalizacao.concluido;
    final corDestaque = StatusPill.colorFor(status);
    final data = sessao.concluidaEm ?? sessao.iniciadaEm;

    return FiscalizaListTile(
      title: sessao.madeireiraNome,
      titleFontSize: 11.5,
      titleColor: _textDark,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      pill: StatusPill(status),
      metaRows: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FiscalizaMetaChip(icon: AppIcon.history, text: _formatData(data)),
            const SizedBox(width: 12),
            FiscalizaMetaChip(
              icon: AppIcon.box,
              text: '${sessao.itensTotalSnapshot ?? 0} produtos',
            ),
          ],
        ),
      ],
      highlightRow: Text(
        _formatVolume(sessao.volumeTotalSnapshot ?? 0),
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
          color: corDestaque,
        ),
      ),
      showDivider: showDivider,
    );
  }
}
