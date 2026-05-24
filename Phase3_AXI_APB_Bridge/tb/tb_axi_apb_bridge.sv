
`timescale 1ns/1ps

`include "axi_defs.svh"
`include "apb_defs.svh"
`include "soc_memory_map.svh"

//========================================================
// TESTBENCH NAME : tb_axi_apb_bridge
//========================================================
// DESCRIPTION :
// -------------------------------------------------------
// Testbench for AXI->APB bridge verification.
//
// PURPOSE:
// -------------------------------------------------------
// - Verifies AXI to APB protocol conversion
// - Verifies APB GPIO accesses through bridge
// - Verifies read/write path
//
// TESTCASES:
// -------------------------------------------------------
// TEST1 : GPIO OUTPUT MODE
// TEST2 : GPIO INPUT MODE
//
// NOTES:
// -------------------------------------------------------
// - AXI4-Lite master model
// - APB GPIO peripheral connected
// - Directed verification
//========================================================

module tb_axi_apb_bridge;

    //====================================================
    // CLOCK / RESET
    //====================================================
    reg ACLK;
    reg ARESETn;

    //====================================================
    // AXI INTERFACE
    //====================================================

    // WRITE ADDRESS
    reg  [`AXI_ADDR_WIDTH-1:0] AWADDR;
    reg                         AWVALID;
    wire                        AWREADY;

    // WRITE DATA
    reg  [`AXI_DATA_WIDTH-1:0] WDATA;
    reg  [`AXI_STRB_WIDTH-1:0] WSTRB;
    reg                         WVALID;
    wire                        WREADY;

    // WRITE RESPONSE
    wire [1:0]                 BRESP;
    wire                        BVALID;
    reg                         BREADY;

    // READ ADDRESS
    reg  [`AXI_ADDR_WIDTH-1:0] ARADDR;
    reg                         ARVALID;
    wire                        ARREADY;

    // READ DATA
    wire [`AXI_DATA_WIDTH-1:0] RDATA;
    wire [1:0]                 RRESP;
    wire                        RVALID;
    reg                         RREADY;

    //====================================================
    // APB INTERFACE
    //====================================================
    wire [`APB_ADDR_WIDTH-1:0] PADDR;
    wire [`APB_DATA_WIDTH-1:0] PWDATA;

    wire PSEL;
    wire PENABLE;
    wire PWRITE;

    wire [`APB_DATA_WIDTH-1:0] PRDATA;
    wire PREADY;

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
    // DUT : AXI->APB BRIDGE
    //====================================================
    axi_apb_bridge dut (

        .ACLK      (ACLK),
        .ARESETn   (ARESETn),

        .AWADDR    (AWADDR),
        .AWVALID   (AWVALID),
        .AWREADY   (AWREADY),

        .WDATA     (WDATA),
        .WSTRB     (WSTRB),
        .WVALID    (WVALID),
        .WREADY    (WREADY),

        .BRESP     (BRESP),
        .BVALID    (BVALID),
        .BREADY    (BREADY),

        .ARADDR    (ARADDR),
        .ARVALID   (ARVALID),
        .ARREADY   (ARREADY),

        .RDATA     (RDATA),
        .RRESP     (RRESP),
        .RVALID    (RVALID),
        .RREADY    (RREADY),

        .PADDR     (PADDR),
        .PWDATA    (PWDATA),

        .PSEL      (PSEL),
        .PENABLE   (PENABLE),
        .PWRITE    (PWRITE),

        .PRDATA    (PRDATA),
        .PREADY    (PREADY)
    );

    //====================================================
    // APB GPIO INSTANCE
    //====================================================
    apb_gpio gpio (

        .PCLK      (ACLK),
        .PRESETn   (ARESETn),

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

        ACLK = 0;

        forever #5 ACLK = ~ACLK;

    end

    //====================================================
    // AXI WRITE TASK
    //====================================================
    task axi_write;

        input [`AXI_ADDR_WIDTH-1:0] addr;
        input [`AXI_DATA_WIDTH-1:0] data;

        begin

            @(posedge ACLK);

            AWADDR  <= addr;
            AWVALID <= 1'b1;

            WDATA   <= data;
            WSTRB   <= 4'b1111;
            WVALID  <= 1'b1;

            wait (AWREADY && WREADY);

            @(posedge ACLK);

            AWVALID <= 1'b0;
            WVALID  <= 1'b0;

            BREADY <= 1'b1;

            wait (BVALID);

            @(posedge ACLK);

            BREADY <= 1'b0;

            $display("[TB][WRITE] TIME=%0t ADDR=0x%0h DATA=0x%0h",
                     $time,
                     addr,
                     data);

        end

    endtask

    //====================================================
    // AXI READ TASK
    //====================================================
    task axi_read;

        input [`AXI_ADDR_WIDTH-1:0] addr;

        begin

            @(posedge ACLK);

            ARADDR  <= addr;
            ARVALID <= 1'b1;

            wait (ARREADY);

            @(posedge ACLK);

            ARVALID <= 1'b0;

            RREADY <= 1'b1;

            wait (RVALID);

            @(posedge ACLK);

            RREADY <= 1'b0;

            $display("[TB][READ] TIME=%0t ADDR=0x%0h DATA=0x%0h",
                     $time,
                     addr,
                     RDATA);

        end

    endtask

    //====================================================
    // CHECK TASK
    //====================================================
    task check;

        input [31:0] exp;

        begin

            expected = exp;

            if (RDATA === expected) begin

                $display("[TB][CHECK_PASS] TIME=%0t EXPECTED=0x%0h ACTUAL=0x%0h",
                         $time,
                         expected,
                         RDATA);

            end

            else begin

                $display("[TB][CHECK_FAIL] TIME=%0t EXPECTED=0x%0h ACTUAL=0x%0h",
                         $time,
                         expected,
                         RDATA);

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
        AWADDR   = 0;
        AWVALID  = 0;

        WDATA    = 0;
        WSTRB    = 0;
        WVALID   = 0;

        BREADY   = 0;

        ARADDR   = 0;
        ARVALID  = 0;

        RREADY   = 0;

        gpio_in  = 0;

        //================================================
        // RESET
        //================================================
        ARESETn = 0;

        repeat(5) @(posedge ACLK);

        ARESETn = 1;

        $display("\n=======================================");
        $display(" AXI -> APB BRIDGE TEST START ");
        $display("=======================================\n");

        //================================================
        // TEST1 : GPIO OUTPUT MODE
        //================================================
        $display("[TEST1] GPIO OUTPUT MODE");

        // GPIO_DIR = OUTPUT
        axi_write(`GPIO_BASE_ADDR + 32'h04,
                  32'h000000FF);

        // GPIO_DATA = A5
        axi_write(`GPIO_BASE_ADDR + 32'h00,
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

        axi_read(`GPIO_BASE_ADDR + 32'h00);

        check(32'h000000A5);

        //================================================
        // TEST2 : GPIO INPUT MODE
        //================================================
        $display("\n[TEST2] GPIO INPUT MODE");

        // GPIO_DIR = INPUT
        axi_write(`GPIO_BASE_ADDR + 32'h04,
                  32'h00000000);

        gpio_in = 8'h3C;

        repeat(2) @(posedge ACLK);

        axi_read(`GPIO_BASE_ADDR + 32'h00);

        check(32'h0000003C);

        $display("\n=======================================");
        $display(" AXI -> APB BRIDGE TEST END ");
        $display("=======================================\n");

        #20;

        $finish;

    end

    //====================================================
    // WAVE DUMP
    //====================================================
    initial begin

        $vcdplusfile("../waves/axi_apb_bridge.vpd");
        $vcdpluson;

    end

endmodule

