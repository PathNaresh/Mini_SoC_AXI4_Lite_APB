# Mini-SoC Architecture

## High-Level Architecture

AXI Master TB
    ↓
AXI Interconnect
    ├── AXI SRAM
    └── AXI → APB Bridge
                    ↓
              APB Subsystem
         ├── GPIO
         ├── UART
         └── SPI

---

# Component Description

## AXI Master TB

Generates AXI4-Lite read/write transactions for SoC verification.

Responsibilities:
- AXI stimulus generation
- data checking
- PASS/FAIL reporting

---

## AXI Interconnect

Routes AXI transactions based on address decoding.

Responsibilities:
- SRAM selection
- APB bridge selection
- response routing

---

## AXI SRAM

AXI4-Lite slave memory block.

Responsibilities:
- memory storage
- read/write servicing
- AXI handshake support

---

## AXI→APB Bridge

Converts AXI4-Lite transactions into APB protocol transactions.

Responsibilities:
- protocol conversion
- APB setup/access phase generation
- AXI response generation

---

## APB Subsystem

Contains:
- APB decoder
- peripheral integration

Responsibilities:
- peripheral selection
- APB routing

---

## GPIO Peripheral

Simple APB GPIO controller.

Registers:
- GPIO_DATA
- GPIO_DIR

---

## UART Stub

Simplified UART peripheral model used for APB integration testing.

---

## SPI Stub

Simplified SPI peripheral model used for APB integration testing.
