import 'package:tabnews/service/storage.dart';
import 'package:url_launcher/url_launcher.dart';

class LaunchUrlWrapper {
  static LaunchMode launchUrlMode = LaunchMode.inAppWebView;

  static Future<void> getTypeLaunchMode(StorageService storage) async {
    final typeLaunchUrlMode =
        await storage.sharedPreferencesGet('launch_url_mode', 'internal');

    if (typeLaunchUrlMode == 'internal') {
      launchUrlMode = LaunchMode.inAppWebView;
    } else {
      launchUrlMode = LaunchMode.externalApplication;
    }
  }

  static Future<void> launch(Uri url) async {
    if (!await launchUrl(url, mode: launchUrlMode)) {
      throw Exception('Erro ao abrir $url');
    }
  }
}
