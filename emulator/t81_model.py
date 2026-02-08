#!/usr/bin/env python3
"""Reference model and vector generator for t81 RTL baselines."""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path

OP_NOP = 0
OP_PASSA = 1
OP_ADD = 2
OP_SUB = 3
OP_NEG = 4
OP_MIN = 5
OP_MAX = 6
OP_ISZERO = 7

CMD_LOAD = 0
CMD_EXEC = 1
CMD_STORE = 2
CMD_NOP = 3


@dataclass(frozen=True)
class Vector:
    opcode: int
    trit_a: int
    trit_b: int
    trit_y: int
    valid: int


@dataclass(frozen=True)
class ProgramStep:
    step: int
    cmd: int
    opcode: int
    src_a: int
    src_b: int
    dst: int
    imm_trit: int


@dataclass(frozen=True)
class SeqTraceRow:
    step: int
    store_data: int
    store_valid: int
    last_y: int
    last_valid: int
    r0: int
    r1: int
    r2: int
    r3: int


def clamp_trit(value: int) -> int:
    if value > 1:
        return 1
    if value < -1:
        return -1
    return value


def eval_instruction(opcode: int, trit_a: int, trit_b: int) -> tuple[int, int]:
    if opcode == OP_NOP:
        return 0, 1
    if opcode == OP_PASSA:
        return clamp_trit(trit_a), 1
    if opcode == OP_ADD:
        return clamp_trit(trit_a + trit_b), 1
    if opcode == OP_SUB:
        return clamp_trit(trit_a - trit_b), 1
    if opcode == OP_NEG:
        return clamp_trit(-trit_a), 1
    if opcode == OP_MIN:
        return min(trit_a, trit_b), 1
    if opcode == OP_MAX:
        return max(trit_a, trit_b), 1
    if opcode == OP_ISZERO:
        return (1 if trit_a == 0 else -1), 1
    return 0, 0


def generate_top_vectors() -> list[Vector]:
    rows: list[Vector] = []
    for opcode in range(0, 8):
        for trit_a in (-1, 0, 1):
            for trit_b in (-1, 0, 1):
                trit_y, valid = eval_instruction(opcode, trit_a, trit_b)
                rows.append(Vector(opcode, trit_a, trit_b, trit_y, valid))
    return rows


def default_program() -> list[ProgramStep]:
    # Compact deterministic sequence that exercises LOAD/EXEC/STORE.
    return [
        ProgramStep(0, CMD_LOAD, OP_NOP, 0, 0, 0, 1),
        ProgramStep(1, CMD_LOAD, OP_NOP, 0, 0, 1, -1),
        ProgramStep(2, CMD_EXEC, OP_ADD, 0, 1, 2, 0),
        ProgramStep(3, CMD_EXEC, OP_ISZERO, 2, 0, 3, 0),
        ProgramStep(4, CMD_STORE, OP_NOP, 3, 0, 0, 0),
        ProgramStep(5, CMD_EXEC, OP_SUB, 0, 1, 2, 0),
        ProgramStep(6, CMD_STORE, OP_NOP, 2, 0, 0, 0),
        ProgramStep(7, CMD_EXEC, OP_MIN, 0, 1, 3, 0),
        ProgramStep(8, CMD_STORE, OP_NOP, 3, 0, 0, 0),
        ProgramStep(9, CMD_EXEC, OP_MAX, 0, 1, 3, 0),
        ProgramStep(10, CMD_STORE, OP_NOP, 3, 0, 0, 0),
        ProgramStep(11, CMD_EXEC, OP_NEG, 1, 0, 1, 0),
        ProgramStep(12, CMD_STORE, OP_NOP, 1, 0, 0, 0),
        ProgramStep(13, CMD_NOP, OP_NOP, 0, 0, 0, 0),
    ]


def simulate_program(program: list[ProgramStep]) -> list[SeqTraceRow]:
    regs = [0, 0, 0, 0]
    rows: list[SeqTraceRow] = []

    for step in program:
        store_data = 0
        store_valid = 0
        last_y = 0
        last_valid = 0

        if step.cmd == CMD_LOAD:
            regs[step.dst] = clamp_trit(step.imm_trit)
        elif step.cmd == CMD_EXEC:
            y, v = eval_instruction(step.opcode, regs[step.src_a], regs[step.src_b])
            last_y = y
            last_valid = v
            if v:
                regs[step.dst] = y
        elif step.cmd == CMD_STORE:
            store_data = regs[step.src_a]
            store_valid = 1
        elif step.cmd == CMD_NOP:
            pass

        rows.append(
            SeqTraceRow(
                step=step.step,
                store_data=store_data,
                store_valid=store_valid,
                last_y=last_y,
                last_valid=last_valid,
                r0=regs[0],
                r1=regs[1],
                r2=regs[2],
                r3=regs[3],
            )
        )

    return rows


def write_top_vectors(path: Path, rows: list[Vector]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", encoding="utf-8") as f:
        f.write("opcode\ttrit_a\ttrit_b\ttrit_y\tvalid\n")
        for row in rows:
            f.write(f"{row.opcode}\t{row.trit_a}\t{row.trit_b}\t{row.trit_y}\t{row.valid}\n")


def write_program(path: Path, rows: list[ProgramStep]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", encoding="utf-8") as f:
        f.write("step\tcmd\topcode\tsrc_a\tsrc_b\tdst\timm_trit\n")
        for row in rows:
            f.write(
                f"{row.step}\t{row.cmd}\t{row.opcode}\t{row.src_a}\t{row.src_b}\t{row.dst}\t{row.imm_trit}\n"
            )


def write_trace(path: Path, rows: list[SeqTraceRow]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", encoding="utf-8") as f:
        f.write("step\tstore_data\tstore_valid\tlast_y\tlast_valid\tr0\tr1\tr2\tr3\n")
        for row in rows:
            f.write(
                f"{row.step}\t{row.store_data}\t{row.store_valid}\t{row.last_y}\t{row.last_valid}"
                f"\t{row.r0}\t{row.r1}\t{row.r2}\t{row.r3}\n"
            )


def main() -> None:
    root = Path(__file__).resolve().parent.parent

    top_vectors_path = root / "sim" / "vectors" / "t81_top_vectors.tsv"
    seq_program_path = root / "sim" / "vectors" / "t81_seq_program.tsv"
    seq_expected_path = root / "sim" / "vectors" / "t81_seq_expected.tsv"

    top_vectors = generate_top_vectors()
    program = default_program()
    seq_trace = simulate_program(program)

    write_top_vectors(top_vectors_path, top_vectors)
    write_program(seq_program_path, program)
    write_trace(seq_expected_path, seq_trace)

    print(f"wrote {top_vectors_path} ({len(top_vectors)} rows)")
    print(f"wrote {seq_program_path} ({len(program)} rows)")
    print(f"wrote {seq_expected_path} ({len(seq_trace)} rows)")


if __name__ == "__main__":
    main()
