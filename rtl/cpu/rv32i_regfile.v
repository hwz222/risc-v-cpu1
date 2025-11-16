module rv32i_regfile(
    input  wire        clk,
    input  wire        rst_n,

    // write register
    input  wire        RegWE,
    input  wire [4:0]  RegWA,
    input  wire [31:0] RegWD,

    // read register
    input  wire [4:0]  Reg1RA,
    output wire [31:0] Reg1RD,

    input  wire [4:0]  Reg2RA,
    output wire [31:0] Reg2RD
);

    reg [31:0] regs [31:0];
    integer i;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (i = 0; i < 32; i = i + 1) begin
                regs[i] <= 32'b0;
            end
        end else if (RegWE && (RegWA != 5'd0)) begin
            regs[RegWA] <= RegWD;
        end
    end

    assign Reg1RD = (Reg1RA == 5'd0) ? 32'b0 : regs[Reg1RA];
    assign Reg2RD = (Reg2RA == 5'd0) ? 32'b0 : regs[Reg2RA];

endmodule
