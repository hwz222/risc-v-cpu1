module instr_mem #(
    parameter DEPTH = 256
)(
    input  wire [31:0] addr,   // byte address
    output wire [31:0] instr
);
    // 用 reg 陣列描述 ROM
    reg [31:0] mem [0:DEPTH-1];

    // async read：addr 一變，instr 會經過 LUT delay 後跟著變
    assign instr = mem[addr[31:2]];  // word address = addr[31:2]
    initial begin
        $readmemh("instr_mem.hex", mem); 
    end

endmodule