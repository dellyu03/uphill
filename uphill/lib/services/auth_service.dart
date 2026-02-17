/// 인증 서비스
/// Google Sign In 및 Firebase Auth를 관리합니다.
library;

import 'package:flutter/foundation.dart';
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

  /// Firebase Auth 인스턴스
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  /// Firebase ID Token (API 인증용)
  String? _firebaseToken;

  /// 사용자 UID
  String? _uid;

  /// 사용자 정보
  Map<String, dynamic>? _userInfo;

  /// 신규 사용자 여부
  bool _isNewUser = false;

  // Getters
  String? get firebaseToken => _firebaseToken;
  String? get uid => _uid;
  Map<String, dynamic>? get userInfo => _userInfo;
  bool get isLoggedIn => _firebaseToken != null && _uid != null;
  bool get isNewUser => _isNewUser;

  /// Google Sign In (Firebase Auth 사용)
  /// Firebase Auth로 직접 Google 로그인 후 백엔드와 동기화
  Future<bool> signIn() async {
    try {
      debugPrint('🔄 Firebase Google Sign In 시작...');

      // 1. Firebase Auth로 Google Sign In
      final GoogleAuthProvider googleProvider = GoogleAuthProvider();
      final UserCredential userCredential =
          await _firebaseAuth.signInWithProvider(googleProvider);

      final User? firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        debugPrint('❌ Firebase 사용자를 가져올 수 없습니다');
        return false;
      }

      // 신규 사용자 여부 확인
      _isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;

      debugPrint('✅ Firebase Google Sign In 성공: ${firebaseUser.email}');
      debugPrint('   신규 사용자: $_isNewUser');

      // 2. Firebase ID Token 획득
      final firebaseIdToken = await firebaseUser.getIdToken();
      if (firebaseIdToken == null) {
        debugPrint('❌ Firebase ID Token을 가져올 수 없습니다');
        return false;
      }

      _firebaseToken = firebaseIdToken;
      _uid = firebaseUser.uid;
      _userInfo = {
        'uid': firebaseUser.uid,
        'email': firebaseUser.email,
        'name': firebaseUser.displayName,
        'picture': firebaseUser.photoURL,
      };

      // 3. SharedPreferences에 저장
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(StorageKeys.firebaseToken, _firebaseToken!);
      await prefs.setString(StorageKeys.uid, _uid!);
      await prefs.setString(StorageKeys.userInfo, jsonEncode(_userInfo));

      debugPrint('✅ 로그인 성공! UID: $_uid');
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


  /// 로그아웃
  /// 모든 인증 정보를 초기화합니다.
  Future<void> signOut() async {
    await _firebaseAuth.signOut();

    _firebaseToken = null;
    _uid = null;
    _userInfo = null;

    // SharedPreferences에서 삭제
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(StorageKeys.firebaseToken);
    await prefs.remove(StorageKeys.uid);
    await prefs.remove(StorageKeys.userInfo);

    debugPrint('✅ 로그아웃 완료');
  }

  /// 저장된 인증 정보 로드
  /// Firebase Auth 상태 또는 저장된 Custom Token으로 복구합니다.
  Future<bool> loadStoredAuth() async {
    try {
      debugPrint('🔄 저장된 인증 정보 로드 시도...');

      // 1. Firebase Auth에서 현재 사용자 확인
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser != null) {
        debugPrint('✅ Firebase Auth 사용자 발견: ${firebaseUser.uid}');

        // 타임아웃 5초 설정
        final idToken = await firebaseUser.getIdToken().timeout(
          const Duration(seconds: 5),
          onTimeout: () {
            debugPrint('⚠️ ID Token 가져오기 타임아웃');
            return null;
          },
        );

        if (idToken == null) {
          debugPrint('❌ ID Token 가져오기 실패');
          return false;
        }

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

        debugPrint('✅ Firebase Auth로 자동 로그인 성공');
        return true;
      }

      debugPrint('ℹ️ 저장된 인증 정보 없음');
      return false;
    } catch (e) {
      debugPrint('❌ 저장된 인증 정보 로드 실패: $e');
      return false;
    }
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

  /// 프로필 업데이트
  /// 사용자 이름과 프로필 사진을 업데이트합니다.
  Future<void> updateProfile({String? name, String? picture}) async {
    if (_userInfo != null) {
      if (name != null) _userInfo!['name'] = name;
      if (picture != null) _userInfo!['picture'] = picture;

      // SharedPreferences에 저장
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(StorageKeys.userInfo, jsonEncode(_userInfo));

      debugPrint('✅ 프로필 업데이트 완료 (로컬)');
      if (name != null) debugPrint('   - 이름: $name');
      if (picture != null) debugPrint('   - 사진: $picture');

      // TODO: 백엔드에 프로필 업데이트 API가 구현되면 여기서 호출
      // final response = await http.put(
      //   Uri.parse('${ApiConstants.baseUrl}/user/profile'),
      //   headers: {'Authorization': getAuthHeader()!},
      //   body: jsonEncode({'name': name, 'picture': picture}),
      // );
    }
  }
}
