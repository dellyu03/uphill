import 'package:flutter/material.dart';

/// 앱 전체에서 사용될 루틴 데이터 모델
class Routine {
  final String id;
  final String title;
  final String category; // e.g. 건강, 학습
  final bool isFlexible; // 유연 루틴인지 정해진 시간에 하는 루틴인지 여부

  final String? time; // 시작 시간 (HH:mm)
  final String? endTime; // 종료 시간 (HH:mm)
  final List<int> days; // 요일 (0:월 ~ 6:일)
  final String? color; // 아이콘 등 표시할 컬러

  // Premium Fields
  final String? purpose; // 목적 텍스트
  final String? space; // 루틴 진행 공간
  final String? description; // 상세 설명문
  final String? notificationTime;

  final bool isPinned;
  final bool isUpdated;
  final List<dynamic>? iotDevices;

  Routine({
    required this.id,
    required this.title,
    required this.category,
    this.isFlexible = false,
    this.time,
    this.endTime,
    this.days = const [],
    this.color,
    this.purpose,
    this.space,
    this.description,
    this.notificationTime,
    this.isPinned = false,
    this.isUpdated = false,
    this.iotDevices,
  });

  /// TimeOfDay 형태로 시간 파싱을 돕는 유틸성 getter
  TimeOfDay? get parsedStartTime {
    if (time == null || !time!.contains(':')) return null;
    final splitted = time!.split(':');
    return TimeOfDay(
      hour: int.parse(splitted[0]),
      minute: int.parse(splitted[1]),
    );
  }

  TimeOfDay? get parsedEndTime {
    if (endTime == null || !endTime!.contains(':')) return null;
    final splitted = endTime!.split(':');
    return TimeOfDay(
      hour: int.parse(splitted[0]),
      minute: int.parse(splitted[1]),
    );
  }

  factory Routine.fromJson(Map<String, dynamic> json) {
    return Routine(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      category: json['category'] ?? '',
      isFlexible: json['is_flexible'] == true,
      time: json['time'],
      endTime: json['end_time'],
      days: json['days'] != null ? List<int>.from(json['days']) : [],
      color: json['color'],
      purpose: json['purpose'],
      space: json['space'],
      description: json['description'],
      notificationTime: json['notification_time'],
      isPinned: json['isPinned'] == true,
      isUpdated: json['isUpdated'] == true,
      iotDevices: json['iot_devices'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'is_flexible': isFlexible,
      'time': time,
      'end_time': endTime,
      'days': days,
      'color': color,
      'purpose': purpose,
      'space': space,
      'description': description,
      'notification_time': notificationTime,
      'isPinned': isPinned,
      'isUpdated': isUpdated,
      'iot_devices': iotDevices,
    };
  }

  /// 새로운 값으로 복제본을 리턴
  Routine copyWith({
    String? id,
    String? title,
    String? category,
    bool? isFlexible,
    String? time,
    String? endTime,
    List<int>? days,
    String? color,
    String? purpose,
    String? space,
    String? description,
    String? notificationTime,
    bool? isPinned,
    bool? isUpdated,
    List<dynamic>? iotDevices,
  }) {
    return Routine(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      isFlexible: isFlexible ?? this.isFlexible,
      time: time ?? this.time,
      endTime: endTime ?? this.endTime,
      days: days ?? this.days,
      color: color ?? this.color,
      purpose: purpose ?? this.purpose,
      space: space ?? this.space,
      description: description ?? this.description,
      notificationTime: notificationTime ?? this.notificationTime,
      isPinned: isPinned ?? this.isPinned,
      isUpdated: isUpdated ?? this.isUpdated,
      iotDevices: iotDevices ?? this.iotDevices,
    );
  }
}
