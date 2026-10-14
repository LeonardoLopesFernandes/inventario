import 'package:shared_preferences/shared_preferences.dart';

/// Guarda o token da Troca Fácil (separado do token do SL/minhaloja).
class TrocaSession {
  static const String _kToken = 'TROCA_TOKEN';
  static const String _kExpiry = 'TROCA_TOKEN_EXPIRY';

  final SharedPreferences _prefs;
  TrocaSession(this._prefs);

  static Future<TrocaSession> create() async =>
      TrocaSession(await SharedPreferences.getInstance());

  void saveToken(String token, {int? expiryEpochSeconds}) {
    _prefs.setString(_kToken, token);
    final expiry = expiryEpochSeconds != null
        ? expiryEpochSeconds * 1000
        : DateTime.now()
            .add(const Duration(minutes: 30))
            .millisecondsSinceEpoch;
    _prefs.setInt(_kExpiry, expiry);
  }

  String? getToken() {
    final t = _prefs.getString(_kToken);
    if (t == null || t.isEmpty) return null;
    final exp = _prefs.getInt(_kExpiry) ?? 0;
    if (exp != 0 && DateTime.now().millisecondsSinceEpoch > exp) {
      clear();
      return null;
    }
    return t;
  }

  bool isLoggedIn() => getToken() != null;

  void clear() {
    _prefs.remove(_kToken);
    _prefs.remove(_kExpiry);
  }
}
