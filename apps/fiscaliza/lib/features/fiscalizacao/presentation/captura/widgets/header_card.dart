import 'package:flutter/material.dart';

import 'package:fiscaliza/design_system/theme/app_colors.dart';
import 'package:fiscaliza/features/dof/data/models/dof_item_model.dart';

class HeaderCard extends StatelessWidget {
  final DofItemModel dofItem;
  final bool isOver;
  final double volumeTotalM3;

  const HeaderCard({super.key, 
    required this.dofItem,
    required this.isOver,
    this.volumeTotalM3 = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    final showVolume = volumeTotalM3 > 0.0;
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  dofItem.produto,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${dofItem.especieCientifico} (${dofItem.nomePopular})',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'Saldo: ${dofItem.saldoTotal.toStringAsFixed(2)} ${dofItem.unidade}',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showVolume) ...[
                Text(
                  'Volume',
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                ),
                Text(
                  '${volumeTotalM3.toStringAsFixed(3)} m³',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isOver ? Colors.red.shade700 : AppColors.green,
                  ),
                ),
              ] else
                const Text(''),
            ],
          ),
        ],
      ),
    );
  }
}
