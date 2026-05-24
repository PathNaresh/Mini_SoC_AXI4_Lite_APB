# Protocol Notes

# AXI4-Lite

AXI4-Lite is a lightweight AXI protocol supporting single-beat transactions.

Channels:
- Write Address Channel
- Write Data Channel
- Write Response Channel
- Read Address Channel
- Read Data Channel

Handshake:
- VALID/READY protocol

Features:
- single-beat transfers
- simple address-based communication
- no burst support

---

# APB3

APB is a simple peripheral bus used for low-bandwidth peripherals.

Signals:
- PADDR
- PWDATA
- PRDATA
- PSEL
- PENABLE
- PWRITE

---

# APB Transaction Phases

## Setup Phase

PSEL    = 1
PENABLE = 0

Address and control become valid.

---

## Access Phase

PSEL    = 1
PENABLE = 1

Data transfer occurs.

---

# Important Debug Lesson

APB ACCESS phase must remain active for a complete clock cycle.

Incorrect timing can cause peripherals to miss transactions.
