# T81 Hardware Ecosystem Integration

Snapshot date: 2026-02-08
Source namespace: `https://github.com/t81dev`

This document maps each current `t81dev` repository to hardware impacts and integration points.

| Repository | Primary Role | Hardware Integration in `t81-hardware` |
|---|---|---|
| `ANGELA` | Adjacent project (unspecified) | Track for future interface requirements; no hard dependency yet. |
| `duotronic-computing` | Interpretive/contextual material | Use as explanatory context, not normative behavior. |
| `duotronic-thesis` | Research material | Use for rationale and long-form design tradeoffs. |
| `duotronic-whitepaper` | Formal proposal/reference semantics | Primary normative source for RTL semantics and verification oracles. |
| `llama.cpp` | LLM inference runtime | Potential downstream accelerator target and benchmark consumer. |
| `t81-benchmarks` | Performance/accuracy/energy comparisons | Upstream benchmark harness should consume FPGA/emulator metrics from this repo. |
| `t81-constraints` | Assumptions and failure boundaries | Convert constraints into hardware requirements and verification assertions. |
| `t81-docs` | Unified ecosystem docs | Publish hardware build/usage docs for cross-repo discoverability. |
| `t81-examples` | Demonstrations | Add hardware-backed examples and reference waveforms. |
| `t81-foundation` | Core T81 stack | Align instruction/data semantics and coprocessor interface contracts. |
| `t81-hardware` | Hardware implementation | This repository. |
| `t81-python` | High-level bindings/APIs | Expose simulation/emulator hooks for Python-driven testing. |
| `t81-roadmap` | Milestones and strategy | Keep hardware milestones synchronized with ecosystem roadmap. |
| `t81lib` | Ternary arithmetic core library | Cross-validate arithmetic behavior against RTL and emulator model. |
| `ternary` | T3_K quantization implementation | Candidate workload generator for accelerator validation. |
| `ternary-delta` | Positioning and impact analysis | Input for productization priorities; no normative dependency. |
| `ternary-fabric` | Memory/interconnect co-processor | Define interoperability boundary for multi-block hardware systems. |
| `ternary-memory-research` | Memory research | Feed memory architecture experiments for RTL prototypes. |
| `ternary-pager` | Semantic compression falsification tool | Potential stress workload and corner-case generator. |
| `ternary-tools` | Balanced-ternary tooling | Integrate inspectors/debug tooling into verification workflows. |
| `ternary_gcc_plugin` | GCC lowering/ABI experimentation | Define ABI-level test vectors and coprocessor call protocol checks. |
| `trinity` | Ternary-native cipher suite | Security workload for datapath and throughput validation. |
| `trinity-decrypt` | Decrypt tooling | Additional crypto test vectors and interoperability checks. |
| `trinity-pow` | PoW algorithm in balanced ternary | Throughput/entropy-heavy benchmark for implementation stress tests. |

## Priority Interfaces to Implement First

1. ISA/ABI boundary with `t81-foundation` and `ternary_gcc_plugin`.
2. Arithmetic correctness parity with `duotronic-whitepaper` and `t81lib`.
3. Benchmark output compatibility with `t81-benchmarks`.
4. Workload compatibility with `ternary`, `trinity`, and `llama.cpp` integration paths.
