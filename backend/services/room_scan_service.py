"""
방 스캔 서비스 Layer
YOLO11을 사용하여 방 이미지에서 가구를 감지하는 비즈니스 로직을 처리합니다.
"""
from typing import List


class RoomScanService:
    """
    방 스캔 비즈니스 로직을 담당하는 서비스 클래스.

    YOLO11 모델을 로드하여 이미지에서 가구를 감지하고,
    감지된 가구 목록을 반환합니다.
    """

    def __init__(self):
        """
        RoomScanService 초기화.
        YOLO11 모델을 로드합니다.
        """
        pass

    def analyze_room_image(self, image_bytes: bytes) -> List[str]:
        """
        방 이미지를 분석하여 감지된 가구 목록을 반환합니다.

        YOLO11 모델로 이미지를 추론하고, 감지된 객체 중
        가구에 해당하는 클래스만 필터링하여 반환합니다.

        Args:
            image_bytes: 분석할 이미지의 바이트 데이터

        Returns:
            List[str]: 감지된 가구 이름 목록 (중복 제거, 한국어)
        """
        pass

    def _load_model(self):
        """
        YOLO11 모델을 파일에서 로드합니다.

        Returns:
            YOLO 모델 객체
        """
        pass

    def _filter_furniture_classes(self, detected_labels: List[str]) -> List[str]:
        """
        YOLO 감지 결과에서 가구 관련 클래스만 필터링합니다.

        Args:
            detected_labels: YOLO가 감지한 전체 레이블 목록

        Returns:
            List[str]: 가구 클래스만 필터링된 목록 (한국어 변환)
        """
        pass
