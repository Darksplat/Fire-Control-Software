import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1] / "PSG 2021"
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))
