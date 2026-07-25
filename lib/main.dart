import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'data/services/storage_service.dart';
import 'core/services/update_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await StorageService.init();

  runApp(
    const ProviderScope(
      child: TrackerApp(),
    ),
  );

  // Auto-check for updates in background
  Future.delayed(const Duration(seconds: 5), () async {
    try {
      await UpdateService.checkForUpdate();
    } catch (_) {}
  });
}
