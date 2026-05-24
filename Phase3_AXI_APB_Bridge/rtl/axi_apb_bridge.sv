
`timescale 1ns/1ps

`include "axi_defs.svh"
`include "apb_defs.svh"
`include "soc_memory_map.svh"

//========================================================
// MODULE NAME : axi_apb_bridge
//========================================================
// DESCRIPTION :
// -------------------------------------------------------
// AXI4-Lite to APB bridge.
//
// PURPOSE:
// -------------------------------------------------------
// - Converts AXI transactions into APB transactions
// - Provides protocol conversion between:
//       AXI4-Lite  ->  APB3
//
// SUPPORTED FEATURES:
// -------------------------------------------------------
// - AXI4-Lite single beat transfers
// - APB3 single slave access
// - Read transactions
// - Write transactions
//
// APB OPERATION:
// -------------------------------------------------------
// SETUP CYCLE:
//   PSEL    = 1
//   PENABLE = 0
//
// ACCESS CYCLE:
//   PSEL    = 1
//   PENABLE = 1
//
// LIMITATIONS:
// -------------------------------------------------------
// - No pipelining
// - No outstanding transactions
// - No wait-state support
// - Single APB slave
//
// FSM STATES:
// -------------------------------------------------------
// IDLE
// WRITE_SETUP
// WRITE_ACCESS
// WRITE_RESP
// READ_SETUP
// READ_ACCESS
// READ_RESP
//========================================================

module axi_apb_bridge (

    //====================================================
    // GLOBAL SIGNALS
    //====================================================
    input  wire                         ACLK,
    input  wire                         ARESETn,

    //====================================================
    // AXI WRITE ADDRESS CHANNEL
    //====================================================
    input  wire [`AXI_ADDR_WIDTH-1:0]  AWADDR,
    input  wire                         AWVALID,
    output reg                          AWREADY,

    //====================================================
    // AXI WRITE DATA CHANNEL
    //====================================================
    input  wire [`AXI_DATA_WIDTH-1:0]  WDATA,
    input  wire [`AXI_STRB_WIDTH-1:0]  WSTRB,
    input  wire                         WVALID,
    output reg                          WREADY,

    //====================================================
    // AXI WRITE RESPONSE CHANNEL
    //====================================================
    output reg [1:0]                   BRESP,
    output reg                         BVALID,
    input  wire                        BREADY,

    //====================================================
    // AXI READ ADDRESS CHANNEL
    //====================================================
    input  wire [`AXI_ADDR_WIDTH-1:0]  ARADDR,
    input  wire                         ARVALID,
    output reg                          ARREADY,

    //====================================================
    // AXI READ DATA CHANNEL
    //====================================================
    output reg [`AXI_DATA_WIDTH-1:0]  RDATA,
    output reg [1:0]                  RRESP,
    output reg                        RVALID,
    input  wire                       RREADY,

    //====================================================
    // APB MASTER INTERFACE
    //====================================================
    output reg [`APB_ADDR_WIDTH-1:0]  PADDR,
    output reg [`APB_DATA_WIDTH-1:0]  PWDATA,

    output reg                         PSEL,
    output reg                         PENABLE,
    output reg                         PWRITE,

    input  wire [`APB_DATA_WIDTH-1:0] PRDATA,
    input  wire                        PREADY
);

    //====================================================
    // FSM STATES
    //====================================================
    localparam IDLE          = 3'd0;
    localparam WRITE_SETUP   = 3'd1;
    localparam WRITE_ACCESS  = 3'd2;
    localparam WRITE_RESP    = 3'd3;
    localparam READ_SETUP    = 3'd4;
    localparam READ_ACCESS   = 3'd5;
    localparam READ_RESP     = 3'd6;

    reg [2:0] state;

    //====================================================
    // INTERNAL REGISTERS
    //====================================================
    reg [`AXI_ADDR_WIDTH-1:0] addr_reg;
    reg [`AXI_DATA_WIDTH-1:0] data_reg;

    //====================================================
    // MAIN FSM
    //====================================================
    always @(posedge ACLK or negedge ARESETn) begin

        if (!ARESETn) begin

            state    <= IDLE;

            AWREADY  <= 1'b0;
            WREADY   <= 1'b0;

            BRESP    <= 2'b00;
            BVALID   <= 1'b0;

            ARREADY  <= 1'b0;

            RDATA    <= 32'h0;
            RRESP    <= 2'b00;
            RVALID   <= 1'b0;

            PADDR    <= 32'h0;
            PWDATA   <= 32'h0;

            PSEL     <= 1'b0;
            PENABLE  <= 1'b0;
            PWRITE   <= 1'b0;

            addr_reg <= 32'h0;
            data_reg <= 32'h0;

            $display("[BRIDGE][RESET] TIME=%0t AXI->APB bridge reset",
                     $time);

        end

        else begin

            case (state)

                //============================================
                // IDLE
                //============================================
                IDLE: begin

                    AWREADY <= 1'b0;
                    WREADY  <= 1'b0;

                    BVALID  <= 1'b0;

                    ARREADY <= 1'b0;
                    RVALID  <= 1'b0;

                    PSEL    <= 1'b0;
                    PENABLE <= 1'b0;

                    //========================================
                    // WRITE TRANSACTION
                    //========================================
                    if (AWVALID && WVALID) begin

                        AWREADY <= 1'b1;
                        WREADY  <= 1'b1;

                        addr_reg <= AWADDR;
                        data_reg <= WDATA;

                        $display("[BRIDGE][AXI_WRITE] TIME=%0t ADDR=0x%0h DATA=0x%0h",
                                 $time,
                                 AWADDR,
                                 WDATA);

                        state <= WRITE_SETUP;

                    end

                    //========================================
                    // READ TRANSACTION
                    //========================================
                    else if (ARVALID) begin

                        ARREADY <= 1'b1;

                        addr_reg <= ARADDR;

                        $display("[BRIDGE][AXI_READ] TIME=%0t ADDR=0x%0h",
                                 $time,
                                 ARADDR);

                        state <= READ_SETUP;

                    end

                end

                //============================================
                // WRITE SETUP
                //============================================
                WRITE_SETUP: begin

                    AWREADY <= 1'b0;
                    WREADY  <= 1'b0;

                    PADDR   <= addr_reg;
                    PWDATA  <= data_reg;

                    PWRITE  <= 1'b1;
                    PSEL    <= 1'b1;
                    PENABLE <= 1'b0;

                    $display("[BRIDGE][APB_WRITE_SETUP] TIME=%0t ADDR=0x%0h DATA=0x%0h",
                             $time,
                             addr_reg,
                             data_reg);

                    state <= WRITE_ACCESS;

                end

                //============================================
                // WRITE ACCESS
                //============================================
                WRITE_ACCESS: begin

                    PENABLE <= 1'b1;

                    if (PREADY) begin

                        $display("[BRIDGE][APB_WRITE_ACCESS] TIME=%0t",
                                 $time);

                        PSEL    <= 1'b0;
                        PENABLE <= 1'b0;

                        BRESP   <= 2'b00;
                        BVALID  <= 1'b1;

                        state <= WRITE_RESP;

                    end

                end

                //============================================
                // WRITE RESPONSE
                //============================================
                WRITE_RESP: begin

                    if (BREADY) begin

                        BVALID <= 1'b0;

                        $display("[BRIDGE][WRITE_COMPLETE] TIME=%0t",
                                 $time);

                        state <= IDLE;

                    end

                end

                //============================================
                // READ SETUP
                //============================================
                READ_SETUP: begin

                    ARREADY <= 1'b0;

                    PADDR   <= addr_reg;

                    PWRITE  <= 1'b0;
                    PSEL    <= 1'b1;
                    PENABLE <= 1'b0;

                    $display("[BRIDGE][APB_READ_SETUP] TIME=%0t ADDR=0x%0h",
                             $time,
                             addr_reg);

                    state <= READ_ACCESS;

                end

                //============================================
                // READ ACCESS
                //============================================
                READ_ACCESS: begin

                    PENABLE <= 1'b1;

                    if (PREADY) begin

                        RDATA  <= PRDATA;
                        RRESP  <= 2'b00;
                        RVALID <= 1'b1;

                        PSEL    <= 1'b0;
                        PENABLE <= 1'b0;

                        $display("[BRIDGE][APB_READ_ACCESS] TIME=%0t DATA=0x%0h",
                                 $time,
                                 PRDATA);

                        state <= READ_RESP;

                    end

                end

                //============================================
                // READ RESPONSE
                //============================================
                READ_RESP: begin

                    if (RREADY) begin

                        RVALID <= 1'b0;

                        $display("[BRIDGE][READ_COMPLETE] TIME=%0t",
                                 $time);

                        state <= IDLE;

                    end

                end

                //============================================
                // DEFAULT
                //============================================
                default: begin

                    state <= IDLE;

                end

            endcase

        end

    end

endmodule

