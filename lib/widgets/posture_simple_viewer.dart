import 'package:flutter/material.dart';
import 'dart:math' as math;

class PostureSimpleViewer extends StatefulWidget {
  final int postureNumber;
  final double width;
  final double height;
  final bool showControls;

  const PostureSimpleViewer({
    super.key,
    required this.postureNumber,
    this.width = 200,
    this.height = 200,
    this.showControls = false,
  });

  @override
  State<PostureSimpleViewer> createState() => _PostureSimpleViewerState();
}

class _PostureSimpleViewerState extends State<PostureSimpleViewer>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(_rotationController);

    _rotationController.repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
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
            // 배경
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [const Color(0xFFF8FAFC), const Color(0xFFE2E8F0)],
                ),
              ),
            ),

            // 3D 스타일 자세 아이콘
            Center(
              child: AnimatedBuilder(
                animation: _rotationAnimation,
                builder: (context, child) {
                  return Transform(
                    alignment: Alignment.center,
                    transform:
                        Matrix4.identity()
                          ..setEntry(3, 2, 0.001) // 3D perspective
                          ..rotateY(_rotationAnimation.value * 0.3)
                          ..rotateX(math.sin(_rotationAnimation.value) * 0.1),
                    child: _buildPostureIcon(),
                  );
                },
              ),
            ),

            // 자세 번호 라벨
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getPostureColor().withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${widget.postureNumber}번',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            // 회전 표시
            if (widget.showControls)
              Positioned(
                bottom: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.threesixty,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostureIcon() {
    Color postureColor = _getPostureColor();

    return Container(
      width: widget.width * 0.6,
      height: widget.height * 0.6,
      child: CustomPaint(
        painter: PosturePainter(
          postureNumber: widget.postureNumber,
          color: postureColor,
        ),
      ),
    );
  }

  Color _getPostureColor() {
    switch (widget.postureNumber) {
      case 0:
        return const Color(0xFF48BB78); // 바른 자세 - 초록색
      case 1:
        return const Color(0xFFE53E3E); // 거북목 - 빨간색
      case 2:
        return const Color(0xFFED8936); // 목 숙이기 - 주황색
      case 3:
        return const Color(0xFFE53E3E); // 앞으로 당겨 기대기 - 빨간색
      case 4:
        return const Color(0xFF9F7AEA); // 오른쪽으로 기대기 - 보라색
      case 5:
        return const Color(0xFF9F7AEA); // 왼쪽으로 기대기 - 보라색
      case 6:
        return const Color(0xFF4A90E2); // 오른쪽 다리 꼬기 - 파란색
      case 7:
        return const Color(0xFF4A90E2); // 왼쪽 다리 꼬기 - 파란색
      default:
        return const Color(0xFF9CA3AF);
    }
  }
}

class PosturePainter extends CustomPainter {
  final int postureNumber;
  final Color color;

  PosturePainter({required this.postureNumber, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.fill
          ..strokeWidth = 3;

    final Paint strokePaint =
        Paint()
          ..color = color.withOpacity(0.8)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;

    double centerX = size.width / 2;
    double centerY = size.height / 2;
    double headRadius = size.width * 0.08;
    double bodyHeight = size.height * 0.35;
    double armLength = size.width * 0.15;
    double legLength = size.height * 0.2;

    switch (postureNumber) {
      case 0: // 바른 자세
        _drawCorrectPosture(
          canvas,
          paint,
          strokePaint,
          centerX,
          centerY,
          headRadius,
          bodyHeight,
          armLength,
          legLength,
        );
        break;
      case 1: // 거북목 자세
        _drawTurtleNeck(
          canvas,
          paint,
          strokePaint,
          centerX,
          centerY,
          headRadius,
          bodyHeight,
          armLength,
          legLength,
        );
        break;
      case 2: // 목 숙이기
        _drawHeadDown(
          canvas,
          paint,
          strokePaint,
          centerX,
          centerY,
          headRadius,
          bodyHeight,
          armLength,
          legLength,
        );
        break;
      case 3: // 앞으로 당겨 기대기
        _drawLeanForward(
          canvas,
          paint,
          strokePaint,
          centerX,
          centerY,
          headRadius,
          bodyHeight,
          armLength,
          legLength,
        );
        break;
      case 4: // 오른쪽으로 기대기
        _drawLeanRight(
          canvas,
          paint,
          strokePaint,
          centerX,
          centerY,
          headRadius,
          bodyHeight,
          armLength,
          legLength,
        );
        break;
      case 5: // 왼쪽으로 기대기
        _drawLeanLeft(
          canvas,
          paint,
          strokePaint,
          centerX,
          centerY,
          headRadius,
          bodyHeight,
          armLength,
          legLength,
        );
        break;
      case 6: // 오른쪽 다리 꼬기
        _drawRightLegCross(
          canvas,
          paint,
          strokePaint,
          centerX,
          centerY,
          headRadius,
          bodyHeight,
          armLength,
          legLength,
        );
        break;
      case 7: // 왼쪽 다리 꼬기
        _drawLeftLegCross(
          canvas,
          paint,
          strokePaint,
          centerX,
          centerY,
          headRadius,
          bodyHeight,
          armLength,
          legLength,
        );
        break;
    }
  }

  void _drawCorrectPosture(
    Canvas canvas,
    Paint paint,
    Paint strokePaint,
    double centerX,
    double centerY,
    double headRadius,
    double bodyHeight,
    double armLength,
    double legLength,
  ) {
    // 머리
    canvas.drawCircle(
      Offset(centerX, centerY - bodyHeight / 2 - headRadius),
      headRadius,
      paint,
    );

    // 몸통 (직선)
    canvas.drawLine(
      Offset(centerX, centerY - bodyHeight / 2),
      Offset(centerX, centerY + bodyHeight / 2),
      strokePaint,
    );

    // 팔 (수평)
    canvas.drawLine(
      Offset(centerX - armLength, centerY - bodyHeight / 4),
      Offset(centerX + armLength, centerY - bodyHeight / 4),
      strokePaint,
    );

    // 다리 (수직)
    canvas.drawLine(
      Offset(centerX - legLength / 2, centerY + bodyHeight / 2),
      Offset(centerX - legLength / 2, centerY + bodyHeight / 2 + legLength),
      strokePaint,
    );
    canvas.drawLine(
      Offset(centerX + legLength / 2, centerY + bodyHeight / 2),
      Offset(centerX + legLength / 2, centerY + bodyHeight / 2 + legLength),
      strokePaint,
    );
  }

  void _drawTurtleNeck(
    Canvas canvas,
    Paint paint,
    Paint strokePaint,
    double centerX,
    double centerY,
    double headRadius,
    double bodyHeight,
    double armLength,
    double legLength,
  ) {
    // 머리 (앞으로 나온 거북목)
    canvas.drawCircle(
      Offset(centerX + headRadius, centerY - bodyHeight / 2 - headRadius / 2),
      headRadius,
      paint,
    );

    // 목 (구부러진 라인)
    Path neckPath = Path();
    neckPath.moveTo(centerX, centerY - bodyHeight / 2);
    neckPath.quadraticBezierTo(
      centerX + headRadius / 2,
      centerY - bodyHeight / 2 - headRadius / 4,
      centerX + headRadius,
      centerY - bodyHeight / 2 - headRadius / 2,
    );
    canvas.drawPath(neckPath, strokePaint);

    // 몸통
    canvas.drawLine(
      Offset(centerX, centerY - bodyHeight / 2),
      Offset(centerX, centerY + bodyHeight / 2),
      strokePaint,
    );

    // 팔
    canvas.drawLine(
      Offset(centerX - armLength, centerY - bodyHeight / 4),
      Offset(centerX + armLength, centerY - bodyHeight / 4),
      strokePaint,
    );

    // 다리
    canvas.drawLine(
      Offset(centerX - legLength / 2, centerY + bodyHeight / 2),
      Offset(centerX - legLength / 2, centerY + bodyHeight / 2 + legLength),
      strokePaint,
    );
    canvas.drawLine(
      Offset(centerX + legLength / 2, centerY + bodyHeight / 2),
      Offset(centerX + legLength / 2, centerY + bodyHeight / 2 + legLength),
      strokePaint,
    );
  }

  void _drawHeadDown(
    Canvas canvas,
    Paint paint,
    Paint strokePaint,
    double centerX,
    double centerY,
    double headRadius,
    double bodyHeight,
    double armLength,
    double legLength,
  ) {
    // 머리 (아래로 숙인)
    canvas.drawCircle(
      Offset(centerX, centerY - bodyHeight / 4),
      headRadius,
      paint,
    );

    // 목 (구부러진)
    Path neckPath = Path();
    neckPath.moveTo(centerX, centerY - bodyHeight / 2);
    neckPath.quadraticBezierTo(
      centerX,
      centerY - bodyHeight / 3,
      centerX,
      centerY - bodyHeight / 4 + headRadius,
    );
    canvas.drawPath(neckPath, strokePaint);

    // 몸통
    canvas.drawLine(
      Offset(centerX, centerY - bodyHeight / 2),
      Offset(centerX, centerY + bodyHeight / 2),
      strokePaint,
    );

    // 팔
    canvas.drawLine(
      Offset(centerX - armLength, centerY - bodyHeight / 4),
      Offset(centerX + armLength, centerY - bodyHeight / 4),
      strokePaint,
    );

    // 다리
    canvas.drawLine(
      Offset(centerX - legLength / 2, centerY + bodyHeight / 2),
      Offset(centerX - legLength / 2, centerY + bodyHeight / 2 + legLength),
      strokePaint,
    );
    canvas.drawLine(
      Offset(centerX + legLength / 2, centerY + bodyHeight / 2),
      Offset(centerX + legLength / 2, centerY + bodyHeight / 2 + legLength),
      strokePaint,
    );
  }

  void _drawLeanForward(
    Canvas canvas,
    Paint paint,
    Paint strokePaint,
    double centerX,
    double centerY,
    double headRadius,
    double bodyHeight,
    double armLength,
    double legLength,
  ) {
    double leanOffset = centerX * 0.2;

    // 머리 (앞으로 기울어진)
    canvas.drawCircle(
      Offset(centerX + leanOffset, centerY - bodyHeight / 2 - headRadius),
      headRadius,
      paint,
    );

    // 몸통 (앞으로 기울어진)
    canvas.drawLine(
      Offset(centerX, centerY - bodyHeight / 2),
      Offset(centerX + leanOffset, centerY + bodyHeight / 2),
      strokePaint,
    );

    // 팔
    canvas.drawLine(
      Offset(centerX - armLength + leanOffset / 2, centerY - bodyHeight / 4),
      Offset(centerX + armLength + leanOffset / 2, centerY - bodyHeight / 4),
      strokePaint,
    );

    // 다리
    canvas.drawLine(
      Offset(centerX - legLength / 2, centerY + bodyHeight / 2),
      Offset(centerX - legLength / 2, centerY + bodyHeight / 2 + legLength),
      strokePaint,
    );
    canvas.drawLine(
      Offset(centerX + legLength / 2, centerY + bodyHeight / 2),
      Offset(centerX + legLength / 2, centerY + bodyHeight / 2 + legLength),
      strokePaint,
    );
  }

  void _drawLeanRight(
    Canvas canvas,
    Paint paint,
    Paint strokePaint,
    double centerX,
    double centerY,
    double headRadius,
    double bodyHeight,
    double armLength,
    double legLength,
  ) {
    double leanOffset = centerX * 0.15;

    // 머리 (오른쪽으로 기울어진)
    canvas.drawCircle(
      Offset(centerX + leanOffset, centerY - bodyHeight / 2 - headRadius),
      headRadius,
      paint,
    );

    // 몸통 (오른쪽으로 기울어진)
    canvas.drawLine(
      Offset(centerX, centerY - bodyHeight / 2),
      Offset(centerX + leanOffset, centerY + bodyHeight / 2),
      strokePaint,
    );

    // 팔
    canvas.drawLine(
      Offset(centerX - armLength + leanOffset / 2, centerY - bodyHeight / 4),
      Offset(centerX + armLength + leanOffset / 2, centerY - bodyHeight / 4),
      strokePaint,
    );

    // 다리
    canvas.drawLine(
      Offset(centerX - legLength / 2, centerY + bodyHeight / 2),
      Offset(centerX - legLength / 2, centerY + bodyHeight / 2 + legLength),
      strokePaint,
    );
    canvas.drawLine(
      Offset(centerX + legLength / 2, centerY + bodyHeight / 2),
      Offset(centerX + legLength / 2, centerY + bodyHeight / 2 + legLength),
      strokePaint,
    );
  }

  void _drawLeanLeft(
    Canvas canvas,
    Paint paint,
    Paint strokePaint,
    double centerX,
    double centerY,
    double headRadius,
    double bodyHeight,
    double armLength,
    double legLength,
  ) {
    double leanOffset = centerX * 0.15;

    // 머리 (왼쪽으로 기울어진)
    canvas.drawCircle(
      Offset(centerX - leanOffset, centerY - bodyHeight / 2 - headRadius),
      headRadius,
      paint,
    );

    // 몸통 (왼쪽으로 기울어진)
    canvas.drawLine(
      Offset(centerX, centerY - bodyHeight / 2),
      Offset(centerX - leanOffset, centerY + bodyHeight / 2),
      strokePaint,
    );

    // 팔
    canvas.drawLine(
      Offset(centerX - armLength - leanOffset / 2, centerY - bodyHeight / 4),
      Offset(centerX + armLength - leanOffset / 2, centerY - bodyHeight / 4),
      strokePaint,
    );

    // 다리
    canvas.drawLine(
      Offset(centerX - legLength / 2, centerY + bodyHeight / 2),
      Offset(centerX - legLength / 2, centerY + bodyHeight / 2 + legLength),
      strokePaint,
    );
    canvas.drawLine(
      Offset(centerX + legLength / 2, centerY + bodyHeight / 2),
      Offset(centerX + legLength / 2, centerY + bodyHeight / 2 + legLength),
      strokePaint,
    );
  }

  void _drawRightLegCross(
    Canvas canvas,
    Paint paint,
    Paint strokePaint,
    double centerX,
    double centerY,
    double headRadius,
    double bodyHeight,
    double armLength,
    double legLength,
  ) {
    // 머리
    canvas.drawCircle(
      Offset(centerX, centerY - bodyHeight / 2 - headRadius),
      headRadius,
      paint,
    );

    // 몸통
    canvas.drawLine(
      Offset(centerX, centerY - bodyHeight / 2),
      Offset(centerX, centerY + bodyHeight / 2),
      strokePaint,
    );

    // 팔
    canvas.drawLine(
      Offset(centerX - armLength, centerY - bodyHeight / 4),
      Offset(centerX + armLength, centerY - bodyHeight / 4),
      strokePaint,
    );

    // 왼쪽 다리 (직선)
    canvas.drawLine(
      Offset(centerX - legLength / 2, centerY + bodyHeight / 2),
      Offset(centerX - legLength / 2, centerY + bodyHeight / 2 + legLength),
      strokePaint,
    );

    // 오른쪽 다리 (꼬인 모양)
    Path legPath = Path();
    legPath.moveTo(centerX + legLength / 2, centerY + bodyHeight / 2);
    legPath.quadraticBezierTo(
      centerX - legLength / 4,
      centerY + bodyHeight / 2 + legLength / 2,
      centerX - legLength / 3,
      centerY + bodyHeight / 2 + legLength,
    );
    canvas.drawPath(legPath, strokePaint);
  }

  void _drawLeftLegCross(
    Canvas canvas,
    Paint paint,
    Paint strokePaint,
    double centerX,
    double centerY,
    double headRadius,
    double bodyHeight,
    double armLength,
    double legLength,
  ) {
    // 머리
    canvas.drawCircle(
      Offset(centerX, centerY - bodyHeight / 2 - headRadius),
      headRadius,
      paint,
    );

    // 몸통
    canvas.drawLine(
      Offset(centerX, centerY - bodyHeight / 2),
      Offset(centerX, centerY + bodyHeight / 2),
      strokePaint,
    );

    // 팔
    canvas.drawLine(
      Offset(centerX - armLength, centerY - bodyHeight / 4),
      Offset(centerX + armLength, centerY - bodyHeight / 4),
      strokePaint,
    );

    // 오른쪽 다리 (직선)
    canvas.drawLine(
      Offset(centerX + legLength / 2, centerY + bodyHeight / 2),
      Offset(centerX + legLength / 2, centerY + bodyHeight / 2 + legLength),
      strokePaint,
    );

    // 왼쪽 다리 (꼬인 모양)
    Path legPath = Path();
    legPath.moveTo(centerX - legLength / 2, centerY + bodyHeight / 2);
    legPath.quadraticBezierTo(
      centerX + legLength / 4,
      centerY + bodyHeight / 2 + legLength / 2,
      centerX + legLength / 3,
      centerY + bodyHeight / 2 + legLength,
    );
    canvas.drawPath(legPath, strokePaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
