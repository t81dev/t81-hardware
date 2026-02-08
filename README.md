# t81-hardware

Hardware implementation and verification workspace for the T81 ternary coprocessor ecosystem.

## Goals

- Define synthesizable RTL for ternary arithmetic and control blocks.
- Provide deterministic simulation and regression infrastructure.
- Provide FPGA bring-up flows for iterative hardware validation.
- Maintain compatibility contracts with the broader `t81dev` repositories.

## Repository Layout

- `rtl/`: Verilog/SystemVerilog/VHDL source for core and primitive blocks.
- `sim/`: testbenches, vectors, and simulation harnesses.
- `fpga/`: board-specific constraints and build scripts.
- `emulator/`: software reference model for RTL cross-checking.
- `interfaces/`: ABI/ISA boundary docs and data-format contracts.
- `verification/`: assertions, formal setup, and verification notes.
- `docs/`: architecture docs and ecosystem integration map.
- `scripts/`: automation helpers (sync, lint, regression, packaging).

## Ecosystem Alignment

`docs/ecosystem-integration.md` maps this repo to every repository currently published under `https://github.com/t81dev`.

`docs/ecosystem-repos.tsv` is a machine-readable snapshot produced by `scripts/sync_ecosystem.sh`.

## Quick Start

Requirements:

- `python3`
- `iverilog` + `vvp`
- `verilator` (lint)
- `jq` + `curl` (ecosystem sync)

Run:

```bash
make vectors
make lint
make sim
make parity
```

## Current Baseline

- Combinational ALU (`rtl/core/t81_top.sv`) with 8 opcodes.
- Stateful core shell (`rtl/core/t81_core_seq.sv`) with `LOAD/EXEC/STORE/NOP` sequencing over `r0..r3`.
- Golden-model-generated vectors and trace files via `emulator/t81_model.py`.
- Python parity checker (`emulator/rtl_parity.py`) for emulator vs RTL sequential trace equality.
- CI includes Icarus lint/sim and Verilator lint.

## Key Contracts

- ISA and sequencing semantics: `interfaces/isa-contract.md`
- Combinational testbench: `sim/testbenches/tb_t81_top.sv`
- Stateful testbench: `sim/testbenches/tb_t81_core_seq.sv`
