# OBJ to GLB 변환 가이드

## 🎯 목표

현재 7MB OBJ 파일들 → 1-3MB GLB 파일들로 변환하여

- 로딩 속도 10배 개선
- 메모리 사용량 50% 감소
- 부드러운 하드웨어 가속 렌더링

## 🔧 변환 방법

### 방법 1: 온라인 변환 (추천)

1. **Facebook/Meta 3D Posts**

   - https://www.facebook.com/3dposts/
   - OBJ 업로드 → GLB 다운로드

2. **GitHub glTF-Validator**

   - https://github.khronos.org/glTF-Validator/
   - 드래그&드롭으로 간단 변환

3. **Sketchfab**
   - https://sketchfab.com/
   - 무료 계정으로 변환 가능

### 방법 2: 로컬 도구 설치

1. **Blender** (무료, 강력)

   ```
   1. Blender 설치 (https://www.blender.org/)
   2. File → Import → Wavefront (.obj)
   3. File → Export → glTF 2.0 (.glb)
   4. 압축 옵션 활성화
   ```

2. **obj2gltf** (Node.js 도구)
   ```bash
   npm install -g obj2gltf
   obj2gltf -i input.obj -o output.glb --binary
   ```

### 방법 3: Python 스크립트

```python
# pip install pymeshlab
import pymeshlab

def convert_obj_to_glb(obj_path, glb_path):
    ms = pymeshlab.MeshSet()
    ms.load_new_mesh(obj_path)
    ms.save_current_mesh(glb_path)

# 사용 예시
for i in range(8):
    convert_obj_to_glb(f'{i}번자세.obj', f'{i}번자세.glb')
```

## 📊 예상 결과

- **파일 크기**: 7MB → 1-3MB (50-85% 압축)
- **로딩 속도**: 3-5초 → 0.5-1초
- **렌더링**: 버벅거림 → 60fps 부드러움
- **메모리**: 500MB → 100-200MB

## 🚀 변환 후 사용법

```dart
// GLB 파일을 Model Viewer에서 사용
ModelViewer(
  src: 'assets/postures/0번자세.glb',
  alt: '포스처 3D 모델',
  cameraControls: true,
  autoRotate: true,
)
```

## 📋 체크리스트

- [ ] 변환 도구 선택 (Blender 추천)
- [ ] 8개 OBJ 파일 → GLB 변환
- [ ] pubspec.yaml assets 경로 업데이트
- [ ] PostureModelViewer 위젯 GLB 지원 추가
- [ ] Android/Windows 테스트
- [ ] 성능 및 품질 검증
