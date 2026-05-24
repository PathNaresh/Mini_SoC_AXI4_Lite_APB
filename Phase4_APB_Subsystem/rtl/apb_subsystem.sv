
`timescale 1ns/1ps

`include "apb_defs.svh"
`include "soc_memory_map.svh"

//========================================================
// MODULE NAME : apb_subsystem
//========================================================
// DESCRIPTION :
// -------------------------------------------------------
// Top-level APB subsystem.
//
// PURPOSE:
// -------------------------------------------------------
// - Integrates multiple APB peripherals
// - Performs APB address decoding
// - Routes APB transactions
// - Multiplexes PRDATA
//
// CONNECTED PERIPHERALS:
// -------------------------------------------------------
// GPIO
// UART (stub)
// SPI  (stub)
//
// ADDRESS MAP:
// -------------------------------------------------------
// GPIO : 0x1000_0000
// UART : 0x1000_1000
// SPI  : 0x1000_2000
//
// NOTES:
// -------------------------------------------------------
// - Shared APB bus architecture
// - Only one peripheral active at a time
// - Decoder-based peripheral selection
//========================================================

module apb_subsystem (

    //====================================================
    // GLOBAL SIGNALS
    //====================================================
    input  wire                         PCLK,
    input  wire                         PRESETn,

    //====================================================
    // APB SLAVE INTERFACE
    //====================================================
    input  wire                         PSEL,
    input  wire                         PENABLE,
    input  wire                         PWRITE,

    input  wire [`APB_ADDR_WIDTH-1:0]  PADDR,
    input  wire [`APB_DATA_WIDTH-1:0]  PWDATA,

    output reg  [`APB_DATA_WIDTH-1:0]  PRDATA,
    output wire                        PREADY,

    //====================================================
    // GPIO SIGNALS
    //====================================================
    input  wire [7:0]                  gpio_in,

    output wire [7:0]                  gpio_out,
    output wire [7:0]                  gpio_dir
);

    //====================================================
    // DECODER OUTPUTS
    //====================================================
    wire PSEL_GPIO;
    wire PSEL_UART;
    wire PSEL_SPI;

    //====================================================
    // PERIPHERAL PRDATA
    //====================================================
    wire [31:0] prdata_gpio;
    wire [31:0] prdata_uart;
    wire [31:0] prdata_spi;

    //====================================================
    // PERIPHERAL PREADY
    //====================================================
    wire pready_gpio;
    wire pready_uart;
    wire pready_spi;

    //====================================================
    // APB DECODER
    //====================================================
    apb_decoder u_apb_decoder (

        .PADDR      (PADDR),
        .PSEL       (PSEL),

        .PSEL_GPIO  (PSEL_GPIO),
        .PSEL_UART  (PSEL_UART),
        .PSEL_SPI   (PSEL_SPI)
    );

    //====================================================
    // GPIO PERIPHERAL
    //====================================================
    apb_gpio u_apb_gpio (

        .PCLK       (PCLK),
        .PRESETn    (PRESETn),

        .PSEL       (PSEL_GPIO),
        .PENABLE    (PENABLE),
        .PWRITE     (PWRITE),

        .PADDR      (PADDR),
        .PWDATA     (PWDATA),

        .PRDATA     (prdata_gpio),
        .PREADY     (pready_gpio),

        .gpio_in    (gpio_in),

        .gpio_out   (gpio_out),
        .gpio_dir   (gpio_dir)
    );

    //====================================================
    // UART STUB
    //====================================================
    apb_uart_stub u_apb_uart (

        .PCLK       (PCLK),
        .PRESETn    (PRESETn),

        .PSEL       (PSEL_UART),
        .PENABLE    (PENABLE),
        .PWRITE     (PWRITE),

        .PADDR      (PADDR),
        .PWDATA     (PWDATA),

        .PRDATA     (prdata_uart),
        .PREADY     (pready_uart)
    );

    //====================================================
    // SPI STUB
    //====================================================
    apb_spi_stub u_apb_spi (

        .PCLK       (PCLK),
        .PRESETn    (PRESETn),

        .PSEL       (PSEL_SPI),
        .PENABLE    (PENABLE),
        .PWRITE     (PWRITE),

        .PADDR      (PADDR),
        .PWDATA     (PWDATA),

        .PRDATA     (prdata_spi),
        .PREADY     (pready_spi)
    );

    //====================================================
    // PRDATA MUX
    //====================================================
    always @(*) begin

        PRDATA = 32'h00000000;

        if (PSEL_GPIO) begin
            PRDATA = prdata_gpio;
        end

        else if (PSEL_UART) begin
            PRDATA = prdata_uart;
        end

        else if (PSEL_SPI) begin
            PRDATA = prdata_spi;
        end

        else begin
            PRDATA = 32'hDEADBEEF;
        end

    end

    //====================================================
    // PREADY MUX
    //====================================================
    assign PREADY =
            (PSEL_GPIO) ? pready_gpio :
            (PSEL_UART) ? pready_uart :
            (PSEL_SPI ) ? pready_spi  :
                           1'b1;

endmodule

