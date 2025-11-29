module data_mem #(
    parameter DEPTH = 256
)(
    input  wire        clk,
    input  wire        we,
    input  wire [3:0]  strobe,
    input  wire [31:0] addr,   // byte address
    input  wire [31:0] wdata,
    output wire [31:0] rdata
);
    reg [31:0] mem [0:DEPTH-1];
    initial begin
        $readmemh("data_mem.hex", mem); 
    end

    wire [31:0] word_addr = addr[31:2];

    // synchronous write
    always @(posedge clk) begin
        if (we) begin
            if(strobe[0]) mem[word_addr][7:0] <= wdata[7:0];
            if(strobe[1]) mem[word_addr][15:8] <= wdata[15:8];
            if(strobe[2]) mem[word_addr][23:16] <= wdata[23:16];
            if(strobe[3]) mem[word_addr][31:24] <= wdata[31:24];
        end
    end

    // async read
    assign rdata = mem[word_addr];

    
endmodule
