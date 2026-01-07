import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/auth_service.dart';

class RoutineService {
  static final RoutineService _instance = RoutineService._internal();
  factory RoutineService() => _instance;
  RoutineService._internal();

  static const String _baseUrl = "http://10.0.2.2:8000"; // Android 에뮬레이터용
  // 실제 기기나 iOS 시뮬레이터의 경우: "http://localhost:8000" 또는 실제 서버 IP

  final AuthService _authService = AuthService();

  Future<List<Map<String, dynamic>>> getRoutines() async {
    try {
      final authHeader = _authService.getAuthHeader();
      if (authHeader == null) {
        throw Exception("로그인이 필요합니다");
      }

      final response = await http.get(
        Uri.parse("$_baseUrl/routines"),
        headers: {
          "Authorization": authHeader,
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => item as Map<String, dynamic>).toList();
      } else if (response.statusCode == 401) {
        throw Exception("인증이 만료되었습니다. 다시 로그인해주세요.");
      } else {
        throw Exception("루틴 조회 실패: ${response.body}");
      }
    } catch (e) {
      debugPrint("❌ 루틴 조회 에러: $e");
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createRoutine({
    required String title,
    required String time,
    required String category,
    String? color,
  }) async {
    try {
      final authHeader = _authService.getAuthHeader();
      if (authHeader == null) {
        throw Exception("로그인이 필요합니다");
      }

      final response = await http.post(
        Uri.parse("$_baseUrl/routines"),
        headers: {
          "Authorization": authHeader,
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "title": title,
          "time": time,
          "category": category,
          if (color != null) "color": color,
        }),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else if (response.statusCode == 401) {
        throw Exception("인증이 만료되었습니다. 다시 로그인해주세요.");
      } else {
        throw Exception("루틴 생성 실패: ${response.body}");
      }
    } catch (e) {
      debugPrint("❌ 루틴 생성 에러: $e");
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateRoutine({
    required String routineId,
    String? title,
    String? time,
    String? category,
    String? color,
  }) async {
    try {
      final authHeader = _authService.getAuthHeader();
      if (authHeader == null) {
        throw Exception("로그인이 필요합니다");
      }

      final body = <String, dynamic>{};
      if (title != null) body["title"] = title;
      if (time != null) body["time"] = time;
      if (category != null) body["category"] = category;
      if (color != null) body["color"] = color;

      final response = await http.put(
        Uri.parse("$_baseUrl/routines/$routineId"),
        headers: {
          "Authorization": authHeader,
          "Content-Type": "application/json",
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else if (response.statusCode == 401) {
        throw Exception("인증이 만료되었습니다. 다시 로그인해주세요.");
      } else {
        throw Exception("루틴 수정 실패: ${response.body}");
      }
    } catch (e) {
      debugPrint("❌ 루틴 수정 에러: $e");
      rethrow;
    }
  }

  Future<void> deleteRoutine(String routineId) async {
    try {
      final authHeader = _authService.getAuthHeader();
      if (authHeader == null) {
        throw Exception("로그인이 필요합니다");
      }

      final response = await http.delete(
        Uri.parse("$_baseUrl/routines/$routineId"),
        headers: {"Authorization": authHeader},
      );

      if (response.statusCode == 204) {
        return;
      } else if (response.statusCode == 401) {
        throw Exception("인증이 만료되었습니다. 다시 로그인해주세요.");
      } else {
        throw Exception("루틴 삭제 실패: ${response.body}");
      }
    } catch (e) {
      debugPrint("❌ 루틴 삭제 에러: $e");
      rethrow;
    }
  }
}
