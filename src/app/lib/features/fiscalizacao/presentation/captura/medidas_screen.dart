import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:app/core/theme/app_colors.dart';
import 'package:app/features/dof/data/models/dof_item_model.dart';

class MedidasScreen extends StatelessWidget {
  final DofItemModel dofItem;
  final int fotoIndex;

  const MedidasScreen({
    super.key,
    required this.dofItem,
    required this.fotoIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Medidas — Foto ${fotoIndex + 1}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        backgroundColor: AppColors.green,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('Em construção'),
      ),
    );
  }
}
