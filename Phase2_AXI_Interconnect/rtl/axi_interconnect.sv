
`timescale 1ns/1ps

`include "axi_defs.svh"
`include "soc_memory_map.svh"

//========================================================
// MODULE NAME : axi_interconnect
//========================================================
// DESCRIPTION :
// -------------------------------------------------------
// Simple AXI4-Lite interconnect.
//
// PURPOSE:
// -------------------------------------------------------
// - Routes AXI transactions from one master
//   to multiple slaves
// - Performs address decoding
// - Selects correct slave
// - Muxes slave responses back to master
//
// CONNECTED SLAVES:
// -------------------------------------------------------
// 1. AXI SRAM
//    Address Range:
//    0x0000_0000 -> 0x0000_FFFF
//
// 2. AXI->APB Stub
//    Address Range:
//    0x1000_0000 -> 0x1000_FFFF
//
// NOTES:
// -------------------------------------------------------
// - AXI4-Lite only
// - Single master
// - Two slaves
// - No arbitration
// - No bursts
// - No outstanding transactions
//========================================================

module axi_interconnect (

    input  wire                         ACLK,
    input  wire                         ARESETn,

    //====================================================
    // MASTER SIDE AXI INTERFACE
    //====================================================

    // WRITE ADDRESS
    input  wire [`AXI_ADDR_WIDTH-1:0]  M_AWADDR,
    input  wire                         M_AWVALID,
    output wire                         M_AWREADY,

    // WRITE DATA
    input  wire [`AXI_DATA_WIDTH-1:0]  M_WDATA,
    input  wire [`AXI_STRB_WIDTH-1:0]  M_WSTRB,
    input  wire                         M_WVALID,
    output wire                         M_WREADY,

    // WRITE RESPONSE
    output wire [1:0]                  M_BRESP,
    output wire                         M_BVALID,
    input  wire                         M_BREADY,

    // READ ADDRESS
    input  wire [`AXI_ADDR_WIDTH-1:0]  M_ARADDR,
    input  wire                         M_ARVALID,
    output wire                         M_ARREADY,

    // READ DATA
    output wire [`AXI_DATA_WIDTH-1:0]  M_RDATA,
    output wire [1:0]                  M_RRESP,
    output wire                         M_RVALID,
    input  wire                         M_RREADY,

    //====================================================
    // SRAM SLAVE INTERFACE
    //====================================================

    output wire [`AXI_ADDR_WIDTH-1:0]  S0_AWADDR,
    output wire                         S0_AWVALID,
    input  wire                         S0_AWREADY,

    output wire [`AXI_DATA_WIDTH-1:0]  S0_WDATA,
    output wire [`AXI_STRB_WIDTH-1:0]  S0_WSTRB,
    output wire                         S0_WVALID,
    input  wire                         S0_WREADY,

    input  wire [1:0]                  S0_BRESP,
    input  wire                         S0_BVALID,
    output wire                         S0_BREADY,

    output wire [`AXI_ADDR_WIDTH-1:0]  S0_ARADDR,
    output wire                         S0_ARVALID,
    input  wire                         S0_ARREADY,

    input  wire [`AXI_DATA_WIDTH-1:0]  S0_RDATA,
    input  wire [1:0]                  S0_RRESP,
    input  wire                         S0_RVALID,
    output wire                         S0_RREADY,

    //====================================================
    // APB STUB SLAVE INTERFACE
    //====================================================

    output wire [`AXI_ADDR_WIDTH-1:0]  S1_AWADDR,
    output wire                         S1_AWVALID,
    input  wire                         S1_AWREADY,

    output wire [`AXI_DATA_WIDTH-1:0]  S1_WDATA,
    output wire [`AXI_STRB_WIDTH-1:0]  S1_WSTRB,
    output wire                         S1_WVALID,
    input  wire                         S1_WREADY,

    input  wire [1:0]                  S1_BRESP,
    input  wire                         S1_BVALID,
    output wire                         S1_BREADY,

    output wire [`AXI_ADDR_WIDTH-1:0]  S1_ARADDR,
    output wire                         S1_ARVALID,
    input  wire                         S1_ARREADY,

    input  wire [`AXI_DATA_WIDTH-1:0]  S1_RDATA,
    input  wire [1:0]                  S1_RRESP,
    input  wire                         S1_RVALID,
    output wire                         S1_RREADY
);

    //====================================================
    // ADDRESS DECODE
    //====================================================

    wire sram_sel_wr;
    wire apb_sel_wr;

    wire sram_sel_rd;
    wire apb_sel_rd;

    assign sram_sel_wr =
        (M_AWADDR >= `SRAM_BASE_ADDR) &&
        (M_AWADDR <= `SRAM_END_ADDR);

    assign apb_sel_wr =
        (M_AWADDR >= `APB_BASE_ADDR) &&
        (M_AWADDR <= `APB_END_ADDR);

    assign sram_sel_rd =
        (M_ARADDR >= `SRAM_BASE_ADDR) &&
        (M_ARADDR <= `SRAM_END_ADDR);

    assign apb_sel_rd =
        (M_ARADDR >= `APB_BASE_ADDR) &&
        (M_ARADDR <= `APB_END_ADDR);

    //====================================================
    // WRITE ADDRESS ROUTING
    //====================================================

    assign S0_AWADDR  = M_AWADDR;
    assign S0_AWVALID = M_AWVALID & sram_sel_wr;

    assign S1_AWADDR  = M_AWADDR;
    assign S1_AWVALID = M_AWVALID & apb_sel_wr;

    assign M_AWREADY =
            sram_sel_wr ? S0_AWREADY :
            apb_sel_wr  ? S1_AWREADY :
            1'b0;

    //====================================================
    // WRITE DATA ROUTING
    //====================================================

    assign S0_WDATA  = M_WDATA;
    assign S0_WSTRB  = M_WSTRB;
    assign S0_WVALID = M_WVALID & sram_sel_wr;

    assign S1_WDATA  = M_WDATA;
    assign S1_WSTRB  = M_WSTRB;
    assign S1_WVALID = M_WVALID & apb_sel_wr;

    assign M_WREADY =
            sram_sel_wr ? S0_WREADY :
            apb_sel_wr  ? S1_WREADY :
            1'b0;

    //====================================================
    // WRITE RESPONSE MUX
    //====================================================

    assign M_BRESP =
            sram_sel_wr ? S0_BRESP :
            apb_sel_wr  ? S1_BRESP :
            2'b00;

    assign M_BVALID =
            sram_sel_wr ? S0_BVALID :
            apb_sel_wr  ? S1_BVALID :
            1'b0;

    assign S0_BREADY = M_BREADY;
    assign S1_BREADY = M_BREADY;

    //====================================================
    // READ ADDRESS ROUTING
    //====================================================

    assign S0_ARADDR  = M_ARADDR;
    assign S0_ARVALID = M_ARVALID & sram_sel_rd;

    assign S1_ARADDR  = M_ARADDR;
    assign S1_ARVALID = M_ARVALID & apb_sel_rd;

    assign M_ARREADY =
            sram_sel_rd ? S0_ARREADY :
            apb_sel_rd  ? S1_ARREADY :
            1'b0;

    //====================================================
    // READ DATA MUX
    //====================================================

    assign M_RDATA =
            sram_sel_rd ? S0_RDATA :
            apb_sel_rd  ? S1_RDATA :
            32'h0;

    assign M_RRESP =
            sram_sel_rd ? S0_RRESP :
            apb_sel_rd  ? S1_RRESP :
            2'b00;

    assign M_RVALID =
            sram_sel_rd ? S0_RVALID :
            apb_sel_rd  ? S1_RVALID :
            1'b0;

    assign S0_RREADY = M_RREADY;
    assign S1_RREADY = M_RREADY;

endmodule

