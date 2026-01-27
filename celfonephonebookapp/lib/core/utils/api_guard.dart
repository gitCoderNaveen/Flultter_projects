import 'dart:io';

Future<T> safeApiCall<T>(Future<T> Function() call) async {
  try {
    return await call();
  } on SocketException {
    throw const SocketException('No Internet');
  } catch (e) {
    rethrow;
  }
}
