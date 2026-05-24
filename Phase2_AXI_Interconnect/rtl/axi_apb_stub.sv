
`timescale 1ns/1ps

`include "axi_defs.svh"
`include "soc_memory_map.svh"

//========================================================
// MODULE NAME : axi_apb_stub
//========================================================
// DESCRIPTION :
// -------------------------------------------------------
// Simple AXI4-Lite slave stub used for
// AXI interconnect verification.
//
// PURPOSE:
// -------------------------------------------------------
// - Acts as second AXI slave
// - Helps verify address decode
// - Helps verify routing logic
// - Helps verify response muxing
//
// FUNCTIONALITY:
// -------------------------------------------------------
// WRITE :
//   - Accepts AXI writes
//   - Returns OKAY response
//
// READ :
//   - Returns fixed pattern
//   - DATA = 32'hABCD1234
//
// NOTES:
// -------------------------------------------------------
// - Used only for Phase2_AXI_Interconnect
// - Temporary placeholder before real
//   AXI->APB bridge integration
//========================================================

module axi_apb_stub (

    input  wire                         ACLK,
    input  wire                         ARESETn,

    //====================================================
    // WRITE ADDRESS CHANNEL
    //====================================================
    input  wire [`AXI_ADDR_WIDTH-1:0]  AWADDR,
    input  wire                         AWVALID,
    output reg                          AWREADY,

    //====================================================
    // WRITE DATA CHANNEL
    //====================================================
    input  wire [`AXI_DATA_WIDTH-1:0]  WDATA,
    input  wire [`AXI_STRB_WIDTH-1:0]  WSTRB,
    input  wire                         WVALID,
    output reg                          WREADY,

    //====================================================
    // WRITE RESPONSE CHANNEL
    //====================================================
    output reg [1:0]                   BRESP,
    output reg                         BVALID,
    input  wire                        BREADY,

    //====================================================
    // READ ADDRESS CHANNEL
    //====================================================
    input  wire [`AXI_ADDR_WIDTH-1:0] ARADDR,
    input  wire                        ARVALID,
    output reg                         ARREADY,

    //====================================================
    // READ DATA CHANNEL
    //====================================================
    output reg [`AXI_DATA_WIDTH-1:0]  RDATA,
    output reg [1:0]                  RRESP,
    output reg                        RVALID,
    input  wire                       RREADY
);

    //====================================================
    // RESET
    //====================================================
    always @(posedge ACLK or negedge ARESETn) begin

        if (!ARESETn) begin

            AWREADY <= 1'b0;
            WREADY  <= 1'b0;

            BVALID  <= 1'b0;
            BRESP   <= 2'b00;

            ARREADY <= 1'b0;

            RVALID  <= 1'b0;
            RRESP   <= 2'b00;
            RDATA   <= 32'h0;

            $display("[APB_STUB][RESET] TIME=%0t",
                     $time);

        end

    end

    //====================================================
    // WRITE ADDRESS
    //====================================================
    always @(posedge ACLK) begin

        if (ARESETn) begin

            if (AWVALID && !AWREADY) begin

                AWREADY <= 1'b1;

                $display("[APB_STUB][AW] TIME=%0t ADDR=0x%0h",
                         $time,
                         AWADDR);

            end

            else begin

                AWREADY <= 1'b0;

            end

        end

    end

    //====================================================
    // WRITE DATA
    //====================================================
    always @(posedge ACLK) begin

        if (ARESETn) begin

            if (WVALID && !WREADY) begin

                WREADY <= 1'b1;

                $display("[APB_STUB][W] TIME=%0t DATA=0x%0h",
                         $time,
                         WDATA);

            end

            else begin

                WREADY <= 1'b0;

            end

        end

    end

    //====================================================
    // WRITE RESPONSE
    //====================================================
    always @(posedge ACLK) begin

        if (ARESETn) begin

            if (AWVALID && AWREADY &&
                WVALID  && WREADY) begin

                BVALID <= 1'b1;
                BRESP  <= 2'b00;

                $display("[APB_STUB][WRITE_OK] TIME=%0t",
                         $time);

            end

            else begin

                if (BVALID && BREADY) begin

                    BVALID <= 1'b0;

                end

            end

        end

    end

    //====================================================
    // READ ADDRESS
    //====================================================
    always @(posedge ACLK) begin

        if (ARESETn) begin

            if (ARVALID && !ARREADY) begin

                ARREADY <= 1'b1;

                $display("[APB_STUB][AR] TIME=%0t ADDR=0x%0h",
                         $time,
                         ARADDR);

            end

            else begin

                ARREADY <= 1'b0;

            end

        end

    end

    //====================================================
    // READ RESPONSE
    //====================================================
    always @(posedge ACLK) begin

        if (ARESETn) begin

            if (ARVALID && ARREADY) begin

                RVALID <= 1'b1;
                RRESP  <= 2'b00;

                //========================================
                // FIXED STUB DATA
                //========================================
                RDATA <= 32'hABCD1234;

                $display("[APB_STUB][READ] TIME=%0t DATA=0xABCD1234",
                         $time);

            end

            else begin

                if (RVALID && RREADY) begin

                    RVALID <= 1'b0;

                end

            end

        end

    end

endmodule

