`timescale 1ns/1ps

module tb_InstructionFetch;

    // DUT I/O
    reg         clk;
    reg         rst_n;
    reg         JumpFlag;
    reg  [31:0] JumpAddr;

    wire [31:0] pc;
    wire [31:0] instruction;

    // DUT
    InstructionFetch #(
        .PC_RESET_ADDR(32'h0000_0000),
        .IMEM_DEPTH   (256)
    ) dut (
        .clk        (clk),
        .rst_n      (rst_n),
        .JumpFlag   (JumpFlag),
        .JumpAddr   (JumpAddr),
        .pc         (pc),
        .instruction(instruction)
    );

    // 產生 clock：10ns 週期
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    // 主測試流程
    initial begin
        // 初始狀態
        rst_n    = 1'b0;        // 一開始先 reset
        JumpFlag = 1'b0;
        JumpAddr = 32'h0000_0000;

        // === 一開始的 reset（同步 reset 要吃到 clock）===
        @(posedge clk);         // 第一次 posedge，rst_n=0 → pc 被設成 PC_RESET_ADDR
        @(posedge clk);         // 第二次 posedge 前我們再把 reset 放開
        rst_n = 1'b1;
        $display("=== Release reset at T=%0t ===", $time);

        // === 讓 pc 正常跑幾個 cycle ===
        repeat (3) begin
            @(posedge clk);
            #1; // 等組合邏輯穩定
            $display("[Normal] T=%0t pc=%08h instr=%08h", $time, pc, instruction);
        end

        // 此時理論上 pc = 0x00000008（0,4,8 這樣跑）

        // === 中間拉 reset（mid reset）===
        $display("=== Assert mid-reset at T=%0t ===", $time);
        rst_n = 1'b0;           // 在下一個 posedge 之前先拉低

        @(posedge clk);         // 這個 posedge，因為 rst_n=0 → pc 被清回 PC_RESET_ADDR
        #1;
        $display("[During reset] T=%0t pc=%08h instr=%08h (expect pc=00000000, instr=第一條)",
                 $time, pc, instruction);

        // 放開 reset
        rst_n = 1'b1;
        $display("=== Release mid-reset at T=%0t ===", $time);

        // === reset 之後再觀察 pc 是否重新從 0,4,8... 開始 ===
        @(posedge clk);
        #1;
        $display("[After mid-reset] T=%0t pc=%08h instr=%08h (expect pc=00000000)",
                 $time, pc, instruction);

        @(posedge clk);
        #1;
        $display("[After mid-reset] T=%0t pc=%08h instr=%08h (expect pc=00000004)",
                 $time, pc, instruction);

        @(posedge clk);
        #1;
        $display("[After mid-reset] T=%0t pc=%08h instr=%08h (expect pc=00000008)",
                 $time, pc, instruction);

        #20;
        $finish;
    end

    // 若你用 iverilog/GTKWave，可以打 VCD 看波形
    initial begin
        $dumpfile("InstructionFetch.vcd");
        $dumpvars(0, tb_InstructionFetch);
    end

endmodule
