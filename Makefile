SHELL := /bin/bash

IVERILOG ?= iverilog
VVP ?= vvp
VERILATOR ?= verilator
PYTHON ?= python3

RTL_TOP := rtl/core/t81_top.sv
RTL_SEQ := rtl/core/t81_core_seq.sv
TB_TOP := sim/testbenches/tb_t81_top.sv
TB_SEQ := sim/testbenches/tb_t81_core_seq.sv
SIM_TOP_OUT := sim/out/t81_top_tb.vvp
SIM_SEQ_OUT := sim/out/t81_core_seq_tb.vvp

.PHONY: all vectors lint lint-iverilog lint-verilator sim-top sim-seq sim parity clean

all: lint sim parity

vectors:
	$(PYTHON) emulator/t81_model.py

lint: lint-iverilog lint-verilator

lint-iverilog:
	mkdir -p sim/out
	$(IVERILOG) -g2012 -t null -Wall $(RTL_TOP) $(TB_TOP)
	$(IVERILOG) -g2012 -t null -Wall $(RTL_SEQ) $(TB_SEQ)

lint-verilator:
	$(VERILATOR) --lint-only -Wall -Wno-DECLFILENAME $(RTL_TOP)
	$(VERILATOR) --lint-only -Wall -Wno-DECLFILENAME $(RTL_SEQ)

sim-top: vectors
	mkdir -p sim/out
	$(IVERILOG) -g2012 -o $(SIM_TOP_OUT) $(RTL_TOP) $(TB_TOP)
	$(VVP) $(SIM_TOP_OUT)

sim-seq: vectors
	mkdir -p sim/out
	$(IVERILOG) -g2012 -o $(SIM_SEQ_OUT) $(RTL_SEQ) $(TB_SEQ)
	$(VVP) $(SIM_SEQ_OUT)

sim: sim-top sim-seq

parity: sim-seq
	$(PYTHON) emulator/rtl_parity.py

clean:
	rm -rf sim/out
