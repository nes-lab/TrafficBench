"""
Search for .log-files in parent folder and analyze them.

Log-Files contain the uart-output of the trafficbench-nodes
"""

import sys
from pathlib import Path

import tables as tbl
from shepherd_core import Reader
from trafficbench import analyze_trx
from trafficbench import dump_trx
from trafficbench import filter_logfile
from trafficbench.filesystem import get_files

# Config
dir_input = Path(__file__).parent / "experiment"
file_b64 = Path("trx.b64")
file_h5 = Path("trx.h5")

# scp -r user@shepherd.cfaed.tu-dresden.de:/var/shepherd/experiments/ ./experiment/
if not dir_input.exists():
    print("No Shepherd-Files found - will exit")
    sys.exit(0)

# extract uart
files_shp = get_files(dir_input, suffix=".h5")
for file in files_shp:
    print(f"Extract Shp-file {file.name}")
    with Reader(file) as sr:
        if sr["uart"]["time"].shape[0] < 1:
            print("file is empty, no log generated")
            continue
        log_path = sr.file_path.with_suffix(".uart.log")
        with log_path.open("wb") as log_file:
            for _, message in enumerate(sr["uart"]["message"][:]):
                log_file.write(message)


# Process uart-logs
filter_logfile(dir_input, file_b64)
dump_trx(file_b64, file_h5)
analyze_trx(file_h5)

# Extract data
h5file = tbl.open_file(file_h5.as_posix(), mode="r", title="TRX data")

if False:
    nodes = h5file.root.catalogs.nodes
    print(nodes[:])

if True:
    link_matrix = h5file.root.catalogs.link_matrix_dBm
    print(link_matrix[:])
