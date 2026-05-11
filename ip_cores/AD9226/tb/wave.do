onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group AXI4-Lite /driver_ad9226_tb/DUT/axi_clk
add wave -noupdate -expand -group AXI4-Lite /driver_ad9226_tb/DUT/axi_reset_n
add wave -noupdate -expand -group AXI4-Lite /driver_ad9226_tb/DUT/s_axil_awready
add wave -noupdate -expand -group AXI4-Lite /driver_ad9226_tb/DUT/s_axil_awvalid
add wave -noupdate -expand -group AXI4-Lite /driver_ad9226_tb/DUT/s_axil_awaddr
add wave -noupdate -expand -group AXI4-Lite /driver_ad9226_tb/DUT/s_axil_awprot
add wave -noupdate -expand -group AXI4-Lite /driver_ad9226_tb/DUT/s_axil_wready
add wave -noupdate -expand -group AXI4-Lite /driver_ad9226_tb/DUT/s_axil_wvalid
add wave -noupdate -expand -group AXI4-Lite /driver_ad9226_tb/DUT/s_axil_wdata
add wave -noupdate -expand -group AXI4-Lite /driver_ad9226_tb/DUT/s_axil_wstrb
add wave -noupdate -expand -group AXI4-Lite /driver_ad9226_tb/DUT/s_axil_bready
add wave -noupdate -expand -group AXI4-Lite /driver_ad9226_tb/DUT/s_axil_bvalid
add wave -noupdate -expand -group AXI4-Lite /driver_ad9226_tb/DUT/s_axil_bresp
add wave -noupdate -expand -group AXI4-Lite /driver_ad9226_tb/DUT/s_axil_arready
add wave -noupdate -expand -group AXI4-Lite /driver_ad9226_tb/DUT/s_axil_arvalid
add wave -noupdate -expand -group AXI4-Lite /driver_ad9226_tb/DUT/s_axil_araddr
add wave -noupdate -expand -group AXI4-Lite /driver_ad9226_tb/DUT/s_axil_arprot
add wave -noupdate -expand -group AXI4-Lite /driver_ad9226_tb/DUT/s_axil_rready
add wave -noupdate -expand -group AXI4-Lite /driver_ad9226_tb/DUT/s_axil_rvalid
add wave -noupdate -expand -group AXI4-Lite /driver_ad9226_tb/DUT/s_axil_rdata
add wave -noupdate -expand -group AXI4-Lite /driver_ad9226_tb/DUT/s_axil_rresp
add wave -noupdate -expand -group AXI4-Stream /driver_ad9226_tb/DUT/axis_clk
add wave -noupdate -expand -group AXI4-Stream /driver_ad9226_tb/DUT/axis_reset_n
add wave -noupdate -expand -group AXI4-Stream /driver_ad9226_tb/DUT/m_axis_data_o
add wave -noupdate -expand -group AXI4-Stream /driver_ad9226_tb/DUT/m_axis_valid_o
add wave -noupdate -expand -group AXI4-Stream /driver_ad9226_tb/DUT/m_axis_ready_i
add wave -noupdate -expand -group ADC /driver_ad9226_tb/DUT/adc_clk_i
add wave -noupdate -expand -group ADC /driver_ad9226_tb/DUT/adc_data_i
add wave -noupdate -expand -group ADC /driver_ad9226_tb/DUT/adc_otr_i
add wave -noupdate -expand -group ADC /driver_ad9226_tb/DUT/adc_en_o
add wave -noupdate -expand -group ADC /driver_ad9226_tb/DUT/adc_otr_o
add wave -noupdate -expand -group debug /driver_ad9226_tb/DUT/adc_reset_n
add wave -noupdate -expand -group debug /driver_ad9226_tb/DUT/adc_reset_sync
add wave -noupdate -expand -group debug /driver_ad9226_tb/DUT/hwif_in
add wave -noupdate -expand -group debug /driver_ad9226_tb/DUT/hwif_out
add wave -noupdate -expand -group debug /driver_ad9226_tb/DUT/adc_data_sync
add wave -noupdate -expand -group debug /driver_ad9226_tb/DUT/s_adc_dcfifo_ready
add wave -noupdate -expand -group debug /driver_ad9226_tb/DUT/m_adc_dcfifo_data
add wave -noupdate -expand -group debug /driver_ad9226_tb/DUT/m_adc_dcfifo_valid
add wave -noupdate -expand -group debug /driver_ad9226_tb/DUT/m_adc_dcfifo_ready
add wave -noupdate -expand -group debug /driver_ad9226_tb/DUT/m_adc_dcfifo_full
add wave -noupdate -expand -group debug /driver_ad9226_tb/DUT/cnt_over_impl
add wave -noupdate -expand -group debug /driver_ad9226_tb/DUT/cnt_drop_impl
add wave -noupdate -expand -group debug /driver_ad9226_tb/DUT/stat_cnt_over_word
add wave -noupdate -expand -group debug /driver_ad9226_tb/DUT/stat_cnt_drop_word
add wave -noupdate -expand -group debug /driver_ad9226_tb/DUT/min_ampl_reg
add wave -noupdate -expand -group debug /driver_ad9226_tb/DUT/soft_otr
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {33439 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 297
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {27864 ns} {51030 ns}
