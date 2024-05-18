import os
import subprocess
from pathlib import Path

import pytest


@pytest.fixture
def example_path() -> Path:
    path = Path(__file__).resolve().parent.parent / "examples"
    os.chdir(path)
    return path


examples = [
    "firmware_patch_node_id.py",
    "process_shepherd.py",
    "process_tbench_logs.py",
    "receive_logs.py",
]


@pytest.mark.parametrize("file", examples)
def test_example_scripts(example_path: Path, file: str) -> None:
    subprocess.check_call(f"python {example_path / file}", shell=True)


def test_schedule_builder(example_path: Path, file: str) -> None:
    path = Path(__file__).resolve().parent.parent / "schedule_builder/"
    os.chdir(path)
    subprocess.check_call(f"python {example_path / 'build.py'}", shell=True)
