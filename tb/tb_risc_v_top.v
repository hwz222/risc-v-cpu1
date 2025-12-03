`timescale 1ns/1ps

module tb_risc_v_top;

    // =======================
    // Testbench signals
    // =======================
    reg         clk;
    reg         rst_n;

    // Instruction memory interface
    wire [31:0] Instruction;
    wire [31:0] InstrAddr;

    // Data memory interface
    reg  [31:0] RD;
    wire [31:0] Addr;
    wire [31:0] WD;
    wire        WE;
    wire [3:0]  Strobe;

    // =======================
    // DUT instance
    // =======================
    risc_v_top dut (
        .clk        (clk),
        .rst_n      (rst_n),

        .RD         (RD),
        .Addr       (Addr),
        .WD         (WD),
        .WE         (WE),
        .Strobe     (Strobe),

        .Instruction(Instruction),
        .InstrAddr  (InstrAddr)
    );

    // =======================
    // Clock generation
    // =======================
    initial clk = 1'b0;
    always #10 clk = ~clk;

    // =======================
    // Reset 序列
    // =======================
    initial begin
        rst_n = 1'b0;
        #25;
        rst_n = 1'b1;
    end

    // =======================
    // Instruction Memory
    // =======================
    // 256 words depth
    reg [31:0] imem [0:255];

    // Word Addressable mapping
    assign Instruction = imem[ InstrAddr[9:2] ];

    integer i;
    initial begin
        // 1. 先全部填滿 NOP (addi x0, x0, 0)
        for (i = 0; i < 256; i = i + 1) begin
            imem[i] = 32'h0000_0013;
        end

        // 2. 載入您的測試程式碼 (Machine Code)
        // 這些代碼對應到您之前的測試邏輯
        // imem[0]  = 32'hffff09b7; // lui s3, 0xffff0      (LED_ADDR Base)
        // imem[1]  = 32'h00000293; // li t0, 0
        // imem[2]  = 32'h00100313; // li t1, 1
        // imem[3]  = 32'h00a00393; // li t2, 10
        // imem[4]  = 32'h00200e13; // li t3, 2             (Used for comparison?)
        // imem[5]  = 32'h00628eb3; // add t4, t0, t1       (Fibonacci calculation?)
        // imem[6]  = 32'h006002b3; // add t0, x0, t1       (Move t1 to t0)
        // imem[7]  = 32'h01d00333; // add t1, x0, t4       (Move sum to t1)
        // imem[8]  = 32'h001e0e13; // addi t3, t3, 1       (Counter++)
        // imem[9]  = 32'hfe7e48e3; // blt t3, t2, -24      (Loop back)
        
        // // 檢查結果區段 (推測邏輯)
        // imem[10] = 32'h03700f13; // li t5, 55            (Expected result?)
        // imem[11] = 32'h01e31863; // bne t1, t5, +16      (If fail, jump to fail)
        
        // // PASS 區段
        // imem[12] = 32'h00100f93; // li t6, 1             (Success Code)
        // imem[13] = 32'h01f9a023; // sw t6, 0(s3)         (Write 1 to LED_ADDR)
        // imem[14] = 32'hff9ff06f; // j -8                 (Infinite Loop PASS)
        
        // // FAIL 區段
        // imem[15] = 32'h00200f93; // li t6, 2             (Fail Code)
        // imem[16] = 32'h01f9a023; // sw t6, 0(s3)         (Write 2 to LED_ADDR)
        // imem[17] = 32'hff9ff06f; // j -8                 (Infinite Loop FAIL)
        $readmemh("instr_mem.hex", imem);
    end

    // =======================
    // Data Memory Stub
    // =======================
    reg [31:0] dmem [0:255];

    always @(*) begin
        // 簡單的讀取保護，避免讀到未定義的空間
        RD = dmem[ Addr[9:2] ];
    end

    always @(posedge clk) begin
        if (WE) begin
            // 寫入一般記憶體 (如果是正常範圍)
            if (Addr < 32'h0000_0400) begin
                if (Strobe == 4'b1111) dmem[ Addr[9:2] ] <= WD;
            end
        end
    end

    // =======================
    // 監控 LED_ADDR (0xFFFF0000) 的寫入
    // =======================
    // 因為您的程式碼是用 sw 寫入 0xFFFF0000 來回報 Pass/Fail
    always @(posedge clk) begin
        if (rst_n && WE && (Addr == 32'hFFFF_0000)) begin
            if (WD == 32'd1) begin
                $display("\n[TESTBENCH] ===================================");
                $display("[TESTBENCH] Write to LED_ADDR detected: 0x%h", WD);
                $display("[TESTBENCH] Simulation Result: PASS !!!");
                $display("[TESTBENCH] ===================================\n");
                $finish; // 測試通過，結束模擬
            end else begin
                $display("\n[TESTBENCH] ===================================");
                $display("[TESTBENCH] Write to LED_ADDR detected: 0x%h", WD);
                $display("[TESTBENCH] Simulation Result: FAIL !!!");
                $display("[TESTBENCH] ===================================\n");
                $finish; // 測試失敗，結束模擬
            end
        end
    end

    // =======================
    // 監看訊號 & Timeout
    // =======================
    initial begin
        $display("Time    PC        Instr       RegWE RegWA RegWD      MemWE MemAddr    MemWD");
        $monitor("%4t    %h  %h    %b     %0d     %h   %b     %h   %h",
                 $time, dut.pc, Instruction,
                 dut.RegWE, dut.RegWA, dut.RegWD,
                 WE, Addr, WD);

        // 設定一個足夠長的 Timeout，避免死無窮迴圈
        #5000;
        $display("\n[TESTBENCH] Simulation Timeout! No write to LED_ADDR detected.");
        $finish;
    end

endmodule