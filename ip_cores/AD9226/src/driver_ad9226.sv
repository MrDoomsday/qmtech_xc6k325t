// `include "adc_driver_csr_pkg.sv"

module driver_ad9226 (
	input 	logic 					axi_clk,
	input 	logic 					axi_reset_n,

	input 	logic 					axis_clk,
	input 	logic 					axis_reset_n,

	// AXI4-Lite
	output 	logic 					s_axil_awready,
	input 	wire 					s_axil_awvalid,
	input	wire 			[3:0] 	s_axil_awaddr,
	input	wire 			[2:0] 	s_axil_awprot,
	output 	logic 					s_axil_wready,
	input 	wire 					s_axil_wvalid,
	input 	wire 			[31:0] 	s_axil_wdata,
	input 	wire 			[3:0]	s_axil_wstrb,
	input 	wire 					s_axil_bready,
	output 	logic 					s_axil_bvalid,
	output 	logic 			[1:0] 	s_axil_bresp,
	output 	logic 					s_axil_arready,
	input 	wire 					s_axil_arvalid,
	input 	wire 			[3:0] 	s_axil_araddr,
	input 	wire 			[2:0] 	s_axil_arprot,
	input 	wire 					s_axil_rready,
	output 	logic 					s_axil_rvalid,
	output 	logic 			[31:0] 	s_axil_rdata,
	output 	logic 			[1:0] 	s_axil_rresp,
	

	// AXI4-Stream 
	output 	logic signed 	[15:0] 	m_axis_data_o,
	output 	logic 					m_axis_valid_o,
	input 	logic 					m_axis_ready_i,
	
	// ADC interface 
	input 	logic 					adc_clk_i, 	// тактовый сигнал, на котором планируется прием данных от АЦП
	input	logic 			[11:0] 	adc_data_i, // принимаемые данные от АЦП
	input 	logic 					adc_otr_i, 	// сигнал переполнения разрядной сетки
	output 	logic					adc_en_o, 
	
	output 	logic 					adc_otr_o // аппаратно-программное переполнение разрядной сетки
);



/***********************************************************************************************************************/
/*******************************************            DECLARATION      ***********************************************/
/***********************************************************************************************************************/
	logic 			adc_reset_n;
	logic 	[3:0] 	adc_reset_sync;
	
    adc_driver_csr_pkg::adc_driver_csr__in_t hwif_in;
    adc_driver_csr_pkg::adc_driver_csr__out_t hwif_out;

	reg 	[12:0] 	adc_data_sync [1:0];
	logic 			s_adc_dcfifo_ready;
    logic   [12:0]  m_adc_dcfifo_data;
    logic       	m_adc_dcfifo_valid;
    logic           m_adc_dcfifo_ready;
	logic           m_adc_dcfifo_full;
	

	logic cnt_over_impl, cnt_drop_impl;
	logic [31:0] stat_cnt_over_word, stat_cnt_drop_word;
	logic adc_en;

	reg [11:0] min_ampl_reg; // минимальная амплитуда для выставления сигнала soft_otr
	wire soft_otr;

/***********************************************************************************************************************/
/*****************************************            INSTANCE            **********************************************/
/***********************************************************************************************************************/
	adc_driver_csr adc_driver_csr_inst (
		.clk(axi_clk),
		.rst(~axi_reset_n),
		.s_axil_awready(s_axil_awready),
		.s_axil_awvalid(s_axil_awvalid),
		.s_axil_awaddr(s_axil_awaddr),
		.s_axil_awprot(s_axil_awprot),
		.s_axil_wready(s_axil_wready),
		.s_axil_wvalid(s_axil_wvalid),
		.s_axil_wdata(s_axil_wdata),
		.s_axil_wstrb(s_axil_wstrb),
		.s_axil_bready(s_axil_bready),
		.s_axil_bvalid(s_axil_bvalid),
		.s_axil_bresp(s_axil_bresp),
		.s_axil_arready(s_axil_arready),
		.s_axil_arvalid(s_axil_arvalid),
		.s_axil_araddr(s_axil_araddr),
		.s_axil_arprot(s_axil_arprot),
		.s_axil_rready(s_axil_rready),
		.s_axil_rvalid(s_axil_rvalid),
		.s_axil_rdata(s_axil_rdata),
		.s_axil_rresp(s_axil_rresp),

		.hwif_in(hwif_in),
		.hwif_out(hwif_out)
	);


	adc_cdc adc_cdc_inst (
		.s_clk			( axi_clk),
		.s_reset_n		( axi_reset_n),
		.s_adc_en_i		( hwif_out.adc_control.enable.value),
		.s_min_ampl_i	( hwif_out.adc_minampl.minampl.value),
		.s_over_word_o	( hwif_in.adc_counter_overflow.amount_overflow.next),
		.s_drop_word_o	( hwif_in.adc_drop_word.amount.next),
		
		.m_clk			( axis_clk),
		.m_adc_en_o		( adc_en ),
		.m_min_ampl_o	( min_ampl_reg),
		.m_over_word_i	( stat_cnt_over_word),
		.m_drop_word_i	( stat_cnt_drop_word)
	);

	adc_axis_dcfifo # (
		.DATA_WIDTH(12+1),
		.FIFO_DEPTH(8),
		.WR_CDC_STAGE(2),
		.RD_CDC_STAGE(2)
	) adc_axis_dcfifo_inst (
		.s_clk		(adc_clk_i),
		.s_reset_n	(adc_reset_n),
		.s_data_i	(adc_data_sync[1]),
		.s_valid_i	(adc_en),
		.s_ready_o	(s_adc_dcfifo_ready),
		.s_fifo_usedw_o(),
		.s_fifo_availwd_o(),
		.s_fifo_empty_o(),
		.s_fifo_full_o(),

		.m_clk		(axis_clk),
		.m_reset_n	(axis_reset_n),
		.m_data_o	(m_adc_dcfifo_data),
		.m_valid_o	(m_adc_dcfifo_valid),
		.m_ready_i	(m_adc_dcfifo_ready),
		.m_fifo_usedw_o(),
		.m_fifo_availwd_o(),
		.m_fifo_empty_o(),
		.m_fifo_full_o(m_adc_dcfifo_full)
	);


	adc_statistic  adc_statistic_inst (
		.axis_clk(axis_clk),
		.axis_reset_n(axis_reset_n),

		.cnt_over_impl_i(cnt_over_impl),
		.cnt_drop_impl_i(cnt_drop_impl),
		
		.stat_cnt_over_word_o(stat_cnt_over_word),
		.stat_cnt_drop_word_o(stat_cnt_drop_word)
	);


/***********************************************************************************************************************/
/*******************************************            LOGIC            ***********************************************/
/***********************************************************************************************************************/
	always_ff @(posedge adc_clk_i or negedge axis_reset_n) begin
		if(!axis_reset_n) begin
			adc_reset_sync <= '0;
		end else begin
			adc_reset_sync <= {adc_reset_sync[2:0], 1'b1};
		end
	end

	assign adc_reset_n = adc_reset_sync[3];



// synchronization
	always_ff @(posedge adc_clk_i) begin 
		// adc_data_sync[0] <= {adc_otr_i, {	adc_data_i[0], 
		// 									adc_data_i[1], 
		// 									adc_data_i[2], 
		// 									adc_data_i[3], 
		// 									adc_data_i[4], 
		// 									adc_data_i[5], 
		// 									adc_data_i[6], 
		// 									adc_data_i[7], 
		// 									adc_data_i[8], 
		// 									adc_data_i[9], 
		// 									adc_data_i[10], 
		// 									adc_data_i[11]
		// 								}
		// 					};
		adc_data_sync[0] <= {adc_otr_i, adc_data_i[11:0]};
		adc_data_sync[1] <= adc_data_sync[0];
	end 

// statistic
	assign cnt_over_impl = adc_otr_o & m_axis_valid_o & m_axis_ready_i;
	assign cnt_drop_impl = ~m_adc_dcfifo_ready & m_adc_dcfifo_full;

// AXIS4-Stream
	assign m_axis_data_o = {{4{m_adc_dcfifo_data[11]}}, m_adc_dcfifo_data[11:0]};
	assign m_axis_valid_o = m_adc_dcfifo_valid;
	assign adc_otr_o = m_adc_dcfifo_data[12] | soft_otr;


// other
	assign m_adc_dcfifo_ready = m_axis_ready_i;
	assign adc_en_o = hwif_out.adc_control.enable.value;
	assign soft_otr = $signed(m_axis_data_o) >= $signed(min_ampl_reg);

endmodule 