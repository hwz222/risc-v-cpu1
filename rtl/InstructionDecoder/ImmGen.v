`include "rv32i_defs.vh"

module ImmGen(
    input  wire [31:0] instr,
    output reg  [31:0] imm
);

    wire [6:0] opcode = instr[6:0];

    // 各種格式的立即數拆解
    wire [31:0] imm_i = {{20{instr[31]}}, instr[31:20]};
    wire [31:0] imm_s = {{20{instr[31]}}, instr[31:25], instr[11:7]};
    wire [31:0] imm_b = {{19{instr[31]}}, instr[31], instr[7],
                         instr[30:25], instr[11:8], 1'b0};
    wire [31:0] imm_u = {instr[31:12], 12'b0};
    wire [31:0] imm_j = {{11{instr[31]}}, instr[31],
                         instr[19:12], instr[20],
                         instr[30:21], 1'b0};

    always @* begin
        case (opcode)
            // I-type 立即數：LOAD / I-type ALU / JALR
            OPC_LOAD,
            OPC_ITYPE,
            OPC_JALR:  imm = imm_i;

            // S-type：STORE
            OPC_STORE: imm = imm_s;

            // B-type：BRANCH
            OPC_BRANCH: imm = imm_b;

            // U-type：LUI / AUIPC
            OPC_LUI,
            OPC_AUIPC: imm = imm_u;

            // J-type：JAL
            OPC_JAL:   imm = imm_j;

            default:   imm = 32'b0;
        endcase
    end

endmodule
