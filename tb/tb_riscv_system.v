`timescale 1ns/1ps

module tb_riscv_system;

    // =========================================
    // Testbench 端訊號
    // =========================================
    reg        clock;
    reg        rst_n;
    wire [7:0] led;

    // =========================================
    // DUT (Device Under Test)
    // =========================================
    riscv_system dut (
        .clock (clock),
        .rst_n (rst_n),
        .led   (led)
    );

    // =========================================
    // Clock 產生：20 ns period (50 MHz)
    // =========================================
    initial begin
        clock = 1'b0;
    end

    always #10 clock = ~clock;  // 10 ns high + 10 ns low = 20 ns

    // =========================================
    // Reset 產生
    // 先 reset 幾個 cycle，再釋放
    // =========================================
    initial begin
        rst_n = 1'b0;
        // 等待幾個 clock edge，確保所有東西 reset 到位
        repeat (5) @(posedge clock);
        rst_n = 1'b1;
    end

    // =========================================
    // (選配) 初始化 Instruction Memory
    // 這段要配合你的 instr_mem 實作
    // =========================================
    initial begin
        // 如果你的 instr_mem 裡面有像這樣：
        //   reg [31:0] mem [0:1023];
        // 可以這樣初始化：
        //
        // $readmemh("prog.hex", dut.IM.mem);
        //
        // 若名稱不是 mem / IM，自行改成對應名稱。

        // 示意：先等 reset 開始，再做初始化（實際上可以直接 init）
        // #1;  // 視需要加一點時間
        // $readmemh("prog.hex", dut.IM.mem);
    end

    // =========================================
    // 監看 LED 與模擬結束條件
    // =========================================
    integer cycle_cnt;

    initial begin
        cycle_cnt = 0;

        // 如果用 ModelSim/Questa，也可以關掉這段 $dump*
        //`ifdef VCD
        //    $dumpfile("riscv_system_tb.vcd");
        //    $dumpvars(0, tb_riscv_system);
        //`endif

        // 等待 reset 解除
        @(posedge rst_n);
        $display("[%0t] Reset deasserted, start running...", $time);

        // 主 loop：最多跑 2000 個 cycle
        while (cycle_cnt < 2000) begin
            @(posedge clock);
            cycle_cnt = cycle_cnt + 1;

            // 顯示 LED 變化
            $display("[%0t] cycle=%0d, led = 0x%02h", $time, cycle_cnt, led);

            // 如果你有寫測試程式：把 LED 寫成 0xAA 當作成功
            if (led == 8'hAA) begin
                $display("[%0t] *** TEST PASS: LED = 0x%02h ***", $time, led);
                #20;
                $finish;
            end
        end

        $display("[%0t] *** TIMEOUT: LED never reached expected value ***", $time);
        $finish;
    end

endmodule
