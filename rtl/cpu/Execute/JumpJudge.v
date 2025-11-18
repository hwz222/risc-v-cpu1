`include "rv32i_defs.vh"

module JumpJudge(
    input  wire [6:0]  Opcode,   // 接 instruction[6:0]
    input  wire [2:0]  Funct3,   // instruction[14:12]
    input  wire [31:0] Reg1RD,   // rs1
    input  wire [31:0] Reg2RD,   // rs2

    output wire        JumpFlag  // 這個 cycle 要不要跳
);

    // -------- 基本類型判斷 --------
    wire is_jal    = (Opcode == `OPC_JAL);
    wire is_jalr   = (Opcode == `OPC_JALR);
    wire is_branch = (Opcode == `OPC_BRANCH);

    // -------- branch 條件判斷 --------
    reg branch_taken;

    always @* begin
        branch_taken = 1'b0;

        if (is_branch) begin
            case (Funct3)
                3'b000: branch_taken = (Reg1RD == Reg2RD);                       // BEQ
                3'b001: branch_taken = (Reg1RD != Reg2RD);                       // BNE
                3'b100: branch_taken = ($signed(Reg1RD) <  $signed(Reg2RD));     // BLT
                3'b101: branch_taken = ($signed(Reg1RD) >= $signed(Reg2RD));     // BGE
                3'b110: branch_taken = (Reg1RD <  Reg2RD);                       // BLTU
                3'b111: branch_taken = (Reg1RD >= Reg2RD);                       // BGEU
                default: branch_taken = 1'b0;
            endcase
        end
    end

    // -------- 最終 JumpFlag --------
    // JAL / JALR：無條件跳
    // B-type：依 branch_taken 決定
    // 其他（LUI / AUIPC / Load / Store / I / R ...）：不跳
    assign JumpFlag = is_jal | is_jalr | branch_taken;

endmodule