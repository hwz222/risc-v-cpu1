module WriteBack (
    input  wire [1:0]  RegWriteSrc,   // 來源選擇
    input  wire [31:0] SrcALU,        // (例) ALU 結果
    input  wire [31:0] SrcMEM,        // (例) Memory 讀取資料
    input  wire [31:0] SrcPC,         // (例) PC+4 (for JAL / JALR)
    output reg  [31:0] RegWD          // 寫回 Register File 的資料
);

    always @* begin
        case (RegWriteSrc)
            2'b00: RegWD = SrcALU;    // ALU 結果寫回 (R-type, I-type 等)
            2'b01: RegWD = SrcMEM;    // Memory load (LW、LH、LB)
            2'b10: RegWD = SrcPC + 3'd4;     // JAL / JALR 回填 return address
            default: RegWD = 32'b0;   // 非法狀態（可當 NOP）
        endcase
    end

endmodule
