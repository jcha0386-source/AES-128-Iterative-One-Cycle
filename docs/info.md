## How it works

This project implements an iterative, hardware-accelerated **AES-128 Encryption Core** optimized for low area overhead while preserving single-cycle round execution. 

Instead of unrolling all 10 cryptographic rounds spatially (which would consume massive hardware resources), this design loops the data feedback through a single, highly optimized state register over consecutive clock cycles.

### Architectural Key Features:
* **Round-per-Cycle Execution:** Executes exactly one complete AES round function per clock cycle, concluding a full block encryption in a total **11-cycle processing window**.
* **Stream Serialization (8-bit Interface):** Utilizes a multiplexed serial loading and unloading wrapper to stream plaintext and cipher keys through the standard Tiny Tapeout 8-bit input bus (`ui_in`), eliminating the need for expensive high-pin-count parallel routing.
* **Optimized S-Box Cells:** Maps the SubBytes substitution transformation efficiently using synthesized Verilog case-statements to reduce total Logic Element (LE) count on the SkyWater 130nm standard cell grid.

---

## How to test

The design interfaces with an external testbench wrapper that cycles control signals through the bidirectional IO lines.

### Test Instructions:
1. Pulse the system reset low (`rst_n`) to initialize the FSM controllers.
2. Stream the 128-bit Plaintext block and 128-bit Cipher Key byte-by-byte into `ui_in` using the `byte_idx` multiplexer, asserting `load_ptext` and `load_key` respectively.
3. Assert the `start` pulse high on the control line to initiate execution.
4. Monitor the `busy` line; it will stay high for exactly **11 clock cycles** during execution.
5. When `done` pulses high, read out the final output payload from the 8-bit `uo_out` streaming bus.

---

## External hardware

No specialized external analog components are required. The hardware core acts as a pure digital co-processor. It can be monitored or driven by:
* An FPGA development board (e.g., DE1-SoC or Cyclone IV/V platforms used during synthesis verification).
* A standard microcontroller or logic analyzer communicating via digital GPIO lines to toggle control, clocking, and data index buses.
