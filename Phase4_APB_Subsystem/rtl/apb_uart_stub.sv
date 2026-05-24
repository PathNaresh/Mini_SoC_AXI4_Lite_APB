
`timescale 1ns/1ps

`include "apb_defs.svh"

//========================================================
// MODULE NAME : apb_uart_stub
//========================================================
// DESCRIPTION :
// -------------------------------------------------------
// Dummy APB UART peripheral.
//
// PURPOSE:
// -------------------------------------------------------
// - Mimics UART APB slave behavior
// - Used for APB subsystem verification
// - Helps validate decoder routing
//
// REGISTER MAP:
// -------------------------------------------------------
// OFFSET      REGISTER
// 0x00        TXDATA
// 0x04        RXDATA
// 0x08        STATUS
// 0x0C        CONTROL
//
// NOTES:
// -------------------------------------------------------
// - Stub peripheral only
// - Returns fixed read patterns
// - No real UART functionality
// - PREADY always asserted
//========================================================

module apb_uart_stub (

    //====================================================
    // GLOBAL SIGNALS
    //====================================================
    input  wire                         PCLK,
    input  wire                         PRESETn,

    //====================================================
    // APB INTERFACE
    //====================================================
    input  wire                         PSEL,
    input  wire                         PENABLE,
    input  wire                         PWRITE,

    input  wire [`APB_ADDR_WIDTH-1:0]  PADDR,
    input  wire [`APB_DATA_WIDTH-1:0]  PWDATA,

    output reg  [`APB_DATA_WIDTH-1:0]  PRDATA,
    output wire                        PREADY
);

    //====================================================
    // INTERNAL REGISTERS
    //====================================================
    reg [31:0] txdata_reg;
    reg [31:0] control_reg;

    //====================================================
    // APB READY
    //====================================================
    assign PREADY = 1'b1;

    //====================================================
    // WRITE LOGIC
    //====================================================
    always @(posedge PCLK or negedge PRESETn) begin

        if (!PRESETn) begin
            txdata_reg  <= 32'h0;
            control_reg <= 32'h0;
            $display("[UART][RESET] TIME=%0t UART stub reset",
                     $time);
        end

        else begin

            if (PSEL && PENABLE && PWRITE) begin
                case (PADDR[7:0])

                    //========================================
                    // TXDATA
                    //========================================
                    8'h00: begin
                        txdata_reg <= PWDATA;
                        $display("[UART][WRITE] TIME=%0t REG=TXDATA DATA=0x%0h",
                                 $time,
                                 PWDATA);
                    end

                    //========================================
                    // CONTROL
                    //========================================
                    8'h0C: begin
                        control_reg <= PWDATA;
                        $display("[UART][WRITE] TIME=%0t REG=CONTROL DATA=0x%0h",
                                 $time,
                                 PWDATA);
                    end

                    //========================================
                    // INVALID
                    //========================================
                    default: begin
                        $display("[UART][INVALID_WRITE] TIME=%0t ADDR=0x%0h",
                                 $time,
                                 PADDR);
                    end

                endcase
            end

        end

    end

    //====================================================
    // READ LOGIC
    //====================================================
    always @(*) begin

        PRDATA = 32'h00000000;

        if (PSEL && !PWRITE) begin

            case (PADDR[7:0])

                //============================================
                // TXDATA
                //============================================
                8'h00: begin
                    PRDATA = txdata_reg;
                end

                //============================================
                // RXDATA
                //============================================
                8'h04: begin
                    PRDATA = 32'hABCD1234;
                end

                //============================================
                // STATUS
                //============================================
                8'h08: begin
                    PRDATA = 32'h00000001;
                end

                //============================================
                // CONTROL
                //============================================
                8'h0C: begin
                    PRDATA = control_reg;
                end

                //============================================
                // INVALID
                //============================================
                default: begin
                    PRDATA = 32'hDEADBEEF;
                end

            endcase

        end

    end

endmodule

