module golden_top(
    input sys_clk,
    input sys_rst_n,

// LED PINS
    output led_1,
    output led_2,

//GPIO U4
	output GPIO_U4_7,
	output GPIO_U4_8,
	output GPIO_U4_9,
	output GPIO_U4_10,
	output GPIO_U4_11,
	output GPIO_U4_12,
	output GPIO_U4_13,
	output GPIO_U4_14,
	output GPIO_U4_15,
	output GPIO_U4_16,
	output GPIO_U4_17,
	output GPIO_U4_18,
	output GPIO_U4_19,
	output GPIO_U4_20,
	output GPIO_U4_21,
	output GPIO_U4_22,
	output GPIO_U4_23,
	output GPIO_U4_24,
	output GPIO_U4_25,
	output GPIO_U4_26,
	output GPIO_U4_27,
	output GPIO_U4_28,
	output GPIO_U4_29,
	output GPIO_U4_30,
	output GPIO_U4_31,
	output GPIO_U4_32,
	output GPIO_U4_33,
	output GPIO_U4_34,
	output GPIO_U4_35,
	output GPIO_U4_36,
	output GPIO_U4_37,
	output GPIO_U4_38,
	output GPIO_U4_39,
	output GPIO_U4_40,
	output GPIO_U4_41,
	output GPIO_U4_42,
	output GPIO_U4_43,
	output GPIO_U4_44,
	output GPIO_U4_45,
	output GPIO_U4_46,
	input GPIO_U4_47,
	input GPIO_U4_48,
	input GPIO_U4_49,
	input GPIO_U4_50,
	input GPIO_U4_51,
	input GPIO_U4_52,
	input GPIO_U4_53,
	input GPIO_U4_54,
	input GPIO_U4_55,
	input GPIO_U4_56,
	input GPIO_U4_57,
	input GPIO_U4_58,
	input GPIO_U4_59,
	output GPIO_U4_60,
//GPIO U5
	output GPIO_U5_7,
	output GPIO_U5_8,
	output GPIO_U5_9,
	output GPIO_U5_10,
	output GPIO_U5_11,
	output GPIO_U5_12,
	output GPIO_U5_13,
	output GPIO_U5_14,
	output GPIO_U5_15,
	output GPIO_U5_16,
	output GPIO_U5_17,
	output GPIO_U5_18,
	output GPIO_U5_19,
	output GPIO_U5_20,
	output GPIO_U5_21,
	output GPIO_U5_22,
	output GPIO_U5_23,
	output GPIO_U5_24,
	output GPIO_U5_25,
	output GPIO_U5_26,
	output GPIO_U5_27,
	output GPIO_U5_28,
	output GPIO_U5_29,
	output GPIO_U5_30,
	output GPIO_U5_31,
	output GPIO_U5_32,
	output GPIO_U5_33,
	output GPIO_U5_34,
	output GPIO_U5_35,
	output GPIO_U5_36,
	output GPIO_U5_37,
	output GPIO_U5_38,
	output GPIO_U5_39,
	output GPIO_U5_40,
	output GPIO_U5_41,
	output GPIO_U5_42,
	output GPIO_U5_43,
	output GPIO_U5_44,
	output GPIO_U5_45,
	output GPIO_U5_46,
	output GPIO_U5_47,
	output GPIO_U5_48,
	output GPIO_U5_49,
	output GPIO_U5_50,
	output GPIO_U5_51,
	output GPIO_U5_52,
	output GPIO_U5_53,
	output GPIO_U5_54,
	output GPIO_U5_55,
	output GPIO_U5_56,
	input GPIO_U5_57,
	output GPIO_U5_58,
	inout GPIO_U5_59,
	inout GPIO_U5_60,

// DDR3
// Inouts
	inout [15:0]       	ddr3_dq,
	inout [1:0]        	ddr3_dqs_n,
	inout [1:0]        	ddr3_dqs_p,
// Outputs
	output [13:0]     	ddr3_addr,
	output [2:0]      	ddr3_ba,
	output            	ddr3_ras_n,
	output            	ddr3_cas_n,
	output            	ddr3_we_n,
	output            	ddr3_reset_n,
	output [0:0]      	ddr3_ck_p,
	output [0:0]      	ddr3_ck_n,
	output [0:0]      	ddr3_cke,
	output [1:0]     	ddr3_dm,
	output [0:0]       	ddr3_odt

);


reg [9:0] reset_counter;
reg soft_reset_n;
wire init_calib_complete;
wire mmcm_locked;
wire clk_50;

wire [11:0] adc_data;
wire adc_clk;
wire adc_otr;

// temp wires
wire [15:0] axis_data;
wire axis_tvalid;
wire axis_otr;

//instance block design
top_bd_wrapper top_bd_wrapper_inst (    
	.ddr3_addr			(ddr3_addr),
    .ddr3_ba			(ddr3_ba),
    .ddr3_cas_n			(ddr3_cas_n),
    .ddr3_ck_n			(ddr3_ck_n),
    .ddr3_ck_p			(ddr3_ck_p),
    .ddr3_cke			(ddr3_cke),
    .ddr3_dm			(ddr3_dm),
    .ddr3_dq			(ddr3_dq),
    .ddr3_dqs_n			(ddr3_dqs_n),
    .ddr3_dqs_p			(ddr3_dqs_p),
    .ddr3_odt			(ddr3_odt),
    .ddr3_ras_n			(ddr3_ras_n),
    .ddr3_reset_n		(ddr3_reset_n),
    .ddr3_we_n			(ddr3_we_n),
    
	.ext_reset_n		(soft_reset_n),
    .init_calib_complete(init_calib_complete),
    .mmcm_locked		(mmcm_locked),
    .sys_clk			(sys_clk),
    .clk_50_o           (clk_50),
    
    .adc_clk_o  (adc_clk),
    .adc_data_i (adc_data),
    .adc_otr_i  (adc_otr),
    
    
    .adc_otr_o          (axis_otr),
    .m_axis_0_tdata     (axis_data),
    .m_axis_0_tready    (1'b1),
    .m_axis_0_tvalid    (axis_tvalid)
    
);
// (* mark_debug = "TRUE" *)

	//reset logic 
	always @ (posedge clk_50 or negedge sys_rst_n) begin
		if(!sys_rst_n) begin
			reset_counter <= 10'h0;
			soft_reset_n <= 1'b0;
		end
		else if(reset_counter < 10'd1023) begin
			reset_counter <= reset_counter + 10'h1;
			soft_reset_n <= 1'b0;
		end
		else begin
			reset_counter <= reset_counter;
			soft_reset_n <= 1'b1;
		end
	end



// pinout blink
	(* mark_debug = "TRUE" *) reg [31:0] gp_counter;

	always @(posedge clk_50 or negedge soft_reset_n) begin
		if(!soft_reset_n) gp_counter <= 32'h0;
		else gp_counter <= gp_counter + 32'h1;
	end

	assign led_1 = init_calib_complete & mmcm_locked? gp_counter[23] : 1'b1;
	assign led_2 = ^{axis_otr, axis_data, axis_tvalid};

// assign ADC
    assign GPIO_U4_60 = adc_clk;

    assign {adc_otr, adc_data} = {  GPIO_U4_47,
                                    GPIO_U4_48,
                                    GPIO_U4_49,
                                    GPIO_U4_50,
                                    GPIO_U4_51,
                                    GPIO_U4_52,
                                    GPIO_U4_53,
                                    GPIO_U4_54,
                                    GPIO_U4_55,
                                    GPIO_U4_56,
                                    GPIO_U4_57,
                                    GPIO_U4_58,
                                    GPIO_U4_59
                                 };
                                    
	assign GPIO_U4_43 = 1'bZ;
	assign GPIO_U4_44 = 1'bZ;
	assign GPIO_U4_45 = 1'bZ;
	assign GPIO_U4_46 = 1'bZ;
	
endmodule