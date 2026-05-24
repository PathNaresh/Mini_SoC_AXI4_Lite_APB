
`timescale 1ns/1ps

`include "apb_defs.svh"

//========================================================
// MODULE NAME : apb_gpio
//========================================================
// DESCRIPTION :
// -------------------------------------------------------
// Simple APB GPIO peripheral.
//
// PURPOSE:
// -------------------------------------------------------
// - Provides programmable GPIO interface
// - Supports GPIO input mode
// - Supports GPIO output mode
// - Used for AXI->APB bridge verification
//
// APB REGISTER MAP:
// -------------------------------------------------------
// OFFSET      REGISTER
// 0x00        GPIO_DATA
// 0x04        GPIO_DIR
//
// GPIO_DIR:
// -------------------------------------------------------
// 1 = OUTPUT
// 0 = INPUT
//
// GPIO_DATA:
// -------------------------------------------------------
// OUTPUT MODE:
//   Write value drives gpio_out
//
// INPUT MODE:
//   gpio_in sampled into GPIO_DATA
//
// NOTES:
// -------------------------------------------------------
// - APB3-style simple slave
// - No wait states
// - PREADY always asserted
// - 8-bit GPIO interface
//========================================================

module apb_gpio (

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
    output wire                        PREADY,

    //====================================================
    // GPIO INTERFACE
    //====================================================
    input  wire [7:0]                  gpio_in,

    output wire [7:0]                  gpio_out,
    output wire [7:0]                  gpio_dir
);

    //====================================================
    // INTERNAL REGISTERS
    //====================================================
    reg [7:0] gpio_data_reg;
    reg [7:0] gpio_dir_reg;

    integer i;

    //====================================================
    // APB READY
    //====================================================
    assign PREADY = 1'b1;

    //====================================================
    // GPIO CONNECTIONS
    //====================================================
    assign gpio_out = gpio_data_reg;
    assign gpio_dir = gpio_dir_reg;

    //====================================================
    // GPIO INPUT SAMPLING
    //====================================================
    always @(posedge PCLK or negedge PRESETn) begin

        if (!PRESETn) begin

            gpio_data_reg <= 8'h00;

        end

        else begin

            for (i = 0; i < 8; i = i + 1) begin

                if (gpio_dir_reg[i] == 1'b0) begin

                    gpio_data_reg[i] <= gpio_in[i];

                end

            end

        end

    end

    //====================================================
    // APB WRITE LOGIC
    //====================================================
    always @(posedge PCLK or negedge PRESETn) begin

        if (!PRESETn) begin

            gpio_data_reg <= 8'h00;
            gpio_dir_reg  <= 8'h00;

            $display("[GPIO][RESET] TIME=%0t GPIO reset done",
                     $time);

        end

        else begin

            if (PSEL && PENABLE && PWRITE) begin

                case (PADDR[7:0])

                    //========================================
                    // GPIO_DATA REGISTER
                    //========================================
                    8'h00: begin

                        for (i = 0; i < 8; i = i + 1) begin

                            if (gpio_dir_reg[i]) begin

                                gpio_data_reg[i] <= PWDATA[i];

                            end

                        end

                        $display("[GPIO][WRITE] TIME=%0t REG=GPIO_DATA DATA=0x%0h",
                                 $time,
                                 PWDATA[7:0]);

                    end

                    //========================================
                    // GPIO_DIR REGISTER
                    //========================================
                    8'h04: begin

                        gpio_dir_reg <= PWDATA[7:0];

                        $display("[GPIO][WRITE] TIME=%0t REG=GPIO_DIR DATA=0x%0h",
                                 $time,
                                 PWDATA[7:0]);

                    end

                    //========================================
                    // INVALID ADDRESS
                    //========================================
                    default: begin

                        $display("[GPIO][INVALID_WRITE] TIME=%0t ADDR=0x%0h",
                                 $time,
                                 PADDR);

                    end

                endcase

            end

        end

    end

    //====================================================
    // APB READ LOGIC
    //====================================================
    always @(*) begin

        PRDATA = 32'h00000000;

        if (PSEL && !PWRITE) begin

            case (PADDR[7:0])

                //============================================
                // GPIO_DATA
                //============================================
                8'h00: begin

                    PRDATA = {24'h0, gpio_data_reg};

                end

                //============================================
                // GPIO_DIR
                //============================================
                8'h04: begin

                    PRDATA = {24'h0, gpio_dir_reg};

                end

                //============================================
                // INVALID ADDRESS
                //============================================
                default: begin

                    PRDATA = 32'hDEADBEEF;

                end

            endcase

        end

    end

endmodule

