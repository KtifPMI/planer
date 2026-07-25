import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateInfo {
  final String latestVersion;
  final String downloadUrl;
  final String releaseNotes;
  final bool hasUpdate;

  const UpdateInfo({
    required this.latestVersion,
    required this.downloadUrl,
    required this.releaseNotes,
    required this.hasUpdate,
  });
}

class UpdateService {
  static const _owner = 'KtifPMI';
  static const _repo = 'planer';

  static Future<UpdateInfo> checkForUpdate() async {
    final packageInfo = await PackageInfo.fromPlatform();
    final currentVersion = packageInfo.version;

    final url = Uri.parse(
      'https://api.github.com/repos/$_owner/$_repo/releases/latest',
    );

    final response = await http.get(
      url,
      headers: {'Accept': 'application/vnd.github.v3+json'},
    );

    if (response.statusCode != 200) {
      return UpdateInfo(
        latestVersion: currentVersion,
        downloadUrl: '',
        releaseNotes: '',
        hasUpdate: false,
      );
    }

    final data = json.decode(response.body);
    final tagName = (data['tag_name'] as String?) ?? '';
    final latestVersion = tagName.replaceFirst('v', '');
    final body = (data['body'] as String?) ?? '';

    String downloadUrl = '';
    final assets = data['assets'] as List? ?? [];
    for (final asset in assets) {
      final name = asset['name'] as String? ?? '';
      if (name.endsWith('.apk')) {
        downloadUrl = asset['browser_download_url'] as String? ?? '';
        break;
      }
    }

    final hasUpdate = _isNewer(latestVersion, currentVersion);

    return UpdateInfo(
      latestVersion: latestVersion,
      downloadUrl: downloadUrl,
      releaseNotes: body,
      hasUpdate: hasUpdate,
    );
  }

  static bool _isNewer(String latest, String current) {
    final latestParts = latest.split('.').map(int.tryParse).whereType<int>().toList();
    final currentParts = current.split('.').map(int.tryParse).whereType<int>().toList();

    for (int i = 0; i < 3; i++) {
      final l = i < latestParts.length ? latestParts[i] : 0;
      final c = i < currentParts.length ? currentParts[i] : 0;
      if (l > c) return true;
      if (l < c) return false;
    }
    return false;
  }

  static Future<void> openDownload(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
