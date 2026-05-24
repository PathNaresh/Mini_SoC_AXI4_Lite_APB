# Debug Lessons

# 1. APB ACCESS Phase Timing Bug

Issue:
GPIO transactions failed even though AXI and bridge activity appeared correct.

Root Cause:
PENABLE was asserted and deasserted within the same clock timing window.

Lesson:
APB ACCESS phase must exist for one full clock cycle.

---

# 2. Full Address vs Register Offset Decode

Issue:
Peripheral register decode failed in full SoC integration.

Root Cause:
Peripheral expected local register offsets while receiving full SoC addresses.

Fix:
Use:
PADDR[7:0]

inside peripheral register decode logic.

---

# 3. Nonblocking Assignment Timing

Issue:
Signals appeared correct in RTL but peripherals sampled old values.

Root Cause:
Nonblocking assignments update at end of timestep.

Lesson:
Sequential timing behavior must be carefully considered in FSM design.

---

# 4. Hierarchical Address Decode

Issue:
Peripheral selection failed initially.

Lesson:
Use upper address bits for subsystem-level peripheral decode and lower bits for local register decode.

---

# 5. Waveform Debugging Importance

Waveform analysis using DVE/VPD was critical for:
- protocol timing debug
- FSM validation
- signal visibility
- transaction tracing
```
