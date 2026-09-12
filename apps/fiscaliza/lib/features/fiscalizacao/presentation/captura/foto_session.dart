import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

import 'package:fiscaliza/core/ml/recognition.dart';
import 'package:fiscaliza/features/fiscalizacao/presentation/captura/fisc_edit_action.dart';

class FotoSession {
  final File imageFile;
  final img.Image? decodedImage;
  final List<Recognition> detections;
  final List<FiscEditAction> undoStack;
  final List<Rect> savedRegions;
  final bool awaitingRegionSelection;

  const FotoSession({
    required this.imageFile,
    this.decodedImage,
    this.detections = const [],
    this.undoStack = const [],
    this.savedRegions = const [],
    this.awaitingRegionSelection = true,
  });

  int get count => detections.length;
  int get width => decodedImage?.width ?? 640;
  int get height => decodedImage?.height ?? 640;

  FotoSession copyWith({
    File? imageFile,
    img.Image? decodedImage,
    List<Recognition>? detections,
    List<FiscEditAction>? undoStack,
    List<Rect>? savedRegions,
    bool? awaitingRegionSelection,
  }) =>
      FotoSession(
        imageFile: imageFile ?? this.imageFile,
        decodedImage: decodedImage ?? this.decodedImage,
        detections: detections ?? this.detections,
        undoStack: undoStack ?? this.undoStack,
        savedRegions: savedRegions ?? this.savedRegions,
        awaitingRegionSelection:
            awaitingRegionSelection ?? this.awaitingRegionSelection,
      );
}
