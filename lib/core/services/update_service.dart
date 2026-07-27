import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import '../localization/app_localizations.dart';

class UpdateInfo {
  final String version;
  final String currentVersion;
  final String downloadUrl;
  final String? changelog;
  final bool hasUpdate;

  const UpdateInfo({
    required this.version,
    required this.currentVersion,
    required this.downloadUrl,
    this.changelog,
    required this.hasUpdate,
  });
}

class UpdateService {
  static const _owner = 'KtifPMI';
  static const _repo = 'planer';
  static const _apiUrl = 'https://api.github.com/repos/$_owner/$_repo/releases/latest';
  static const _pageUrl = 'https://github.com/$_owner/$_repo/releases/latest';

  static Future<UpdateInfo?> check() async {
    try {
      final info = await PackageInfo.fromPlatform();
      final current = info.version.split('+').first;

      Map<String, dynamic>? data;

      try {
        data = await _fetchViaApi();
      } catch (_) {
        data = null;
      }

      data ??= await _fetchViaPage();

      final tag = (data['tag_name'] as String?)?.replaceFirst('v', '').split('+').first ?? '';
      if (tag.isEmpty) return null;

      final hasUpdate = _isNewer(tag, current);

      String downloadUrl = '';
      final assets = data['assets'] as List? ?? [];
      for (final a in assets) {
        final name = (a as Map<String, dynamic>)['name'] as String? ?? '';
        if (name.endsWith('.apk')) {
          downloadUrl = a['browser_download_url'] as String? ?? '';
          break;
        }
      }

      if (downloadUrl.isEmpty) {
        final pageBody = data['page_html'] as String? ?? '';
        final apkMatch = RegExp(r'href="([^"]*\.apk)"').firstMatch(pageBody);
        if (apkMatch != null) {
          downloadUrl = apkMatch.group(1)!;
          if (downloadUrl.startsWith('/')) {
            downloadUrl = 'https://github.com$downloadUrl';
          }
        }
      }

      if (downloadUrl.isEmpty) return null;

      return UpdateInfo(
        version: tag,
        currentVersion: current,
        downloadUrl: downloadUrl,
        changelog: data['body'] as String?,
        hasUpdate: hasUpdate,
      );
    } catch (_) {
      return null;
    }
  }

  static Future<Map<String, dynamic>> _fetchViaApi() async {
    final response = await http.get(
      Uri.parse(_apiUrl),
      headers: {'Accept': 'application/vnd.github.v3+json'},
    ).timeout(const Duration(seconds: 15));
    if (response.statusCode != 200) throw Exception('HTTP ${response.statusCode}');
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> _fetchViaPage() async {
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 15)
      ..badCertificateCallback = (_, __, ___) => true;

    try {
      final request = await client.getUrl(Uri.parse(_pageUrl));
      final response = await request.close().timeout(const Duration(seconds: 15));
      final body = await response.transform(utf8.decoder).join();

      final tagMatch = RegExp(r'/releases/tag/(v?[\d.]+)').firstMatch(body);
      if (tagMatch == null) throw Exception('No tag found');

      return {
        'tag_name': tagMatch.group(1),
        'assets': [],
        'body': '',
        'page_html': body,
      };
    } finally {
      client.close();
    }
  }

  static bool _isNewer(String latest, String current) {
    final l = latest.split('.').map((s) => int.tryParse(s.split('+').first)).whereType<int>().toList();
    final c = current.split('.').map((s) => int.tryParse(s.split('+').first)).whereType<int>().toList();
    for (int i = 0; i < l.length && i < c.length; i++) {
      if (l[i] > c[i]) return true;
      if (l[i] < c[i]) return false;
    }
    return l.length > c.length;
  }

  static Future<void> downloadAndInstall(String url, BuildContext context) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/tracker.apk');

    final client = http.Client();
    try {
      final request = http.Request('GET', Uri.parse(url));
      final response = await client.send(request).timeout(const Duration(minutes: 5));

      final sink = file.openWrite();
      await for (final chunk in response.stream) {
        sink.add(chunk);
      }
      await sink.close();
    } finally {
      client.close();
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).apkDownloaded)),
      );
    }

    await OpenFilex.open(file.path);
  }

  static Future<void> checkAndShow(BuildContext context) async {
    final update = await check();
    if (update == null || !context.mounted) return;

    if (!update.hasUpdate) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${AppLocalizations.of(context).latestVersion} (${update.currentVersion})')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) {
        final l10n = AppLocalizations.of(context);
        return AlertDialog(
        title: Text(l10n.updateTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Новая версия: ${update.version}',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            if (update.changelog != null && update.changelog!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                update.changelog!,
                style: const TextStyle(fontSize: 13),
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.later),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              _downloadWithProgress(context, update.downloadUrl);
            },
            child: Text(l10n.updateNow),
          ),
        ],
      );},
    );
  }

  static void _downloadWithProgress(BuildContext context, String url) async {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(l10n.downloading),
              ],
            ),
          ),
        ),
      ),
    );
    try {
      await downloadAndInstall(url, context);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.downloadError),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (context.mounted) Navigator.of(context, rootNavigator: true).pop();
    }
  }
}
