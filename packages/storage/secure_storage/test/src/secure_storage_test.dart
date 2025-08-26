// ignore_for_file: prefer_const_constructors
import 'package:secure_storage/secure_storage.dart';
import 'package:test/test.dart';

void main() {
  group('SecureStorage', () {
    test('can be instantiated', () {
      expect(SecureStorage(), isNotNull);
    });
  });
}
