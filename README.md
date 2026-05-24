# Final Mini-SoC

## Overview

Final Mini-SoC is a modular educational System-on-Chip (SoC) project developed using Verilog/SystemVerilog to understand real SoC architecture, bus protocols, subsystem integration, and verification methodologies.

The project incrementally builds a complete SoC platform using industry-style RTL hierarchy and verification flow.

---

# Architecture

AXI Master TB
    ↓
AXI Interconnect
    ├── AXI SRAM
    └── AXI → APB Bridge
                    ↓
              APB Subsystem
         ├── GPIO Peripheral
         ├── UART Stub
         └── SPI Stub

---

# Supported Protocols

- AXI4-Lite
- APB3

---

# Key Features

- AXI4-Lite Master Verification TB
- AXI Interconnect
- AXI SRAM Slave
- AXI→APB Bridge
- APB Decoder
- GPIO Peripheral
- UART Stub Peripheral
- SPI Stub Peripheral
- Full-System Integration
- Structured Logging
- Waveform Debugging using VPD/DVE

---

# Address Map

## AXI Address Space

| Address Range | Target |
|---|---|
| 0x0000_0000 – 0x0000_FFFF | AXI SRAM |
| 0x1000_0000 – 0x1000_FFFF | AXI→APB Bridge |

---

## APB Peripheral Map

| Peripheral | Base Address |
|---|---|
| GPIO | 0x1000_0000 |
| UART | 0x1000_1000 |
| SPI  | 0x1000_2000 |

---

# Project Structure

Final_SoC/
├── common/
├── Phase1_AXI_Basics/
├── Phase2_AXI_Interconnect/
├── Phase3_AXI_APB_Bridge/
├── Phase4_APB_Subsystem/
├── Phase5_Full_System/
└── docs/

---

# Simulation

## Compile + Run

```bash
./run_vcs.sh
```

## Open Waveform

```bash
dve -vpd ../waves/full_soc.vpd &
```

---

# Verification

- Directed AXI transactions
- SRAM read/write verification
- GPIO verification
- UART verification
- SPI verification
- PASS/FAIL logging
- Waveform-based debug

---

# Future Enhancements

- DMA Controller
- Interrupt Controller
- APB Timer
- Functional UART/SPI
- Multiple AXI Masters
- AXI Arbiter
- Cache Controller
- RISC-V CPU Integration
- UVM Verification

---

# Status

✅ Fully Integrated Mini-SoC Operational
