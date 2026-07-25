import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateInfo {
  final String latestVersion;
  final String currentVersion;
  final String downloadUrl;
  final String releaseNotes;
  final bool hasUpdate;

  const UpdateInfo({
    required this.latestVersion,
    required this.currentVersion,
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

    UpdateInfo? result;

    try {
      result = await _checkViaApi(currentVersion);
    } catch (_) {
      result = null;
    }

    result ??= await _checkViaPage(currentVersion);

    return result;
  }

  static Future<UpdateInfo> _checkViaApi(String currentVersion) async {
    final url = Uri.parse(
      'https://api.github.com/repos/$_owner/$_repo/releases/latest',
    );

    final response = await http.get(
      url,
      headers: {'Accept': 'application/vnd.github.v3+json'},
    ).timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}');
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
      currentVersion: currentVersion,
      downloadUrl: downloadUrl,
      releaseNotes: body,
      hasUpdate: hasUpdate,
    );
  }

  static Future<UpdateInfo> _checkViaPage(String currentVersion) async {
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 15)
      ..badCertificateCallback = (_, __, ___) => true;

    try {
      final request = await client.getUrl(
        Uri.parse('https://github.com/$_owner/$_repo/releases/latest'),
      );
      final response = await request.close().timeout(const Duration(seconds: 15));
      final body = await response.transform(utf8.decoder).join();

      final tagMatch = RegExp(r'/releases/tag/(v?[\d.]+)').firstMatch(body);
      if (tagMatch == null) {
        throw Exception('No tag found');
      }
      final latestVersion = tagMatch.group(1)!.replaceFirst('v', '');

      String downloadUrl = '';
      final apkMatch = RegExp(
        r'href="([^"]*\.apk)"',
      ).firstMatch(body);
      if (apkMatch != null) {
        downloadUrl = apkMatch.group(1)!;
        if (downloadUrl.startsWith('/')) {
          downloadUrl = 'https://github.com$downloadUrl';
        }
      }

      final hasUpdate = _isNewer(latestVersion, currentVersion);

      return UpdateInfo(
        latestVersion: latestVersion,
        currentVersion: currentVersion,
        downloadUrl: downloadUrl,
        releaseNotes: '',
        hasUpdate: hasUpdate,
      );
    } finally {
      client.close();
    }
  }

  static bool _isNewer(String latest, String current) {
    final latestClean = latest.split('+').first;
    final currentClean = current.split('+').first;

    final latestParts = latestClean.split('.').map(int.tryParse).whereType<int>().toList();
    final currentParts = currentClean.split('.').map(int.tryParse).whereType<int>().toList();

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
