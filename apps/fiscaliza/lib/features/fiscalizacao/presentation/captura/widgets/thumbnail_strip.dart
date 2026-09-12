import 'package:flutter/material.dart';

import 'package:fiscaliza/design_system/theme/app_colors.dart';
import 'package:fiscaliza/features/fiscalizacao/presentation/captura/foto_session.dart';

class ThumbnailStrip extends StatelessWidget {
  final List<FotoSession> fotos;
  final int currentIndex;
  final VoidCallback onAdicionar;
  final ValueChanged<int> onSelecionar;
  final ValueChanged<int> onRemover;

  const ThumbnailStrip({
    super.key,
    required this.fotos,
    required this.currentIndex,
    required this.onAdicionar,
    required this.onSelecionar,
    required this.onRemover,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: fotos.length + 1,
        itemBuilder: (context, i) {
          if (i == fotos.length) return _BotaoAdicionar(onTap: onAdicionar);
          return _Miniatura(
            foto: fotos[i],
            isAtiva: i == currentIndex,
            onTap: () => onSelecionar(i),
            onLongPress: () => onRemover(i),
          );
        },
      ),
    );
  }
}

class _BotaoAdicionar extends StatelessWidget {
  final VoidCallback onTap;

  const _BotaoAdicionar({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 48,
          decoration: BoxDecoration(
            color: AppColors.green.withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.add, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}

class _Miniatura extends StatelessWidget {
  final FotoSession foto;
  final bool isAtiva;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _Miniatura({
    required this.foto,
    required this.isAtiva,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              width: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: isAtiva
                    ? Border.all(color: AppColors.green, width: 2)
                    : Border.all(color: Colors.grey.shade500),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(isAtiva ? 2 : 3),
                child: Image.file(foto.imageFile, fit: BoxFit.cover),
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
                '${foto.count}',
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
  }
}
