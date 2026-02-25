import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants/app_constants.dart';
import '../../main_scaffold.dart';
import '../../services/routine_service.dart';

class RoutineStep3Screen extends StatefulWidget {
  final String routineTitle;

  // Step 1 Data
  final String purpose;
  final String space;
  final String description;

  // Step 2 Data
  final bool isFlexible;
  final TimeOfDay startTime;
  final TimeOfDay? endTime;
  final List<int> selectedDays;
  final String? notificationTime;

  const RoutineStep3Screen({
    super.key,
    required this.routineTitle,
    required this.purpose,
    required this.space,
    required this.description,
    required this.isFlexible,
    required this.startTime,
    required this.endTime,
    required this.selectedDays,
    this.notificationTime,
  });

  @override
  State<RoutineStep3Screen> createState() => _RoutineStep3ScreenState();
}

class _RoutineStep3ScreenState extends State<RoutineStep3Screen> {
  final RoutineService _routineService = RoutineService();
  bool _isSaving = false;

  // AI 공간 솔루션 상태
  bool _isLoadingSolution = true; // AI 솔루션 + 평면도 생성 중 여부
  bool _isEditingSolution = false; // 솔루션 편집 모드 여부
  String _spaceSolution = ''; // AI가 생성한 솔루션 텍스트
  String? _floorPlanImageUrl; // DALL-E 3가 생성한 평면도 이미지 URL
  final TextEditingController _solutionController = TextEditingController();

  // IoT Devices State
  final List<Map<String, dynamic>> _iotDevices = [
    {'type': '조명', 'value': 80.0},
  ];

  final List<String> _deviceTypes = ['조명', '커튼', '공기청정기', '가습기', '스피커'];

  @override
  void initState() {
    super.initState();
    // 화면 진입 시 AI 공간 솔루션 자동 생성
    _loadSpaceSolutionFromAI();
  }

  @override
  void dispose() {
    _solutionController.dispose();
    super.dispose();
  }

  /// SharedPreferences에서 가구 목록을 로드하고 AI 솔루션을 생성합니다.
  Future<void> _loadSpaceSolutionFromAI() async {
    // 온보딩에서 저장된 가구 목록 로드
    final prefs = await SharedPreferences.getInstance();
    final detectedFurniture =
        prefs.getStringList(StorageKeys.detectedFurniture) ?? [];

    if (!mounted) return;

    try {
      // [Backend 요청] AI 공간 솔루션 + DALL-E 3 평면도 생성
      final result = await _routineService.getSpaceSolution(
        routineTitle: widget.routineTitle,
        purpose: widget.purpose,
        description: widget.description,
        detectedFurniture: detectedFurniture,
      );

      if (mounted) {
        setState(() {
          _spaceSolution = result['solution'] as String? ?? '';
          _floorPlanImageUrl = result['floor_plan_image_url'] as String?;
          _solutionController.text = _spaceSolution;
          _isLoadingSolution = false;
        });
      }
    } catch (e) {
      debugPrint('❌ AI 솔루션 로드 실패: $e');
      if (mounted) {
        setState(() {
          _isLoadingSolution = false;
          // API 호출 실패 시 빈 텍스트로 두어 사용자가 직접 입력 가능하도록 함
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '루틴 등록',
          style: GoogleFonts.notoSans(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),

                    // 진행 바 (3단계 - 완료)
                    Row(
                      children: [
                        Expanded(
                          child: Container(height: 4, color: Colors.black),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(height: 4, color: Colors.black),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(height: 4, color: Colors.black),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'IOT사물 연동\n설정해주세요',
                      style: GoogleFonts.notoSans(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 공간 평면도 영역: 로딩 중 / 이미지 / 실패 placeholder
                    _buildFloorPlanSection(),
                    const SizedBox(height: 24),

                    // AI 공간 변경 솔루션 섹션
                    Text(
                      '공간 변경 솔루션',
                      style: GoogleFonts.notoSans(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildSpaceSolutionCard(),
                    const SizedBox(height: 24),

                    // IoT 연동 섹션
                    Text(
                      'IOT 연동',
                      style: GoogleFonts.notoSans(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // IoT 기기 목록
                    ...List.generate(_iotDevices.length, (index) {
                      final device = _iotDevices[index];
                      return _buildIoTDeviceCard(device, index);
                    }),

                    // IoT 연동 추가 버튼
                    GestureDetector(
                      onTap: _addIoTDevice,
                      child: Container(
                        height: 50,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '+ IOT 연동 추가하기',
                          style: GoogleFonts.notoSans(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),

            // 하단 완료 버튼
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveRoutine,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF383B45),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Text(
                          '완료',
                          style: GoogleFonts.notoSans(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// AI가 생성한 공간 변경 솔루션 카드
  /// 로딩 중이면 스피너, 완료 시 솔루션 텍스트 또는 편집 필드를 표시합니다.
  Widget _buildSpaceSolutionCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 카드 헤더: 타이틀과 편집/완료 버튼
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    'AI 추천 솔루션',
                    style: GoogleFonts.notoSans(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (_isLoadingSolution) ...[
                    const SizedBox(width: 8),
                    // AI 생성 중 표시
                    const SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF9CAA7D),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              // 로딩 완료 후 편집/확인 아이콘 표시
              if (!_isLoadingSolution)
                GestureDetector(
                  onTap: _toggleEditMode,
                  child: Icon(
                    _isEditingSolution ? Icons.check_circle : Icons.edit,
                    size: 18,
                    color: _isEditingSolution
                        ? const Color(0xFF9CAA7D)
                        : Colors.grey,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // 솔루션 콘텐츠 영역
          if (_isLoadingSolution)
            // 로딩 중: 스켈레톤 placeholder
            _buildSolutionLoadingPlaceholder()
          else if (_isEditingSolution)
            // 편집 모드: 텍스트 필드
            _buildSolutionEditField()
          else
            // 표시 모드: 솔루션 텍스트
            _buildSolutionText(),
        ],
      ),
    );
  }

  /// 공간 평면도 섹션: 로딩 중 / DALL-E 이미지 / 실패 placeholder 표시
  Widget _buildFloorPlanSection() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: double.infinity,
        height: 220,
        child: _isLoadingSolution
            // 로딩 중: 그레이 배경 + 스피너
            ? Container(
                color: Colors.grey[200],
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFF9CAA7D),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'AI가 평면도를 생성 중입니다...',
                        style: GoogleFonts.notoSans(
                          fontSize: 13,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : _floorPlanImageUrl != null
                // 이미지 로드 성공
                ? Image.network(
                    _floorPlanImageUrl!,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: Colors.grey[200],
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFF9CAA7D),
                            ),
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) =>
                        _buildFloorPlanPlaceholder(),
                  )
                // 이미지 생성 실패 시 placeholder
                : _buildFloorPlanPlaceholder(),
      ),
    );
  }

  /// 평면도 이미지 로드 실패 시 placeholder
  Widget _buildFloorPlanPlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.map_outlined, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 8),
          Text(
            '공간 도면',
            style: GoogleFonts.notoSans(fontSize: 13, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  /// 솔루션 로딩 중 스켈레톤 UI
  Widget _buildSolutionLoadingPlaceholder() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'AI가 공간 솔루션을 생성하고 있습니다...',
          style: GoogleFonts.notoSans(
            fontSize: 13,
            color: Colors.grey[400],
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 8),
        // 스켈레톤 바 2줄
        Container(
          height: 12,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 12,
          width: 200,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ],
    );
  }

  /// 솔루션 편집 텍스트 필드
  Widget _buildSolutionEditField() {
    return TextField(
      controller: _solutionController,
      maxLines: null,
      minLines: 3,
      style: GoogleFonts.notoSans(fontSize: 14, color: Colors.black87),
      decoration: InputDecoration(
        hintText: '공간 변경 솔루션을 직접 입력해주세요',
        hintStyle: GoogleFonts.notoSans(
          fontSize: 14,
          color: Colors.grey[400],
        ),
        filled: true,
        fillColor: const Color(0xFFF8F8F8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: const Color(0xFF9CAA7D), width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: const Color(0xFF9CAA7D), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: const Color(0xFF9CAA7D), width: 2),
        ),
        contentPadding: const EdgeInsets.all(12),
      ),
    );
  }

  /// 솔루션 텍스트 표시 (읽기 모드)
  Widget _buildSolutionText() {
    if (_spaceSolution.isEmpty) {
      return Text(
        '솔루션을 생성하지 못했습니다. 편집 버튼을 눌러 직접 입력해주세요.',
        style: GoogleFonts.notoSans(fontSize: 13, color: Colors.grey[400]),
      );
    }
    return Text(
      _spaceSolution,
      style: GoogleFonts.notoSans(fontSize: 14, color: Colors.grey[700]),
    );
  }

  /// IoT 기기 카드 위젯
  Widget _buildIoTDeviceCard(Map<String, dynamic> device, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 카드 헤더: 번호 + 삭제 버튼
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'IOT 사물 (${index + 1})',
                style: GoogleFonts.notoSans(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (_iotDevices.length > 1)
                GestureDetector(
                  onTap: () => _removeIoTDevice(index),
                  child: const Icon(Icons.close, size: 18, color: Colors.grey),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // 사물 종류 드롭다운
          Row(
            children: [
              SizedBox(
                width: 60,
                child: Text(
                  '사물 종류',
                  style: GoogleFonts.notoSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: device['type'],
                      isExpanded: true,
                      items: _deviceTypes.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(
                            type,
                            style: GoogleFonts.notoSans(fontSize: 14),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            device['type'] = value;
                          });
                        }
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),

          // 조명 선택 시 밝기 슬라이더 표시
          if (device['type'] == '조명') ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '밝기',
                  style: GoogleFonts.notoSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '최대 밝기',
                  style: GoogleFonts.notoSans(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            SizedBox(
              width: double.infinity,
              child: CupertinoSlider(
                value: device['value'] as double,
                min: 0,
                max: 100,
                activeColor: Colors.grey[600],
                thumbColor: Colors.white,
                onChanged: (val) {
                  setState(() {
                    device['value'] = val;
                  });
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 솔루션 편집 모드 토글
  void _toggleEditMode() {
    setState(() {
      if (_isEditingSolution) {
        // 편집 완료 시 수정된 텍스트 저장
        _spaceSolution = _solutionController.text;
      }
      _isEditingSolution = !_isEditingSolution;
    });
  }

  /// IoT 기기 추가
  void _addIoTDevice() {
    setState(() {
      _iotDevices.add({'type': '조명', 'value': 50.0});
    });
  }

  /// IoT 기기 삭제
  void _removeIoTDevice(int index) {
    setState(() {
      _iotDevices.removeAt(index);
    });
  }

  /// DALL-E 임시 URL에서 이미지를 다운받아 Firebase Storage에 영구 저장합니다.
  /// DALL-E URL은 약 1시간 후 만료되므로 Firebase Storage에 재업로드합니다.
  /// 업로드 성공 시 영구 다운로드 URL을 반환하고, 실패 시 null을 반환합니다.
  Future<String?> _uploadFloorPlanToStorage(String dalleUrl) async {
    try {
      // DALL-E URL에서 이미지 바이트 다운로드
      final response = await http.get(Uri.parse(dalleUrl));
      if (response.statusCode != 200) return null;

      // 현재 로그인 사용자 UID 및 파일명 생성
      final uid = FirebaseAuth.instance.currentUser?.uid ?? 'unknown';
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('floor_plans/$uid/$timestamp.jpg');

      // Firebase Storage에 이미지 업로드 (영구 저장)
      final uploadTask = await storageRef.putData(
        response.bodyBytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      debugPrint('❌ 평면도 Firebase Storage 업로드 실패: $e');
      return null;
    }
  }

  /// 루틴 저장 및 홈 화면으로 이동
  Future<void> _saveRoutine() async {
    setState(() => _isSaving = true);

    try {
      // TimeOfDay → HH:MM 문자열 변환
      final startTimeStr =
          '${widget.startTime.hour.toString().padLeft(2, '0')}:${widget.startTime.minute.toString().padLeft(2, '0')}';

      String? endTimeStr;
      if (widget.endTime != null) {
        endTimeStr =
            '${widget.endTime!.hour.toString().padLeft(2, '0')}:${widget.endTime!.minute.toString().padLeft(2, '0')}';
      }

      // DALL-E 임시 URL → Firebase Storage 영구 URL로 교체
      String? permanentFloorPlanUrl;
      if (_floorPlanImageUrl != null) {
        permanentFloorPlanUrl = await _uploadFloorPlanToStorage(_floorPlanImageUrl!);
      }

      // [Backend 요청] 루틴 생성 (AI 공간 솔루션 + 영구 평면도 URL 포함)
      await _routineService.createRoutine(
        title: widget.routineTitle,
        time: startTimeStr,
        category: '일반',
        days: widget.selectedDays,
        purpose: widget.purpose,
        space: widget.space,
        description: widget.description,
        isFlexible: widget.isFlexible,
        endTime: endTimeStr,
        notificationTime: widget.notificationTime,
        iotDevices: _iotDevices,
        spaceSolution: _spaceSolution.isNotEmpty ? _spaceSolution : null,
        // Firebase Storage URL 우선, 업로드 실패 시 DALL-E URL 폴백
        floorPlanImageUrl: permanentFloorPlanUrl ?? _floorPlanImageUrl,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ 루틴이 생성되었습니다!'),
            backgroundColor: Colors.green,
          ),
        );

        // 홈 화면으로 이동 (이전 스택 모두 제거)
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MainScaffold()),
          (route) => false,
        );
      }
    } catch (e) {
      debugPrint('❌ 루틴 생성 실패: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('루틴 생성 실패: $e'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isSaving = false);
      }
    }
  }
}
