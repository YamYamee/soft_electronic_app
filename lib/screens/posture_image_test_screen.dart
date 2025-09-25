import 'package:flutter/material.dart';
import '../widgets/posture_image_viewer.dart';

class PostureImageTestScreen extends StatefulWidget {
  const PostureImageTestScreen({super.key});

  @override
  State<PostureImageTestScreen> createState() => _PostureImageTestScreenState();
}

class _PostureImageTestScreenState extends State<PostureImageTestScreen> {
  int selectedPostureIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          '📸 포스처 이미지 뷰어',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3748),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF4A90E2)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [const Color(0xFFF0F7FF), const Color(0xFFF8FAFC)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                // 메인 포스처 표시 (실제 측정 화면과 같은 형태)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // 상단 타이틀
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.visibility,
                            color: const Color(0xFF4A90E2),
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            '현재 자세',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D3748),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // 메인 포스처 뷰어 (측정 화면과 동일한 크기)
                      PostureImageViewer(
                        postureIndex: selectedPostureIndex,
                        width: 280,
                        height: 320,
                        showLabel: true,
                      ),
                      const SizedBox(height: 20),

                      // 포스처 정보
                      _buildPostureInfo(),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // 포스처 선택 그리드
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '🎯 포스처 선택',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D3748),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 4,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                  childAspectRatio: 0.8,
                                ),
                            itemCount: 8,
                            itemBuilder: (context, index) {
                              final isSelected = index == selectedPostureIndex;
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedPostureIndex = index;
                                  });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color:
                                          isSelected
                                              ? const Color(0xFF4A90E2)
                                              : Colors.transparent,
                                      width: 3,
                                    ),
                                  ),
                                  child: PostureImageViewer(
                                    postureIndex: index,
                                    width: 80,
                                    height: 100,
                                    showLabel: false,
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

                const SizedBox(height: 20),

                // 하단 액션 버튼들
                Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.refresh,
                        label: '새로고침',
                        color: const Color(0xFF48BB78),
                        onPressed: () {
                          setState(() {
                            selectedPostureIndex = 0;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.info_outline,
                        label: '자세 가이드',
                        color: const Color(0xFF4A90E2),
                        onPressed: () {
                          _showPostureGuide();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPostureInfo() {
    final postureNames = {
      0: '정상 자세',
      1: '목 앞으로',
      2: '목 뒤로',
      3: '목 왼쪽',
      4: '목 오른쪽',
      5: '어깨 굽음',
      6: '등 구부림',
      7: '전체 구부림',
    };

    final postureAdvices = {
      0: '완벽한 자세입니다! 계속 유지하세요.',
      1: '턱을 안쪽으로 당기고 목을 곧게 세워보세요.',
      2: '목을 자연스럽게 앞으로 내리세요.',
      3: '어깨를 좌우 균형있게 맞춰보세요.',
      4: '어깨를 좌우 균형있게 맞춰보세요.',
      5: '어깨를 펴고 가슴을 내밀어보세요.',
      6: '등을 곧게 펴고 허리를 세워보세요.',
      7: '전체적으로 몸을 곧게 펴보세요.',
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            selectedPostureIndex == 0
                ? Colors.green.withOpacity(0.1)
                : Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              selectedPostureIndex == 0
                  ? Colors.green.withOpacity(0.3)
                  : Colors.orange.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                selectedPostureIndex == 0 ? Icons.check_circle : Icons.warning,
                color:
                    selectedPostureIndex == 0
                        ? Colors.green[600]
                        : Colors.orange[600],
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                postureNames[selectedPostureIndex] ?? '알 수 없음',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color:
                      selectedPostureIndex == 0
                          ? Colors.green[700]
                          : Colors.orange[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            postureAdvices[selectedPostureIndex] ?? '자세를 확인해보세요.',
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
        ),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showPostureGuide() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text(
              '📋 자세 가이드',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildGuideItem('0번: 정상 자세', '머리, 목, 등이 일직선', Colors.green),
                _buildGuideItem('1번: 목 앞으로', '거북목 증상', Colors.orange),
                _buildGuideItem('2번: 목 뒤로', '목이 뒤로 젖혀짐', Colors.red),
                _buildGuideItem('3-4번: 목 좌우', '목이 한쪽으로 기울어짐', Colors.purple),
                _buildGuideItem('5번: 어깨 굽음', '어깨가 앞으로 굽어짐', Colors.orange),
                _buildGuideItem('6번: 등 구부림', '등이 둥글게 굽어짐', Colors.red),
                _buildGuideItem('7번: 전체 구부림', '전신 자세 불량', Colors.red),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('확인'),
              ),
            ],
          ),
    );
  }

  Widget _buildGuideItem(String title, String description, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
