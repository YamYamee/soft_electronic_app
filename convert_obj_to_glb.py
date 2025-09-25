#!/usr/bin/env python3
"""
OBJ to GLB 자동 변환 스크립트
8개의 포스처 OBJ 파일을 GLB로 일괄 변환
"""

import os
import sys
from pathlib import Path

try:
    import pymeshlab
    print("✅ pymeshlab 모듈을 찾았습니다.")
except ImportError:
    print("❌ pymeshlab가 설치되지 않았습니다.")
    print("설치 명령어: pip install pymeshlab")
    sys.exit(1)

def convert_obj_to_glb(obj_path, glb_path, compression_level=10):
    """
    OBJ 파일을 GLB로 변환
    
    Args:
        obj_path: 입력 OBJ 파일 경로
        glb_path: 출력 GLB 파일 경로  
        compression_level: 압축 레벨 (0-10, 높을수록 작은 파일)
    """
    try:
        print(f"🔄 변환 중: {obj_path} → {glb_path}")
        
        # MeshLab 메시셋 생성
        ms = pymeshlab.MeshSet()
        
        # OBJ 파일 로드
        ms.load_new_mesh(str(obj_path))
        
        # 메시 정보 출력
        mesh = ms.current_mesh()
        print(f"   📊 정점: {mesh.vertex_number():,}개, 면: {mesh.face_number():,}개")
        
        # 메시 최적화 (선택사항)
        if compression_level > 5:
            print("   🔧 메시 단순화 적용...")
            # 면 수를 80%로 줄여서 파일 크기 최적화
            target_faces = int(mesh.face_number() * 0.8)
            ms.apply_filter('meshing_decimation_quadric_edge_collapse', 
                          targetfacenum=target_faces)
        
        # GLB 형식으로 저장
        ms.save_current_mesh(str(glb_path), save_texcoord=False)
        
        # 파일 크기 비교
        obj_size = obj_path.stat().st_size
        glb_size = glb_path.stat().st_size
        compression_ratio = (1 - glb_size / obj_size) * 100
        
        print(f"   ✅ 완료! {obj_size/1024/1024:.1f}MB → {glb_size/1024/1024:.1f}MB ({compression_ratio:.1f}% 압축)")
        
    except Exception as e:
        print(f"   ❌ 오류: {e}")
        return False
    
    return True

def main():
    """메인 변환 프로세스"""
    # 경로 설정
    script_dir = Path(__file__).parent
    postures_dir = script_dir / "postures"
    
    if not postures_dir.exists():
        print(f"❌ 포스처 디렉토리를 찾을 수 없습니다: {postures_dir}")
        return
    
    print("🚀 OBJ → GLB 변환 시작")
    print(f"📁 작업 디렉토리: {postures_dir}")
    
    # 8개 포스처 파일 변환
    success_count = 0
    total_obj_size = 0
    total_glb_size = 0
    
    for i in range(8):
        obj_filename = f"{i}번자세.obj"
        glb_filename = f"{i}번자세.glb"
        
        obj_path = postures_dir / obj_filename
        glb_path = postures_dir / glb_filename
        
        if not obj_path.exists():
            print(f"⚠️  파일을 찾을 수 없습니다: {obj_filename}")
            continue
        
        # 변환 실행
        if convert_obj_to_glb(obj_path, glb_path, compression_level=7):
            success_count += 1
            total_obj_size += obj_path.stat().st_size
            total_glb_size += glb_path.stat().st_size
    
    # 결과 요약
    print("\n" + "="*50)
    print(f"🎉 변환 완료: {success_count}/8개 파일")
    
    if success_count > 0:
        total_compression = (1 - total_glb_size / total_obj_size) * 100
        print(f"📊 총 용량: {total_obj_size/1024/1024:.1f}MB → {total_glb_size/1024/1024:.1f}MB")
        print(f"💾 압축률: {total_compression:.1f}%")
        print(f"⚡ 예상 로딩 속도 개선: {total_obj_size/total_glb_size:.1f}x")
    
    print("\n📋 다음 단계:")
    print("1. pubspec.yaml에서 assets 경로 확인")
    print("2. PostureModelViewer에서 GLB 파일 사용")
    print("3. 앱에서 성능 테스트")

if __name__ == "__main__":
    main()