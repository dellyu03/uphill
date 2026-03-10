import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:camera/camera.dart';

/// 온보딩 Step 2: 카메라로 방 인식 확인
class OnboardingStep2Screen extends StatefulWidget {
  const OnboardingStep2Screen({super.key});

  @override
  State<OnboardingStep2Screen> createState() => _OnboardingStep2ScreenState();
}

class _OnboardingStep2ScreenState extends State<OnboardingStep2Screen> {
  bool _isProcessing = false;

  Future<void> _handleCameraRequest() async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      // 카메라 권한 요청
      final status = await Permission.camera.request();

      if (status.isGranted) {
        // 권한이 허용된 경우 - 카메라 실행
        await _openCamera();
      } else if (status.isDenied) {
        // 권한이 거부된 경우
        _showPermissionDeniedDialog();
      } else if (status.isPermanentlyDenied) {
        // 권한이 영구적으로 거부된 경우
        _showPermissionPermanentlyDeniedDialog();
      }
    } catch (e) {
      debugPrint('카메라 권한 요청 오류: $e');
      _showErrorDialog();
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _openCamera() async {
    try {
      // 사용 가능한 카메라 목록 가져오기
      final cameras = await availableCameras();

      if (cameras.isEmpty) {
        _showNoCameraDialog();
        return;
      }

      // 후면 카메라 찾기 (없으면 첫 번째 카메라 사용)
      final camera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      if (!mounted) return;

      // 카메라 화면으로 이동
      Navigator.pushNamed(
        context,
        '/onboarding/step3',
        arguments: {'hasCamera': true, 'camera': camera},
      );
    } catch (e) {
      debugPrint('카메라 초기화 오류: $e');
      _showErrorDialog();
    }
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: Text(
            '카메라 권한 필요',
            style: GoogleFonts.notoSansKr(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1B1B1B),
            ),
          ),
          content: Text(
            '카메라 없이 방의 구조를 파악할 수 없습니다.',
            style: GoogleFonts.notoSansKr(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF666666),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/', (route) => false); // 로그인 화면으로 이동
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
        );
      },
    );
  }

  void _showPermissionPermanentlyDeniedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: Text(
            '카메라 권한 필요',
            style: GoogleFonts.notoSansKr(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1B1B1B),
            ),
          ),
          content: Text(
            '카메라 없이 방의 구조를 파악할 수 없습니다.\n설정에서 카메라 권한을 허용해주세요.',
            style: GoogleFonts.notoSansKr(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF666666),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/', (route) => false);
              },
              child: Text(
                '취소',
                style: GoogleFonts.notoSansKr(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF999999),
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                openAppSettings();
                Navigator.of(context).pop();
              },
              child: Text(
                '설정으로 이동',
                style: GoogleFonts.notoSansKr(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF9CAA7D),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showNoCameraDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: Text(
            '카메라를 찾을 수 없습니다',
            style: GoogleFonts.notoSansKr(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1B1B1B),
            ),
          ),
          content: Text(
            '카메라 없이 방의 구조를 파악할 수 없습니다.',
            style: GoogleFonts.notoSansKr(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF666666),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/', (route) => false);
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
        );
      },
    );
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: Text(
            '오류 발생',
            style: GoogleFonts.notoSansKr(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1B1B1B),
            ),
          ),
          content: Text(
            '카메라를 실행하는 중에 오류가 발생했습니다.',
            style: GoogleFonts.notoSansKr(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF666666),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
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
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(color: Color(0xFFF8F8F8)),
        child: Stack(
          children: [
            // Background Gradient
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: const Alignment(0, -0.6),
                    end: const Alignment(0, 1.2),
                    colors: [
                      const Color(0xFFBDDE54).withValues(alpha: 0),
                      const Color(0xFFC7DE5D).withValues(alpha: 0.165),
                      const Color(0xFFEAF0C2).withValues(alpha: 0.5),
                      const Color(0xFFD4E090).withValues(alpha: 0.5),
                      const Color(0xFFAABB49).withValues(alpha: 0.5),
                    ],
                    stops: const [0.1048, 0.2995, 0.4909, 0.6743, 1.0],
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 70), // StatusBar + Top margin
                    // Top Icon Placeholder (Camera)
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFA5BB3D),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.camera_alt_outlined,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '카메라',
                            style: GoogleFonts.notoSansKr(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF4A4A4A),
                              letterSpacing: -0.56,
                            ),
                          ),
                          TextSpan(
                            text: '로 방 인식을\n시작할까요?',
                            style: GoogleFonts.notoSansKr(
                              fontSize: 28,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF787878),
                              letterSpacing: -0.56,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    _buildButtonRow(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButtonRow() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _isProcessing ? null : _handleCameraRequest,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFFA5BB3D),
              elevation: 0,
              disabledBackgroundColor: Colors.white.withValues(alpha: 0.5),
              disabledForegroundColor: const Color(
                0xFFA5BB3D,
              ).withValues(alpha: 0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: _isProcessing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFFA5BB3D),
                      ),
                    ),
                  )
                : Text(
                    '예',
                    style: GoogleFonts.notoSansKr(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.32,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _isProcessing
                ? null
                : () {
                    Navigator.pushNamed(
                      context,
                      '/onboarding/step3',
                      arguments: {'hasCamera': false},
                    );
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF999999),
              elevation: 0,
              disabledBackgroundColor: Colors.white.withValues(alpha: 0.5),
              disabledForegroundColor: const Color(
                0xFF999999,
              ).withValues(alpha: 0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: Text(
              '아니요',
              style: GoogleFonts.notoSansKr(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.32,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
