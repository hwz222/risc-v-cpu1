module ImmGen(
    input  wire [31:0] instr,
    output reg  [31:0] imm
);

    wire [6:0] opcode = instr[6:0];

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
            7'b0000011,  // LOAD (I)
            7'b0010011,  // I-type ALU
            7'b1100111: imm = imm_i;  // JALR

            7'b0100011: imm = imm_s;  // STORE (S)
            7'b1100011: imm = imm_b;  // BRANCH (B)
            7'b0110111,
            7'b0010111: imm = imm_u;  // LUI / AUIPC (U)
            7'b1101111: imm = imm_j;  // JAL (J)
            default:    imm = 32'b0;
        endcase
    end

endmodule
