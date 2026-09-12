import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fiscaliza/core/ml/yolo_service.dart';

final yoloServiceProvider = Provider<YoloService>((ref) => YoloService());
