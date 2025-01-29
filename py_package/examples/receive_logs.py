"""
Listen on available COM-Ports for trafficbench-chatter and log output into files.

Serial ports can either be auto-discovered (default) or handed to the routine.
"""

from pathlib import Path

from trafficbench import receive_serial

receive_serial(file_path=Path(__file__).parent, serial_ports=None, duration_s=30, baud_rate=230400)
