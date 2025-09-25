import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

/// 고품질 Model Viewer를 사용한 3D 포스처 뷰어
///
/// 주요 특징:
/// - WebGL 하드웨어 가속 렌더링
/// - 부드러운 터치 인터랙션 (회전, 줌, 팬)
/// - 자동 중앙정렬 및 카메라 컨트롤
/// - 고품질 라이팅 및 셰이딩
/// - GLB/GLTF 포맷 지원으로 최적화된 성능
class PostureModelViewer extends StatefulWidget {
  final int postureNumber;
  final double width;
  final double height;
  final bool enableInteraction;
  final String? backgroundColor;

  const PostureModelViewer({
    super.key,
    required this.postureNumber,
    this.width = 300,
    this.height = 300,
    this.enableInteraction = true,
    this.backgroundColor = "#f5f5f5",
  });

  @override
  State<PostureModelViewer> createState() => _PostureModelViewerState();
}

class _PostureModelViewerState extends State<PostureModelViewer> {
  bool isLoading = true;
  String? errorMessage;
  String? modelPath;

  @override
  void initState() {
    super.initState();
    _loadModel();
  }

  @override
  void didUpdateWidget(PostureModelViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.postureNumber != widget.postureNumber) {
      _loadModel();
    }
  }

  Future<void> _loadModel() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      // GLB 파일 경로 (OBJ에서 변환된 파일)
      final glbPath = 'postures/posture_${widget.postureNumber}.glb';

      // GLB 파일 로드 시도

      // GLB 파일 존재 확인
      try {
        await rootBundle.load(glbPath);
        // GLB 파일 로드 성공

        setState(() {
          modelPath = glbPath;
          isLoading = false;
        });
      } catch (e) {
        // GLB가 없으면 OBJ 파일 시도 (호환성)
        final objPath = 'postures/posture_${widget.postureNumber}.obj';
        try {
          await rootBundle.loadString(objPath);
          // GLB 파일이 없어 OBJ 파일 사용
          setState(() {
            errorMessage = 'GLB 파일이 필요합니다. OBJ → GLB 변환을 실행하세요.';
            isLoading = false;
          });
        } catch (objError) {
          // OBJ 파일도 로드 실패
          setState(() {
            errorMessage = '3D 모델 파일을 찾을 수 없습니다: ${widget.postureNumber}번자세';
            isLoading = false;
          });
        }
      }
    } catch (e) {
      // 모델 로드 오류
      setState(() {
        errorMessage = '모델 로드 실패: $e';
        isLoading = false;
      });
    }
  }

  Widget _buildLoadingWidget() {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Color(0xFF6366F1), strokeWidth: 3),
          SizedBox(height: 16),
          Text(
            '3D 모델 로드 중...',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String message) {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFECACA), width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFEF4444), size: 48),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              message,
              style: const TextStyle(
                color: Color(0xFFDC2626),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _loadModel,
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('다시 시도'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              textStyle: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 유효한 자세 번호인지 확인 (0~7번)
    if (widget.postureNumber < 0 || widget.postureNumber > 7) {
      return _buildErrorWidget('잘못된 자세 번호: ${widget.postureNumber}');
    }

    if (isLoading) {
      return _buildLoadingWidget();
    }

    if (errorMessage != null) {
      return _buildErrorWidget(errorMessage!);
    }

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: ModelViewer(
        key: ValueKey('model_${widget.postureNumber}_$modelPath'),
        backgroundColor:
            widget.backgroundColor == 'transparent'
                ? Colors.transparent
                : Color(
                  int.parse(widget.backgroundColor!.replaceFirst('#', '0xFF')),
                ),
        src: modelPath!, // GLB 파일 사용 (pubspec.yaml의 postures/ 경로 사용)
        alt: '${widget.postureNumber}번 포스처 3D 모델',
        ar: false,
        autoRotate: widget.enableInteraction,
        autoRotateDelay: 1000,
        rotationPerSecond: '60deg',
        cameraControls: widget.enableInteraction,
        cameraTarget: 'auto auto auto',
        disableZoom: !widget.enableInteraction,
        disablePan: !widget.enableInteraction,
        disableTap: !widget.enableInteraction,
        interactionPrompt: InteractionPrompt.none,
        loading: Loading.eager,
        // 카메라 설정 - 모델을 매우 작게 보이도록 설정
        cameraOrbit: '0deg 75deg 80m',
        minCameraOrbit: 'auto auto 60m',
        maxCameraOrbit: 'auto auto 100m',
        fieldOfView: '3deg',
        // 조명 설정 - 모델이 더 잘 보이도록 개선
        environmentImage: null, // 기본 환경 조명 사용
        shadowIntensity: 0.7,
        shadowSoftness: 0.6,
        exposure: 1.2,
        // GLB 최적화 설정
        poster: null,
        reveal: Reveal.auto,
        touchAction: TouchAction.panY,
      ),
    );
  }
}

/// Model Viewer를 사용한 간단한 사용 예시
class PostureModelViewerDemo extends StatelessWidget {
  const PostureModelViewerDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('고품질 3D 포스처 뷰어'),
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              '✨ Model Viewer 기반 고품질 3D 렌더링',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '• WebGL 하드웨어 가속\n• 부드러운 터치 인터랙션\n• 자동 중앙정렬 및 조명',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF64748B),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            // 3D 모델 뷰어
            const Center(
              child: PostureModelViewer(
                postureNumber: 0,
                width: 350,
                height: 350,
                enableInteraction: true,
                backgroundColor: '#f8fafc',
              ),
            ),
            const SizedBox(height: 24),
            // 포스처 선택 버튼들
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.0,
                ),
                itemCount: 8,
                itemBuilder: (context, index) {
                  return ElevatedButton(
                    onPressed: () {
                      // 포스처 변경 로직 구현 예정
                      // 포스처 선택
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      '$index',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
