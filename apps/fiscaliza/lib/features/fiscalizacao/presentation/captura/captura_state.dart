import 'package:flutter/material.dart';

import 'package:fiscaliza/core/utils/sentinel.dart';
import 'package:fiscaliza/features/fiscalizacao/presentation/captura/foto_session.dart';

class CapturaState {
  final List<FotoSession> fotos;
  final int currentIndex;
  final bool isProcessing;
  final bool modelReady;
  final bool modelError;
  final bool isEditMode;
  final bool isRegionMode;
  final Rect? draggingRegion;
  final bool isDirty;

  const CapturaState({
    this.fotos = const [],
    this.currentIndex = 0,
    this.isProcessing = false,
    this.modelReady = false,
    this.modelError = false,
    this.isEditMode = false,
    this.isRegionMode = false,
    this.draggingRegion,
    this.isDirty = false,
  });

  int get totalCount => fotos.fold(0, (s, f) => s + f.count);

  FotoSession? get current =>
      fotos.isEmpty ? null : fotos[currentIndex];

  CapturaState copyWith({
    List<FotoSession>? fotos,
    int? currentIndex,
    bool? isProcessing,
    bool? modelReady,
    bool? modelError,
    bool? isEditMode,
    bool? isRegionMode,
    Object? draggingRegion = kSentinel,
    bool? isDirty,
  }) =>
      CapturaState(
        fotos: fotos ?? this.fotos,
        currentIndex: currentIndex ?? this.currentIndex,
        isProcessing: isProcessing ?? this.isProcessing,
        modelReady: modelReady ?? this.modelReady,
        modelError: modelError ?? this.modelError,
        isEditMode: isEditMode ?? this.isEditMode,
        isRegionMode: isRegionMode ?? this.isRegionMode,
        draggingRegion: draggingRegion == kSentinel
            ? this.draggingRegion
            : draggingRegion as Rect?,
        isDirty: isDirty ?? this.isDirty,
      );
}

