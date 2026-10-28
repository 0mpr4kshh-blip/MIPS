# 32-bit MIPS-Inspired Processor (Verilog)

A learning project: a simple 32-bit processor written in Verilog, loosely based on the MIPS32 instruction set. It was built from first principles rather than from a textbook datapath, so the structure is my own take on the fetch / decode / execute / memory / write-back flow.

**Status: work in progress.** The core modules and a testbench are written, but the design has known gaps (see [Known limitations](#known-limitations)).

## Files

| File | Description |
|------|-------------|
| `mips.v` | The processor. Top module is `main`. |
| `mipstb.v` | Testbench (`mipstb`) that loads a small program, prints state each clock cycle, and dumps a waveform. |

## Architecture

The design is split into registered stages, all driven by one clock:

| Module | Role |
|--------|------|
| `main` | Top level. Holds the PC and instruction memory (64 words), fetches an instruction each cycle, handles the jump mux, and wires everything together. |
| `decode_diff` | Decodes the opcode into R-type, I-type, or J-type. Selects the destination register, picks register or sign-extended immediate as the second ALU operand, and extracts the jump target. |
| `alu_exe` | Execute stage. Performs the ALU operation and raises load/store control signals. |
| `gp_registers` | 32 x 32-bit general-purpose register file with a load/store handshake. |
| `memory` | 256 x 32-bit data memory, word addressed. |
| `d_buffer` | Holds the destination register and memory address for loads and stores. |

Instruction flow: **fetch → decode (reads registers) → ALU → memory / write-back**.

## Supported instructions

| Type | Instructions |
|------|--------------|
| R-type | `add`, `sub`, `and`, `or`, `xor`, `nor`, `slt`, `addu`, `subu`, `sltu` |
| I-type | `addi`, `lw`, `sw` |
| J-type | `j`, `jal` (decoded, PC target computed; no return-address link yet) |

## Testbench

`mipstb.v` generates a clock (period 10 time units), loads this program into instruction memory, and runs for 100 time units:

| # | Machine code | Assembly |
|---|--------------|----------|
| 0 | `001000 00000 01000 0000000000000101` | `addi $t0, $zero, 5` |
| 1 | `001000 00000 01001 0000000000001010` | `addi $t1, $zero, 10` |
| 2 | `000000 01000 01001 01010 00000 100000` | `add  $t2, $t0, $t1` |
| 3 | `000000 01001 01000 01011 00000 100010` | `sub  $t3, $t1, $t0` |
| 4 | `000000 01000 01001 01010 00000 100100` | `and  $t2, $t0, $t1` |
| 5 | `000000 01000 01001 01010 00000 100101` | `or   $t2, $t0, $t1` |
| 6 | `000000 01000 01001 01010 00000 100110` | `xor  $t2, $t0, $t1` |
| 7 | `000000 01000 01001 01010 00000 101010` | `slt  $t2, $t0, $t1` |
| 8 | `001000 00000 10000 0000000001100100` | `addi $s0, $zero, 100` |

Each cycle it prints the PC, opcode, destination register, ALU result, and register contents. It also writes `mipstb.vcd` for viewing in GTKWave.

Expected architectural results (ignoring pipeline timing): `$t0 = 5`, `$t1 = 10`, `$t3 = 5`, `$s0 = 100`, and `$t2` ending at `1` after the final `slt` (`0` after `and`, `15` after `or` and `xor`).

## How to run

With [Icarus Verilog](https://steveicarus.github.io/iverilog/) and [GTKWave](https://gtkwave.sourceforge.net/):

```bash
iverilog -o mips_sim mips.v mipstb.v
vvp mips_sim
gtkwave mipstb.vcd
```

> The code may need small fixes to compile cleanly under strict tools (see below).

## Known limitations

- **No hazard handling.** There is no stalling or forwarding, so back-to-back dependent instructions may read stale register values.
- **No branches.** `beq` / `bne` are not implemented.
- **No shifts or logical immediates.** The `shamt` field is not wired up; `sll`, `srl`, `andi`, `ori`, etc. are missing.
- **Register `$0` is not hardwired to zero**, and only `gpr[0]` is initialized.
- **Jumps:** `j_mux` is never cleared after a jump, and `jal` does not save a return address.
- **Testbench is not self-checking.** It prints values but does not compare them against expected results.
- **Run length.** 100 time units is about 10 clock cycles, which may not be enough for the last instruction to complete through all stages.
- **Verilog portability.** Array-typed module ports, some multiply-declared signals, and `assign` to `reg` types may be rejected by strict simulators or synthesis tools.

## Roadmap

- [ ] Fix compile issues and get the test program running cleanly
- [ ] Hardwire `$0` and initialize the full register file
- [ ] Make the testbench self-checking (assert expected register values)
- [ ] Add `beq` / `bne` and shift instructions
- [ ] Add hazard detection and forwarding
- [ ] Add a block diagram and waveform screenshot

## What I learned

Basics of processor datapath design, instruction encoding (R/I/J formats), register files and memories in Verilog, clocked vs. combinational logic, and writing testbenches with waveform dumping.
