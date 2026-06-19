import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../core/constants/espn_constants.dart';

class EspnService {
  final http.Client _client = http.Client();

  Future<dynamic> get(String url) async {
    int attempts = 0;
    while (attempts < EspnConstants.maxRetries) {
      try {
        final response = await _client
            .get(Uri.parse(url))
            .timeout(EspnConstants.receiveTimeout);

        if (response.statusCode == 200) {
          return json.decode(response.body);
        } else {
          throw HttpException('Status code: ${response.statusCode}');
        }
      } on SocketException {
        if (attempts >= EspnConstants.maxRetries - 1) {
          throw const SocketException('No Internet Connection');
        }
      } on Exception {
        if (attempts >= EspnConstants.maxRetries - 1) {
          rethrow;
        }
      }
      attempts++;
      // Wait before retry
      await Future.delayed(Duration(milliseconds: 500 * attempts));
    }
  }

  void dispose() {
    _client.close();
  }
}
