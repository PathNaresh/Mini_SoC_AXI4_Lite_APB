
`timescale 1ns/1ps

`include "axi_defs.svh"
`include "apb_defs.svh"
`include "soc_memory_map.svh"

//========================================================
// MODULE NAME : soc_top
//========================================================
// DESCRIPTION :
// -------------------------------------------------------
// Full Mini-SoC top-level integration.
//
// PURPOSE:
// -------------------------------------------------------
// - Integrates AXI interconnect
// - Integrates AXI SRAM
// - Integrates AXI -> APB bridge
// - Integrates APB subsystem
//
// SOC ARCHITECTURE:
// -------------------------------------------------------
//
//                 AXI MASTER
//                      |
//              AXI INTERCONNECT
//               |            |
//               |            |
//           AXI SRAM    AXI->APB BRIDGE
//                               |
//                         APB SUBSYSTEM
//                         |     |      |
//                       GPIO  UART   SPI
//
// ADDRESS MAP:
// -------------------------------------------------------
// SRAM : 0x0000_0000
// APB  : 0x1000_0000
//
// NOTES:
// -------------------------------------------------------
// - AXI4-Lite based system
// - Single AXI master
// - Shared APB peripheral subsystem
//========================================================

module soc_top (

    //====================================================
    // GLOBAL SIGNALS
    //====================================================
    input  wire                         ACLK,
    input  wire                         ARESETn,

    //====================================================
    // AXI MASTER INTERFACE
    //====================================================

    // WRITE ADDRESS
    input  wire [`AXI_ADDR_WIDTH-1:0]  AWADDR,
    input  wire                        AWVALID,
    output wire                        AWREADY,

    // WRITE DATA
    input  wire [`AXI_DATA_WIDTH-1:0]  WDATA,
    input  wire [`AXI_STRB_WIDTH-1:0]  WSTRB,
    input  wire                        WVALID,
    output wire                        WREADY,

    // WRITE RESPONSE
    output wire [1:0]                  BRESP,
    output wire                        BVALID,
    input  wire                        BREADY,

    // READ ADDRESS
    input  wire [`AXI_ADDR_WIDTH-1:0]  ARADDR,
    input  wire                        ARVALID,
    output wire                        ARREADY,

    // READ DATA
    output wire [`AXI_DATA_WIDTH-1:0]  RDATA,
    output wire [1:0]                  RRESP,
    output wire                        RVALID,
    input  wire                        RREADY,

    //====================================================
    // GPIO SIGNALS
    //====================================================
    input  wire [7:0]                  gpio_in,

    output wire [7:0]                  gpio_out,
    output wire [7:0]                  gpio_dir
);

    //====================================================
    // INTERCONNECT -> SRAM SIGNALS
    //====================================================

    // WRITE ADDRESS
    wire [`AXI_ADDR_WIDTH-1:0] sram_AWADDR;
    wire                       sram_AWVALID;
    wire                       sram_AWREADY;

    // WRITE DATA
    wire [`AXI_DATA_WIDTH-1:0] sram_WDATA;
    wire [`AXI_STRB_WIDTH-1:0] sram_WSTRB;
    wire                       sram_WVALID;
    wire                       sram_WREADY;

    // WRITE RESPONSE
    wire [1:0]                 sram_BRESP;
    wire                       sram_BVALID;
    wire                       sram_BREADY;

    // READ ADDRESS
    wire [`AXI_ADDR_WIDTH-1:0] sram_ARADDR;
    wire                       sram_ARVALID;
    wire                       sram_ARREADY;

    // READ DATA
    wire [`AXI_DATA_WIDTH-1:0] sram_RDATA;
    wire [1:0]                 sram_RRESP;
    wire                       sram_RVALID;
    wire                       sram_RREADY;

    //====================================================
    // INTERCONNECT -> BRIDGE SIGNALS
    //====================================================

    // WRITE ADDRESS
    wire [`AXI_ADDR_WIDTH-1:0] apb_AWADDR;
    wire                       apb_AWVALID;
    wire                       apb_AWREADY;

    // WRITE DATA
    wire [`AXI_DATA_WIDTH-1:0] apb_WDATA;
    wire [`AXI_STRB_WIDTH-1:0] apb_WSTRB;
    wire                       apb_WVALID;
    wire                       apb_WREADY;

    // WRITE RESPONSE
    wire [1:0]                 apb_BRESP;
    wire                       apb_BVALID;
    wire                       apb_BREADY;

    // READ ADDRESS
    wire [`AXI_ADDR_WIDTH-1:0] apb_ARADDR;
    wire                       apb_ARVALID;
    wire                       apb_ARREADY;

    // READ DATA
    wire [`AXI_DATA_WIDTH-1:0] apb_RDATA;
    wire [1:0]                 apb_RRESP;
    wire                       apb_RVALID;
    wire                       apb_RREADY;

    //====================================================
    // APB BRIDGE -> APB SUBSYSTEM SIGNALS
    //====================================================
    wire [`APB_ADDR_WIDTH-1:0] PADDR;
    wire [`APB_DATA_WIDTH-1:0] PWDATA;

    wire                       PSEL;
    wire                       PENABLE;
    wire                       PWRITE;

    wire [`APB_DATA_WIDTH-1:0] PRDATA;
    wire                       PREADY;

    //====================================================
    // AXI INTERCONNECT
    //====================================================
    axi_interconnect u_axi_interconnect (

        .ACLK          (ACLK),
        .ARESETn       (ARESETn),

        //================================================
        // AXI MASTER SIDE
        //================================================
        .M_AWADDR        (AWADDR),
        .M_AWVALID       (AWVALID),
        .M_AWREADY       (AWREADY),

        .M_WDATA         (WDATA),
        .M_WSTRB         (WSTRB),
        .M_WVALID        (WVALID),
        .M_WREADY        (WREADY),

        .M_BRESP         (BRESP),
        .M_BVALID        (BVALID),
        .M_BREADY        (BREADY),

        .M_ARADDR        (ARADDR),
        .M_ARVALID       (ARVALID),
        .M_ARREADY       (ARREADY),

        .M_RDATA         (RDATA),
        .M_RRESP         (RRESP),
        .M_RVALID        (RVALID),
        .M_RREADY        (RREADY),

        //================================================
        // SRAM SIDE
        //================================================
        .S0_AWADDR   (sram_AWADDR),
        .S0_AWVALID  (sram_AWVALID),
        .S0_AWREADY  (sram_AWREADY),

        .S0_WDATA    (sram_WDATA),
        .S0_WSTRB    (sram_WSTRB),
        .S0_WVALID   (sram_WVALID),
        .S0_WREADY   (sram_WREADY),

        .S0_BRESP    (sram_BRESP),
        .S0_BVALID   (sram_BVALID),
        .S0_BREADY   (sram_BREADY),

        .S0_ARADDR   (sram_ARADDR),
        .S0_ARVALID  (sram_ARVALID),
        .S0_ARREADY  (sram_ARREADY),

        .S0_RDATA    (sram_RDATA),
        .S0_RRESP    (sram_RRESP),
        .S0_RVALID   (sram_RVALID),
        .S0_RREADY   (sram_RREADY),

        //================================================
        // APB BRIDGE SIDE
        //================================================
        .S1_AWADDR    (apb_AWADDR),
        .S1_AWVALID   (apb_AWVALID),
        .S1_AWREADY   (apb_AWREADY),

        .S1_WDATA     (apb_WDATA),
        .S1_WSTRB     (apb_WSTRB),
        .S1_WVALID    (apb_WVALID),
        .S1_WREADY    (apb_WREADY),

        .S1_BRESP     (apb_BRESP),
        .S1_BVALID    (apb_BVALID),
        .S1_BREADY    (apb_BREADY),

        .S1_ARADDR    (apb_ARADDR),
        .S1_ARVALID   (apb_ARVALID),
        .S1_ARREADY   (apb_ARREADY),

        .S1_RDATA     (apb_RDATA),
        .S1_RRESP     (apb_RRESP),
        .S1_RVALID    (apb_RVALID),
        .S1_RREADY    (apb_RREADY)
    );

    //====================================================
    // AXI SRAM
    //====================================================
    axi_sram u_axi_sram (

        .ACLK       (ACLK),
        .ARESETn    (ARESETn),

        .AWADDR     (sram_AWADDR),
        .AWVALID    (sram_AWVALID),
        .AWREADY    (sram_AWREADY),

        .WDATA      (sram_WDATA),
        .WSTRB      (sram_WSTRB),
        .WVALID     (sram_WVALID),
        .WREADY     (sram_WREADY),

        .BRESP      (sram_BRESP),
        .BVALID     (sram_BVALID),
        .BREADY     (sram_BREADY),

        .ARADDR     (sram_ARADDR),
        .ARVALID    (sram_ARVALID),
        .ARREADY    (sram_ARREADY),

        .RDATA      (sram_RDATA),
        .RRESP      (sram_RRESP),
        .RVALID     (sram_RVALID),
        .RREADY     (sram_RREADY)
    );

    //====================================================
    // AXI -> APB BRIDGE
    //====================================================
    axi_apb_bridge u_axi_apb_bridge (

        .ACLK       (ACLK),
        .ARESETn    (ARESETn),

        .AWADDR     (apb_AWADDR),
        .AWVALID    (apb_AWVALID),
        .AWREADY    (apb_AWREADY),

        .WDATA      (apb_WDATA),
        .WSTRB      (apb_WSTRB),
        .WVALID     (apb_WVALID),
        .WREADY     (apb_WREADY),

        .BRESP      (apb_BRESP),
        .BVALID     (apb_BVALID),
        .BREADY     (apb_BREADY),

        .ARADDR     (apb_ARADDR),
        .ARVALID    (apb_ARVALID),
        .ARREADY    (apb_ARREADY),

        .RDATA      (apb_RDATA),
        .RRESP      (apb_RRESP),
        .RVALID     (apb_RVALID),
        .RREADY     (apb_RREADY),

        //================================================
        // APB MASTER SIDE
        //================================================
        .PADDR      (PADDR),
        .PWDATA     (PWDATA),

        .PSEL       (PSEL),
        .PENABLE    (PENABLE),
        .PWRITE     (PWRITE),

        .PRDATA     (PRDATA),
        .PREADY     (PREADY)
    );

    //====================================================
    // APB SUBSYSTEM
    //====================================================
    apb_subsystem u_apb_subsystem (

        .PCLK       (ACLK),
        .PRESETn    (ARESETn),

        .PSEL       (PSEL),
        .PENABLE    (PENABLE),
        .PWRITE     (PWRITE),

        .PADDR      (PADDR),
        .PWDATA     (PWDATA),

        .PRDATA     (PRDATA),
        .PREADY     (PREADY),

        .gpio_in    (gpio_in),

        .gpio_out   (gpio_out),
        .gpio_dir   (gpio_dir)
    );

endmodule

