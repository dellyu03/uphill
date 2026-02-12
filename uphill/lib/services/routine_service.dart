/// 루틴 서비스
/// 루틴 CRUD 및 수행 기록, AI 피드백 API를 담당합니다.
library;

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../constants/app_constants.dart';
import 'auth_service.dart';
import 'dummy_auth_service.dart';

/// 루틴 서비스 (Singleton)
/// 백엔드 API와 통신하여 루틴 데이터를 관리합니다.
class RoutineService {
  // Singleton 패턴
  static final RoutineService _instance = RoutineService._internal();
  factory RoutineService() => _instance;
  RoutineService._internal();

  /// 인증 서비스 싱글톤
  final AuthService _authService = AuthService();
  final DummyAuthService _dummyAuthService = DummyAuthService();

  // ===== 루틴 CRUD API =====

  /// 루틴 목록 조회
  /// [Backend 요청] GET /routines
  /// 사용자의 모든 루틴 목록을 반환합니다.
  Future<List<Map<String, dynamic>>> getRoutines() async {
    // 1. 더미 로그인 확인
    if (_dummyAuthService.isLoggedIn) {
      debugPrint('🔄 [Dummy] 루틴 목록 조회');
      // 더미 데이터 반환
      return _getDummyRoutines();
    }

    try {
      final authHeader = _authService.getAuthHeader();
      if (authHeader == null) {
        throw Exception(TextConstants.loginRequired);
      }

      // [Backend 요청] 루틴 목록 조회
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.routines}'),
        headers: {
          'Authorization': authHeader,
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => item as Map<String, dynamic>).toList();
      } else if (response.statusCode == 401) {
        throw Exception(TextConstants.authExpired);
      } else {
        throw Exception('루틴 조회 실패: ${response.body}');
      }
    } catch (e) {
      debugPrint('❌ 루틴 조회 에러: $e');
      rethrow;
    }
  }

  /// 루틴 생성
  /// [Backend 요청] POST /routines
  Future<Map<String, dynamic>> createRoutine({
    required String title,
    required String time,
    required String category,
    String? color,
    List<int>? days,
    // 프리미엄 UI 추가 필드
    String? purpose,
    String? space,
    String? description,
    bool? isFlexible,
    String? notificationTime,
    String? endTime, // 지속 시간 종료
    List<Map<String, dynamic>>? iotDevices, // IOT 장비 설정
  }) async {
    // 1. 더미 로그인 확인
    if (_dummyAuthService.isLoggedIn) {
      debugPrint('🔄 [Dummy] 루틴 생성: $title');
      debugPrint('   - Purpose: $purpose');
      debugPrint('   - Space: $space');
      debugPrint('   - Devices: ${iotDevices?.length}');

      return {
        'id': 'dummy_${DateTime.now().millisecondsSinceEpoch}',
        'title': title,
        'time': time, // Start Time
        'category': category,
        'color': color ?? '#9CAA7D',
        'days': days ?? [],
        'purpose': purpose,
        'space': space,
        'description': description,
        'is_flexible': isFlexible,
        'notification_time': notificationTime,
        'end_time': endTime,
        'iot_devices': iotDevices,
      };
    }

    try {
      final authHeader = _authService.getAuthHeader();
      if (authHeader == null) {
        throw Exception(TextConstants.loginRequired);
      }

      // [Backend 요청] 루틴 생성
      // 백엔드가 아직 새 필드를 지원하지 않을 수 있으므로,
      // 지원하는 필드만 보내거나, 필요시 'meta' 필드 등에 담아서 보낼 수 있음.
      // 여기서는 일단 기존 필드 + 가능한 필드만 전송한다고 가정.
      final body = {
        'title': title,
        'time': time,
        'category': category,
        if (color != null) 'color': color,
        if (days != null) 'days': days,
        // 필요시 백엔드 스펙에 맞춰 추가전송
        if (purpose != null) 'purpose': purpose,
        if (space != null) 'space': space,
      };

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.routines}'),
        headers: {
          'Authorization': authHeader,
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else if (response.statusCode == 401) {
        throw Exception(TextConstants.authExpired);
      } else {
        throw Exception('루틴 생성 실패: ${response.body}');
      }
    } catch (e) {
      debugPrint('❌ 루틴 생성 에러: $e');
      rethrow;
    }
  }

  /// 루틴 수정
  /// [Backend 요청] PUT /routines/{id}
  Future<Map<String, dynamic>> updateRoutine({
    required String routineId,
    String? title,
    String? time,
    String? category,
    String? color,
    List<int>? days,
    // 프리미엄 UI 추가 필드
    String? purpose,
    String? space,
    String? description,
    bool? isFlexible,
    String? notificationTime,
    String? endTime,
    List<Map<String, dynamic>>? iotDevices,
  }) async {
    // 1. 더미 로그인 확인
    if (_dummyAuthService.isLoggedIn) {
      debugPrint('🔄 [Dummy] 루틴 수정: $routineId');
      return {
        'id': routineId,
        'title': title ?? '수정된 루틴',
        'time': time ?? '09:00',
        'category': category ?? '건강',
        'color': color ?? '#9CAA7D',
        'days': days ?? [],
        'purpose': purpose,
        'space': space,
        'description': description,
        'is_flexible': isFlexible,
        'notification_time': notificationTime,
        'end_time': endTime,
        'iot_devices': iotDevices,
      };
    }

    try {
      final authHeader = _authService.getAuthHeader();
      if (authHeader == null) {
        throw Exception(TextConstants.loginRequired);
      }

      final body = <String, dynamic>{};
      if (title != null) body['title'] = title;
      if (time != null) body['time'] = time;
      if (category != null) body['category'] = category;
      if (color != null) body['color'] = color;
      if (days != null) body['days'] = days;
      if (purpose != null) body['purpose'] = purpose;
      if (space != null) body['space'] = space;
      if (description != null) body['description'] = description;
      if (isFlexible != null) body['is_flexible'] = isFlexible;
      if (notificationTime != null) {
        body['notification_time'] = notificationTime;
      }
      if (endTime != null) body['end_time'] = endTime;
      if (iotDevices != null) body['iot_devices'] = iotDevices;

      // [Backend 요청] 루틴 수정
      final response = await http.put(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.routines}/$routineId'),
        headers: {
          'Authorization': authHeader,
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else if (response.statusCode == 401) {
        throw Exception(TextConstants.authExpired);
      } else {
        throw Exception('루틴 수정 실패: ${response.body}');
      }
    } catch (e) {
      debugPrint('❌ 루틴 수정 에러: $e');
      rethrow;
    }
  }

  /// 루틴 삭제
  /// [Backend 요청] DELETE /routines/{id}
  Future<void> deleteRoutine(String routineId) async {
    // 1. 더미 로그인 확인
    if (_dummyAuthService.isLoggedIn) {
      debugPrint('🔄 [Dummy] 루틴 삭제: $routineId');
      return;
    }

    try {
      final authHeader = _authService.getAuthHeader();
      if (authHeader == null) {
        throw Exception(TextConstants.loginRequired);
      }

      // [Backend 요청] 루틴 삭제
      final response = await http.delete(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.routines}/$routineId'),
        headers: {'Authorization': authHeader},
      );

      if (response.statusCode == 204) {
        return;
      } else if (response.statusCode == 401) {
        throw Exception(TextConstants.authExpired);
      } else {
        throw Exception('루틴 삭제 실패: ${response.body}');
      }
    } catch (e) {
      debugPrint('❌ 루틴 삭제 에러: $e');
      rethrow;
    }
  }

  // ===== 수행 기록 API =====

  /// 루틴 수행 기록 저장
  /// [Backend 요청] POST /executions/{routineId}
  Future<Map<String, dynamic>> createExecution({
    required String routineId,
    required String routineTitle,
    required DateTime startedAt,
    required DateTime endedAt,
    required int durationSeconds,
  }) async {
    // 1. 더미 로그인 확인
    if (_dummyAuthService.isLoggedIn) {
      debugPrint('🔄 [Dummy] 수행 기록 저장: $routineTitle');
      return {
        'id': 'dummy_exec_${DateTime.now().millisecondsSinceEpoch}',
        'routine_id': routineId,
        'routine_title': routineTitle,
        'started_at': startedAt.toUtc().toIso8601String(),
        'ended_at': endedAt.toUtc().toIso8601String(),
        'duration_seconds': durationSeconds,
      };
    }

    try {
      final authHeader = _authService.getAuthHeader();
      if (authHeader == null) {
        throw Exception(TextConstants.loginRequired);
      }

      // [Backend 요청] 수행 기록 저장
      final response = await http.post(
        Uri.parse(
          '${ApiConstants.baseUrl}${ApiConstants.executions}/$routineId',
        ),
        headers: {
          'Authorization': authHeader,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'routine_id': routineId,
          'routine_title': routineTitle,
          'started_at': startedAt.toUtc().toIso8601String(),
          'ended_at': endedAt.toUtc().toIso8601String(),
          'duration_seconds': durationSeconds,
        }),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else if (response.statusCode == 401) {
        throw Exception(TextConstants.authExpired);
      } else {
        throw Exception('수행 기록 저장 실패: ${response.body}');
      }
    } catch (e) {
      debugPrint('❌ 수행 기록 저장 에러: $e');
      rethrow;
    }
  }

  /// 일간 수행 기록 조회
  /// [Backend 요청] GET /executions/daily?date={date}
  Future<Map<String, dynamic>> getDailyExecutions(String date) async {
    // 1. 더미 로그인 확인
    if (_dummyAuthService.isLoggedIn) {
      debugPrint('🔄 [Dummy] 일간 기록 조회: $date');
      return {
        'date': date,
        'executions': [],
        'total_duration_seconds': 0,
        'total_count': 0,
      };
    }

    try {
      final authHeader = _authService.getAuthHeader();
      if (authHeader == null) {
        throw Exception(TextConstants.loginRequired);
      }

      // [Backend 요청] 일간 수행 기록 조회
      final response = await http.get(
        Uri.parse(
          '${ApiConstants.baseUrl}${ApiConstants.executions}/daily?date=$date',
        ),
        headers: {
          'Authorization': authHeader,
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else if (response.statusCode == 401) {
        throw Exception(TextConstants.authExpired);
      } else {
        throw Exception('일간 기록 조회 실패: ${response.body}');
      }
    } catch (e) {
      debugPrint('❌ 일간 기록 조회 에러: $e');
      rethrow;
    }
  }

  /// 일간 AI 피드백 조회
  /// [Backend 요청] GET /executions/daily/{date}/feedback
  Future<Map<String, dynamic>> getDailyFeedback(String date) async {
    // 1. 더미 로그인 확인
    if (_dummyAuthService.isLoggedIn) {
      debugPrint('🔄 [Dummy] AI 피드백 조회: $date');
      return {
        'date': date,
        'ai_feedback_short': '침대에서 너무 많은 시간을 보내고 있어요',
        'ai_feedback_full':
            '이러이러한 루틴을 추가해 보는것이 어떤가요? 이러이러한 루틴을 추가해 보는것이 어떤가요? 이러이러한 루틴을 추가해 보는것이 어떤가요...',
        'recommended_routines': ['명상하기', '스트레칭'],
        'background_image_url': 'assets/images/img_feedback_background.png',
        'summary': {'total_routines': 3, 'total_duration_seconds': 1800},
      };
    }

    try {
      final authHeader = _authService.getAuthHeader();
      if (authHeader == null) {
        throw Exception(TextConstants.loginRequired);
      }

      // [Backend 요청] AI 피드백 조회
      final response = await http.get(
        Uri.parse(
          '${ApiConstants.baseUrl}${ApiConstants.executions}/daily/$date/feedback',
        ),
        headers: {
          'Authorization': authHeader,
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else if (response.statusCode == 401) {
        throw Exception(TextConstants.authExpired);
      } else {
        throw Exception('피드백 조회 실패: ${response.body}');
      }
    } catch (e) {
      debugPrint('❌ 피드백 조회 에러: $e');
      rethrow;
    }
  }

  /// 루틴 단건 조회
  /// [Backend 요청] GET /routines/{id}
  Future<Map<String, dynamic>> getRoutine(String routineId) async {
    // 1. 더미 로그인 확인
    if (_dummyAuthService.isLoggedIn) {
      debugPrint('🔄 [Dummy] 루틴 단건 조회: $routineId');
      final routines = _getDummyRoutines();
      final routine = routines.firstWhere(
        (element) => element['id'].toString() == routineId,
        orElse: () => {},
      );

      if (routine.isEmpty) {
        throw Exception('루틴을 찾을 수 없습니다.');
      }
      return routine;
    }

    try {
      final authHeader = _authService.getAuthHeader();
      if (authHeader == null) {
        throw Exception(TextConstants.loginRequired);
      }

      // [Backend 요청] 루틴 단건 조회
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.routines}/$routineId'),
        headers: {
          'Authorization': authHeader,
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else if (response.statusCode == 401) {
        throw Exception(TextConstants.authExpired);
      } else {
        throw Exception('루틴 조회 실패: ${response.body}');
      }
    } catch (e) {
      debugPrint('❌ 루틴 단건 조회 에러: $e');
      rethrow;
    }
  }

  // ===== 더미 데이터 =====
  List<Map<String, dynamic>> _getDummyRoutines() {
    return [
      {
        'id': '1',
        'title': '모닝 스트레칭',
        'time': '07:00',
        'end_time': '08:00',
        'category': '건강', // purpose
        'purpose': '건강',
        'color': '#FF9E9E',
        'days': [0, 1, 2, 3, 4], // 월~금
        'space': '방 1',
        'description': '편안한 분위기에서 가벼운 스트레칭',
        'is_flexible': true,
        'notification_time': '10분 전',
        'isPinned': false,
        'isUpdated': true, // 업데이트 카드 (그라디언트)
        'iot_devices': [
          {'type': '조명', 'brightness': 0.8, 'hasBrightness': true},
          {'type': '커튼', 'brightness': 0.0, 'hasBrightness': false},
        ],
      },
      {
        'id': '2',
        'title': '독서',
        'time': '20:00',
        'end_time': '21:00',
        'category': '자기계발',
        'purpose': '자기계발',
        'color': '#9E9EFF',
        'days': [0, 1, 2, 3, 4, 5, 6],
        'space': '거실',
        'description': '조용한 분위기에서 독서',
        'is_flexible': false,
        'notification_time': '30분 전',
        'isPinned': false,
        'isUpdated': false, // 기본 카드
        'iot_devices': [],
      },
      {
        'id': '3',
        'title': '영양제 먹기',
        'time': '08:00',
        'end_time': '08:05',
        'category': '건강',
        'purpose': '건강',
        'color': '#9EFF9E',
        'days': [0, 1, 2, 3, 4, 5, 6],
        'space': '주방',
        'description': '',
        'is_flexible': true,
        'notification_time': '5분 전',
        'isPinned': true, // 핀 카드 (회전된 아이콘)
        'isUpdated': false,
        'iot_devices': [],
      },
      {
        'id': '4',
        'title': '영어 단어 암기',
        'time': '21:00',
        'end_time': '22:00',
        'category': '학습',
        'purpose': '학습',
        'color': '#FFFF9E',
        'days': [0, 2, 4],
        'space': '방 2',
        'description': '집중할 수 있는 환경',
        'is_flexible': false,
        'notification_time': '1시간 전',
        'isPinned': false,
        'isUpdated': false, // 기본 카드
        'iot_devices': [],
      },
    ];
  }
}
