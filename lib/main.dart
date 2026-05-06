import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:device_preview/device_preview.dart';
import 'theme/app_theme.dart';
import 'utils/app_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'providers/db_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  
  final dbService = DatabaseService();
  await dbService.init();

  runApp(
    DevicePreview(
      enabled: const bool.fromEnvironment('dart.vm.product') == false,
      builder: (context) => ProviderScope(
        overrides: [
          dbProvider.overrideWithValue(dbService),
        ],
        child: const EventCheckinApp(),
      ),
    ),
  );
}

class EventCheckinApp extends ConsumerWidget {
  const EventCheckinApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'Smart Event Check-in',
      theme: AppTheme.lightTheme,
      routerConfig: router,
      useInheritedMediaQuery: true,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      debugShowCheckedModeBanner: false,
    );
  }
}
