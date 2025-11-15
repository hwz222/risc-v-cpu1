// 支援 RV32I 的 LB / LBU / LH / LHU / LW 以及 SB / SH / SW
module MemoryControl (
    // From Execute module result
    input  wire [31:0] MemAddr,   // byte address
    // From Regfile RD (rs2：store 的資料)
    input  wire [31:0] Reg2RD,
    // From Instruction (funct3)
    input  wire [2:0]  Funct3,
    // From Instruction Decoder
    input  wire        MemoryRE,  // load enable
    input  wire        MemoryWE,  // store enable

    /* Memory Communication (連到 data_mem) */
    input  wire [31:0] RD,        // data_mem.rdata
    output wire [31:0] Addr,      // data_mem.addr
    output wire [31:0] WD,        // data_mem.wdata
    output wire        WE,        // data_mem.we
    output wire [3:0]  Strobe,    // data_mem.strobe

    // To WriteBack module (load 完成的資料)
    output wire [31:0] MemoryRD
);

    // 直接把位址丟給 data_mem
    assign Addr = MemAddr;

    // =============== 寫入側 (store) ===============
    reg [31:0] wd_reg;
    reg [3:0]  strobe_reg;

    always @* begin
        wd_reg     = 32'b0;
        strobe_reg = 4'b0000;

        if (MemoryWE) begin
            case (Funct3)
                3'b000: begin // SB
                    // 選哪個 byte
                    strobe_reg = 4'b0001 << MemAddr[1:0];
                    // 將欲寫入的 byte 放到對應位置
                    wd_reg = Reg2RD << (8 * MemAddr[1:0]);
                end
                3'b001: begin // SH
                    // 低 halfword or 高 halfword
                    strobe_reg = MemAddr[1] ? 4'b1100 : 4'b0011;
                    wd_reg = Reg2RD << (16 * MemAddr[1]);
                end
                3'b010: begin // SW
                    strobe_reg = 4'b1111;
                    wd_reg = Reg2RD;
                end
                default: begin
                    strobe_reg = 4'b0000;
                    wd_reg     = 32'b0;
                end
            endcase
        end
    end

    assign WE     = MemoryWE;
    assign WD     = wd_reg;
    assign Strobe = strobe_reg;

    // =============== 讀取側 (load) ===============
    wire [7:0]  sel_byte;
    wire [15:0] sel_half;
    reg  [31:0] memrd_reg;

    // 根據 addr[1:0] 選出 byte / halfword
    assign sel_byte = RD >> (8 * MemAddr[1:0]);
    assign sel_half = MemAddr[1] ? RD[31:16] : RD[15:0];

    always @* begin
        memrd_reg = 32'b0;

        if (MemoryRE) begin
            case (Funct3)
                3'b000: begin // LB
                    memrd_reg = {{24{sel_byte[7]}}, sel_byte};
                end
                3'b100: begin // LBU
                    memrd_reg = {24'b0, sel_byte};
                end
                3'b001: begin // LH
                    memrd_reg = {{16{sel_half[15]}}, sel_half};
                end
                3'b101: begin // LHU
                    memrd_reg = {16'b0, sel_half};
                end
                3'b010: begin // LW
                    memrd_reg = RD; // 假設 word 對齊
                end
                default: begin
                    memrd_reg = 32'b0;
                end
            endcase
        end
    end

    assign MemoryRD = memrd_reg;

endmodule
