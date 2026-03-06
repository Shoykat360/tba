import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/di/injection_container.dart' as di;
import 'features/attendance/presentation/pages/home_screen.dart';
import 'features/camera/data/background/background_upload_worker.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Hive init — must be BEFORE everything
  await _initHive();

  // WorkManager init
  try {
    await BackgroundUploadWorker.initialize();
    await BackgroundUploadWorker.schedulePeriodicSync();
  } catch (e) {
    debugPrint('[Main] WorkManager init failed: $e');
  }

  await di.initDependencies();
  runApp(const MyApp());
}

/// Centralized Hive initialization — called from main AND background isolate
Future<void> _initHive() async {
  await Hive.initFlutter();
  if (!Hive.isBoxOpen('image_batches')) {
    await Hive.openBox<Map>('image_batches');
  }
  debugPrint('[Main] ✅ Hive initialized and box open');
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Sync on first launch too
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncPendingImages();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState appState) async {
    if (appState == AppLifecycleState.resumed) {
      debugPrint('[Main] 🔄 App resumed — ensuring Hive open and syncing');
      // Re-open Hive box in case it was closed when app was in background
      await _ensureHiveOpen();
      await _syncPendingImages();
    } else if (appState == AppLifecycleState.paused) {
      debugPrint('[Main] ⏸️ App paused — ensuring all pending writes flushed');
      await _flushHive();
    }
  }

  /// Ensure Hive box is open — it can close when app is backgrounded
  Future<void> _ensureHiveOpen() async {
    try {
      if (!Hive.isBoxOpen('image_batches')) {
        await Hive.openBox<Map>('image_batches');
        debugPrint('[Main] ✅ Hive box reopened after resume');
      }
    } catch (e) {
      debugPrint('[Main] ❌ Failed to reopen Hive box: $e');
    }
  }

  /// Flush all pending Hive writes to disk
  Future<void> _flushHive() async {
    try {
      if (Hive.isBoxOpen('image_batches')) {
        await Hive.box<Map>('image_batches').flush();
        debugPrint('[Main] ✅ Hive flushed to disk');
      }
    } catch (e) {
      debugPrint('[Main] ❌ Hive flush failed: $e');
    }
  }

  /// Attempt to upload any pending images
  Future<void> _syncPendingImages() async {
    try {
      await _ensureHiveOpen();
      // Use WorkManager one-off task for background resilience
      await BackgroundUploadWorker.triggerImmediateSync();
      debugPrint('[Main] ✅ Immediate sync task registered');
    } catch (e) {
      debugPrint('[Main] ❌ Sync on resume failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TBA Assessment',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF4F46E5),
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF4F46E5),
        brightness: Brightness.dark,
      ),
      home: const HomeScreen(),
    );
  }
}
