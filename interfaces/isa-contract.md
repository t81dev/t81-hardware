# ISA Contract (t81 v1 Baseline)

Status: executable baseline for bring-up with combinational + stateful flows.
Normative references for future expansion: `duotronic-whitepaper`, `t81-foundation`, `ternary_gcc_plugin`.

## Scope

This contract defines the currently implemented instruction subset and command sequencing model.

- Trit domain: balanced trits represented as signed integers in `{-1, 0, 1}`.
- Trit values are clamped through `clamp(x)` where arithmetic could exceed bounds.
- `t81_top` is a combinational ALU view.
- `t81_core_seq` is a stateful 4-register execution shell with command sequencing.

## ALU Opcode Encodings (3 bits)

- `0`: `NOP` -> `y = 0`, `valid = 1`
- `1`: `PASSA` -> `y = clamp(a)`, `valid = 1`
- `2`: `ADD` -> `y = clamp(a + b)`, `valid = 1`
- `3`: `SUB` -> `y = clamp(a - b)`, `valid = 1`
- `4`: `NEG` -> `y = clamp(-a)`, `valid = 1`
- `5`: `MIN` -> `y = min(a, b)`, `valid = 1`
- `6`: `MAX` -> `y = max(a, b)`, `valid = 1`
- `7`: `ISZERO` -> `y = 1 if a == 0 else -1`, `valid = 1`

`clamp(x)` returns:

- `1` if `x > 1`
- `-1` if `x < -1`
- `x` otherwise

## Stateful Command Sequencing (`t81_core_seq`)

Register file:

- 4 registers (`r0..r3`), each one trit wide.

Command encoding (`cmd`, 2 bits):

- `0`: `LOAD` -> `reg[dst] = clamp(imm_trit)`
- `1`: `EXEC` -> `y, valid = ALU(opcode, reg[src_a], reg[src_b])`; if valid, `reg[dst] = y`; outputs `last_y`, `last_valid`
- `2`: `STORE` -> outputs `store_data = reg[src_a]`, `store_valid = 1`
- `3`: `NOP` -> no state updates

Determinism rules:

- Outputs are deterministic for legal inputs.
- No undefined opcode paths exist in the current 3-bit ALU encoding.
- `emulator/t81_model.py` is the golden source for generated vectors and sequential expected traces.

## Verification Artifacts

- Combinational vectors: `sim/vectors/t81_top_vectors.tsv`
- Sequential program stimulus: `sim/vectors/t81_seq_program.tsv`
- Sequential expected trace: `sim/vectors/t81_seq_expected.tsv`
- Sequential observed trace from RTL: `sim/out/t81_seq_observed.tsv`

## Planned Extensions

- Multi-trit packed lanes (base-81 words).
- Wider register file and memory operations.
- Exception/fault signaling beyond `valid` flags.
- ABI-level command stream alignment with compiler lowering.
