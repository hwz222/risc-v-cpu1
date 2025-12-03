`timescale 1ns/1ps

module tb_InstructionFetch;

    // === 測試用訊號 ===
    reg         clk;
    reg         rst_n;
    reg         JumpFlag;
    reg  [31:0] JumpAddr;
    wire [31:0] pc;

    // === DUT: 例化你的 InstructionFetch ===
    InstructionFetch #(
        .PC_RESET_ADDR(32'h0000_0000),
        .IMEM_DEPTH(256)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .JumpFlag(JumpFlag),
        .JumpAddr(JumpAddr),
        .pc(pc)
    );

    // === 產生 clock: 20ns 週期 (50 MHz) ===
    initial begin
        clk = 0;
        forever #10 clk = ~clk;  // 每 10ns 反相一次 → 20ns 一個週期
    end

    // === 測試流程 ===
    initial begin
        // 波形輸出 (使用 Icarus/GTKWave 可看)
        // $dumpfile("InstructionFetch_tb.vcd");
        // $dumpvars(0, InstructionFetch_tb);

        // 初始值
        rst_n    = 0;
        JumpFlag = 0;
        JumpAddr = 32'h0000_0000;

        // 先觀察幾個 clock 在 reset 期間
        $display("=== 上電 reset 階段 ===");
        repeat (3) @(posedge clk);  // 等 3 個正緣

        // 解除 reset
        $display("=== 解除 reset ===");
        rst_n = 1;

        // 觀察 PC 自動 +4 的情況
        $display("=== PC 自然遞增階段 ===");
        repeat (20) @(posedge clk);

        // 做一次 Jump 測試
        $display("=== Jump 測試：Jump 到 0x40 ===");
        JumpAddr = 32'h0000_0040;
        JumpFlag = 1;
        @(posedge clk);  // 下一個 clock，pc 應該會變成 0x40

        // 取消 JumpFlag，之後應該又是 +4
        JumpFlag = 0;
        $display("=== Jump 後繼續遞增 ===");
        repeat (20) @(posedge clk);

        $display("=== 測試結束 ===");
        $finish;
    end

    // === 方便觀察的 monitor ===
    initial begin
        $display("time    rst_n  JumpFlag  JumpAddr      pc");
        $monitor("%4t    %b      %b      %h   %h",
                 $time, rst_n, JumpFlag, JumpAddr, pc);
    end

endmodule
