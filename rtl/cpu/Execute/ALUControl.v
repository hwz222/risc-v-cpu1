`include "rv32i_defs.vh"

module ALUControl(
    input  wire [6:0] Opcode,   // 直接接 instruction[6:0]
    input  wire [2:0] Funct3,   // instr[14:12]
    input  wire [6:0] Funct7,   // instr[31:25]
    output reg  [3:0] ALUFunct  // 給 ALU 的 control code
);

    always @* begin
        // 預設：ADD（load/store/auipc/jump 的位址計算）
        ALUFunct = `ALU_ADD;

        case (Opcode)

            // ===============================
            // R-type (add, sub, and, or...)
            // ===============================
            `OPC_RTYPE: begin
                case (Funct3)
                    3'b000: begin
                        // ADD / SUB
                        if (Funct7 == 7'b0100000)
                            ALUFunct = `ALU_SUB;   // SUB
                        else
                            ALUFunct = `ALU_ADD;   // ADD
                    end
                    3'b001: ALUFunct = `ALU_SLL;   // SLL
                    3'b010: ALUFunct = `ALU_SLT;   // SLT
                    3'b011: ALUFunct = `ALU_SLTU;  // SLTU
                    3'b100: ALUFunct = `ALU_XOR;   // XOR
                    3'b101: begin                 // SRL / SRA
                        if (Funct7 == 7'b0100000)
                            ALUFunct = `ALU_SRA;   // SRA
                        else
                            ALUFunct = `ALU_SRL;   // SRL
                    end
                    3'b110: ALUFunct = `ALU_OR;    // OR
                    3'b111: ALUFunct = `ALU_AND;   // AND
                    default: ALUFunct = `ALU_ADD;
                endcase
            end

            // ===============================
            // I-type 算術 (addi/andi/ori/...)
            // ===============================
            `OPC_ITYPE: begin
                case (Funct3)
                    3'b000: ALUFunct = `ALU_ADD;   // ADDI
                    3'b010: ALUFunct = `ALU_SLT;   // SLTI
                    3'b011: ALUFunct = `ALU_SLTU;  // SLTIU
                    3'b100: ALUFunct = `ALU_XOR;   // XORI
                    3'b110: ALUFunct = `ALU_OR;    // ORI
                    3'b111: ALUFunct = `ALU_AND;   // ANDI
                    3'b001: ALUFunct = `ALU_SLL;   // SLLI
                    3'b101: begin                 // SRLI / SRAI
                        if (Funct7 == 7'b0100000)
                            ALUFunct = `ALU_SRA;   // SRAI
                        else
                            ALUFunct = `ALU_SRL;   // SRLI
                    end
                    default: ALUFunct = `ALU_ADD;
                endcase
            end

            // ===============================
            // Branch (BEQ/BNE/BLT/BGE/BLTU/BGEU)
            // ===============================
            `OPC_BRANCH: begin
                case (Funct3)
                    3'b000,
                    3'b001: ALUFunct = `ALU_SUB;   // BEQ/BNE 用 SUB
                    3'b100,
                    3'b101: ALUFunct = `ALU_SLT;   // BLT/BGE 用 signed SLT
                    3'b110,
                    3'b111: ALUFunct = `ALU_SLTU;  // BLTU/BGEU 用 unsigned SLTU
                    default: ALUFunct = `ALU_SUB;
                endcase
            end

            // ===============================
            // Load / Store / AUIPC / JAL / JALR / LUI
            // ===============================
            `OPC_LOAD,
            `OPC_STORE,
            `OPC_AUIPC,
            `OPC_JAL,
            `OPC_JALR,
            `OPC_LUI: begin
                ALUFunct = `ALU_ADD;
            end

            default: begin
                ALUFunct = `ALU_ADD;
            end

        endcase
    end

endmodule
