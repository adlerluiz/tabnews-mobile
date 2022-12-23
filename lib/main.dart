import 'package:flutter/material.dart';
import 'package:tabnews/page/home.dart';
import 'package:tabnews/service/global_current_theme.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> with WidgetsBindingObserver {
  ThemeMode selectedTheme = ThemeMode.system;

  @override
  void initState() {
    super.initState();

    selectedTheme = currentTheme.getCurrentTheme();

    currentTheme.addListener(() {
      selectedTheme = currentTheme.getCurrentTheme();
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    String appName = 'TabNews';

    return MaterialApp(
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('pt', ''),
      ],
      debugShowCheckedModeBanner: false,
      title: appName,
      themeMode: selectedTheme,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(backgroundColor: Colors.white),
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.light,
          seedColor: Colors.blue,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.grey[900],
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.dark,
          seedColor: Colors.blue,
        ),
      ),
      home: HomePage(appName: appName),
    );
  }
}
