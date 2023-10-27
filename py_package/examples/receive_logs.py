"""
Log-Files contain the uart-output of the trafficbench-nodes
"""
from pathlib import Path

from trafficbench import receive_serial

receive_serial(
    file_path=Path(__file__).parent,
    serial_ports=None,
    duration_s=30,
    baud_rate=230400)
