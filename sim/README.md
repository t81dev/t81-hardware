# Simulation

Simulation harnesses and vectors.

- `testbenches/`: block and system testbenches.
- `vectors/`: deterministic test vectors, programs, and expected traces.

Run from repo root:

- `make sim-top`: combinational ALU checks.
- `make sim-seq`: stateful command-sequencing checks.
- `make sim`: runs both.
- `make parity`: runs sequential sim then emulator-vs-RTL trace parity check.
