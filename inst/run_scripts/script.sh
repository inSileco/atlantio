#!/bin/bash
set -e
atlantisMerged \
    -i {{init_file}} 0 \
    -o {{output_main}} \
    -r {{run.prm}} \
    -f {{force.prm}} \
    -p {{physics.prm}} \
    -b {{biol.prm}} \
    -s {{groups.csv}} \
    -q {{fisheries.csv}} \
    -d {{output_dir}}
