import json
from pathlib import Path
from typing import Iterable, List, Tuple


ZoneTuple = Tuple[int, int, int, int]


class STFZHandler:
    def __init__(self, config_file: str = "config.json") -> None:
        self.config_file = Path(config_file)
        self.zones: List[ZoneTuple] = []

    def load_zones(self) -> List[ZoneTuple]:
        if not self.config_file.exists():
            self.zones = []
            return self.zones

        with self.config_file.open("r", encoding="utf-8") as handle:
            raw = json.load(handle)

        loaded: List[ZoneTuple] = []
        for item in raw if isinstance(raw, list) else []:
            if isinstance(item, dict):
                loaded.append((
                    int(item["x"]),
                    int(item["y"]),
                    int(item["w"]),
                    int(item["h"]),
                ))
            else:
                x, y, w, h = item
                loaded.append((int(x), int(y), int(w), int(h)))

        self.zones = loaded
        return self.zones

    def save_zones(self) -> None:
        data = [self._zone_to_dict(zone) for zone in self.zones]
        with self.config_file.open("w", encoding="utf-8") as handle:
            json.dump(data, handle, indent=2)

    def add_zone(self, zone: ZoneTuple) -> None:
        self.zones.append(self._normalize_zone(zone))

    def remove_zone(self, zone_id: int) -> ZoneTuple:
        if zone_id < 0 or zone_id >= len(self.zones):
            raise IndexError("Zone ID out of range")
        return self.zones.pop(zone_id)

    def clear_zones(self) -> None:
        self.zones = []

    def get_all_zones(self) -> List[dict]:
        return [self._zone_to_dict(zone) for zone in self.zones]

    def is_target_in_zone(self, target_box: ZoneTuple) -> bool:
        tx, ty, tw, th = target_box
        target_rect = (tx, ty, tx + tw, ty + th)

        for zone in self.zones:
            zx, zy, zw, zh = zone
            zone_rect = (zx, zy, zx + zw, zy + zh)
            if self._rects_intersect(target_rect, zone_rect):
                return True
        return False

    def draw_zones(self, frame):
        try:
            import cv2
        except ImportError as exc:  # pragma: no cover - runtime dependency
            raise RuntimeError("OpenCV is required to draw zones.") from exc

        for zone in self.zones:
            x, y, w, h = zone
            cv2.rectangle(frame, (x, y), (x + w, y + h), (0, 0, 255), 2)
        return frame

    def _normalize_zone(self, zone: Iterable[int]) -> ZoneTuple:
        x, y, w, h = zone
        if w < 0:
            x += w
            w = abs(w)
        if h < 0:
            y += h
            h = abs(h)
        return int(x), int(y), int(w), int(h)

    @staticmethod
    def _rects_intersect(a: Tuple[int, int, int, int], b: Tuple[int, int, int, int]) -> bool:
        ax1, ay1, ax2, ay2 = a
        bx1, by1, bx2, by2 = b
        return ax1 < bx2 and ax2 > bx1 and ay1 < by2 and ay2 > by1

    @staticmethod
    def _zone_to_dict(zone: ZoneTuple) -> dict:
        x, y, w, h = zone
        return {"x": x, "y": y, "w": w, "h": h}
