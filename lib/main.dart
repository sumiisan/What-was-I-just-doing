import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_state.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    var title = AppLocalizations.of(context)?.whatWasIJustDoing ?? "?";
    return ChangeNotifierProvider(
      create: (context) => AppState(),
      child: MaterialApp(
        title: title,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 40, 183, 194)),
        ),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', 'US'),
          Locale('ja', 'JP'),
        ],
        home: MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    var title = AppLocalizations.of(context)?.whatWasIJustDoing ?? "[a]";

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: DefaultTextStyle(
        style: const TextStyle(
          color: Color.fromARGB(255, 65, 65, 65),
          fontSize: 30,
        ),
        child: Center(
          child:
          ButtonTheme(
            minWidth: 400,
            height: 60,
            child: Localizations.override(   // override locale for testing purpose TODO: remove this later
              context: context,
              locale: const Locale('ja'),
              child: const ContentPage(),
            ),
          ), 
          
        ),
      ) 
    );
  }
}

