import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../core/constants/api_constants.dart';
import '../models/app_version_info.dart';

class AppVersionService {
  static Future<AppVersionInfo?> checkVersion({String? platform}) async {
    final effectivePlatform = platform ?? (Platform.isIOS ? 'iOS' : 'Android');
    final url = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.appVersionCheck}?platform=$effectivePlatform&currentVersion=${ApiConstants.appVersion}',
    );

    try {
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'X-App-Version': ApiConstants.appVersion,
        },
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] != null) {
          final info = AppVersionInfo.fromJson(body['data']);
          return info;
        }
      }
      return null;
    } catch (_) {
      // Network issue or offline: return null to let offline handling take over
      return null;
    }
  }

  static bool isVersionOutdated(String current, String required) {
    if (current.trim().toLowerCase() == required.trim().toLowerCase()) {
      return false;
    }

    try {
      final curParts = current.split('.').map((e) => int.tryParse(e) ?? 0).toList();
      final reqParts = required.split('.').map((e) => int.tryParse(e) ?? 0).toList();

      for (int i = 0; i < 3; i++) {
        final c = i < curParts.length ? curParts[i] : 0;
        final r = i < reqParts.length ? reqParts[i] : 0;
        if (c < r) return true;
        if (c > r) return false;
      }
      return false;
    } catch (_) {
      return current != required;
    }
  }
}
