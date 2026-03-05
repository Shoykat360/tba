/*import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di/injection_container.dart';
import 'core/di/injection_container.dart' as di;
import 'features/attendance/presentation/bloc/attendance_bloc.dart';
import 'features/attendance/presentation/pages/attendance_screen.dart';
import 'features/camera/presentation/bloc/camera_bloc.dart';
import 'features/camera/presentation/bloc/sync_bloc.dart';
import 'features/camera/presentation/pages/camera_preview_screen.dart';
import 'features/ui_showcase/presentation/pages/ui_reconstruction_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait — prevents layout jank on first frame
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialise DI — wrapped so a WorkManager/Hive failure on emulator
  // does not leave the app on a permanent black screen.
  try {
    await di.initializeDependencies();
  } catch (e) {
    debugPrint('[DI] initializeDependencies failed: $e');
  }

  runApp(const TbaTaskApp());
}

class TbaTaskApp extends StatelessWidget {
  const TbaTaskApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TBA Task',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
        ),
      ),
      home: Builder(
        builder: (context) => UIReconstructionScreen(
          onAttendanceTapped: () =>
              Navigator.pushNamed(context, '/attendance'),
          onCameraTapped: () =>
              Navigator.pushNamed(context, '/camera'),
        ),
      ),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/attendance':
            return MaterialPageRoute(
              builder: (_) => BlocProvider<AttendanceBloc>(
                create: (_) => serviceLocator<AttendanceBloc>(),
                child: const AttendanceScreen(),
              ),
            );
          case '/camera':
            return MaterialPageRoute(
              builder: (_) => MultiBlocProvider(
                providers: [
                  BlocProvider<CameraBloc>(
                    create: (_) => serviceLocator<CameraBloc>(),
                  ),
                  BlocProvider<SyncBloc>(
                    create: (_) => serviceLocator<SyncBloc>(),
                  ),
                ],
                child: const CameraPreviewScreen(),
              ),
            );
          default:
            return null;
        }
      },
    );
  }
}*//*

import 'package:flutter/material.dart';

import 'core/di/injection_container.dart' as di;
import 'features/home/presentation/pages/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.initDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
}*/


import 'package:flutter/material.dart';

import 'core/di/injection_container.dart' as di;
import 'features/attendance/presentation/pages/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.initDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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