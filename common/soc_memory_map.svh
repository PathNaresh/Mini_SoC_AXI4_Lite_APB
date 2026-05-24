
`ifndef SOC_MEMORY_MAP_SVH
`define SOC_MEMORY_MAP_SVH

//====================================================
// AXI MEMORY MAP
//====================================================
`define SRAM_BASE_ADDR    32'h0000_0000
`define SRAM_END_ADDR     32'h0000_FFFF

`define APB_BASE_ADDR     32'h1000_0000
`define APB_END_ADDR      32'h1000_FFFF

//====================================================
// APB PERIPHERAL MAP
//====================================================
`define GPIO_BASE_ADDR    32'h1000_0000
`define UART_BASE_ADDR    32'h1000_1000
`define SPI_BASE_ADDR     32'h1000_2000
`define DMA_BASE_ADDR     32'h1000_3000

`endif

