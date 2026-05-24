
`timescale 1ns/1ps

`include "apb_defs.svh"
`include "soc_memory_map.svh"

//========================================================
// TESTBENCH NAME : tb_apb_subsystem
//========================================================
// DESCRIPTION :
// -------------------------------------------------------
// Testbench for APB subsystem verification.
//
// PURPOSE:
// -------------------------------------------------------
// - Verifies APB decoder routing
// - Verifies GPIO peripheral access
// - Verifies UART stub access
// - Verifies SPI stub access
// - Verifies PRDATA muxing
//
// TESTCASES:
// -------------------------------------------------------
// TEST1 : GPIO ACCESS
// TEST2 : UART ACCESS
// TEST3 : SPI ACCESS
// TEST4 : INVALID ADDRESS ACCESS
//
// NOTES:
// -------------------------------------------------------
// - Direct APB master model
// - Shared APB subsystem verification
//========================================================

module tb_apb_subsystem;

    //====================================================
    // GLOBAL SIGNALS
    //====================================================
    reg PCLK;
    reg PRESETn;

    //====================================================
    // APB INTERFACE
    //====================================================
    reg                         PSEL;
    reg                         PENABLE;
    reg                         PWRITE;

    reg  [`APB_ADDR_WIDTH-1:0] PADDR;
    reg  [`APB_DATA_WIDTH-1:0] PWDATA;

    wire [`APB_DATA_WIDTH-1:0] PRDATA;
    wire                       PREADY;

    //====================================================
    // GPIO SIGNALS
    //====================================================
    reg  [7:0] gpio_in;

    wire [7:0] gpio_out;
    wire [7:0] gpio_dir;

    //====================================================
    // REFERENCE MODEL
    //====================================================
    reg [31:0] expected;

    //====================================================
    // DUT
    //====================================================
    apb_subsystem dut (

        .PCLK      (PCLK),
        .PRESETn   (PRESETn),

        .PSEL      (PSEL),
        .PENABLE   (PENABLE),
        .PWRITE    (PWRITE),

        .PADDR     (PADDR),
        .PWDATA    (PWDATA),

        .PRDATA    (PRDATA),
        .PREADY    (PREADY),

        .gpio_in   (gpio_in),

        .gpio_out  (gpio_out),
        .gpio_dir  (gpio_dir)
    );

    //====================================================
    // CLOCK GENERATION
    //====================================================
    initial begin

        PCLK = 0;

        forever #5 PCLK = ~PCLK;

    end

    //====================================================
    // APB WRITE TASK
    //====================================================
    task apb_write;

        input [31:0] addr;
        input [31:0] data;

        begin

            @(posedge PCLK);

            PADDR   <= addr;
            PWDATA  <= data;

            PWRITE  <= 1'b1;

            PSEL    <= 1'b1;
            PENABLE <= 1'b0;

            @(posedge PCLK);

            PENABLE <= 1'b1;

            wait(PREADY);

            @(posedge PCLK);

            PSEL    <= 1'b0;
            PENABLE <= 1'b0;
            PWRITE  <= 1'b0;

            $display("[TB][WRITE] TIME=%0t ADDR=0x%0h DATA=0x%0h",
                     $time,
                     addr,
                     data);

        end

    endtask

    //====================================================
    // APB READ TASK
    //====================================================
    task apb_read;

        input [31:0] addr;

        begin

            @(posedge PCLK);

            PADDR   <= addr;

            PWRITE  <= 1'b0;

            PSEL    <= 1'b1;
            PENABLE <= 1'b0;

            @(posedge PCLK);

            PENABLE <= 1'b1;

            wait(PREADY);

            @(posedge PCLK);

            $display("[TB][READ] TIME=%0t ADDR=0x%0h DATA=0x%0h",
                     $time,
                     addr,
                     PRDATA);

            PSEL    <= 1'b0;
            PENABLE <= 1'b0;

        end

    endtask

    //====================================================
    // CHECK TASK
    //====================================================
    task check;

        input [31:0] exp;

        begin

            expected = exp;

            if (PRDATA === expected) begin

                $display("[TB][CHECK_PASS] TIME=%0t EXPECTED=0x%0h ACTUAL=0x%0h",
                         $time,
                         expected,
                         PRDATA);

            end

            else begin

                $display("[TB][CHECK_FAIL] TIME=%0t EXPECTED=0x%0h ACTUAL=0x%0h",
                         $time,
                         expected,
                         PRDATA);

            end

        end

    endtask

    //====================================================
    // MAIN TEST
    //====================================================
    initial begin

        //================================================
        // INITIALIZATION
        //================================================
        PSEL     = 0;
        PENABLE  = 0;
        PWRITE   = 0;

        PADDR    = 0;
        PWDATA   = 0;

        gpio_in  = 0;

        //================================================
        // RESET
        //================================================
        PRESETn = 0;

        repeat(5) @(posedge PCLK);

        PRESETn = 1;

        $display("\n=======================================");
        $display(" APB SUBSYSTEM TEST START ");
        $display("=======================================\n");

        //================================================
        // TEST1 : GPIO ACCESS
        //================================================
        $display("[TEST1] GPIO ACCESS");

        apb_write(`GPIO_BASE_ADDR + 32'h04,
                  32'h000000FF);

        apb_write(`GPIO_BASE_ADDR + 32'h00,
                  32'h000000A5);

        #10;

        if (gpio_out === 8'hA5) begin

            $display("[TB][GPIO_PASS] TIME=%0t GPIO_OUT=0x%0h",
                     $time,
                     gpio_out);

        end

        else begin

            $display("[TB][GPIO_FAIL] TIME=%0t GPIO_OUT=0x%0h",
                     $time,
                     gpio_out);

        end

        apb_read(`GPIO_BASE_ADDR + 32'h00);

        check(32'h000000A5);

        //================================================
        // TEST2 : UART ACCESS
        //================================================
        $display("\n[TEST2] UART ACCESS");

        apb_write(`UART_BASE_ADDR + 32'h00,
                  32'h12345678);

        apb_read(`UART_BASE_ADDR + 32'h04);

        check(32'hABCD1234);

        //================================================
        // TEST3 : SPI ACCESS
        //================================================
        $display("\n[TEST3] SPI ACCESS");

        apb_write(`SPI_BASE_ADDR + 32'h00,
                  32'hCAFEBABE);

        apb_read(`SPI_BASE_ADDR + 32'h04);

        check(32'h55AA55AA);

        //================================================
        // TEST4 : INVALID ADDRESS
        //================================================
        $display("\n[TEST4] INVALID ADDRESS");

        apb_read(32'h20000000);

        check(32'hDEADBEEF);

        $display("\n=======================================");
        $display(" APB SUBSYSTEM TEST END ");
        $display("=======================================\n");

        #20;

        $finish;

    end

    //====================================================
    // WAVE DUMP
    //====================================================
    initial begin

        $vcdplusfile("../waves/apb_subsystem.vpd");
        $vcdpluson;

    end

endmodule

