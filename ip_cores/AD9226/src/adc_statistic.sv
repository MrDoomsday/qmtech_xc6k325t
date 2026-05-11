module adc_statistic (
    input logic axis_clk,
    input logic axis_reset_n,

    input logic cnt_over_impl_i,
    input logic cnt_drop_impl_i,
    
    output logic [31:0] stat_cnt_over_word_o,
    output logic [31:0] stat_cnt_drop_word_o
);
    
    always_ff @(posedge axis_clk or negedge axis_reset_n) begin
        if(!axis_reset_n) begin
            stat_cnt_over_word_o <= '0;
            stat_cnt_drop_word_o <= '0;
        end else begin
            if(cnt_over_impl_i) begin
                stat_cnt_over_word_o <= stat_cnt_over_word_o + 'h1;
            end

            if(cnt_drop_impl_i) begin
                stat_cnt_drop_word_o <= stat_cnt_drop_word_o + 'h1;
            end
        end
    end

endmodule