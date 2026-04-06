import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Handles encrypted storage of sensitive credentials (PIN / password)
/// using the OS-level keychain (Android Keystore / iOS Keychain).
class SecureStorageService {
  static const _credentialKey = 'user_credential';
  final _storage = const FlutterSecureStorage();

  /// Saves the user's PIN or password (encrypted at rest by the OS).
  Future<void> saveCredential(String value) async {
    await _storage.write(key: _credentialKey, value: value);
  }

  /// Retrieves the stored credential, or null if none is set.
  Future<String?> getCredential() async {
    return _storage.read(key: _credentialKey);
  }

  /// Validates user input against the stored credential.
  Future<bool> validateCredential(String input) async {
    final stored = await getCredential();
    return stored != null && stored == input;
  }

  /// Clears the stored credential (used when disabling security).
  Future<void> clearCredential() async {
    await _storage.delete(key: _credentialKey);
  }
}
