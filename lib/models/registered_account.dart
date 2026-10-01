import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

enum AccountRole { visitor, provider, admin }

extension AccountRoleLabels on AccountRole {
  String get label => switch (this) {
        AccountRole.visitor => 'Visitor',
        AccountRole.provider => 'Provider',
        AccountRole.admin => 'Admin',
      };

  String get apiValue => switch (this) {
        AccountRole.visitor => 'VISITOR',
        AccountRole.provider => 'PROVIDER',
        AccountRole.admin => 'ADMIN',
      };

  String get description => switch (this) {
        AccountRole.visitor =>
          'Discover and book Zanzibar tourism and coastal experiences.',
        AccountRole.provider =>
          'List and manage tourism or coastal experiences on ZanziConnect.',
        AccountRole.admin => 'Manage the ZanziConnect platform.',
      };
}

const publicRegistrationRoles = [AccountRole.visitor, AccountRole.provider];

/// Account profile contains no password or credential material.
class RegisteredAccount {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final AccountRole role;

  const RegisteredAccount({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.role,
  });
}

/// Local prototype account and session store. Passwords are salted and hashed;
/// no credentials or account data survive a page refresh/restart.
class DemoAccountStore {
  DemoAccountStore._();

  static final Map<String, _StoredAccount> _accounts = {};
  static RegisteredAccount? currentSession;
  static int _nextId = 1;

  static RegisteredAccount newAccount({
    required String fullName,
    required String email,
    required String phone,
    required AccountRole role,
  }) =>
      RegisteredAccount(
        id: 'demo-${(_nextId++).toString().padLeft(5, '0')}',
        fullName: fullName,
        email: email,
        phone: phone,
        role: role,
      );

  /// Returns false if the email already belongs to an account.
  static bool register(RegisteredAccount account, String password) {
    if (account.role == AccountRole.admin) return false;
    final email = account.email.toLowerCase();
    if (_accounts.containsKey(email)) return false;
    final salt = List<int>.generate(16, (_) => Random.secure().nextInt(256));
    _accounts[email] = _StoredAccount(
      account: account,
      salt: salt,
      passwordHash: _derivePasswordHash(password, salt),
    );
    return true;
  }

  static RegisteredAccount? authenticate(String email, String password) {
    final stored = _accounts[email.trim().toLowerCase()];
    if (stored == null) return null;
    final attempted = _derivePasswordHash(password, stored.salt);
    var difference = attempted.length ^ stored.passwordHash.length;
    for (var i = 0;
        i < attempted.length && i < stored.passwordHash.length;
        i++) {
      difference |= attempted[i] ^ stored.passwordHash[i];
    }
    if (difference != 0) return null;
    currentSession = stored.account;
    return stored.account;
  }

  static void logout() {
    currentSession = null;
  }

  static List<int> _derivePasswordHash(String password, List<int> salt) {
    const iterations = 12000;
    final hmac = Hmac(sha256, utf8.encode(password));
    final block = Uint8List.fromList([...salt, 0, 0, 0, 1]);
    var u = hmac.convert(block).bytes;
    final derived = List<int>.from(u);
    for (var round = 1; round < iterations; round++) {
      u = hmac.convert(u).bytes;
      for (var index = 0; index < derived.length; index++) {
        derived[index] ^= u[index];
      }
    }
    return derived;
  }
}

class _StoredAccount {
  final RegisteredAccount account;
  final List<int> salt;
  final List<int> passwordHash;

  const _StoredAccount({
    required this.account,
    required this.salt,
    required this.passwordHash,
  });
}
