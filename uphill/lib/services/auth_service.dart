/// 인증 서비스
/// Google Sign In 및 Firebase Auth를 관리합니다.
library;

import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../constants/app_constants.dart';

/// 인증 서비스 (Singleton)
/// 사용자 인증 및 토큰 관리를 담당합니다.
class AuthService {
  // Singleton 패턴
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  /// Google Sign In 인스턴스
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

  /// Firebase ID Token (API 인증용)
  String? _firebaseToken;

  /// 사용자 UID
  String? _uid;

  /// 사용자 정보
  Map<String, dynamic>? _userInfo;

  // Getters
  String? get firebaseToken => _firebaseToken;
  String? get uid => _uid;
  Map<String, dynamic>? get userInfo => _userInfo;
  bool get isLoggedIn => _firebaseToken != null && _uid != null;

  /// Google Sign In 및 백엔드 인증
  /// [Backend 요청] POST /auth/google
  /// Google ID Token을 백엔드로 전송하여 Firebase Custom Token을 받습니다.
  Future<bool> signIn() async {
    try {
      debugPrint('🔄 Google Sign In 시작...');

      // 1. Google Sign In
      final GoogleSignInAccount? user = await _googleSignIn.signIn();
      if (user == null) {
        debugPrint('❌ 사용자가 로그인을 취소했습니다');
        return false;
      }

      debugPrint('✅ Google Sign In 성공: ${user.email}');

      // 2. Google ID Token 획득
      final googleAuth = await user.authentication;
      final idToken = googleAuth.idToken;
      if (idToken == null) {
        debugPrint('❌ ID Token을 가져올 수 없습니다');
        return false;
      }

      // 3. [Backend 요청] Google ID Token으로 백엔드 인증
      debugPrint('📤 백엔드로 ID Token 전송 중...');
      final loginRes = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.authGoogle}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id_token': idToken}),
      );

      debugPrint('📥 백엔드 응답: ${loginRes.statusCode}');
      if (loginRes.statusCode != 200) {
        debugPrint('❌ 백엔드 로그인 실패: ${loginRes.body}');
        return false;
      }

      final loginData = jsonDecode(loginRes.body);
      _uid = loginData['uid'];
      final customToken = loginData['firebase_token'];

      // 4. Firebase Auth로 Custom Token 로그인
      debugPrint('🔄 Firebase Auth로 Custom Token 로그인 중...');
      final credential = await FirebaseAuth.instance.signInWithCustomToken(
        customToken,
      );
      final firebaseUser = credential.user;

      if (firebaseUser == null) {
        debugPrint('❌ Firebase 사용자를 가져올 수 없습니다');
        return false;
      }

      // 5. Firebase ID Token 획득
      final firebaseIdToken = await firebaseUser.getIdToken();
      if (firebaseIdToken == null) {
        debugPrint('❌ ID Token을 가져올 수 없습니다');
        return false;
      }

      _firebaseToken = firebaseIdToken;
      _userInfo = {
        'uid': _uid,
        'email': loginData['email'],
        'name': loginData['name'],
        'picture': loginData['picture'],
      };

      // 6. SharedPreferences에 저장
      await _saveAuthData(customToken);

      debugPrint('✅ 백엔드 로그인 성공! UID: $_uid');
      debugPrint('✅ Firebase ID Token 획득 성공!');
      return true;
    } catch (e, stack) {
      debugPrint('=' * 60);
      debugPrint('❌ 에러 발생!');
      debugPrint('Error: $e');
      debugPrint('Stack trace: $stack');
      debugPrint('=' * 60);
      return false;
    }
  }

  /// 인증 데이터 저장
  Future<void> _saveAuthData(String customToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(StorageKeys.firebaseToken, _firebaseToken!);
    await prefs.setString(StorageKeys.customToken, customToken);
    await prefs.setString(StorageKeys.uid, _uid!);
    await prefs.setString(StorageKeys.userInfo, jsonEncode(_userInfo));
  }

  /// 로그아웃
  /// 모든 인증 정보를 초기화합니다.
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await FirebaseAuth.instance.signOut();

    _firebaseToken = null;
    _uid = null;
    _userInfo = null;

    // SharedPreferences에서 삭제
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(StorageKeys.firebaseToken);
    await prefs.remove(StorageKeys.customToken);
    await prefs.remove(StorageKeys.uid);
    await prefs.remove(StorageKeys.userInfo);
  }

  /// 저장된 인증 정보 로드
  /// Firebase Auth 상태 또는 저장된 Custom Token으로 복구합니다.
  Future<bool> loadStoredAuth() async {
    try {
      // 1. Firebase Auth에서 현재 사용자 확인
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser != null) {
        final idToken = await firebaseUser.getIdToken();
        _firebaseToken = idToken;
        _uid = firebaseUser.uid;

        final prefs = await SharedPreferences.getInstance();
        final userInfoStr = prefs.getString(StorageKeys.userInfo);
        if (userInfoStr != null) {
          _userInfo = jsonDecode(userInfoStr);
        }

        // SharedPreferences 업데이트
        await prefs.setString(StorageKeys.firebaseToken, _firebaseToken!);
        await prefs.setString(StorageKeys.uid, _uid!);

        return true;
      }

      // 2. Firebase Auth에 없으면 Custom Token으로 재로그인 시도
      final prefs = await SharedPreferences.getInstance();
      final customToken = prefs.getString(StorageKeys.customToken);
      final uid = prefs.getString(StorageKeys.uid);
      final userInfoStr = prefs.getString(StorageKeys.userInfo);

      if (customToken != null && uid != null) {
        try {
          debugPrint('🔄 저장된 Custom Token으로 Firebase Auth 재로그인 시도...');

          final credential = await FirebaseAuth.instance.signInWithCustomToken(
            customToken,
          );
          final firebaseUser = credential.user;

          if (firebaseUser != null) {
            final idToken = await firebaseUser.getIdToken();
            if (idToken != null) {
              _firebaseToken = idToken;
              _uid = firebaseUser.uid;
              if (userInfoStr != null) {
                _userInfo = jsonDecode(userInfoStr);
              }

              // SharedPreferences 업데이트
              await prefs.setString(StorageKeys.firebaseToken, _firebaseToken!);
              await prefs.setString(StorageKeys.uid, _uid!);

              debugPrint('✅ Custom Token으로 재로그인 성공! ID Token 획득 완료');
              return true;
            }
          }
        } catch (e) {
          debugPrint('❌ Custom Token으로 재로그인 실패: $e');
          // Custom Token이 만료되었거나 유효하지 않으면 삭제
          await _clearStoredAuth(prefs);
          return false;
        }
      }

      return false;
    } catch (e) {
      debugPrint('❌ 저장된 인증 정보 로드 실패: $e');
      return false;
    }
  }

  /// 저장된 인증 정보 삭제
  Future<void> _clearStoredAuth(SharedPreferences prefs) async {
    await prefs.remove(StorageKeys.customToken);
    await prefs.remove(StorageKeys.firebaseToken);
    await prefs.remove(StorageKeys.uid);
    await prefs.remove(StorageKeys.userInfo);
  }

  /// ID Token 갱신 (만료된 경우)
  Future<String?> refreshToken() async {
    try {
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser != null) {
        // 강제 갱신
        final idToken = await firebaseUser.getIdToken(true);
        _firebaseToken = idToken;

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(StorageKeys.firebaseToken, _firebaseToken!);

        return _firebaseToken;
      }
      return null;
    } catch (e) {
      debugPrint('❌ 토큰 갱신 실패: $e');
      return null;
    }
  }

  /// Authorization 헤더 반환
  /// Bearer {token} 형식의 인증 헤더를 반환합니다.
  String? getAuthHeader() {
    if (_firebaseToken == null) return null;
    return 'Bearer $_firebaseToken';
  }
}
