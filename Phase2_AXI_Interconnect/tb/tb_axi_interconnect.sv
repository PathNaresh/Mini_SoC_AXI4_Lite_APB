
`timescale 1ns/1ps

`include "axi_defs.svh"
`include "soc_memory_map.svh"

//========================================================
// TESTBENCH NAME : tb_axi_interconnect
//========================================================
// DESCRIPTION :
// -------------------------------------------------------
// Testbench for AXI interconnect verification.
//
// PURPOSE:
// -------------------------------------------------------
// - Verifies AXI address decode
// - Verifies transaction routing
// - Verifies slave response muxing
//
// CONNECTED SLAVES:
// -------------------------------------------------------
// 1. AXI SRAM
// 2. AXI->APB Stub
//
// TESTCASES:
// -------------------------------------------------------
// TEST1 : SRAM write/read access
// TEST2 : APB stub read access
//
// NOTES:
// -------------------------------------------------------
// - AXI4-Lite only
// - Single master
// - Directed verification
//========================================================

module tb_axi_interconnect;

    //====================================================
    // CLOCK / RESET
    //====================================================
    reg ACLK;
    reg ARESETn;

    //====================================================
    // MASTER AXI SIGNALS
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
    // INTERCONNECT <-> SRAM
    //====================================================

    wire [`AXI_ADDR_WIDTH-1:0] s0_awaddr;
    wire                        s0_awvalid;
    wire                        s0_awready;

    wire [`AXI_DATA_WIDTH-1:0] s0_wdata;
    wire [`AXI_STRB_WIDTH-1:0] s0_wstrb;
    wire                        s0_wvalid;
    wire                        s0_wready;

    wire [1:0]                 s0_bresp;
    wire                        s0_bvalid;
    wire                        s0_bready;

    wire [`AXI_ADDR_WIDTH-1:0] s0_araddr;
    wire                        s0_arvalid;
    wire                        s0_arready;

    wire [`AXI_DATA_WIDTH-1:0] s0_rdata;
    wire [1:0]                 s0_rresp;
    wire                        s0_rvalid;
    wire                        s0_rready;

    //====================================================
    // INTERCONNECT <-> APB STUB
    //====================================================

    wire [`AXI_ADDR_WIDTH-1:0] s1_awaddr;
    wire                        s1_awvalid;
    wire                        s1_awready;

    wire [`AXI_DATA_WIDTH-1:0] s1_wdata;
    wire [`AXI_STRB_WIDTH-1:0] s1_wstrb;
    wire                        s1_wvalid;
    wire                        s1_wready;

    wire [1:0]                 s1_bresp;
    wire                        s1_bvalid;
    wire                        s1_bready;

    wire [`AXI_ADDR_WIDTH-1:0] s1_araddr;
    wire                        s1_arvalid;
    wire                        s1_arready;

    wire [`AXI_DATA_WIDTH-1:0] s1_rdata;
    wire [1:0]                 s1_rresp;
    wire                        s1_rvalid;
    wire                        s1_rready;

    //====================================================
    // REFERENCE MEMORY MODEL
    //====================================================
    reg [`AXI_DATA_WIDTH-1:0] ref_mem [0:255];

    reg [`AXI_DATA_WIDTH-1:0] expected;

    //====================================================
    // DUT : AXI INTERCONNECT
    //====================================================
    axi_interconnect dut (

        .ACLK       (ACLK),
        .ARESETn    (ARESETn),

        // MASTER SIDE
        .M_AWADDR   (AWADDR),
        .M_AWVALID  (AWVALID),
        .M_AWREADY  (AWREADY),

        .M_WDATA    (WDATA),
        .M_WSTRB    (WSTRB),
        .M_WVALID   (WVALID),
        .M_WREADY   (WREADY),

        .M_BRESP    (BRESP),
        .M_BVALID   (BVALID),
        .M_BREADY   (BREADY),

        .M_ARADDR   (ARADDR),
        .M_ARVALID  (ARVALID),
        .M_ARREADY  (ARREADY),

        .M_RDATA    (RDATA),
        .M_RRESP    (RRESP),
        .M_RVALID   (RVALID),
        .M_RREADY   (RREADY),

        // SRAM
        .S0_AWADDR  (s0_awaddr),
        .S0_AWVALID (s0_awvalid),
        .S0_AWREADY (s0_awready),

        .S0_WDATA   (s0_wdata),
        .S0_WSTRB   (s0_wstrb),
        .S0_WVALID  (s0_wvalid),
        .S0_WREADY  (s0_wready),

        .S0_BRESP   (s0_bresp),
        .S0_BVALID  (s0_bvalid),
        .S0_BREADY  (s0_bready),

        .S0_ARADDR  (s0_araddr),
        .S0_ARVALID (s0_arvalid),
        .S0_ARREADY (s0_arready),

        .S0_RDATA   (s0_rdata),
        .S0_RRESP   (s0_rresp),
        .S0_RVALID  (s0_rvalid),
        .S0_RREADY  (s0_rready),

        // APB STUB
        .S1_AWADDR  (s1_awaddr),
        .S1_AWVALID (s1_awvalid),
        .S1_AWREADY (s1_awready),

        .S1_WDATA   (s1_wdata),
        .S1_WSTRB   (s1_wstrb),
        .S1_WVALID  (s1_wvalid),
        .S1_WREADY  (s1_wready),

        .S1_BRESP   (s1_bresp),
        .S1_BVALID  (s1_bvalid),
        .S1_BREADY  (s1_bready),

        .S1_ARADDR  (s1_araddr),
        .S1_ARVALID (s1_arvalid),
        .S1_ARREADY (s1_arready),

        .S1_RDATA   (s1_rdata),
        .S1_RRESP   (s1_rresp),
        .S1_RVALID  (s1_rvalid),
        .S1_RREADY  (s1_rready)
    );

    //====================================================
    // SRAM INSTANCE
    //====================================================
    axi_sram sram (

        .ACLK       (ACLK),
        .ARESETn    (ARESETn),

        .AWADDR     (s0_awaddr),
        .AWVALID    (s0_awvalid),
        .AWREADY    (s0_awready),

        .WDATA      (s0_wdata),
        .WSTRB      (s0_wstrb),
        .WVALID     (s0_wvalid),
        .WREADY     (s0_wready),

        .BRESP      (s0_bresp),
        .BVALID     (s0_bvalid),
        .BREADY     (s0_bready),

        .ARADDR     (s0_araddr),
        .ARVALID    (s0_arvalid),
        .ARREADY    (s0_arready),

        .RDATA      (s0_rdata),
        .RRESP      (s0_rresp),
        .RVALID     (s0_rvalid),
        .RREADY     (s0_rready)
    );

    //====================================================
    // APB STUB INSTANCE
    //====================================================
    axi_apb_stub apb_stub (

        .ACLK       (ACLK),
        .ARESETn    (ARESETn),

        .AWADDR     (s1_awaddr),
        .AWVALID    (s1_awvalid),
        .AWREADY    (s1_awready),

        .WDATA      (s1_wdata),
        .WSTRB      (s1_wstrb),
        .WVALID     (s1_wvalid),
        .WREADY     (s1_wready),

        .BRESP      (s1_bresp),
        .BVALID     (s1_bvalid),
        .BREADY     (s1_bready),

        .ARADDR     (s1_araddr),
        .ARVALID    (s1_arvalid),
        .ARREADY    (s1_arready),

        .RDATA      (s1_rdata),
        .RRESP      (s1_rresp),
        .RVALID     (s1_rvalid),
        .RREADY     (s1_rready)
    );

    //====================================================
    // CLOCK
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
        input [`AXI_STRB_WIDTH-1:0] strb;

        begin

            @(posedge ACLK);

            AWADDR  <= addr;
            AWVALID <= 1'b1;

            WDATA   <= data;
            WSTRB   <= strb;
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

            // Reference memory update for SRAM region
            if (addr >= `SRAM_BASE_ADDR &&
                addr <= `SRAM_END_ADDR) begin

                ref_mem[addr[9:2]] = data;

            end

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

            // Expected data
            if (addr >= `SRAM_BASE_ADDR &&
                addr <= `SRAM_END_ADDR) begin

                expected = ref_mem[addr[9:2]];

            end

            else if (addr >= `APB_BASE_ADDR &&
                     addr <= `APB_END_ADDR) begin

                expected = 32'hABCD1234;

            end

            // CHECK
            if (RDATA === expected) begin

                $display("[TB][READ_PASS] TIME=%0t ADDR=0x%0h DATA=0x%0h",
                         $time,
                         addr,
                         RDATA);

            end

            else begin

                $display("[TB][READ_FAIL] TIME=%0t ADDR=0x%0h EXP=0x%0h ACT=0x%0h",
                         $time,
                         addr,
                         expected,
                         RDATA);

            end

        end

    endtask

    //====================================================
    // MAIN TEST
    //====================================================
    initial begin

        integer i;

        // INIT
        AWADDR  = 0;
        AWVALID = 0;

        WDATA   = 0;
        WSTRB   = 0;
        WVALID  = 0;

        BREADY  = 0;

        ARADDR  = 0;
        ARVALID = 0;

        RREADY  = 0;

        for (i = 0; i < 256; i = i + 1)
            ref_mem[i] = 0;

        // RESET
        ARESETn = 0;

        repeat(5) @(posedge ACLK);

        ARESETn = 1;

        $display("\n====================================");
        $display(" AXI INTERCONNECT TEST START ");
        $display("====================================\n");

        //================================================
        // TEST1 : SRAM ACCESS
        //================================================
        $display("[TEST1] SRAM ACCESS");

        axi_write(`SRAM_BASE_ADDR + 32'h0,
                  32'hDEADBEEF,
                  4'b1111);

        axi_read(`SRAM_BASE_ADDR + 32'h0);

        //================================================
        // TEST2 : APB STUB ACCESS
        //================================================
        $display("\n[TEST2] APB STUB ACCESS");

        axi_read(`APB_BASE_ADDR + 32'h0);

        $display("\n====================================");
        $display(" AXI INTERCONNECT TEST END ");
        $display("====================================\n");

        #20;

        $finish;

    end

    //====================================================
    // WAVE DUMP
    //====================================================
    initial begin

        $vcdplusfile("../waves/axi_interconnect.vpd");
        $vcdpluson;

    end

endmodule

