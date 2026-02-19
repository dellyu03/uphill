/// 앱 전역 상수 정의
/// 하드코딩된 값들을 한 곳에서 관리합니다.
library;

/// 앱 기본 설정
class AppConstants {
  AppConstants._();

  /// 앱 이름
  static const String appName = 'Uphill';

  /// 앱 타이틀 (디버그 모드)
  static const String appTitle = 'Uphill Demo';
}

/// API 관련 상수
class ApiConstants {
  ApiConstants._();

  /// 백엔드 기본 URL (Android 에뮬레이터용)
  static const String baseUrl = 'http://10.0.2.2:8000';

  /// 실제 기기용 URL (필요 시 변경)
  static const String productionUrl = 'http://localhost:8000';

  /// API 엔드포인트
  static const String authGoogle = '/auth/google';
  static const String routines = '/routines';
  static const String executions = '/executions';
  static const String roomScanAnalyze = '/room-scan/analyze';

  /// AI 공간 솔루션 생성 엔드포인트
  static const String spaceSolution = '/routines/space-solution';
}

/// 레이아웃 관련 상수
class LayoutConstants {
  LayoutConstants._();

  /// 타임라인 시간당 높이 (px)
  static const double hourHeight = 150.0;

  /// 타임라인 시작 시간
  static const int startHour = 0;

  /// 타임라인 종료 시간
  static const int endHour = 24;

  /// 타임라인 좌측 마진
  static const double timelineLeftMargin = 70.0;

  /// 기본 수평 패딩
  static const double horizontalPadding = 20.0;

  /// 바텀 네비게이션 바 너비
  static const double bottomNavWidth = 224.0;

  /// 바텀 네비게이션 바 높이
  static const double bottomNavHeight = 60.0;

  /// 바텀 네비게이션 바 하단 위치
  static const double bottomNavBottom = 40.0;

  /// 카드 둥글기
  static const double cardBorderRadius = 24.0;

  /// 큰 카드 둥글기
  static const double largeBorderRadius = 30.0;
}

/// 루틴 관련 상수
class RoutineConstants {
  RoutineConstants._();

  /// 루틴 기본 지속 시간 (분)
  static const int defaultDurationMinutes = 30;

  /// 요일 인덱스 (0=월, 1=화, ..., 6=일)
  static const List<String> weekdayNames = ['월', '화', '수', '목', '금', '토', '일'];
}

/// 텍스트 상수
class TextConstants {
  TextConstants._();

  /// 홈 화면 타이틀
  static const String homeTitle = 'Today';

  /// 피드백 화면 타이틀
  static const String feedbackTitle = 'Feedback';

  /// 루틴 없음 메시지
  static const String noRoutinesMessage = 'No routines assigned.';

  /// 로그인 필요 메시지
  static const String loginRequired = '로그인이 필요합니다';

  /// 인증 만료 메시지
  static const String authExpired = '인증이 만료되었습니다. 다시 로그인해주세요.';

  /// 기본 피드백 메시지
  static const String defaultFeedbackShort = '오늘 하루도 화이팅!';
  static const String defaultFeedbackFull = '루틴을 완료하면 맞춤 피드백을 받을 수 있어요.';

  /// 기본 추천 루틴
  static const List<String> defaultRecommendedRoutines = [
    '스트레칭',
    '물 마시기',
    '명상',
  ];
}

/// SharedPreferences 키
class StorageKeys {
  StorageKeys._();

  static const String firebaseToken = 'firebase_token';
  static const String customToken = 'custom_token';
  static const String uid = 'uid';
  static const String userInfo = 'user_info';

  /// 온보딩 방 스캔에서 감지된 가구 목록 (JSON 문자열 배열)
  static const String detectedFurniture = 'detected_furniture';
}
