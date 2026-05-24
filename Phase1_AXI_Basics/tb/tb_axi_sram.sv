
    initial begin
        ACLK = 0;
        forever #5 ACLK = ~ACLK; // 100MHz
    end

    initial begin
        ARESETn = 0;
        repeat(5) @(posedge ACLK);
        ARESETn = 1;
    end

    //====================================================
    // AXI MASTER SIGNALS
    //====================================================
    reg [`AXI_ADDR_WIDTH-1:0] AWADDR;
    reg                       AWVALID;
    wire                      AWREADY;

    reg [`AXI_DATA_WIDTH-1:0] WDATA;
    reg [`AXI_STRB_WIDTH-1:0] WSTRB;
    reg                       WVALID;
    wire                      WREADY;

    wire [1:0]                BRESP;
    wire                      BVALID;
    reg                       BREADY;

    reg [`AXI_ADDR_WIDTH-1:0] ARADDR;
    reg                       ARVALID;
    wire                      ARREADY;

    wire [`AXI_DATA_WIDTH-1:0] RDATA;
    wire [1:0]                 RRESP;
    wire                       RVALID;
    reg                        RREADY;

    //====================================================
    // DUT INSTANCE
    //====================================================
    axi_sram dut (
        .ACLK    (ACLK),
        .ARESETn (ARESETn),

        .AWADDR  (AWADDR),
        .AWVALID (AWVALID),
        .AWREADY (AWREADY),

        .WDATA   (WDATA),
        .WSTRB   (WSTRB),
        .WVALID  (WVALID),
        .WREADY  (WREADY),

        .BRESP   (BRESP),
        .BVALID  (BVALID),
        .BREADY  (BREADY),

        .ARADDR  (ARADDR),
        .ARVALID (ARVALID),
        .ARREADY (ARREADY),

        .RDATA   (RDATA),
        .RRESP   (RRESP),
        .RVALID  (RVALID),
        .RREADY  (RREADY)
    );

    //====================================================
    // REFERENCE MEMORY FOR SCOREBOARD
    //====================================================
    reg [`AXI_DATA_WIDTH-1:0] ref_mem [0:255];

    //====================================================
    // TASK : AXI WRITE
    //====================================================
    task axi_write(input [31:0] addr, input [31:0] data, input [3:0] strobe);
        begin
            // drive address
            AWADDR  <= addr;
            AWVALID <= 1;
            // drive data
            WDATA   <= data;
            WSTRB   <= strobe;
            WVALID  <= 1;
            BREADY  <= 1;

            // wait for handshake
            wait (AWREADY && WREADY);
            @(posedge ACLK);

            // de-assert
            AWVALID <= 0;
            WVALID  <= 0;

            // wait for BVALID
            wait (BVALID);
            @(posedge ACLK);

            // update reference memory
            //integer i;
            for (integer i = 0; i < 4; i = i + 1)
                if (strobe[i])
                    ref_mem[addr[7:2]][8*i +: 8] <= data[8*i +: 8];

            $display("[TB][WRITE] Addr=0x%0h Data=0x%0h Time=%0t", addr, data, $time);

            BREADY <= 0;
        end
    endtask

    //====================================================
    // TASK : AXI READ
    //====================================================
    task axi_read(input [31:0] addr);
        reg [31:0] expected;
        begin
            ARADDR  <= addr;
            ARVALID <= 1;
            RREADY  <= 1;

            wait (ARREADY);
            @(posedge ACLK);
            ARVALID <= 0;

            wait (RVALID);
            @(posedge ACLK);

            expected = ref_mem[addr[7:2]];
            if (RDATA === expected)
                $display("[TB][READ_PASS] Addr=0x%0h Data=0x%0h Time=%0t", addr, RDATA, $time);
            else
                $display("[TB][READ_FAIL] Addr=0x%0h Data=0x%0h Expected=0x%0h Time=%0t",
                         addr, RDATA, expected, $time);

            RREADY <= 0;
        end
    endtask

    //====================================================
    // INITIALIZE REFERENCE MEMORY
    //====================================================
    initial begin
        integer i;
        for (i = 0; i < 256; i = i + 1)
            ref_mem[i] = 32'h0;
    end

    //====================================================
    // MAIN TEST
    //====================================================
    initial begin
        wait(ARESETn);

        $display("\n=======================");
        $display("  AXI SRAM TEST START  ");
        $display("=======================\n");

        //====================================================
        // TEST 1 : SRAM SINGLE WRITE/READ
        //====================================================
        axi_write(`SRAM_BASE_ADDR + 32'h00, 32'hDEADBEEF, 4'b1111);
        axi_read(`SRAM_BASE_ADDR + 32'h00);

        //====================================================
        // TEST 2 : MULTIPLE WRITES
	//====================================================
        axi_write(`SRAM_BASE_ADDR + 32'h04, 32'h12345678, 4'b1111);
        axi_write(`SRAM_BASE_ADDR + 32'h08, 32'hA5A5A5A5, 4'b1111);
        axi_read(`SRAM_BASE_ADDR + 32'h04);
        axi_read(`SRAM_BASE_ADDR + 32'h08);

        //====================================================
        // TEST 3 : BYTE STROBE
	//====================================================
        axi_write(`SRAM_BASE_ADDR + 32'h0C, 32'hFFFF0000, 4'b1100); // upper 2 bytes only
        axi_read(`SRAM_BASE_ADDR + 32'h0C);

        //====================================================
        // TEST 4 : RANDOM ACCESS
	//====================================================
        axi_write(`SRAM_BASE_ADDR + 32'h10, 32'h0F0F0F0F, 4'b1111);
        axi_read(`SRAM_BASE_ADDR + 32'h10);

        $display("\n=======================");
        $display("  AXI SRAM TEST END    ");
        $display("=======================\n");

        #20 $finish;
    end

    //====================================================
    // WAVE DUMP
    //====================================================
    initial begin
        $vcdplusfile("axi_sram.vpd");
        $vcdpluson;
    end

endmodule

