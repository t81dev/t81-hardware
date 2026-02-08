# Emulator

Software reference model for behavior parity against RTL and testbench outputs.

- `t81_model.py`: generates combinational vectors, sequential program stimulus, and expected sequential traces.
- `rtl_parity.py`: compares RTL observed sequential trace to emulator expected trace.
