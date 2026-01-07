import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);
  static const String _baseUrl = "http://10.0.2.2:8000";

  String? _firebaseToken;
  String? _uid;
  Map<String, dynamic>? _userInfo;

  String? get firebaseToken => _firebaseToken;
  String? get uid => _uid;
  Map<String, dynamic>? get userInfo => _userInfo;
  bool get isLoggedIn => _firebaseToken != null && _uid != null;

  Future<bool> signIn() async {
    try {
      debugPrint("🔄 Google Sign In 시작...");
      final GoogleSignInAccount? user = await _googleSignIn.signIn();

      if (user == null) {
        debugPrint("❌ 사용자가 로그인을 취소했습니다");
        return false;
      }

      debugPrint("✅ Google Sign In 성공: ${user.email}");

      final googleAuth = await user.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        debugPrint("❌ ID Token을 가져올 수 없습니다");
        return false;
      }

      debugPrint("📤 백엔드로 ID Token 전송 중...");

      final loginRes = await http.post(
        Uri.parse("$_baseUrl/auth/google"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"id_token": idToken}),
      );

      debugPrint("📥 백엔드 응답: ${loginRes.statusCode}");
      if (loginRes.statusCode != 200) {
        debugPrint("❌ 백엔드 로그인 실패: ${loginRes.body}");
        return false;
      }

      final loginData = jsonDecode(loginRes.body);
      _uid = loginData["uid"];
      final customToken = loginData["firebase_token"];

      // Firebase Auth를 사용하여 Custom Token으로 로그인하고 ID Token 받기
      debugPrint("🔄 Firebase Auth로 Custom Token 로그인 중...");
      final credential = await FirebaseAuth.instance.signInWithCustomToken(
        customToken,
      );
      final firebaseUser = credential.user;

      if (firebaseUser == null) {
        debugPrint("❌ Firebase 사용자를 가져올 수 없습니다");
        return false;
      }

      final firebaseIdToken = await firebaseUser.getIdToken();

      if (firebaseIdToken == null) {
        debugPrint("❌ ID Token을 가져올 수 없습니다");
        return false;
      }

      _firebaseToken = firebaseIdToken; // ID Token을 저장
      _userInfo = {
        "uid": _uid,
        "email": loginData["email"],
        "name": loginData["name"],
        "picture": loginData["picture"],
      };

      // SharedPreferences에 저장 (Custom Token도 별도로 저장)
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("firebase_token", _firebaseToken!); // ID Token
      await prefs.setString(
        "custom_token",
        customToken,
      ); // Custom Token (재로그인용)
      await prefs.setString("uid", _uid!);
      await prefs.setString("user_info", jsonEncode(_userInfo));

      debugPrint("✅ 백엔드 로그인 성공! UID: $_uid");
      debugPrint("✅ Firebase ID Token 획득 성공!");
      return true;
    } catch (e, stack) {
      debugPrint("=" * 60);
      debugPrint("❌ 에러 발생!");
      debugPrint("Error: $e");
      debugPrint("Stack trace: $stack");
      debugPrint("=" * 60);
      return false;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await FirebaseAuth.instance.signOut();
    _firebaseToken = null;
    _uid = null;
    _userInfo = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("firebase_token");
    await prefs.remove("custom_token");
    await prefs.remove("uid");
    await prefs.remove("user_info");
  }

  Future<bool> loadStoredAuth() async {
    try {
      // Firebase Auth에서 현재 사용자 확인
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser != null) {
        // Firebase Auth에 로그인되어 있으면 ID Token 가져오기
        final idToken = await firebaseUser.getIdToken();
        _firebaseToken = idToken;
        _uid = firebaseUser.uid;

        final prefs = await SharedPreferences.getInstance();
        final userInfoStr = prefs.getString("user_info");
        if (userInfoStr != null) {
          _userInfo = jsonDecode(userInfoStr);
        }

        // SharedPreferences 업데이트
        await prefs.setString("firebase_token", _firebaseToken!);
        await prefs.setString("uid", _uid!);

        return true;
      }

      // Firebase Auth에 로그인되어 있지 않으면 Custom Token으로 재로그인 시도
      final prefs = await SharedPreferences.getInstance();
      final customToken = prefs.getString("custom_token");
      final uid = prefs.getString("uid");
      final userInfoStr = prefs.getString("user_info");

      if (customToken != null && uid != null) {
        try {
          debugPrint("🔄 저장된 Custom Token으로 Firebase Auth 재로그인 시도...");
          // Custom Token으로 Firebase Auth에 로그인
          final credential = await FirebaseAuth.instance.signInWithCustomToken(
            customToken,
          );
          final firebaseUser = credential.user;

          if (firebaseUser != null) {
            // ID Token 가져오기
            final idToken = await firebaseUser.getIdToken();
            if (idToken != null) {
              _firebaseToken = idToken;
              _uid = firebaseUser.uid;
              if (userInfoStr != null) {
                _userInfo = jsonDecode(userInfoStr);
              }

              // SharedPreferences 업데이트
              await prefs.setString("firebase_token", _firebaseToken!);
              await prefs.setString("uid", _uid!);

              debugPrint("✅ Custom Token으로 재로그인 성공! ID Token 획득 완료");
              return true;
            }
          }
        } catch (e) {
          debugPrint("❌ Custom Token으로 재로그인 실패: $e");
          // Custom Token이 만료되었거나 유효하지 않으면 재로그인 필요
          await prefs.remove("custom_token");
          await prefs.remove("firebase_token");
          await prefs.remove("uid");
          await prefs.remove("user_info");
          return false;
        }
      }
      return false;
    } catch (e) {
      debugPrint("❌ 저장된 인증 정보 로드 실패: $e");
      return false;
    }
  }

  /// ID Token을 갱신합니다 (만료된 경우)
  Future<String?> refreshToken() async {
    try {
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser != null) {
        final idToken = await firebaseUser.getIdToken(true); // 강제 갱신
        _firebaseToken = idToken;

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("firebase_token", _firebaseToken!);

        return _firebaseToken;
      }
      return null;
    } catch (e) {
      debugPrint("❌ 토큰 갱신 실패: $e");
      return null;
    }
  }

  String? getAuthHeader() {
    if (_firebaseToken == null) return null;
    return "Bearer $_firebaseToken";
  }
}
