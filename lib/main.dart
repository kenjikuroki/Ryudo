import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/router.dart';

import 'features/monetization/application/ad_manager.dart';

import 'package:archery/l10n/gen/app_localizations.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AdManager.initialize();
  runApp(
    const ProviderScope(
      child: ArcheryNoteApp(),
    ),
  );
}

class ArcheryNoteApp extends StatelessWidget {
  const ArcheryNoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
      ),
      routerConfig: router,
    );
  }
}
