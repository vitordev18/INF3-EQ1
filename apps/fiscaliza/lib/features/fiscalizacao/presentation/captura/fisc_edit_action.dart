import 'package:fiscaliza/core/ml/recognition.dart';

sealed class FiscEditAction {}

class FiscAddedDetections extends FiscEditAction {
  final List<Recognition> added;
  FiscAddedDetections(this.added);
}

class FiscRemovedDetection extends FiscEditAction {
  final Recognition removed;
  final int originalIndex;
  FiscRemovedDetection(this.removed, this.originalIndex);
}

class FiscMovedDetection extends FiscEditAction {
  final Recognition oldDetection;
  final Recognition newDetection;
  FiscMovedDetection(this.oldDetection, this.newDetection);
}
