
`timescale 1ns/1ps

`include "axi_defs.svh"
`include "soc_memory_map.svh"

//========================================================
// Module      : axi_sram
// Description :
//   - AXI4-Lite SRAM Slave
//   - 256 x 32-bit memory
//   - Single beat read/write support
//   - Separate AXI read/write channels
//   - Byte write strobe support
//========================================================

module axi_sram #(
    parameter MEM_DEPTH = 256   // 256-locations
)(

    input  wire                        ACLK,
    input  wire                        ARESETn,

    //====================================================
    // WRITE ADDRESS CHANNEL
    //====================================================
    input  wire [`AXI_ADDR_WIDTH-1:0]  AWADDR,
    input  wire                        AWVALID,
    output reg                         AWREADY,

    //====================================================
    // WRITE DATA CHANNEL
    //====================================================
    input  wire [`AXI_DATA_WIDTH-1:0] WDATA,
    input  wire [`AXI_STRB_WIDTH-1:0] WSTRB,
    input  wire                       WVALID,
    output reg                        WREADY,

    //====================================================
    // WRITE RESPONSE CHANNEL
    //====================================================
    output reg [1:0]                  BRESP,
    output reg                        BVALID,
    input  wire                       BREADY,

    //====================================================
    // READ ADDRESS CHANNEL
    //====================================================
    input  wire [`AXI_ADDR_WIDTH-1:0] ARADDR,
    input  wire                       ARVALID,
    output reg                        ARREADY,

    //====================================================
    // READ DATA CHANNEL
    //====================================================
    output reg [`AXI_DATA_WIDTH-1:0] RDATA,
    output reg [1:0]                 RRESP,
    output reg                       RVALID,
    input  wire                      RREADY
);

    //====================================================
    // MEMORY ARRAY
    //====================================================
    reg [`AXI_DATA_WIDTH-1:0] mem [0:MEM_DEPTH-1];

    integer i;

    //====================================================
    // RESET PRINT CONTROL
    //====================================================
    reg reset_done = 0;

    //====================================================
    // RESET LOGIC
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

            if (!reset_done) begin

                for (i = 0; i < MEM_DEPTH; i = i + 1)
                    mem[i] <= 32'h0;

                $display("[SRAM][RESET] TIME=%0t MEMORY_INITIALIZED",
                         $time);

                reset_done <= 1'b1;

            end

        end

        else begin

            reset_done <= 1'b0;

        end

    end

    //====================================================
    // WRITE ADDRESS CHANNEL
    //====================================================
    always @(posedge ACLK) begin

        if (ARESETn) begin
            if (AWVALID && !AWREADY) begin
                AWREADY <= 1'b1;
                $display("[SRAM][AW] TIME=%0t ADDR=0x%0h",
                         $time, AWADDR);
            end
            else begin
                AWREADY <= 1'b0;
            end
        end

    end

    //====================================================
    // WRITE DATA CHANNEL
    //====================================================
    always @(posedge ACLK) begin

        if (ARESETn) begin
            if (WVALID && !WREADY) begin
                WREADY <= 1'b1;
                $display("[SRAM][W] TIME=%0t DATA=0x%0h WSTRB=0b%b",
                         $time, WDATA, WSTRB);
            end
            else begin
                WREADY <= 1'b0;
            end
        end

    end

    //====================================================
    // WRITE OPERATION
    //====================================================
    always @(posedge ACLK) begin

        if (ARESETn) begin
            if (AWVALID && AWREADY && WVALID  && WREADY) begin
                for (i = 0; i < 4; i = i + 1) begin
                    if (WSTRB[i]) begin
                        mem[AWADDR[9:2]][8*i +: 8] <= WDATA[8*i +: 8];
                    end
                end
                BVALID <= 1'b1;
                BRESP  <= 2'b00;
                $display("[SRAM][WRITE] TIME=%0t ADDR=0x%0h DATA=0x%0h",
                         $time, AWADDR, WDATA);
            end
            else begin
                if (BVALID && BREADY) begin
                    BVALID <= 1'b0;
                end
            end
        end

    end

    //====================================================
    // READ ADDRESS CHANNEL
    //====================================================
    always @(posedge ACLK) begin

        if (ARESETn) begin
            if (ARVALID && !ARREADY) begin
                ARREADY <= 1'b1;
                $display("[SRAM][AR] TIME=%0t ADDR=0x%0h",
                         $time, ARADDR);
            end
            else begin
                ARREADY <= 1'b0;
            end
        end

    end

    //====================================================
    // READ DATA CHANNEL
    //====================================================
    always @(posedge ACLK) begin

        if (ARESETn) begin
            if (ARVALID && ARREADY) begin
                RDATA  <= mem[ARADDR[9:2]];
                RRESP  <= 2'b00;
                RVALID <= 1'b1;
                $display("[SRAM][READ] TIME=%0t ADDR=0x%0h DATA=0x%0h",
                         $time,
                         ARADDR,
                         mem[ARADDR[9:2]]);
            end
            else begin
                if (RVALID && RREADY) begin
                    RVALID <= 1'b0;
                end
            end
        end

    end

endmodule

