`include "rv32i_defs.vh"

module ALU(
    input  wire [3:0]  ALUFunct,   // 4-bit 功能碼
    input  wire [31:0] data1,      // operand A
    input  wire [31:0] data2,      // operand B
    output reg  [31:0] ALUresult
);

    // RV32I：移位量只看低 5 bits
    wire [4:0] shamt = data2[4:0];

    always @* begin
        case (ALUFunct)
            `ALU_ADD:  ALUresult = data1 + data2;                     // add, addi, addr calc
            `ALU_SUB:  ALUresult = data1 - data2;                     // sub, beq/bne 比較

            `ALU_AND:  ALUresult = data1 & data2;                     // and, andi
            `ALU_OR:   ALUresult = data1 | data2;                     // or, ori
            `ALU_XOR:  ALUresult = data1 ^ data2;                     // xor, xori

            `ALU_SLL:  ALUresult = data1 << shamt;                    // sll, slli
            `ALU_SRL:  ALUresult = data1 >> shamt;                    // srl, srli（邏輯右移）
            `ALU_SRA:  ALUresult = $signed(data1) >>> shamt;          // sra, srai（算術右移）

            `ALU_SLT:  ALUresult = ($signed(data1) <  $signed(data2))
                                   ? 32'd1 : 32'd0;                  // slt, slti, blt, bge
            `ALU_SLTU: ALUresult = (data1 < data2)
                                   ? 32'd1 : 32'd0;                  // sltu, sltiu, bltu, bgeu

            default:  ALUresult = 32'd0;
        endcase
    end

endmodule