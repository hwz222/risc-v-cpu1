`include "rv32i_defs.vh"

module InstructionDecoder (
    input  wire [31:0] instruction,

    // Register file
    output wire [4:0] Reg1RA,
    output wire [4:0] Reg2RA,
    output reg        RegWE,
    output wire [4:0] RegWA,

    // Execute
    output reg        ALUOp1Src,      // 0 = rs1, 1 = PC
    output reg        ALUOp2Src,      // 0 = rs2, 1 = Imm
    output wire [31:0] Imm,
    output reg  [2:0]  ALUOp,         // 交給 ALU decoder

    // WriteBack
    output reg [1:0] RegWriteSrc,     // 0=ALU, 1=MEM, 2=PC+4

    // MemoryControl
    output reg MemoryRE,
    output reg MemoryWE
);

    // ---------------------
    // 欄位切割
    // ---------------------
    wire [6:0] opcode = instruction[6:0];
    wire [2:0] funct3 = instruction[14:12];
    wire [6:0] funct7 = instruction[31:25];

    assign Reg1RA = instruction[19:15];
    assign Reg2RA = instruction[24:20];
    assign RegWA  = instruction[11:7];

    // ---------------------
    // 立即數產生器
    // ---------------------
    ImmGen immgen (
        .instr(instruction),
        .imm(Imm)
    );

    // ---------------------
    // 預設值（避免 latch）
    // ---------------------
    always @* begin
        RegWE       = 0;          // write not enable
        MemoryRE    = 0;          // memory cant read
        MemoryWE    = 0;          // memory cant write
        ALUOp1Src   = 0;          //  src1 = rs1
        ALUOp2Src   = 0;          //  src2 = rs2
        RegWriteSrc = 2'b00;      // wirte alu result
        ALUOp       = ALUOP_ADD;  // 預設 ALU ADD
    end

    // ---------------------
    // 主解碼邏輯
    // ---------------------
    always @* begin
        case (opcode)

            // ===========================================
            // R-type
            // ===========================================
            OPC_RTYPE: begin
                RegWE       = 1;
                ALUOp1Src   = 0;
                ALUOp2Src   = 0;
                RegWriteSrc = 2'b00;    // ALU
                ALUOp       = ALUOP_RTYPE;
            end

            // ===========================================
            // I-type arithmetic (addi/andi/ori/..)
            // ===========================================
            OPC_ITYPE: begin
                RegWE       = 1;
                ALUOp1Src   = 0;
                ALUOp2Src   = 1;
                RegWriteSrc = 2'b00;   // ALU
                ALUOp       = ALUOP_ITYPE;
            end

            // ===========================================
            // Load
            // ===========================================
            OPC_LOAD: begin
                RegWE       = 1;
                MemoryRE    = 1;
                ALUOp2Src   = 1;       // rs1 + imm
                RegWriteSrc = 2'b01;   // Memory
                ALUOp       = ALUOP_ADD;
            end

            // ===========================================
            // Store
            // ===========================================
            OPC_STORE: begin
                MemoryWE    = 1;
                ALUOp2Src   = 1;       // rs1 + imm
                ALUOp       = ALUOP_ADD;
            end

            // ===========================================
            // Branch
            // ===========================================
            OPC_BRANCH: begin
                ALUOp1Src   = 0;
                ALUOp2Src   = 0;
                MemoryRE    = 0;
                MemoryWE    = 0;
                RegWE       = 0;
                ALUOp       = ALUOP_BRANCH;
            end

            // ===========================================
            // LUI
            // ===========================================
            OPC_LUI: begin
                RegWE       = 1;
                ALUOp1Src   = 0;
                ALUOp2Src   = 1;
                RegWriteSrc = 2'b00;   // ALU gets U-type number
                ALUOp       = ALUOP_LUI;
            end

            // ===========================================
            // AUIPC
            // ===========================================
            OPC_AUIPC: begin
                RegWE       = 1;
                ALUOp1Src   = 1;       // PC
                ALUOp2Src   = 1;       // imm
                RegWriteSrc = 2'b00;   // ALU
                ALUOp       = ALUOP_ADD;
            end

            // ===========================================
            // JAL
            // ===========================================
            OPC_JAL: begin
                RegWE       = 1;
                ALUOp1Src   = 1;
                ALUOp2Src   = 1;
                RegWriteSrc = 2'b10;   // PC + 4
                ALUOp       = ALUOP_JUMP;
            end

            // ===========================================
            // JALR
            // ===========================================
            OPC_JALR: begin
                RegWE       = 1;
                ALUOp1Src   = 0;
                ALUOp2Src   = 1;
                RegWriteSrc = 2'b10;   // PC + 4
                ALUOp       = ALUOP_JUMP;
            end

            // ===========================================
            // Default: illegal instruction
            // ===========================================
            default: begin
                RegWE = 0;
            end

        endcase
    end

endmodule
