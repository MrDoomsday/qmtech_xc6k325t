/***********************************************************************************************************************/
/*******************************************            IMPORT/INCLUDE      ********************************************/
/***********************************************************************************************************************/
`include "adc_interface.sv"
`include "adc_axi_lite_access.sv"

module driver_ad9226_tb();

/***********************************************************************************************************************/
/*******************************************            DECLARATION      ***********************************************/
/***********************************************************************************************************************/
    localparam int unsigned AXIL_ADDR_WIDTH = 4;
    localparam int unsigned AXIL_DATA_WIDTH = 32;


    reg axi_clk;
    reg axi_reset_n;
    reg axis_clk;
    reg axis_reset_n;

    axi_lite_if #(
        .ADDR_WIDTH ( AXIL_ADDR_WIDTH   ),
        .DATA_WIDTH ( AXIL_DATA_WIDTH   )
    ) axil_intf (axi_clk, axi_reset_n);

    wire [15:0] m_axis_data_o;
    wire m_axis_valid_o;
    reg m_axis_ready_i;
    reg adc_clk_i;
    reg [11:0] adc_data_i;
    reg adc_otr_i;
    wire adc_en_o;
    wire adc_otr_o;


    axi_lite_access #(
        .ADDR_WIDTH ( AXIL_ADDR_WIDTH ),
        .DATA_WIDTH ( AXIL_DATA_WIDTH )
    ) axi_lite;

// offset registers
    const logic [31:0] offset_adc_control = 'h0;
    const logic [31:0] offset_adc_minampl = 'h4;
    const logic [31:0] offset_adc_overflow = 'h8;
    const logic [31:0] offset_adc_drop = 'hC;

/***********************************************************************************************************************/
/*****************************************            INSTANCE            **********************************************/
/***********************************************************************************************************************/
    driver_ad9226 DUT (
        .axi_clk        (axi_clk),
        .axi_reset_n    (axi_reset_n),

        .axis_clk       (axis_clk),
        .axis_reset_n   (axis_reset_n),

        .s_axil_awready ( axil_intf.awready     ),
        .s_axil_awvalid ( axil_intf.awvalid     ),
        .s_axil_awaddr  ( axil_intf.awaddr      ),
        .s_axil_awprot  ( axil_intf.awprot      ),
        .s_axil_wready  ( axil_intf.wready      ),
        .s_axil_wvalid  ( axil_intf.wvalid      ),
        .s_axil_wdata   ( axil_intf.wdata       ),
        .s_axil_wstrb   ( axil_intf.wstrb       ),
        .s_axil_bready  ( axil_intf.bready      ),
        .s_axil_bvalid  ( axil_intf.bvalid      ),
        .s_axil_bresp   ( axil_intf.bresp       ),
        .s_axil_arready ( axil_intf.arready     ),
        .s_axil_arvalid ( axil_intf.arvalid     ),
        .s_axil_araddr  ( axil_intf.araddr      ),
        .s_axil_arprot  ( axil_intf.arprot      ),
        .s_axil_rready  ( axil_intf.rready      ),
        .s_axil_rvalid  ( axil_intf.rvalid      ),
        .s_axil_rdata   ( axil_intf.rdata       ),
        .s_axil_rresp   ( axil_intf.rresp       ),

        .m_axis_data_o  (m_axis_data_o),
        .m_axis_valid_o (m_axis_valid_o),
        .m_axis_ready_i (m_axis_ready_i),

        .adc_clk_i      (adc_clk_i),
        .adc_data_i     (adc_data_i),
        .adc_otr_i      (adc_otr_i),
        .adc_en_o       (adc_en_o),
        .adc_otr_o      (adc_otr_o)
    );

/***********************************************************************************************************************/
/*******************************************            BEHAVIOR         ***********************************************/
/***********************************************************************************************************************/
// AXI4-Lite clock and reset
    always begin
        axi_clk = 1'b0;
        #10;
        axi_clk = 1'b1;
        #10;
    end

    task gen_reset_axil();
        axi_reset_n <= 1'b0;
        repeat(10) @ (posedge axi_clk);
        axi_reset_n <= 1'b1;
    endtask

// AXI4-Stream clock and reset
    always begin
        axis_clk = 1'b0;
        #2;
        axis_clk = 1'b1;
        #2;
    end

    task gen_reset_axis();
        axis_reset_n <= 1'b0;
        repeat(10) @ (posedge axis_clk);
        axis_reset_n <= 1'b1;
    endtask

// ADC free clock
    always begin
        adc_clk_i = 1'b0;
        #7;
        adc_clk_i = 1'b1;
        #7;
    end

// common tasks
    task gen_adc_data();
        adc_data_i <= '0;
        adc_otr_i <= '0;
        repeat(100) @(posedge adc_clk_i);
        forever begin
            adc_data_i <= $urandom();
            adc_otr_i <= $urandom();
            @(posedge adc_clk_i);
        end
    endtask

    task m_axis_drv();
        m_axis_ready_i <= '0;
        wait(axis_reset_n);
        forever begin
            m_axis_ready_i <= '1;
            repeat($urandom_range(5, 0)) @(posedge axis_clk);
            m_axis_ready_i <= '0;
            repeat($urandom_range(2, 0)) @(posedge axis_clk);
        end
    endtask

    task test();
        // common
        logic [AXIL_DATA_WIDTH-1:0] readdata;

        // write enable bit
        axi_lite.write_transaction(offset_adc_control, '1, 32'h1);

        // set minimal amplitude
        axi_lite.write_transaction(offset_adc_minampl, '1, 32'h100);

    
        repeat(10000) @(posedge axis_clk);
    endtask

/***********************************************************************************************************************/
/*******************************************            TEST             ***********************************************/
/***********************************************************************************************************************/
    initial begin
        // new
        axi_lite = new();

        // connect interface 
        axi_lite.vif_axi_lite = axil_intf;
        
        // initialization
        fork
            gen_reset_axil();
            gen_reset_axis();
            gen_adc_data();
            m_axis_drv();
            axi_lite.run();
        join_none

        // test
        test();

        // stop tb
        $stop();
    end

endmodule