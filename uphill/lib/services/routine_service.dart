/// 루틴 서비스
/// 루틴 CRUD 및 수행 기록, AI 피드백 API를 담당합니다.
library;

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../constants/app_constants.dart';
import 'auth_service.dart';

/// 루틴 서비스 (Singleton)
/// 백엔드 API와 통신하여 루틴 데이터를 관리합니다.
class RoutineService {
  // Singleton 패턴
  static final RoutineService _instance = RoutineService._internal();
  factory RoutineService() => _instance;
  RoutineService._internal();

  /// 인증 서비스 싱글톤
  final AuthService _authService = AuthService();

  // ===== 루틴 CRUD API =====

  /// 루틴 목록 조회
  /// [Backend 요청] GET /routines
  /// 사용자의 모든 루틴 목록을 반환합니다.
  Future<List<Map<String, dynamic>>> getRoutines() async {
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
  /// [title] 루틴 제목
  /// [time] 시작 시간 (HH:MM)
  /// [category] 카테고리
  /// [color] 색상 (선택)
  /// [days] 반복 요일 (0=월, 1=화, ..., 6=일)
  Future<Map<String, dynamic>> createRoutine({
    required String title,
    required String time,
    required String category,
    String? color,
    List<int>? days,
  }) async {
    try {
      final authHeader = _authService.getAuthHeader();
      if (authHeader == null) {
        throw Exception(TextConstants.loginRequired);
      }

      // [Backend 요청] 루틴 생성
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.routines}'),
        headers: {
          'Authorization': authHeader,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'title': title,
          'time': time,
          'category': category,
          if (color != null) 'color': color,
          if (days != null) 'days': days,
        }),
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
  /// [routineId] 루틴 ID
  Future<Map<String, dynamic>> updateRoutine({
    required String routineId,
    String? title,
    String? time,
    String? category,
    String? color,
    List<int>? days,
  }) async {
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
  /// [routineId] 루틴 ID
  Future<void> deleteRoutine(String routineId) async {
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
  /// [routineId] 루틴 ID
  /// [routineTitle] 루틴 제목
  /// [startedAt] 시작 시간
  /// [endedAt] 종료 시간
  /// [durationSeconds] 수행 시간 (초)
  Future<Map<String, dynamic>> createExecution({
    required String routineId,
    required String routineTitle,
    required DateTime startedAt,
    required DateTime endedAt,
    required int durationSeconds,
  }) async {
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
  /// [date] 조회 날짜 (YYYY-MM-DD)
  Future<Map<String, dynamic>> getDailyExecutions(String date) async {
    try {
      final authHeader = _authService.getAuthHeader();
      if (authHeader == null) {
        throw Exception(TextConstants.loginRequired);
      }

      // [Backend 요청] 일간 수행 기록 조회
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.executions}/daily?date=$date'),
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
  /// [date] 조회 날짜 (YYYY-MM-DD)
  Future<Map<String, dynamic>> getDailyFeedback(String date) async {
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
}
