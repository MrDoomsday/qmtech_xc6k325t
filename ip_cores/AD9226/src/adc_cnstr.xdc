# adc top module
set_property ASYNC_REG TRUE [get_cells -hier *adc_reset_sync_reg*]
set_false_path -from [get_cells -hier *adc_reset_sync_reg[3]*]

# reset
set_property ASYNC_REG TRUE [get_cells -hier *sync_reset_n_reg*]
set_false_path -from [get_cells -hier *sync_reset_n_reg[3]*]

# loop pulse
set_property ASYNC_REG TRUE [get_cells -hier *m_pulse_req_sync_reg*]
set_property ASYNC_REG TRUE [get_cells -hier *s_pulse_resp_sync_reg*]

set_false_path -from [get_cells -hier *s_pulse_req_gen_reg*] -to [get_cells -hier *m_pulse_req_sync_reg[0]*]
set_false_path -from [get_cells -hier *m_pulse_resp_gen_reg*] -to [get_cells -hier *s_pulse_resp_sync_reg[0]*]

# other register
set_false_path -from [get_cells -hier -filter {name =~ *s_min_ampl_reg_reg* && IS_SEQUENTIAL}] \
               -to   [get_cells -hier -filter {name =~ *m_min_ampl_o_reg* && IS_SEQUENTIAL}]
set_false_path -from [get_cells -hier -filter {name =~ *m_over_word_reg_reg* && IS_SEQUENTIAL}] \
               -to   [get_cells -hier -filter {name =~ *s_over_word_o_reg* && IS_SEQUENTIAL}]
set_false_path -from [get_cells -hier -filter {name =~ *m_drop_word_reg_reg* && IS_SEQUENTIAL}] \
               -to   [get_cells -hier -filter {name =~ *s_drop_word_o_reg* && IS_SEQUENTIAL}]
set_false_path -to   [get_cells -hier *m_adc_en_o_reg*]


# dc fifo
set_property ASYNC_REG TRUE [get_cells -hier *wr_ptr_cdc_reg*]
set_false_path -from [get_cells -hier -filter {name =~ *wr_ptr_reg* && IS_SEQUENTIAL}]

set_property ASYNC_REG TRUE [get_cells -hier *rd_ptr_cdc_reg*]
set_false_path -from [get_cells -hier -filter {name =~ *rd_ptr_reg* && IS_SEQUENTIAL}]

set_false_path -to [get_cells -hier -filter {name =~ *m_data_o_reg* && IS_SEQUENTIAL}]

set_false_path -from [get_cells -hier *m_adc_en_o*]


