// enc2stepper_tb.sv
// Testbench for stepper motor driver module (active-low button simulation)

`timescale 1ns/1ps

module enc2stepper_tb;

    // Clock and DUT inputs/outputs
    logic clk;
    logic s1, s2;                 // Active-low buttons
    logic red, green, blue;
    logic dir, step;

    // Instantiate DUT with fast simulation parameters
    enc2stepper #(
        .NUM_STEPS(3),         // Only 3 steps per move
        .PULSE_LENGTH(10)      // 10 * 20ns = 200ns pulse segments
    ) dut (
        .CLOCK_50(clk),
        .s1(s1),
        .s2(s2),
        .red(red),
        .green(green),
        .blue(blue),
        .dir(dir),
        .step(step)
    );

    // Clock generation: 50 MHz = 20 ns period
    always #10 clk = ~clk;

    // === Task: Simulate an active-low button press ===
    task automatic press_button(input logic is_s1, input int cycles = 2);
    begin
        @(negedge clk);
        if (is_s1) s1 = 0; else s2 = 0; // Press (active-low)
        repeat (cycles - 1) @(negedge clk);
        if (is_s1) s1 = 1; else s2 = 1; // Release
    end
    endtask

    // === Test Sequence ===
    initial begin
        $display("Starting enc2stepper testbench...");
        clk = 0;
        s1  = 1; // Released
        s2  = 1; // Released

        // Wait for startup
        repeat (10) @(negedge clk);

        // 1. CW short press
        $display("== CW Short Press ==");
        press_button(1);  // s1 pressed

        wait (dut.state == dut.READY);
        repeat (10) @(negedge clk);

        // 2. CCW short press
        $display("== CCW Short Press ==");
        press_button(0);  // s2 pressed

        wait (dut.state == dut.READY);
        repeat (10) @(negedge clk);

        // 3. CW held long
        $display("== CW Held Press ==");
        @(negedge clk); s1 = 0; // Hold s1 (active-low)
        repeat (80) @(negedge clk);  // Hold for 80 cycles
        s1 = 1; // Release

        wait (dut.state == dut.READY);
        repeat (10) @(negedge clk);

        // 4. CCW held, then CW pressed midway
        $display("== CCW Held + CW Midway ==");
        @(negedge clk); s2 = 0;       // Start CCW
        repeat (5) @(negedge clk);    // Hold
        s1 = 0;                        // Try CW mid-motion
        repeat (3) @(negedge clk);
        s1 = 1;                        // Release CW
        s2 = 1;                        // Release CCW

        wait (dut.state == dut.READY);
        repeat (50) @(negedge clk);

        $display("Testbench complete.");
        $stop;
    end

endmodule

