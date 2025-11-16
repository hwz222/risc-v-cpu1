module InstructionFetch #(
    parameter PC_RESET_ADDR = 32'h0000_0000,
    parameter IMEM_DEPTH = 256
)(
    input wire clk,
    input wire rst_n,
    
    // instruction addr
    input wire JumpFlag,
    input wire [31:0] JumpAddr,
    
    output reg [31:0] pc,
    output wire [31:0] instruction
);


    /* Update pc */
    wire [31:0] pc_next = JumpFlag ? JumpAddr : pc + 32'd4; 

    always @(posedge clk) begin
        if (!rst_n) begin
            pc <= PC_RESET_ADDR;
        end else begin
            pc <= pc_next;
        end
    end

    /* Get instruction from instruction memory */
    instr_mem instr_mem_inst(
        .addr  (pc),
        .instr (instruction)
    );

endmodule