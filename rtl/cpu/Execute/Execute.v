module Execute(
    input wire [31:0] instruction,
    
    input wire ALUOp1Src,
    input wire [31:0] Reg1RD,
    input wire [31:0] pc,
    
    input wire ALUOp2Src,
    input wire [31:0] Reg2RD,
    input wire [31:0] Imm,

    output wire [31:0] ALUresult,
    output wire JumpFlag
);

    /*========== 拆解 instruction 欄位 ===========*/
    wire [6:0] Opcode = instruction[6:0];
    wire [2:0] Funct3 = instruction[14:12];
    wire [6:0] Funct7 = instruction[31:25];

    /*=========== 功能模組間的連線 ==============*/
    wire [3:0] ALUFunct;
    wire [31:0] data1, data2;

    /*============ 功能模組 =====================*/
    ALUControl ALU_control_inst(
        .Opcode(Opcode),
        .Funct3(Funct3),
        .Funct7(Funct7),
        .ALUFunct(ALUFunct)
    );

    assign data1 = ALUOp1Src ? pc : Reg1RD;
    assign data2 = ALUOp2Src ? Imm : Reg2RD;
    ALU ALU_inst(
        .ALUFunct(ALUFunct),
        .data1(data1),
        .data2(data2),
        .ALUresult(ALUresult)
    );

    JumpJudge JumpJudge_inst(
        .Opcode(Opcode),
        .Funct3(Funct3),
        .Reg1RD(Reg1RD),
        .Reg2RD(Reg2RD),
        .JumpFlag(JumpFlag)
    );

endmodule