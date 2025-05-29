# /usr/bin/auroramax-scheduler.sh

#!/bin/bash
# AuroraMax CPU Scheduler Selection Script

set -euo pipefail

# Check for BORE scheduler
if [ -f /sys/kernel/sched/sched_bore ]; then
    echo 1 > /sys/kernel/sched/sched_bore
    echo "BORE scheduler activated"
fi

# Check for LAVD scheduler
if [ -f /sys/kernel/sched/sched_lavd ]; then
    echo 1 > /sys/kernel/sched/sched_lavd
    echo "LAVD scheduler activated"
fi

# If neither is available, log it
if [ ! -f /sys/kernel/sched/sched_bore ] && [ ! -f /sys/kernel/sched/sched_lavd ]; then
    echo "Warning: Neither BORE nor LAVD scheduler found. Using default CFS."
fi
