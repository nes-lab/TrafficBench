#!/usr/bin/env xonsh

import sys
import os
import subprocess as proc
import glob

TOOLPATH = os.path.abspath(os.path.dirname(__file__) + "/..")

# output file names
BASENAME     = "terminal-"
trx_filtered = f"{BASENAME}trx_filter.dat"
trx_dump     = f"{BASENAME}trx_dump.txt"
trx_h5       = f"{BASENAME}trx_data.h5"

# test if pv is available (pv = pipe viewer, see pv --help for details)
try:
    proc.run(["pv", "--version"], stdout=proc.DEVNULL)
    pv = lambda input: f"pv {input} | "
except OSError:
    pv = lambda input: f"< {input} "

# remove silently
def remove_silent(filename):
	try:
	    os.remove(filename)
	except FileNotFoundError:
		pass

# make script exit if a command fails
# ATTENTION: xonsh does not provide a 'pipefail' equivalent so far (0.13.1),
# so $RAISE_SUBPROC_ERROR does not work with piped commands
$RAISE_SUBPROC_ERROR = True

#===================================================================================================
# extract data from serial log file(s)

patterns = input(f"extract data from log file(s) {BASENAME}<pattern>.log [enter list of <pattern>s, empty = abort]: ")
if not patterns:
    sys.exit(0)

# ATTENTION: Concatenating multiple log files can produce corrupt TRX entries, namely if one file
# ends in the middle of a TRX block and the next file starts in the middle of a TRX block.
# For this reason we avoid concatenating multiple log files and process each file for its own.
# That said, it is not likely that concatenating two incomplete fragments results in a valid
# record (with correct checksum), so the risk of generating wrong records is very low even with
# concatenated files. To be absolutely safe, one could manually check the first and last lines
# of the files before processing and remove broken TRX records (if present).

logfile = os.path.splitext(trx_filtered)[0] + ".log"
remove_silent(trx_filtered)
remove_silent(logfile)
for pattern in patterns.split():
    for infile in glob.iglob(BASENAME + pattern + ".log"):
        echo @(f"extracting TRX records from {infile} ...") | tee -a @(logfile)
        cmd = f'{TOOLPATH}/filter_logs.py -r TRX "" -c --strict --control-chars 01,17,02,03 -a {trx_filtered}'
        execx(pv(infile) + f"{cmd} err>out | tee -a {logfile}")

#===================================================================================================
# parse TRX records

echo @(f"decoding TRX records from {trx_filtered} ...")
logfile = os.path.splitext(trx_dump)[0] + ".log"
with open(trx_filtered, "rt") as f:
    num_lines = sum(1 for _ in f)
cmd = f'{TOOLPATH}/trx_dump.py -o {trx_h5} -d {trx_dump} -l {num_lines}'
execx(pv(trx_filtered) + cmd + f" err>out | tee {logfile}")

#===================================================================================================
# analyze TRX records

# marker syntax (see --help): --add-markers NAME TABLE EXPRESSION CONDITION TITLE NODE_ID_FIELD
echo @(f"analyzing TRX records in {trx_h5} ...")
logfile = os.path.splitext(trx_h5)[0] + ".log"
@(TOOLPATH)/trx_analyze.py \
	--add-markers no_traffic 'catalogs/rx_info' 'num_transmitters' '# == 0' 'use to find external interference' destination_node_id \
	--add-markers high_noise_90 'catalogs/rx_info' 'where(num_transmitters == 0, where(rssi_sum_max > rssi_noise, rssi_sum_max, rssi_noise), rssi_noise)' '# > -90' 'noise > -90 dBm' destination_node_id \
	--add-markers rssi_pp_3 'catalogs/rx_info' 'rssi_sum_max - rssi_sum_min' '# > 3' 'RSSI peak-to-peak range > 3' destination_node_id \
	--add-markers rssi_split_unclear 'catalogs/rx_info' '(rssi_range_noise1_len < 0) | (rssi_range_sum_len < 0)' '#' 'unclear signal and/or noise period, power estimated from histogram' destination_node_id \
	--add-markers rssi_implausible 'catalogs/rx_info' 'rssi_sum - rssi_noise' '# < 0' 'implausible RSSI split (sum < noise)' destination_node_id \
	--add-markers late_start 'trx_data/trx' 'late_start_delay' '# > 0' 'late start occurred' node_id \
	@(trx_h5) err>out | tee @(logfile)

#===================================================================================================

echo "done"
