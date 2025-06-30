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
	output GPIO_U4_47,
	output GPIO_U4_48,
	output GPIO_U4_49,
	output GPIO_U4_50,
	output GPIO_U4_51,
	output GPIO_U4_52,
	output GPIO_U4_53,
	output GPIO_U4_54,
	output GPIO_U4_55,
	output GPIO_U4_56,
	output GPIO_U4_57,
	output GPIO_U4_58,
	output GPIO_U4_59,
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
	output GPIO_U5_57,
	output GPIO_U5_58,
	output GPIO_U5_59,
	output GPIO_U5_60,

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
    .clk_50_o           (clk_50)
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


	assign GPIO_U4_14 = gp_counter[0];
	assign GPIO_U4_8 = gp_counter[1];
	assign GPIO_U4_10 = gp_counter[2];
	assign GPIO_U4_18 = gp_counter[3];
	assign GPIO_U4_7 = gp_counter[4];
	assign GPIO_U4_13 = gp_counter[5];
	assign GPIO_U4_17 = gp_counter[6];
	assign GPIO_U4_19 = gp_counter[7];
	assign GPIO_U4_16 = gp_counter[8];
	assign GPIO_U4_11 = gp_counter[9];
	assign GPIO_U4_9 = gp_counter[10];
	assign GPIO_U4_15 = gp_counter[11];
	assign GPIO_U4_20 = gp_counter[12];
	assign GPIO_U4_21 = gp_counter[13];
	assign GPIO_U4_12 = gp_counter[14];
	assign GPIO_U4_36 = gp_counter[15];

	assign led_1 = init_calib_complete ? gp_counter[23] : 1'b1;
	assign led_2 = mmcm_locked ? gp_counter[25] : 1'b1;

	// lfsr
	(* mark_debug = "TRUE" *) reg [7:0] lfsr;

	always @(posedge clk_50 or negedge soft_reset_n) begin
		if(!soft_reset_n) begin
			lfsr <= 8'h1;
		end else if(gp_counter[29]) begin
			if(gp_counter[15:0] == 16'b1000_0000_0000_0000 && (gp_counter[28:16] > 0) && (gp_counter[28:16] < 13'b0_0001_0000_0000)) begin
				lfsr[0] <= lfsr[1];
				lfsr[1] <= lfsr[2];
				lfsr[2] <= lfsr[3];
				lfsr[3] <= lfsr[4] ^ lfsr[0];
				lfsr[4] <= lfsr[5] ^ lfsr[0];
				lfsr[5] <= lfsr[6] ^ lfsr[0];
				lfsr[6] <= lfsr[7];
				lfsr[7] <= lfsr[0];
			end
		end
	end

	assign GPIO_U4_50 = gp_counter[29] ? lfsr[0] : 1'b0;
	assign GPIO_U4_54 = gp_counter[29] ? lfsr[3] : 1'b0;

endmodule