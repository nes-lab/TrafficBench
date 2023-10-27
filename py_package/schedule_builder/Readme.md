# Schedule to determine Link-Matrix

This setup uses several nRF running TrafficBench to survey the rf-conditions on a testbed.

Trafficbench is configured to let each node send a packet. The other nodes listen automatically and try to capture the packet and also record the P_Rx.

## Explanation of the Survey

- loop - one node after the other talks - the others listen
- each node sends ~ 34 bytes via 1 MBit Bluetooth (~300 us airtime), PTx = 0 dBm
- the other nodes listen and capture for 5 ms (+ 500 us pre- & post-delay)
- sleep 1 s before next node begins

## Installation

- adapt schedule with the [schedule-builder-script](./py_package/schedule_builder/build.py)
  - adapt node-count or scheduler elements
  - run the script to build the schedule
- compiling: follow the [readme](./trafficbench/README.md) of trafficbench
  - newest studio version (tested with v7.30) is fine
  - extra package needed (and restart studio after install) - should be automatic: CMSIS 5 5 CMSIS-CORE Support Package

## Usage of ELF

- patch NODE_ID in elf-file for each node (see [example python script](./_build/update_and_patch.py))
- run on testbed
- postprocessing, TODO
- NOTE: first loop-cycle should be discarded
