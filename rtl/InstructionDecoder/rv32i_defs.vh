// Opcodes
localparam OPC_RTYPE  = 7'b0110011;
localparam OPC_ITYPE  = 7'b0010011;
localparam OPC_LOAD   = 7'b0000011;
localparam OPC_STORE  = 7'b0100011;
localparam OPC_BRANCH = 7'b1100011;
localparam OPC_LUI    = 7'b0110111;
localparam OPC_AUIPC  = 7'b0010111;
localparam OPC_JAL    = 7'b1101111;
localparam OPC_JALR   = 7'b1100111;

// ALU operations (給 ALUDecoder 用)
localparam ALUOP_ADD    = 3'b000;
localparam ALUOP_RTYPE  = 3'b001;
localparam ALUOP_ITYPE  = 3'b010;
localparam ALUOP_BRANCH = 3'b011;
localparam ALUOP_JUMP   = 3'b100;
localparam ALUOP_LUI    = 3'b101;
