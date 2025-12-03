module riscv_system(
    input wire clk_50Mhz,
    input wire rst_n, 
    output reg [7:0] led
);



/* PLL IP */
wire clock;
pll	pll_inst (
	.inclk0 ( clk_50Mhz ),
	.c0 ( clock )
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

// memory-map
localparam LED_ADDR = 32'hFFFF_0000;

always @(posedge clock or negedge rst_n) begin
    if (!rst_n) begin
        led <= 8'd0;
    end else begin
        // 只要 CPU 做 store 且對到 0xFFFF0000 這個 word，就更新 LED
        if (WE && (DataAddr[31:2] == LED_ADDR[31:2])) begin
            led <= WD[7:0];    // 低 8 bits 控制 8 顆 LED
        end
    end
end

risc_v_top cpu(
    .clk(clock),
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
    .clk(clock),
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