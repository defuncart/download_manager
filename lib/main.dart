import 'package:download_manager/download/download_manager.dart';
import 'package:download_manager/home/home_screen.dart';
import 'package:download_manager/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final downloadManager = DownloadManager();
  await downloadManager.init();

  runApp(
    ProviderScope(
      overrides: [
        downloadManagerProvider.overrideWithValue(downloadManager),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: lightTheme,
      darkTheme: darkTheme,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        AppLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      onGenerateRoute: (settings) => MaterialPageRoute(
        builder: (context) => HomeScreen(
          deepLinkUrl: settings.name,
        ),
      ),
    );
  }
}
