import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

class SignInResult {
  final bool hasProfile;
  final Map<String, dynamic>? user;
  SignInResult({required this.hasProfile, this.user});
}

class NyuOnlyException implements Exception {
  final String message;
  NyuOnlyException(this.message);
  @override
  String toString() => message;
}

class AuthService {
  AuthService._();
  static final AuthService _instance = AuthService._();
  factory AuthService() => _instance;

  static const _tokenKey = 'access_token';
  static const _refreshKey = 'refresh_token';
  final _storage = const FlutterSecureStorage();

  Map<String, dynamic>? _cachedUser;
  Map<String, dynamic>? get currentUser => _cachedUser;
  int? get currentUserId => _cachedUser?['user_id'] as int?;

  String get baseUrl => _baseUrl;
  Future<String?> get accessToken => _storage.read(key: _tokenKey);

  static const String _googleServerClientId =
      '705900658517-r50uqjrchabf5q5i71m99me9vqes8nnr.apps.googleusercontent.com';

  late final GoogleSignIn _googleSignIn = GoogleSignIn(
    // Web reads the client ID from the <meta name="google-signin-client_id">
    // tag in index.html and rejects this parameter explicitly.
    serverClientId: kIsWeb ? null : _googleServerClientId,
    scopes: ['email', 'profile', 'openid'],
  );

  String get _baseUrl {
    if (kIsWeb) return 'http://localhost:3000/api';
    if (Platform.isAndroid) return 'http://10.0.2.2:3000/api';
    return 'http://localhost:3000/api';
  }

  Future<SignInResult> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      throw Exception('Sign-in cancelled.');
    }

    final auth = await googleUser.authentication;
    final idToken = auth.idToken;
    if (idToken == null) {
      throw Exception('Failed to obtain Google ID token.');
    }

    final response = await http.post(
      Uri.parse('$_baseUrl/auth/google'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id_token': idToken}),
    );

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode == 403) {
      await _googleSignIn.signOut();
      throw NyuOnlyException(body['message'] ?? 'Only NYU emails are allowed.');
    }
    if (response.statusCode != 200) {
      throw Exception(body['message'] ?? 'Google sign-in failed.');
    }

    await _storage.write(key: _tokenKey, value: body['token'] as String);
    await _storage.write(key: _refreshKey, value: body['refreshToken'] as String);

    _cachedUser = body['user'] as Map<String, dynamic>?;

    return SignInResult(
      hasProfile: body['hasProfile'] as bool? ?? false,
      user: _cachedUser,
    );
  }

  Future<Map<String, dynamic>> completeProfile({
    String? name,
    required String gender,
    String? pronouns,
    String? college,
    String? ethnicity,
    String? age,
    String? birthData,
  }) async {
    final token = await _storage.read(key: _tokenKey);
    final payload = <String, dynamic>{'gender': gender};
    if (name != null && name.isNotEmpty) payload['name'] = name;
    if (pronouns != null && pronouns.isNotEmpty) payload['pronouns'] = pronouns;
    if (college != null && college.isNotEmpty) payload['college'] = college;
    if (ethnicity != null && ethnicity.isNotEmpty) payload['ethnicity'] = ethnicity;
    if (age != null && age.isNotEmpty) payload['age'] = age;
    if (birthData != null && birthData.isNotEmpty) payload['birth_data'] = birthData;

    final response = await http.post(
      Uri.parse('$_baseUrl/auth/profile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(payload),
    );

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 200) {
      throw Exception(body['message'] ?? 'Profile update failed.');
    }
    _cachedUser = body['user'] as Map<String, dynamic>?;
    return _cachedUser!;
  }

  Future<SignInResult?> getMe() async {
    final token = await _storage.read(key: _tokenKey);
    if (token == null) return null;

    final response = await http.get(
      Uri.parse('$_baseUrl/auth/me'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      await clearTokens();
      return null;
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    _cachedUser = body['user'] as Map<String, dynamic>?;
    return SignInResult(
      hasProfile: body['hasProfile'] as bool? ?? false,
      user: _cachedUser,
    );
  }

  Future<void> logout() async {
    final token = await _storage.read(key: _tokenKey);
    if (token != null) {
      await http.post(
        Uri.parse('$_baseUrl/auth/logout'),
        headers: {'Authorization': 'Bearer $token'},
      );
    }
    await clearTokens();
    await _googleSignIn.signOut();
  }

  Future<void> clearTokens() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _refreshKey);
    _cachedUser = null;
  }

  Future<String?> getStoredToken() => _storage.read(key: _tokenKey);
}
