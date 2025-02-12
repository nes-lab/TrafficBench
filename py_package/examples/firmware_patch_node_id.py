"""
Alter the embedded node ID of a given elf-firmware.

It will

- update the elf-file in this directory
- build hex-files with patched node-id

"""

import shutil
import sys
from pathlib import Path

from shepherd_core import fw_tools

# CONFIG

node_count: int = 5
path_local = Path(__file__).parent
path_src: Path = (
    path_local.parent.parent / "target/nrf52840/project_ses/Output/Release/Exe/TrafficBench.elf"
)
path_elf = path_local / "build.elf"

if not path_src.exists():
    print("No Firmware found - will exit")
    sys.exit(0)

# make local copy of elf-file
shutil.copy(path_src, path_elf)

# patch node id and prepare hex-file, TODO: better use tempfile.TemporaryFile()

for node in range(node_count):
    path_elf_node = path_local / f"build_{node}.elf"

    shutil.copy(path_elf, path_elf_node)
    fw_tools.modify_uid(path_elf_node, node)
    fw_tools.elf_to_hex(path_elf_node)
    path_elf_node.unlink()
