/* This file defines RV32I opcodes, ALUOP categories and ALU function codes */

`ifndef RV32I_DEFS_VH
`define RV32I_DEFS_VH

// -----------------------------------------------------
// Opcodes (7-bit)
// -----------------------------------------------------
localparam [6:0] OPC_RTYPE  = 7'b0110011; // R-type ALU
localparam [6:0] OPC_ITYPE  = 7'b0010011; // I-type ALU
localparam [6:0] OPC_LOAD   = 7'b0000011; // LB/LH/LW/LBU/LHU
localparam [6:0] OPC_STORE  = 7'b0100011; // SB/SH/SW
localparam [6:0] OPC_BRANCH = 7'b1100011; // BEQ/BNE/BLT/BGE/BLTU/BGEU
localparam [6:0] OPC_LUI    = 7'b0110111; // LUI
localparam [6:0] OPC_AUIPC  = 7'b0010111; // AUIPC
localparam [6:0] OPC_JAL    = 7'b1101111; // JAL
localparam [6:0] OPC_JALR   = 7'b1100111; // JALR

// -----------------------------------------------------
// ALU function codes (給 ALUControl -> ALU 用，4-bit)
// 這是「真正 ALU 要做的運算」
// -----------------------------------------------------
localparam [3:0] ALU_ADD  = 4'd0;  // A + B
localparam [3:0] ALU_SUB  = 4'd1;  // A - B

localparam [3:0] ALU_AND  = 4'd2;  // A & B
localparam [3:0] ALU_OR   = 4'd3;  // A | B
localparam [3:0] ALU_XOR  = 4'd4;  // A ^ B

localparam [3:0] ALU_SLL  = 4'd5;  // A << shamt
localparam [3:0] ALU_SRL  = 4'd6;  // A >> shamt (logical)
localparam [3:0] ALU_SRA  = 4'd7;  // A >>> shamt (arithmetic)

localparam [3:0] ALU_SLT  = 4'd8;  // set if A < B (signed)
localparam [3:0] ALU_SLTU = 4'd9;  // set if A < B (unsigned)


`endif // RV32I_DEFS_VH
