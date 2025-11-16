module riscv_v_top (
    input wire clk,
    input wire rst_n,

    // Data memory port 
    input wire [31:0] RD,
    output wire [31:0] Addr,
    output wire [31:0] WD,
    output wire WE,
    output wire [3:0] Strobe,

    // Instruction memory port
    input wire [31:0] Instruction,
    output wire [31:0] InstrAddr
);
    
    /*=========== 功能模組間的連線 ==============*/
    // register file
    wire [31:0] Reg1RD, Reg2RD;

    // Instruction Fetch 
    wire [31:0] pc;

    // Instruction Decode
    wire [4:0] Reg1RA, Reg2RA, RegWA;
    wire ALUOp1Src, ALUOp2Src;
    wire [31:0] Imm;
    wire [1:0] RegWriteSrc;
    wire RegWE;
    wire MemoryRE, MemoryWE;

    // Execute
    wire [31:0] ALUresult;
    wire JumpFlag;

    // Memory access
    wire [31:0] MemoryRD;
    wire [31:0] internal_Addr;      // data_mem.addr
    wire [31:0] internal_WD;       // data_mem.wdata
    wire        internal_WE;        // data_mem.we
    wire [3:0]  internal_Strobe;    // data_mem.strobe

    // Register Write back
    wire [31:0] RegWD;

    /*=========== Regfile ==============*/
    rv32i_regfile regfile(
        .clk(clk),
        .rst_n(rst_n),
        .RegWE(RegWE),
        .RegWA(RegWA),
        .RegWD(RegWD),
        .Reg1RA(Reg1RA),
        .Reg1RD(Reg1RD),
        .Reg2RA(Reg2RA),
        .Reg2RD(Reg2RD)
    );

    /*=========== 功能模組 ==============*/
    // Stage 1 : Instruction Fetch 
    InstructionFetch IF_inst(
        .clk(clk),
        .rst_n(rst_n),
        .JumpFlag(JumpFlag),
        .JumpAddr(ALUresult),
        .pc(pc)
    );
    assign InstrAddr = pc;

    // Stage 2 : Instruction Decode
    InstructionDecoder ID_inst(
        // input 
        .instruction(Instruction),
        
        // To Register file
        .Reg1RA(Reg1RA),
        .Reg2RA(Reg2RA),
        .RegWE(RegWE),
        .RegWA(RegWA),

        // To Execute module
        .ALUOp1Src(ALUOp1Src),
        .ALUOp2Src(ALUOp2Src),
        .Imm(Imm),

        // To WriteBack module
        .RegWriteSrc(RegWriteSrc),

        // To Memory Control module
        .MemoryRE(MemoryRE),
        .MemoryWE(MemoryWE)
    );

    // Stage 3 : Execute
    Execute Execute_isnt(
        .instruction(Instruction),

        // mux1
        .ALUOp1Src(ALUOp1Src),
        .Reg1RD(Reg1RD),
        .pc(pc),
        
        // mux2 
        .ALUOp2Src(ALUOp2Src),
        .Reg2RD(Reg2RD),
        .Imm(Imm),

        // output
        .ALUresult(ALUresult),
        .JumpFlag(JumpFlag)
    );

    // Stage 4 : Memory Access
    MemoryControl MemControl_inst(
        // From Execute module result
        .MemAddr(ALUresult),
        
        // From Regfile RD
        .Reg2RD(Reg2RD),
        
        // From Instruction (memroy)
        .Funct3(Instruction[14:12]),

        // From Instruction Decoder
        .MemoryRE(MemoryRE),
        .MemoryWE(MemoryWE),
        
        // To Write Back
        .MemoryRD(MemoryRD),

        /* Memory Communication */
        // input
        .RD(RD),
        // output
        .Addr(internal_Addr),
        .WD(internal_WD),
        .WE(internal_WE),
        .Strobe(internal_Strobe)
    );
    assign Addr = internal_Addr;
    assign WD = internal_WD;
    assign WE = internal_WE;
    assign Strobe = internal_Strobe;

    // Stage 5 : Write Back
    WriteBack WriteBack_isnt(
        .RegWriteSrc(RegWriteSrc),
        .SrcALU(ALUresult),
        .SrcMEM(MemoryRD),
        .SrcPC(pc),
        .RegWD(RegWD)
    );

endmodule