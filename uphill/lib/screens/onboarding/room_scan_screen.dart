import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../constants/app_constants.dart';
import '../../services/auth_service.dart';

/// 온보딩 방 스캔 화면
/// 카메라 미리보기를 표시하고 사진을 촬영하여 YOLO11로 가구를 분석합니다.
class RoomScanScreen extends StatefulWidget {
  const RoomScanScreen({super.key});

  @override
  State<RoomScanScreen> createState() => _RoomScanScreenState();
}

class _RoomScanScreenState extends State<RoomScanScreen> {
  // 카메라 컨트롤러
  CameraController? _cameraController;

  // 촬영된 이미지 파일
  XFile? _capturedImage;

  // 분석 중 상태
  bool _isAnalyzing = false;

  // 감지된 가구 목록
  List<String> _detectedFurniture = [];

  // 분석 완료 여부 (결과가 빈 리스트여도 API 호출이 끝나면 true)
  bool _analysisCompleted = false;

  // 카메라 초기화 완료 여부
  bool _isCameraInitialized = false;

  // 카메라 초기화 중복 실행 방지 플래그
  bool _cameraInitStarted = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // didChangeDependencies에서 호출해야 ModalRoute.of(context)가 올바르게 동작함
    if (!_cameraInitStarted) {
      _cameraInitStarted = true;
      _initCamera();
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  /// 카메라 초기화
  Future<void> _initCamera() async {
    // 이전 화면에서 전달받은 카메라 객체
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final camera = args?['camera'] as CameraDescription?;

    if (camera == null) {
      // 카메라가 없는 경우 사용 가능한 카메라 목록에서 가져오기
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        _showErrorAndNavigate('카메라를 찾을 수 없습니다.');
        return;
      }
      final backCamera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      await _setupCamera(backCamera);
    } else {
      await _setupCamera(camera);
    }
  }

  /// 카메라 컨트롤러 설정
  Future<void> _setupCamera(CameraDescription camera) async {
    _cameraController = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
    );

    try {
      await _cameraController!.initialize();
      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('카메라 초기화 오류: $e');
      _showErrorAndNavigate('카메라를 초기화하지 못했습니다.');
    }
  }

  /// 사진 촬영
  Future<void> _takePicture() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      final image = await _cameraController!.takePicture();
      if (mounted) {
        setState(() {
          _capturedImage = image;
        });
      }
    } catch (e) {
      debugPrint('사진 촬영 오류: $e');
    }
  }

  /// 촬영한 사진 다시 찍기
  void _retakePicture() {
    setState(() {
      _capturedImage = null;
      _detectedFurniture = [];
      _analysisCompleted = false;
    });
  }

  /// 백엔드 YOLO11 분석 API 호출
  Future<void> _analyzeRoom() async {
    if (_capturedImage == null || _isAnalyzing) return;

    setState(() {
      _isAnalyzing = true;
    });

    try {
      // Firebase 인증 토큰 가져오기 (만료 시 자동 갱신)
      final authService = AuthService();
      String? authHeader = authService.getAuthHeader();
      if (authHeader == null) {
        await authService.refreshToken();
        authHeader = authService.getAuthHeader();
      }
      if (authHeader == null) {
        throw Exception('인증 정보가 없습니다. 다시 로그인해주세요.');
      }

      // multipart/form-data로 이미지 전송
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConstants.baseUrl}/room-scan/analyze'),
      );

      // Firebase 인증 헤더 추가
      request.headers['Authorization'] = authHeader;

      // 이미지 파일 첨부
      request.files.add(
        await http.MultipartFile.fromPath('image', _capturedImage!.path),
      );

      // 백엔드로 방 사진 전송
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final furniture = List<String>.from(data['detected_furniture'] ?? []);

        if (mounted) {
          setState(() {
            _detectedFurniture = furniture;
            _analysisCompleted = true;
          });
        }
      } else {
        throw Exception('분석 실패: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('방 스캔 분석 오류: $e');
      if (mounted) {
        // 오류가 발생해도 다음으로 넘어갈 수 있도록 완료 처리
        setState(() {
          _analysisCompleted = true;
        });
        _showErrorDialog('방 분석 중 오류가 발생했습니다.\n가구 정보 없이 다음 단계로 진행합니다.');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });
      }
    }
  }

  /// 에러 표시 후 이전 화면으로 이동
  void _showErrorAndNavigate(String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          '오류',
          style: GoogleFonts.notoSansKr(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1B1B1B),
          ),
        ),
        content: Text(
          message,
          style: GoogleFonts.notoSansKr(
            fontSize: 14,
            color: const Color(0xFF666666),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: Text(
              '확인',
              style: GoogleFonts.notoSansKr(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF9CAA7D),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 오류 다이얼로그 표시
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          '오류 발생',
          style: GoogleFonts.notoSansKr(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1B1B1B),
          ),
        ),
        content: Text(
          message,
          style: GoogleFonts.notoSansKr(
            fontSize: 14,
            color: const Color(0xFF666666),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              '확인',
              style: GoogleFonts.notoSansKr(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF9CAA7D),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 다음 단계(Step3 사용자 정보 입력)로 이동
  /// 가구 목록을 SharedPreferences에 저장한 후 이동합니다.
  Future<void> _goToNextStep() async {
    // 감지된 가구 목록을 SharedPreferences에 저장 (루틴 생성 시 AI 솔루션에 활용)
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      StorageKeys.detectedFurniture,
      _detectedFurniture,
    );

    if (!mounted) return;
    Navigator.pushNamed(
      context,
      '/onboarding/step3',
      arguments: {
        'hasCamera': true,
        'detectedFurniture': _detectedFurniture,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B1B1B),
      body: SafeArea(
        child: _capturedImage == null
            ? _buildCameraView()
            : _buildPreviewView(),
      ),
    );
  }

  /// 카메라 미리보기 화면
  Widget _buildCameraView() {
    return Column(
      children: [
        // 상단 안내 텍스트
        _buildTopBar('방 전체가 보이도록\n카메라를 맞춰주세요'),

        // 카메라 미리보기 영역
        Expanded(
          child: _isCameraInitialized
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: CameraPreview(_cameraController!),
                )
              : const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF9CAA7D),
                    ),
                  ),
                ),
        ),

        // 하단 촬영 버튼
        _buildCaptureButton(),
      ],
    );
  }

  /// 촬영 후 미리보기 및 분석 결과 화면
  Widget _buildPreviewView() {
    return Column(
      children: [
        // 상단 안내 텍스트
        _buildTopBar(
          !_analysisCompleted
              ? '사진을 확인해주세요'
              : _detectedFurniture.isEmpty
              ? '감지된 가구가 없습니다'
              : '감지된 가구 목록',
        ),

        // 촬영된 이미지 미리보기
        Expanded(
          flex: 3,
          child: Stack(
            children: [
              // 찍은 사진 표시
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(
                  File(_capturedImage!.path),
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),

              // 분석 중 로딩 오버레이
              if (_isAnalyzing)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFF9CAA7D),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'YOLO11이 가구를 분석 중...',
                          style: GoogleFonts.notoSansKr(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),

        // 감지된 가구 목록 (분석 완료 + 결과 있을 때)
        if (_analysisCompleted && _detectedFurniture.isNotEmpty)
          _buildFurnitureList(),

        // 감지 결과 없음 안내 (분석 완료 + 결과 없을 때)
        if (_analysisCompleted && _detectedFurniture.isEmpty)
          _buildNoFurnitureNotice(),

        // 하단 액션 버튼들
        _buildActionButtons(),
      ],
    );
  }

  /// 상단 타이틀 바
  Widget _buildTopBar(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Row(
        children: [
          // 뒤로 가기 버튼
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          // 타이틀
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.notoSansKr(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: -0.48,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 카메라 촬영 버튼
  Widget _buildCaptureButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: GestureDetector(
        onTap: _takePicture,
        child: Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 4),
          ),
          child: Center(
            child: Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 감지된 가구가 없을 때 안내 메시지
  Widget _buildNoFurnitureNotice() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Color(0xFF9CAA7D), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '가구를 감지하지 못했습니다.\n가구 정보 없이 다음 단계로 진행할 수 있어요.',
              style: GoogleFonts.notoSansKr(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: Colors.white.withValues(alpha: 0.8),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 감지된 가구 목록 표시
  Widget _buildFurnitureList() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '감지된 가구 (${_detectedFurniture.length}개)',
            style: GoogleFonts.notoSansKr(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF9CAA7D),
              letterSpacing: -0.39,
            ),
          ),
          const SizedBox(height: 8),
          // 가구 태그 목록
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: _detectedFurniture
                .map(
                  (furniture) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF9CAA7D).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF9CAA7D).withValues(alpha: 0.5),
                      ),
                    ),
                    child: Text(
                      furniture,
                      style: GoogleFonts.notoSansKr(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  /// 미리보기 화면 하단 버튼들
  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
      child: Column(
        children: [
          // 미분석 상태: "방 스캔하기" 버튼
          if (!_analysisCompleted && !_isAnalyzing)
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _analyzeRoom,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9CAA7D),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: Text(
                  '방 스캔하기',
                  style: GoogleFonts.notoSansKr(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.48,
                  ),
                ),
              ),
            ),

          // 분석 완료 시: 결과 유무와 관계없이 "다음으로" 버튼 활성화
          if (_analysisCompleted)
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _goToNextStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A5568),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: Text(
                  '다음으로',
                  style: GoogleFonts.notoSansKr(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.48,
                  ),
                ),
              ),
            ),

          const SizedBox(height: 12),

          // 다시 찍기 버튼
          if (!_isAnalyzing)
            SizedBox(
              width: double.infinity,
              height: 48,
              child: TextButton(
                onPressed: _retakePicture,
                child: Text(
                  '다시 찍기',
                  style: GoogleFonts.notoSansKr(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.7),
                    letterSpacing: -0.42,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
