import 'dart:async';
import 'dart:io';

Future<bool> hasInternetConnection({
  Duration timeout = const Duration(seconds: 3),
}) async {
  try {
    final result = await InternetAddress.lookup('example.com').timeout(timeout);
    return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
  } on SocketException {
    return false;
  } on TimeoutException {
    return false;
  } catch (_) {
    return false;
  }
}
