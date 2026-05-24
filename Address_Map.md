# Address Map

# AXI Address Space

| Address Range | Target |
|---|---|
| 0x0000_0000 – 0x0000_FFFF | AXI SRAM |
| 0x1000_0000 – 0x1000_FFFF | AXI→APB Bridge |

---

# APB Peripheral Address Map

| Peripheral | Base Address |
|---|---|
| GPIO | 0x1000_0000 |
| UART | 0x1000_1000 |
| SPI  | 0x1000_2000 |

---

# GPIO Register Map

| Offset | Register |
|---|---|
| 0x00 | GPIO_DATA |
| 0x04 | GPIO_DIR |

---

# UART Register Map

| Offset | Register |
|---|---|
| 0x00 | TXDATA |
| 0x04 | RXDATA |
| 0x08 | STATUS |
| 0x0C | CONTROL |

---

# SPI Register Map

| Offset | Register |
|---|---|
| 0x00 | TXDATA |
| 0x04 | RXDATA |
| 0x08 | STATUS |
| 0x0C | CONTROL |
