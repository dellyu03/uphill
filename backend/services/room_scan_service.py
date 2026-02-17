"""
방 스캔 서비스 Layer
YOLO11을 사용하여 방 이미지에서 가구를 감지하는 비즈니스 로직을 처리합니다.
"""
import io
import os
import logging
from typing import List

from PIL import Image
from ultralytics import YOLO

logger = logging.getLogger(__name__)

# COCO 데이터셋 클래스 중 실내 가구/물건에 해당하는 항목과 한국어 이름 매핑
FURNITURE_LABEL_KO: dict[str, str] = {
    "chair": "의자",
    "couch": "소파",
    "bed": "침대",
    "dining table": "식탁",
    "toilet": "변기",
    "tv": "TV",
    "laptop": "노트북",
    "potted plant": "화분",
    "refrigerator": "냉장고",
    "microwave": "전자레인지",
    "oven": "오븐",
    "sink": "싱크대",
    "clock": "시계",
    "vase": "꽃병",
    "book": "책",
}

# 기본 YOLO11 모델 파일명 (없으면 자동 다운로드)
DEFAULT_MODEL_PATH = os.getenv("YOLO_MODEL_PATH", "yolo11n.pt")


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
        self._model = self._load_model()

    def analyze_room_image(self, image_bytes: bytes) -> List[str]:
        """
        방 이미지를 분석하여 감지된 가구 목록을 반환합니다.

        YOLO11 모델로 이미지를 추론하고, 감지된 객체 중
        가구에 해당하는 클래스만 필터링하여 반환합니다.

        Args:
            image_bytes: 분석할 이미지의 바이트 데이터

        Returns:
            List[str]: 감지된 가구 이름 목록 (중복 제거, 한국어)

        Raises:
            ValueError: 이미지 데이터가 유효하지 않을 경우
        """
        try:
            # 바이트 데이터를 PIL Image로 변환
            image = Image.open(io.BytesIO(image_bytes)).convert("RGB")
        except Exception as e:
            raise ValueError(f"유효하지 않은 이미지 데이터입니다: {e}")

        # YOLO11 추론 수행 (verbose=False로 콘솔 출력 억제)
        results = self._model(image, verbose=False)

        # 감지된 전체 레이블 수집
        detected_labels: List[str] = []
        for result in results:
            for box in result.boxes:
                class_id = int(box.cls)
                label = result.names[class_id]
                detected_labels.append(label)

        logger.info(f"YOLO11 감지 결과: {detected_labels}")

        # 가구 클래스만 필터링하여 한국어로 변환
        return self._filter_furniture_classes(detected_labels)

    def _load_model(self) -> YOLO:
        """
        YOLO11 모델을 파일에서 로드합니다.
        모델 파일이 없으면 ultralytics가 자동으로 다운로드합니다.

        Returns:
            YOLO: 로드된 YOLO11 모델 객체

        Raises:
            RuntimeError: 모델 로드에 실패한 경우
        """
        try:
            model = YOLO(DEFAULT_MODEL_PATH)
            logger.info(f"YOLO11 모델 로드 완료: {DEFAULT_MODEL_PATH}")
            return model
        except Exception as e:
            logger.error(f"YOLO11 모델 로드 실패: {e}")
            raise RuntimeError(f"YOLO11 모델을 로드하지 못했습니다: {e}")

    def _filter_furniture_classes(self, detected_labels: List[str]) -> List[str]:
        """
        YOLO 감지 결과에서 가구 관련 클래스만 필터링합니다.
        중복 항목은 제거하고, 감지 순서를 유지합니다.

        Args:
            detected_labels: YOLO가 감지한 전체 레이블 목록 (영어)

        Returns:
            List[str]: 가구 클래스만 필터링된 목록 (한국어, 중복 제거)
        """
        seen: set[str] = set()
        result: List[str] = []

        for label in detected_labels:
            korean_name = FURNITURE_LABEL_KO.get(label)
            if korean_name and korean_name not in seen:
                seen.add(korean_name)
                result.append(korean_name)

        return result
