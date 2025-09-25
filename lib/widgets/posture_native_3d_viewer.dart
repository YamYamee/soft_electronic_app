import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'package:vector_math/vector_math.dart' as vm;

class PostureNative3DViewer extends StatefulWidget {
  final int postureNumber;
  final double width;
  final double height;
  final bool showControls;

  const PostureNative3DViewer({
    super.key,
    required this.postureNumber,
    this.width = 200,
    this.height = 200,
    this.showControls = false,
  });

  @override
  State<PostureNative3DViewer> createState() => _PostureNative3DViewerState();
}

class _PostureNative3DViewerState extends State<PostureNative3DViewer>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late Animation<double> _rotationAnimation;
  List<vm.Vector3> vertices = [];
  List<List<int>> faces = [];
  bool isLoading = true;
  String? errorMessage;

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

    _loadObjFile();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  Future<void> _loadObjFile() async {
    try {
      // OBJ 파일 로드
      String modelPath = 'postures/${widget.postureNumber}번자세.obj';
      String objContent = await rootBundle.loadString(modelPath);

      // OBJ 파일 파싱
      _parseObjFile(objContent);

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = '모델 로드 실패: $e';
      });
    }
  }

  void _parseObjFile(String content) {
    vertices.clear();
    faces.clear();

    List<String> lines = content.split('\n');

    // 샘플링 없이 모든 정점과 면을 사용
    print('📊 OBJ 파일 파싱 시작: ${lines.length}개 라인 처리');

    for (String line in lines) {
      line = line.trim();

      if (line.startsWith('v ')) {
        // 정점 데이터 파싱 (모든 정점 사용)
        List<String> parts = line.split(' ');
        if (parts.length >= 4) {
          double x = double.tryParse(parts[1]) ?? 0.0;
          double y = double.tryParse(parts[2]) ?? 0.0;
          double z = double.tryParse(parts[3]) ?? 0.0;
          vertices.add(vm.Vector3(x, y, z));
        }
      } else if (line.startsWith('f ')) {
        // 면 데이터 파싱 (모든 면 사용)
        List<String> parts = line.split(' ');
        List<int> faceIndices = [];

        bool validFace = true;
        for (int i = 1; i < parts.length; i++) {
          String part = parts[i];
          // "1/1/1" 형태에서 첫 번째 숫자만 추출
          int vertexIndex = int.tryParse(part.split('/')[0]) ?? 1;
          int adjustedIndex = vertexIndex - 1; // OBJ는 1부터 시작

          if (adjustedIndex >= 0 && adjustedIndex < vertices.length) {
            faceIndices.add(adjustedIndex);
          } else {
            validFace = false;
            break;
          }
        }

        if (validFace && faceIndices.length >= 3) {
          faces.add(faceIndices);
        }
      }
    }

    print(
      '🎯 OBJ 파싱 완료: ${vertices.length}개 정점, ${faces.length}개 면 (원본 데이터 모두 사용)',
    );
  }

  @override
  Widget build(BuildContext context) {
    // 유효한 자세 번호인지 확인 (0~7번)
    if (widget.postureNumber < 0 || widget.postureNumber > 7) {
      return _buildErrorWidget('잘못된 자세 번호: ${widget.postureNumber}');
    }

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
            Container(color: const Color(0xFFF8FAFC)),

            // 3D 모델 렌더링
            if (!isLoading && errorMessage == null && vertices.isNotEmpty)
              AnimatedBuilder(
                animation: _rotationAnimation,
                builder: (context, child) {
                  return CustomPaint(
                    size: Size(widget.width, widget.height),
                    painter: ObjModelPainter(
                      vertices: vertices,
                      faces: faces,
                      rotationY: _rotationAnimation.value,
                      postureNumber: widget.postureNumber,
                    ),
                  );
                },
              )
            else if (isLoading)
              _buildLoadingWidget()
            else
              _buildErrorWidget(errorMessage ?? '모델 데이터가 없습니다'),

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
                  '${widget.postureNumber}번',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            // 컨트롤 표시
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

  Widget _buildLoadingWidget() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4A90E2)),
          ),
          SizedBox(height: 16),
          Text(
            '대용량 3D 모델 로딩 중...',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '최초 로딩 시 시간이 걸릴 수 있습니다',
            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFED8936), size: 32),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(color: Color(0xFFED8936), fontSize: 10),
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          // 대체 표시 (자세 번호)
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFF4A90E2).withOpacity(0.1),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: const Color(0xFF4A90E2), width: 2),
            ),
            child: Center(
              child: Text(
                '${widget.postureNumber}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A90E2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ObjModelPainter extends CustomPainter {
  final List<vm.Vector3> vertices;
  final List<List<int>> faces;
  final double rotationY;
  final int postureNumber;

  ObjModelPainter({
    required this.vertices,
    required this.faces,
    required this.rotationY,
    required this.postureNumber,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (vertices.isEmpty || faces.isEmpty) {
      // 디버그용: 모델이 없을 때 빨간 박스 표시
      final debugPaint =
          Paint()
            ..color = Colors.red.withOpacity(0.3)
            ..style = PaintingStyle.fill;
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), debugPaint);

      final textPainter = TextPainter(
        text: const TextSpan(
          text: 'NO MODEL',
          style: TextStyle(
            color: Colors.red,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          (size.width - textPainter.width) / 2,
          (size.height - textPainter.height) / 2,
        ),
      );
      return;
    }

    print('🎨 렌더링 시작: ${vertices.length}개 정점, ${faces.length}개 면');

    // 더 강한 색상과 더 굵은 선으로 확실히 보이도록
    final Paint paint = Paint()
      ..color = _getPostureColor()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final Paint strokePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..isAntiAlias = true;

    // 모델의 경계 박스 계산
    double minX = vertices.isNotEmpty ? vertices[0].x : 0;
    double maxX = vertices.isNotEmpty ? vertices[0].x : 0;
    double minY = vertices.isNotEmpty ? vertices[0].y : 0;
    double maxY = vertices.isNotEmpty ? vertices[0].y : 0;
    double minZ = vertices.isNotEmpty ? vertices[0].z : 0;
    double maxZ = vertices.isNotEmpty ? vertices[0].z : 0;

    for (vm.Vector3 vertex in vertices) {
      minX = math.min(minX, vertex.x);
      maxX = math.max(maxX, vertex.x);
      minY = math.min(minY, vertex.y);
      maxY = math.max(maxY, vertex.y);
      minZ = math.min(minZ, vertex.z);
      maxZ = math.max(maxZ, vertex.z);
    }

    // 모델을 화면 중앙에 맞추기 위한 스케일 계산
    double modelWidth = maxX - minX;
    double modelHeight = maxY - minY;
    double modelDepth = maxZ - minZ;
    double maxDimension = math.max(
      math.max(modelWidth, modelHeight),
      modelDepth,
    );

    // 더 큰 스케일로 확실히 보이도록
    double scale = math.min(size.width, size.height) * 0.4 / maxDimension;
    if (scale <= 0) scale = 120; // 훨씬 더 큰 최소 스케일

    // 모델 중심점 계산
    double centerX = (minX + maxX) / 2;
    double centerY = (minY + maxY) / 2;
    double centerZ = (minZ + maxZ) / 2;

    // 간단한 3D 투영으로 확실히 보이게 하기
    List<Offset> projectedPoints = [];
    for (vm.Vector3 vertex in vertices) {
      // 중심을 원점으로 이동
      double x = vertex.x - centerX;
      double y = vertex.y - centerY;
      double z = vertex.z - centerZ;

      // Y축 회전 적용
      double cosY = math.cos(rotationY);
      double sinY = math.sin(rotationY);
      double rotatedX = x * cosY - z * sinY;

      // 스케일링 및 화면 좌표로 변환
      double screenX = size.width / 2 + rotatedX * scale;
      double screenY = size.height / 2 - y * scale; // Y축 뒤집기

      projectedPoints.add(Offset(screenX, screenY));
    }

    int renderedFaces = 0;

    // 면들을 그리기
    for (List<int> face in faces) {
      if (face.length >= 3) {
        bool validFace = true;
        for (int index in face) {
          if (index < 0 || index >= projectedPoints.length) {
            validFace = false;
            break;
          }
        }

        if (validFace) {
          Path path = Path();
          path.moveTo(projectedPoints[face[0]].dx, projectedPoints[face[0]].dy);

          for (int i = 1; i < face.length; i++) {
            path.lineTo(projectedPoints[face[i]].dx, projectedPoints[face[i]].dy);
          }

          path.close();

          // 면 채우기 및 테두리 그리기
          canvas.drawPath(path, paint);
          canvas.drawPath(path, strokePaint);
          renderedFaces++;
        }
      }
    }

    print(
      '✅ 렌더링 완료: ${renderedFaces}개 면 그려짐 (스케일: ${scale.toStringAsFixed(2)})',
    );
  }

  Color _getPostureColor() {
    switch (postureNumber) {
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

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
