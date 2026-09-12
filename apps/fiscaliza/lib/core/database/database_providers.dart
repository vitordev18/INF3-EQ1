import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fiscaliza/core/database/isar_service.dart';

final isarServiceProvider = Provider<IsarService>((ref) => IsarService());
