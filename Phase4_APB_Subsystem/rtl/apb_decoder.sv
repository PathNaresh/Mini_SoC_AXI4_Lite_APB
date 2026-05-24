
`timescale 1ns/1ps

`include "apb_defs.svh"
`include "soc_memory_map.svh"

//========================================================
// MODULE NAME : apb_decoder
//========================================================
// DESCRIPTION :
// -------------------------------------------------------
// APB address decoder.
//
// PURPOSE:
// -------------------------------------------------------
// - Decodes APB address
// - Selects one APB peripheral
// - Generates peripheral PSEL signals
//
// SUPPORTED PERIPHERALS:
// -------------------------------------------------------
// GPIO
// UART
// SPI
//
// ADDRESS MAP:
// -------------------------------------------------------
// GPIO : 0x1000_0000
// UART : 0x1000_1000
// SPI  : 0x1000_2000
//
// NOTES:
// -------------------------------------------------------
// - Only one peripheral selected at a time
// - Simple combinational decoder
//========================================================

module apb_decoder (

    //====================================================
    // APB ADDRESS INPUT
    //====================================================
    input  wire [`APB_ADDR_WIDTH-1:0] PADDR,
    input  wire                        PSEL,

    //====================================================
    // PERIPHERAL SELECT OUTPUTS
    //====================================================
    output reg                         PSEL_GPIO,
    output reg                         PSEL_UART,
    output reg                         PSEL_SPI
);

    //====================================================
    // ADDRESS DECODER
    //====================================================
    always @(*) begin

        //================================================
        // DEFAULTS
        //================================================
        PSEL_GPIO = 1'b0;
        PSEL_UART = 1'b0;
        PSEL_SPI  = 1'b0;

        //================================================
        // DECODE ONLY WHEN PSEL ACTIVE
        //================================================
        if (PSEL) begin

            //============================================
            // GPIO
            //============================================
            if ((PADDR >= `GPIO_BASE_ADDR) &&
                (PADDR <  (`GPIO_BASE_ADDR + 32'h1000))) begin

                PSEL_GPIO = 1'b1;

            end

            //============================================
            // UART
            //============================================
            else if ((PADDR >= `UART_BASE_ADDR) &&
                     (PADDR <  (`UART_BASE_ADDR + 32'h1000))) begin

                PSEL_UART = 1'b1;

            end

            //============================================
            // SPI
            //============================================
            else if ((PADDR >= `SPI_BASE_ADDR) &&
                     (PADDR <  (`SPI_BASE_ADDR + 32'h1000))) begin

                PSEL_SPI = 1'b1;

            end

        end

    end

endmodule

