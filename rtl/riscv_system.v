module riscv_system(
    input wire clk,
    input wire rst_n
);

/*=========== 功能模組間的連線 ==============*/
// Data Memory Wires
wire [31:0] DataAddr;
wire [31:0] WD;
wire [31:0] RD;
wire WE;
wire [3:0] Strobe;

// Instruction Memroy Wires
wire [31:0] InstrAddr;
wire [31:0] Instruction;


risc_v_top cpu(
    .clk(clk),
    .rst_n(rst_n),

    .RD(RD),
    .Addr(DataAddr),
    .WD(WD),
    .WE(WE),
    .Strobe(Strobe),

    .Instruction(Instruction),
    .InstrAddr(InstrAddr)
);

data_mem DM(
    .clk(clk),
    .we(WE),
    .strobe(Strobe),
    .addr(DataAddr),
    .wdata(WD),
    .rdata(RD)
);

instr_mem IM(
    .addr(InstrAddr),
    .instr(Instruction)
);



endmodule