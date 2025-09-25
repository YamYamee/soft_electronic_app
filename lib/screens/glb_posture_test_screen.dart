import 'package:flutter/material.dart';
import '../widgets/posture_model_viewer.dart';

/// GLB 기반 고품질 3D 포스처 뷰어 테스트 화면
class GLBPostureTestScreen extends StatefulWidget {
  const GLBPostureTestScreen({super.key});

  @override
  State<GLBPostureTestScreen> createState() => _GLBPostureTestScreenState();
}

class _GLBPostureTestScreenState extends State<GLBPostureTestScreen> {
  int selectedPosture = 0;
  bool enableInteraction = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🚀 GLB 고품질 3D 포스처 뷰어'),
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(enableInteraction ? Icons.pan_tool : Icons.pan_tool_outlined),
            onPressed: () {
              setState(() {
                enableInteraction = !enableInteraction;
              });
            },
            tooltip: enableInteraction ? '인터랙션 비활성화' : '인터랙션 활성화',
          ),
        ],
      ),
      body: Column(
        children: [
          // 정보 헤더
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '✨ WebGL 하드웨어 가속 3D 렌더링',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '현재 포스처: ${selectedPosture}번 • 파일 크기: ~2.7MB (기존 7MB의 60% 압축)\n'
                  '• 하드웨어 가속 렌더링 • 부드러운 터치 조작 • 실시간 조명',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          
          // 3D 모델 뷰어
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: PostureModelViewer(
                  postureNumber: selectedPosture,
                  width: double.infinity,
                  height: double.infinity,
                  enableInteraction: enableInteraction,
                  backgroundColor: '#f8fafc',
                ),
              ),
            ),
          ),
          
          // 포스처 선택 그리드
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '포스처 선택 (0-7번)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.2,
                      ),
                      itemCount: 8,
                      itemBuilder: (context, index) {
                        final isSelected = index == selectedPosture;
                        return Material(
                          elevation: isSelected ? 6 : 2,
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              setState(() {
                                selectedPosture = index;
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                gradient: isSelected
                                    ? const LinearGradient(
                                        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      )
                                    : null,
                                color: isSelected ? null : const Color(0xFFF8FAFC),
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.transparent
                                      : const Color(0xFFE2E8F0),
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '$index',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected
                                          ? Colors.white
                                          : const Color(0xFF6366F1),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${index}번 자세',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isSelected
                                          ? Colors.white70
                                          : const Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      
      // 성능 정보 플로팅 버튼
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showPerformanceInfo(context);
        },
        backgroundColor: const Color(0xFF10B981),
        icon: const Icon(Icons.speed, color: Colors.white),
        label: const Text(
          '성능 정보',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _showPerformanceInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.speed, color: Color(0xFF10B981)),
            SizedBox(width: 8),
            Text('GLB vs OBJ 성능 비교'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('📊 파일 크기 비교:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('• OBJ: ~7MB → GLB: ~2.7MB (60% 압축)'),
            SizedBox(height: 12),
            Text('⚡ 성능 개선:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('• 로딩 속도: 3-5초 → 0.5-1초'),
            Text('• 렌더링: CPU → WebGL 하드웨어 가속'),
            Text('• 메모리: 500MB → 100-200MB'),
            SizedBox(height: 12),
            Text('✨ 품질 개선:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('• 실시간 조명 및 그림자'),
            Text('• 부드러운 터치 인터랙션'),
            Text('• 자동 중앙정렬 및 최적화'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }
}