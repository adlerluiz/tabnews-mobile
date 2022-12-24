import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:tabnews/service/global_current_theme.dart';
import 'package:tabnews/service/storage.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  StorageService storage = StorageService();

  late String _theme = 'light';
  late String _launchUrlMode = 'internal';

  late PackageInfo packageInfo = PackageInfo(
    appName: 'Desconhecido',
    packageName: 'Desconhecido',
    buildNumber: 'Desconhecido',
    version: 'Desconhecido',
  );

  @override
  void initState() {
    super.initState();

    initSettings();
  }

  Future<void> initSettings() async {
    _theme = await storage.sharedPreferencesGet('theme', 'system');
    _launchUrlMode =
        await storage.sharedPreferencesGet('launch_url_mode', 'internal');

    packageInfo = await PackageInfo.fromPlatform();
    setState(() {});
  }

  void setTheme(String value) {
    currentTheme.switchTheme(value);
    _theme = value;
    storage.sharedPreferencesAddString('theme', value);
    setState(() {});
  }

  void setLaunchUrlMode(String value) {
    _launchUrlMode = value;
    storage.sharedPreferencesAddString('launch_url_mode', value);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          titleSpacing: 0,
          title: const Text('Configurações', style: TextStyle(fontSize: 18)),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              const ListTile(
                title: Text('Tema'),
                subtitle: Text('Tema padrão do app'),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Tooltip(
                    message: 'Claro',
                    child: ElevatedButton(
                      style: ButtonStyle(
                        foregroundColor: MaterialStateProperty.all(
                          (_theme == 'light') ? Colors.white : null,
                        ),
                        backgroundColor: MaterialStateProperty.all(
                          (_theme == 'light') ? Colors.blue : null,
                        ),
                        shape: MaterialStateProperty.all(
                          const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                          ),
                        ),
                      ),
                      onPressed: () {
                        setTheme('light');
                      },
                      child: const Icon(
                        Icons.sunny,
                      ),
                    ),
                  ),
                  Tooltip(
                    message: 'Escuro',
                    child: ElevatedButton(
                      style: ButtonStyle(
                        foregroundColor: MaterialStateProperty.all(
                          (_theme == 'dark') ? Colors.white : null,
                        ),
                        backgroundColor: MaterialStateProperty.all(
                          (_theme == 'dark') ? Colors.blue : null,
                        ),
                        shape: MaterialStateProperty.all(
                          const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                          ),
                        ),
                      ),
                      onPressed: () {
                        setTheme('dark');
                      },
                      child: const Icon(
                        Icons.nights_stay,
                      ),
                    ),
                  ),
                  Tooltip(
                    message: 'Automático',
                    child: ElevatedButton(
                      style: ButtonStyle(
                        foregroundColor: MaterialStateProperty.all(
                          (_theme == 'system') ? Colors.white : null,
                        ),
                        backgroundColor: MaterialStateProperty.all(
                          (_theme == 'system') ? Colors.blue : null,
                        ),
                        shape: MaterialStateProperty.all(
                          const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                          ),
                        ),
                      ),
                      onPressed: () {
                        setTheme('system');
                      },
                      child: const Icon(
                        Icons.brightness_auto,
                      ),
                    ),
                  ),
                ],
              ),
              const ListTile(
                title: Text('Abrir link'),
                subtitle: Text('Escolha como abrir os links'),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Tooltip(
                    message: 'App',
                    child: ElevatedButton(
                      style: ButtonStyle(
                        foregroundColor: MaterialStateProperty.all(
                          (_launchUrlMode == 'internal') ? Colors.white : null,
                        ),
                        backgroundColor: MaterialStateProperty.all(
                          (_launchUrlMode == 'internal') ? Colors.blue : null,
                        ),
                        shape: MaterialStateProperty.all(
                          const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                          ),
                        ),
                      ),
                      onPressed: () {
                        setLaunchUrlMode('internal');
                      },
                      child: const Text('No App'),
                    ),
                  ),
                  Tooltip(
                    message: 'Navegador',
                    child: ElevatedButton(
                      style: ButtonStyle(
                        foregroundColor: MaterialStateProperty.all(
                          (_launchUrlMode == 'external') ? Colors.white : null,
                        ),
                        backgroundColor: MaterialStateProperty.all(
                          (_launchUrlMode == 'external') ? Colors.blue : null,
                        ),
                        shape: MaterialStateProperty.all(
                          const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                          ),
                        ),
                      ),
                      onPressed: () {
                        setLaunchUrlMode('external');
                      },
                      child: const Text('Navegador'),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 50),
                child: Text(
                  'v${packageInfo.version}',
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                ),
              )
            ],
          ),
        ),
      );
}
