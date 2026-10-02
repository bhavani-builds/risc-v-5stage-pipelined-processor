`timescale 1ns/1ps

module pipeline_cpu_tb;

    reg clk;
    reg reset;

    integer errors;

    // ==========================================
    // DUT
    // ==========================================

    pipeline_cpu dut (
        .clk   (clk),
        .reset (reset)
    );


    // ==========================================
    // Clock
    // ==========================================

    initial begin

        clk = 1'b0;

        forever #5 clk = ~clk;

    end


    // ==========================================
    // Register Check Task
    // ==========================================

    task check_register;

        input [4:0]  register_number;
        input [31:0] expected_value;

        begin

            if (dut.registers.registers[register_number]
                !== expected_value) begin

                $display(
                    "FAIL: x%0d expected %0d, got %0d",
                    register_number,
                    expected_value,
                    dut.registers.registers[register_number]
                );

                errors = errors + 1;

            end

            else begin

                $display(
                    "PASS: x%0d = %0d",
                    register_number,
                    expected_value
                );

            end

        end

    endtask


    // ==========================================
    // Test
    // ==========================================

    initial begin

        errors = 0;

        // Waveform
        $dumpfile("pipeline_cpu.vcd");
        $dumpvars(0, pipeline_cpu_tb);

        // Reset
        reset = 1'b1;

        #20;

        reset = 1'b0;

        // Allow pipeline to fill and execute
        #200;

        $display("");
        $display("======================================");
        $display("5-STAGE RISC-V PIPELINE VERIFICATION");
        $display("======================================");

        // Expected results from program.hex
        //
        // ADDI x1, x0, 10
        // ADDI x2, x0, 20
        // ADD  x3, x1, x2
        // SUB  x4, x2, x1
        // AND  x5, x1, x2
        // OR   x6, x1, x2
        // XOR  x7, x1, x2

        check_register(5'd1, 32'd10);
        check_register(5'd2, 32'd20);
        check_register(5'd3, 32'd30);
        check_register(5'd4, 32'd10);
        check_register(5'd5, 32'd0);
        check_register(5'd6, 32'd30);
        check_register(5'd7, 32'd30);


        // ======================================
        // Final Result
        // ======================================

        if (errors == 0) begin

            $display("");
            $display("======================================");
            $display("ALL PIPELINE TESTS PASSED");
            $display("======================================");

        end

        else begin

            $display("");
            $display("======================================");
            $display("PIPELINE TEST FAILED");
            $display("ERRORS = %0d", errors);
            $display("======================================");

        end

        $finish;

    end

endmodule
