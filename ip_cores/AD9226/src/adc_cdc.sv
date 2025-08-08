module adc_cdc(
    // s domain
    input   logic           s_clk,
    input   logic           s_reset_n,

    input   logic           s_adc_en_i,
    input   logic   [11:0]  s_min_ampl_i,
    output  logic   [31:0]  s_over_word_o,
    output  logic   [31:0]  s_drop_word_o,

    // m domain
    input   logic           m_clk,
    // input   logic           m_reset_n,

    output  logic           m_adc_en_o,
    output  logic   [11:0]  m_min_ampl_o,
    input   logic   [31:0]  m_over_word_i,
    input   logic   [31:0]  m_drop_word_i

);

/***********************************************************************************************************************/
/*******************************************            DECLARATION      ***********************************************/
/***********************************************************************************************************************/

    logic [3:0] sync_reset_n;
    logic m_reset_n;

    // импульсный синхронизатор регистров s <-> m
    logic s_impl;
    logic s_pulse_req_gen;
    logic [1:0] m_pulse_req_sync;
    logic m_pulse_req_reg;
    logic m_impl;
    logic m_pulse_resp_gen;
    logic [1:0] s_pulse_resp_sync;
    logic s_pulse_resp_reg;


    // промежуточные регистры для синхронизации
    logic           s_adc_en_reg;
    logic   [11:0]  s_min_ampl_reg;
    logic   [31:0]  m_over_word_reg;
    logic   [31:0]  m_drop_word_reg;


/***********************************************************************************************************************/
/*******************************************            LOGIC            ***********************************************/
/***********************************************************************************************************************/
    // synchronization reset
    always_ff @(posedge s_clk or negedge s_reset_n) begin
        if(!s_reset_n) begin
            sync_reset_n <= 'b0;
        end else begin
            sync_reset_n <= {sync_reset_n[2:0], 1'b1};
        end
    end

    assign m_reset_n = sync_reset_n[3];

    // s -> m
    always_ff @(posedge s_clk or negedge s_reset_n) begin
        if(!s_reset_n) begin
            s_pulse_req_gen <= 'b1;
        end else begin
            s_pulse_req_gen <= s_pulse_req_gen ^ s_impl;
        end
    end

    always_ff @(posedge m_clk or negedge m_reset_n) begin
        if(!m_reset_n) begin
            m_pulse_req_sync <= '0;
        end else begin
            m_pulse_req_sync <= {m_pulse_req_sync[0], s_pulse_req_gen};
        end
    end

    always_ff @(posedge m_clk or negedge m_reset_n) begin
        if(!m_reset_n) begin
            m_pulse_req_reg <= '0;
        end else begin
            m_pulse_req_reg <= m_pulse_req_sync[1];
        end
    end

    assign m_impl = m_pulse_req_sync[1] ^ m_pulse_req_reg;

    // m -> s
    always_ff @(posedge m_clk or negedge m_reset_n) begin
        if(!m_reset_n) begin
            m_pulse_resp_gen <= '0;
        end else begin
            m_pulse_resp_gen <= m_pulse_resp_gen ^ m_impl;
        end
    end

    always_ff @(posedge s_clk or negedge s_reset_n) begin
        if(!s_reset_n) begin
            s_pulse_resp_sync <= '0;
        end else begin
            s_pulse_resp_sync <= {s_pulse_resp_sync[0], m_pulse_resp_gen};
        end
    end

    always_ff @(posedge s_clk or negedge s_reset_n) begin
        if(!s_reset_n) begin
            s_pulse_resp_reg <= '0;
        end else begin
            s_pulse_resp_reg <= s_pulse_resp_sync[1];
        end
    end

    assign s_impl = s_pulse_resp_sync[1] ^ s_pulse_resp_reg;

    // синхронизация регистров
    always_ff @(posedge s_clk) begin
        if(s_impl) begin
            s_min_ampl_reg  <= s_min_ampl_i;
            s_over_word_o   <= m_over_word_reg;
            s_drop_word_o   <= m_drop_word_reg;
        end
    end

    always_ff @(posedge m_clk) begin
        if(m_impl) begin
            m_min_ampl_o    <= s_min_ampl_reg;
            m_over_word_reg <= m_over_word_i;
            m_drop_word_reg <= m_drop_word_i;
        end
    end

    // синхронизация бита запуска АЦП
    always_ff @(posedge s_clk or negedge s_reset_n) begin
        if(!s_reset_n) begin
            s_adc_en_reg <= '0;
        end else if(s_impl) begin
            s_adc_en_reg <= s_adc_en_i;
        end
    end

    always_ff @(posedge m_clk or negedge m_reset_n) begin
        if(!m_reset_n) begin 
            m_adc_en_o <= '0;
        end else if(m_impl) begin
            m_adc_en_o <= s_adc_en_reg;
        end
    end

endmodule