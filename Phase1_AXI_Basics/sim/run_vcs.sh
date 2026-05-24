#!/bin/bash

#=========================================================
# VCS ENVIRONMENT
#=========================================================
module load synopsys/vcs/2025.06

#=========================================================
# CLEAN OLD FILES
#=========================================================
rm -rf simv*
rm -rf csrc*
rm -rf *.log
rm -rf *.vpd
rm -rf ucli.key
rm -rf DVEfiles

#=========================================================
# COMPILE
#=========================================================
vcs -full64 -sverilog \
+incdir+../../common \
../rtl/*.sv \
../tb/*.sv \
-o simv \
-debug_access+all \
-kdb \
-l compile.log

#=========================================================
# EXIT IF COMPILE FAILS
#=========================================================
if [ $? -ne 0 ]; then
    echo ""
    echo "[SIM] COMPILE FAILED"
    echo ""
    exit 1
fi

#=========================================================
# RUN SIMULATION
#=========================================================
./simv +vcs+flush+all | tee run.log

#=========================================================
# EXIT IF SIM FAILS
#=========================================================
if [ $? -ne 0 ]; then
    echo ""
    echo "[SIM] SIMULATION FAILED"
    echo ""
    exit 1
fi

echo ""
echo "[SIM] SIMULATION PASSED"
echo ""

