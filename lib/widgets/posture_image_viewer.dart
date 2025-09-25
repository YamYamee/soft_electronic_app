import 'package:flutter/material.dart';

class PostureImageViewer extends StatefulWidget {
  final int postureIndex;
  final double width;
  final double height;
  final bool showLabel;

  const PostureImageViewer({
    super.key,
    required this.postureIndex,
    this.width = 200,
    this.height = 250,
    this.showLabel = true,
  });

  @override
  State<PostureImageViewer> createState() => _PostureImageViewerState();
}

class _PostureImageViewerState extends State<PostureImageViewer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  // 포스처 이름 매핑
  static const Map<int, String> postureNames = {
    0: '정상 자세',
    1: '목 앞으로',
    2: '목 뒤로',
    3: '목 왼쪽',
    4: '목 오른쪽',
    5: '어깨 굽음',
    6: '등 구부림',
    7: '전체 구부림',
  };

  // 포스처별 색상 매핑
  static const Map<int, List<Color>> postureColors = {
    0: [Color(0xFF4CAF50), Color(0xFF45A049)], // 정상 - 녹색
    1: [Color(0xFFFF9800), Color(0xFFF57C00)], // 목 앞으로 - 주황
    2: [Color(0xFFFF5722), Color(0xFFE64A19)], // 목 뒤로 - 빨강
    3: [Color(0xFF9C27B0), Color(0xFF7B1FA2)], // 목 왼쪽 - 보라
    4: [Color(0xFF3F51B5), Color(0xFF303F9F)], // 목 오른쪽 - 인디고
    5: [Color(0xFFFF9800), Color(0xFFF57C00)], // 어깨 굽음 - 주황
    6: [Color(0xFFFF5722), Color(0xFFD32F2F)], // 등 구부림 - 빨강
    7: [Color(0xFFD32F2F), Color(0xFFB71C1C)], // 전체 구부림 - 진한 빨강
  };

  // 포스처별 아이콘 매핑
  static const Map<int, IconData> postureIcons = {
    0: Icons.check_circle,
    1: Icons.keyboard_arrow_down,
    2: Icons.keyboard_arrow_up,
    3: Icons.keyboard_arrow_left,
    4: Icons.keyboard_arrow_right,
    5: Icons.trending_down,
    6: Icons.call_received,
    7: Icons.warning,
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors =
        postureColors[widget.postureIndex] ??
        [const Color(0xFF4CAF50), const Color(0xFF45A049)];
    final postureName = postureNames[widget.postureIndex] ?? '알 수 없음';
    final icon = postureIcons[widget.postureIndex] ?? Icons.help;

    return GestureDetector(
      onTapDown: (_) => _animationController.forward(),
      onTapUp: (_) => _animationController.reverse(),
      onTapCancel: () => _animationController.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: widget.width,
              height: widget.height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    colors[0].withOpacity(0.1),
                    colors[1].withOpacity(0.05),
                  ],
                ),
                border: Border.all(color: colors[0].withOpacity(0.3), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: colors[0].withOpacity(0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 상단 포스처 번호
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: colors),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${widget.postureIndex}번',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 포스처 아이콘 (실제 이미지 대신)
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(colors: colors),
                      boxShadow: [
                        BoxShadow(
                          color: colors[0].withOpacity(0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Icon(icon, size: 60, color: Colors.white),
                  ),
                  const SizedBox(height: 20),

                  // 포스처 이름
                  if (widget.showLabel)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        postureName,
                        style: TextStyle(
                          color: colors[1],
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                  const SizedBox(height: 10),

                  // 자세 평가
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color:
                          widget.postureIndex == 0
                              ? Colors.green.withOpacity(0.1)
                              : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      widget.postureIndex == 0 ? '양호' : '교정 필요',
                      style: TextStyle(
                        color:
                            widget.postureIndex == 0
                                ? Colors.green[700]
                                : Colors.red[700],
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
