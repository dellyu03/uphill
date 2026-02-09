import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// 더미 인증 서비스
/// Firebase 연동 없이 테스트용으로 사용하는 인증 서비스
class DummyAuthService {
  static final DummyAuthService _instance = DummyAuthService._internal();
  factory DummyAuthService() => _instance;
  DummyAuthService._internal();

  // 더미 사용자 데이터베이스
  final Map<String, Map<String, dynamic>> _dummyUsers = {
    'user1@test.com': {
      'uid': 'dummy_uid_001',
      'email': 'user1@test.com',
      'name': '김철수',
      'isNewUser': false,
      'onboardingCompleted': true,
    },
    'user2@test.com': {
      'uid': 'dummy_uid_002',
      'email': 'user2@test.com',
      'name': '이영희',
      'isNewUser': false,
      'onboardingCompleted': true,
    },
    'newuser@test.com': {
      'uid': 'dummy_uid_003',
      'email': 'newuser@test.com',
      'name': '신규사용자',
      'isNewUser': true,
      'onboardingCompleted': false,
    },
  };

  String? _currentUid;
  Map<String, dynamic>? _currentUserInfo;
  bool _isLoggedIn = false;

  // Getters
  String? get uid => _currentUid;
  Map<String, dynamic>? get userInfo => _currentUserInfo;
  bool get isLoggedIn => _isLoggedIn;
  bool get isNewUser => _currentUserInfo?['isNewUser'] ?? true;
  bool get onboardingCompleted =>
      _currentUserInfo?['onboardingCompleted'] ?? false;

  /// 더미 로그인 (이메일 선택 방식)
  Future<bool> signIn(String email) async {
    try {
      debugPrint('🔄 더미 로그인 시도: $email');

      // 더미 사용자 확인
      if (_dummyUsers.containsKey(email)) {
        final userData = _dummyUsers[email]!;
        _currentUid = userData['uid'];
        _currentUserInfo = Map<String, dynamic>.from(userData);
        _isLoggedIn = true;

        // SharedPreferences에 저장
        await _saveAuthData();

        debugPrint('✅ 더미 로그인 성공!');
        debugPrint('   - UID: $_currentUid');
        debugPrint('   - 신규 사용자: ${_currentUserInfo!['isNewUser']}');
        debugPrint('   - 온보딩 완료: ${_currentUserInfo!['onboardingCompleted']}');

        return true;
      } else {
        // 새로운 사용자 생성
        debugPrint('⚠️ 존재하지 않는 사용자 - 신규 사용자로 생성');
        _currentUid = 'dummy_uid_${DateTime.now().millisecondsSinceEpoch}';
        _currentUserInfo = {
          'uid': _currentUid,
          'email': email,
          'name': '신규 사용자',
          'isNewUser': true,
          'onboardingCompleted': false,
        };
        _isLoggedIn = true;

        // 더미 DB에 추가
        _dummyUsers[email] = Map<String, dynamic>.from(_currentUserInfo!);

        await _saveAuthData();

        debugPrint('✅ 신규 사용자 생성 완료!');
        return true;
      }
    } catch (e) {
      debugPrint('❌ 더미 로그인 실패: $e');
      return false;
    }
  }

  /// 저장된 인증 정보 로드
  Future<bool> loadStoredAuth() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('dummy_uid');
      final userInfoStr = prefs.getString('dummy_user_info');

      if (uid != null && userInfoStr != null) {
        _currentUid = uid;
        _currentUserInfo = jsonDecode(userInfoStr);
        _isLoggedIn = true;

        debugPrint('✅ 저장된 인증 정보 로드 성공');
        debugPrint('   - UID: $_currentUid');
        return true;
      }

      return false;
    } catch (e) {
      debugPrint('❌ 저장된 인증 정보 로드 실패: $e');
      return false;
    }
  }

  /// 인증 데이터 저장
  Future<void> _saveAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('dummy_uid', _currentUid!);
    await prefs.setString('dummy_user_info', jsonEncode(_currentUserInfo));
  }

  /// 온보딩 완료 처리
  Future<void> completeOnboarding({
    required Map<String, dynamic> onboardingData,
  }) async {
    if (_currentUserInfo != null) {
      _currentUserInfo!['isNewUser'] = false;
      _currentUserInfo!['onboardingCompleted'] = true;
      _currentUserInfo!['onboardingData'] = onboardingData;

      // 더미 DB 업데이트
      final email = _currentUserInfo!['email'];
      _dummyUsers[email] = Map<String, dynamic>.from(_currentUserInfo!);

      await _saveAuthData();

      debugPrint('✅ 온보딩 완료 처리');
      debugPrint('   - 사용자 정보: ${jsonEncode(onboardingData)}');
    }
  }

  /// 로그아웃
  Future<void> signOut() async {
    _currentUid = null;
    _currentUserInfo = null;
    _isLoggedIn = false;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('dummy_uid');
    await prefs.remove('dummy_user_info');

    debugPrint('✅ 로그아웃 완료');
  }

  /// 사용 가능한 더미 계정 목록
  List<String> getAvailableEmails() {
    return _dummyUsers.keys.toList();
  }
}
