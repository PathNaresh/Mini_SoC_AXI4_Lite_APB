
#!/bin/bash

#=========================================================
# FULL MINI-SOC SIMULATION SCRIPT
#=========================================================

echo ""
echo "=========================================="
echo "      FULL MINI-SOC SIMULATION START"
echo "=========================================="
echo ""

#=========================================================
# LOAD VCS
#=========================================================
source /etc/profile.d/modules.sh

module load synopsys/vcs/2025.06

#=========================================================
# CLEAN
#=========================================================
rm -rf csrc
rm -rf simv*
rm -rf ucli.key
rm -rf *.vpd
rm -rf DVEfiles

#=========================================================
# COMPILE
#=========================================================
vcs -sverilog -full64 -debug_access+all \
+incdir+../../common \
../rtl/axi_interconnect.sv \
../rtl/axi_sram.sv \
../rtl/axi_apb_bridge.sv \
../rtl/apb_decoder.sv \
../rtl/apb_gpio.sv \
../rtl/apb_uart_stub.sv \
../rtl/apb_spi_stub.sv \
../rtl/apb_subsystem.sv \
../rtl/soc_top.sv \
../tb/tb_soc_top.sv \
-l compile.log

#=========================================================
# RUN
#=========================================================
./simv -l sim.log

echo ""
echo "=========================================="
echo "      FULL MINI-SOC SIMULATION DONE"
echo "=========================================="
echo ""

#=========================================================
# CMD TO OPEN DUMP
#=========================================================
dve -vpd ../waves/full_soc.vpd &
