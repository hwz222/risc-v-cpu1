module riscv-1 (
    input wire clk,
    input wire rst_n,




);
    InstructionFetch IF_inst(
        .clk(),
        .rst_n(),

        .JumpFlag(),
        .JumpAddr(),
        .pc()
    );

    /* read only */
    instr_mem instr_mem_inst(
        .addr(),
        .instr(),
    );

    rv32i_regfile regfile_isnt(
        .clk(),
        .rst_n(),
        .RegWE(),
        .RegWA(),
        .RegWA(),
        .Reg1RA(),
        .Reg1RD(),
        .Reg2RA(),
        .Reg2RD()
    );

    InstructionDecoder ID_inst(
        // input 
        .instruction(),
        
        // To Register file
        .Reg1RA(),
        .Reg2RA(),
        .RegWE(),
        .RegWA(),

        // To Execute module
        .ALUOp1Src(),
        .ALUOp2Src(),
        .Imm(),

        // To WriteBack module
        .RegWriteSrc(),

        // To Memory Control module
        .MemoryRE(),
        .MemoryWE()
    );

    MemoryControl MemControl_inst(
        // From Execute module result
        .MemAddr(),
        
        // From Regfile RD
        .Reg2RD(),
        
        // From Instruction (memroy)
        .Funct3(),

        // From Instruction Decoder
        .MemoryRE(),
        .MemoryWE(),
        
        // To Write Back
        .MemoryRD()

        /* Memory Communication */
        // input
        .RD()
        // output
        .Addr(),
        .WD(),
        .WE(),
        .Strobe()
    );

    Execute Execute_isnt(
        .pc(),
        .instruction(),
        .ALUOp1Src(), 
        .Reg1RD(),
        .ALUOp2Src(),
        .Reg2RD(),
        .Imm(),
        .ALUresult(),
        .JumpFlag()

    );

    WriteBack WriteBack_isnt(
        .RegWriteSrc(),
        .SrcALU(),
        .SrcMEM(),
        .SrcPC(),
        .RegWD()
    );

endmodule