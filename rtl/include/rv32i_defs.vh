/* This file defines RV32I opcodes, ALUOP categories and ALU function codes */

`ifndef RV32I_DEFS_VH
`define RV32I_DEFS_VH

// -----------------------------------------------------
// Opcodes (7-bit)
// -----------------------------------------------------
`define OPC_RTYPE   7'b0110011  // R-type ALU
`define OPC_ITYPE   7'b0010011  // I-type ALU
`define OPC_LOAD    7'b0000011  // LB/LH/LW/LBU/LHU
`define OPC_STORE   7'b0100011  // SB/SH/SW
`define OPC_BRANCH  7'b1100011  // BEQ/BNE/BLT/BGE/BLTU/BGEU
`define OPC_LUI     7'b0110111  // LUI
`define OPC_AUIPC   7'b0010111  // AUIPC
`define OPC_JAL     7'b1101111  // JAL
`define OPC_JALR    7'b1100111  // JALR

// -----------------------------------------------------
// ALU function codes (給 ALUControl -> ALU 用，4-bit)
// -----------------------------------------------------
`define ALU_ADD   4'd0  // A + B
`define ALU_SUB   4'd1  // A - B
`define ALU_AND   4'd2  // A & B
`define ALU_OR    4'd3  // A | B
`define ALU_XOR   4'd4  // A ^ B
`define ALU_SLL   4'd5  // A << shamt
`define ALU_SRL   4'd6  // A >> shamt (logical)
`define ALU_SRA   4'd7  // A >>> shamt (arithmetic)
`define ALU_SLT   4'd8  // signed A < B
`define ALU_SLTU  4'd9  // unsigned A < B

`endif // RV32I_DEFS_VH
