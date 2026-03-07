import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/di/injection_container.dart' as di;
import 'features/camera/data/background/background_upload_worker.dart';
import 'features/camera/data/datasources/image_queue_local_datasource.dart';
import 'home_screen.dart';

/// App entry point.
///
/// Startup order matters — do NOT reorder these steps:
///   1. Hive (storage must be ready before WorkManager or DI)
///   2. WorkManager (must register entry point BEFORE runApp)
///   3. DI (wires up repositories that depend on the open Hive box)
///   4. runApp
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Step 1 — open local storage
  await openHiveStorage();

  // Step 2 — register WorkManager entry point and schedule periodic task
  // IMPORTANT: must happen before runApp() so the background isolate
  // entry point is registered in release/AOT builds
  try {
    await BackgroundSyncScheduler.initialise();
    await BackgroundSyncScheduler.schedulePeriodicUploadCheck();
  } catch (e) {
    debugPrint('[Main] ⚠️ WorkManager init failed: $e');
  }

  // Step 3 — wire up dependency injection
  await di.initialiseDependencies();

  runApp(const MyApp());
}

/// Opens Hive and the image-batch box.
/// Extracted as a named function so it can also be called on app resume.
Future<void> openHiveStorage() async {
  await Hive.initFlutter();
  if (!Hive.isBoxOpen(kImageBatchBoxName)) {
    await Hive.openBox<Map>(kImageBatchBoxName);
  }
  debugPrint('[Main] ✅ Hive ready — box "$kImageBatchBoxName" open');
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
    // Queue an immediate upload check after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      triggerUploadCheckOnResume();
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
      debugPrint('[Main] 🔄 App resumed — reopening Hive and syncing');
      await reopenHiveBoxIfClosed();
      await triggerUploadCheckOnResume();
    } else if (appState == AppLifecycleState.paused) {
      debugPrint('[Main] ⏸️ App paused — flushing pending Hive writes');
      await flushHiveToDisk();
    }
  }

  /// Reopens the Hive box if Android closed it while the app was backgrounded.
  Future<void> reopenHiveBoxIfClosed() async {
    try {
      if (!Hive.isBoxOpen(kImageBatchBoxName)) {
        await Hive.openBox<Map>(kImageBatchBoxName);
        debugPrint('[Main] ✅ Hive box reopened after resume');
      }
    } catch (e) {
      debugPrint('[Main] ❌ Could not reopen Hive box: $e');
    }
  }

  /// Flushes all pending Hive writes to disk so data is not lost on kill.
  Future<void> flushHiveToDisk() async {
    try {
      if (Hive.isBoxOpen(kImageBatchBoxName)) {
        await Hive.box<Map>(kImageBatchBoxName).flush();
        debugPrint('[Main] ✅ Hive flushed to disk');
      }
    } catch (e) {
      debugPrint('[Main] ❌ Hive flush failed: $e');
    }
  }

  /// Queues a one-off WorkManager task to upload any pending images.
  /// Uses WorkManager (not direct upload) so it works even if the app
  /// goes to the background immediately after resume.
  Future<void> triggerUploadCheckOnResume() async {
    try {
      await reopenHiveBoxIfClosed();
      await BackgroundSyncScheduler.triggerImmediateUploadNow();
      debugPrint('[Main] ✅ Immediate upload task queued');
    } catch (e) {
      debugPrint('[Main] ❌ Failed to queue immediate upload: $e');
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