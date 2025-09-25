import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

class Posture3DViewer extends StatelessWidget {
  final int postureNumber;
  final double width;
  final double height;
  final bool showControls;

  const Posture3DViewer({
    super.key,
    required this.postureNumber,
    this.width = 200,
    this.height = 200,
    this.showControls = false,
  });

  @override
  Widget build(BuildContext context) {
    // 유효한 자세 번호인지 확인 (0~7번)
    if (postureNumber < 0 || postureNumber > 7) {
      return _buildErrorWidget('잘못된 자세 번호: $postureNumber');
    }

    String modelPath = 'postures/${postureNumber}번자세.obj';

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            // 3D 모델 뷰어
            ModelViewer(
              backgroundColor: const Color(0xFFF8FAFC),
              src: modelPath,
              alt: '${postureNumber}번 자세 3D 모델',
              autoRotate: true,
              autoRotateDelay: 3000,
              rotationPerSecond: '30deg',
              cameraControls: showControls,
              interactionPrompt: InteractionPrompt.none,
              loading: Loading.lazy,
              reveal: Reveal.auto,
              ar: false,
            ),

            // 자세 번호 라벨
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF4A90E2).withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${postureNumber}번',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            // 로딩 인디케이터
            const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4A90E2)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String message) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFED8936), width: 1),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Color(0xFFED8936), size: 32),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(color: Color(0xFFED8936), fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
