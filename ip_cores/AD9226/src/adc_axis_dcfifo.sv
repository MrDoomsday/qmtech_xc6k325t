/*
    Домен Sink
    s_clk - тактовый сигнал для домена
    s_reset_n - сброс для домена 

    s_data_i - ширина шины данных
    s_valid_i - сигнал валидности
    s_ready_o - сигнал готовности принимать новые данные

    s_fifo_usedw_o - указывает сколько слов на текущий момент находится в FIFO
    s_fifo_availwd_o - указывает сколько слов на текущий момент доступно для записи в FIFO
    s_fifo_empty_o - флаг выставляется когда fifo полностью опустеет
    s_fifo_full_o - флаг выставляется когда fifo полностью заполнится (синхронно с ready)

    Замечание: 
        s_fifo_usedw_o меняется не сразу, а через один такт после поступления данных, т.к. выход регистровый
        s_fifo_empty_o, s_fifo_full_o меняются сразу при поступлении данных

*/
module adc_axis_dcfifo #(
    parameter DATA_WIDTH = 32,
    parameter FIFO_DEPTH = 10,
    parameter WR_CDC_STAGE = 2, // число регистров для синхронизации из домена WR в домен RD
    parameter RD_CDC_STAGE = 2 // число регистров для синхронизации из домена RD в домен WR
    
)(

    // sink
    input   logic                       s_clk,
    input   logic                       s_reset_n,

    input   logic   [DATA_WIDTH-1:0]    s_data_i,
    input   logic                       s_valid_i,
    output  logic                       s_ready_o,

    output  logic   [FIFO_DEPTH:0]      s_fifo_usedw_o,   // указывает сколько слов на текущий момент находится в FIFO
    output  logic   [FIFO_DEPTH:0]      s_fifo_availwd_o, // указывает сколько слов на текущий момент доступно для записи в FIFO
    output  logic                       s_fifo_empty_o,
    output  logic                       s_fifo_full_o,

    // source
    input   logic                       m_clk,
    input   logic                       m_reset_n,

    output  logic   [DATA_WIDTH-1:0]    m_data_o,
    output  logic                       m_valid_o,
    input   logic                       m_ready_i,

    output  logic   [FIFO_DEPTH:0]      m_fifo_usedw_o,   // указывает сколько слов на текущий момент находится в FIFO
    output  logic   [FIFO_DEPTH:0]      m_fifo_availwd_o, // указывает сколько слов на текущий момент доступно для записи в FIFO
    output  logic                       m_fifo_empty_o,
    output  logic                       m_fifo_full_o
);



/***********************************************************************************************************************/
/***********************************************************************************************************************/
/*******************************************            DECLARATION      ***********************************************/
/***********************************************************************************************************************/
/***********************************************************************************************************************/

    // domain a (s_clk) -> domain b (m_clk)
    // common
    logic [DATA_WIDTH-1:0] ram [2**FIFO_DEPTH-1:0];

    function logic [FIFO_DEPTH:0] bin2gray (logic [FIFO_DEPTH:0] bin);
        return (bin >> 1) ^ bin;
    endfunction

    function logic [FIFO_DEPTH:0] gray2bin (logic [FIFO_DEPTH:0] gray);
        logic [FIFO_DEPTH:0] bin;
        for(int i = 0; i < FIFO_DEPTH + 1; i++) begin
            bin[i] = ^(gray >> i);
        end
        return bin;
    endfunction
    
    // domain a
    logic                                       wr_en;
    logic [FIFO_DEPTH:0]                        wr_ptr, wr_ptr_next;
    logic [RD_CDC_STAGE-1:0][FIFO_DEPTH:0]      rd_ptr_cdc;
    logic [FIFO_DEPTH:0]                        s_rd_ptr; // указатель на прочитанные данные из domain b


    //domain b
    logic                                       rd_en;
    logic [FIFO_DEPTH:0]                        rd_ptr, rd_ptr_next;
    logic [WR_CDC_STAGE-1:0][FIFO_DEPTH:0]      wr_ptr_cdc;
    logic [FIFO_DEPTH:0]                        m_wr_ptr; // указатель на записанные данные из domain a
    logic                                       m_ready;


/***********************************************************************************************************************/
/***********************************************************************************************************************/
/*******************************************            LOGIC            ***********************************************/
/***********************************************************************************************************************/
/***********************************************************************************************************************/

    // domain a
    assign wr_en = s_valid_i & s_ready_o;

    always_ff @(posedge s_clk) begin
        if(wr_en) begin
            ram[wr_ptr[FIFO_DEPTH-1:0]] <= s_data_i;
        end
    end
    
    always_ff @(posedge s_clk or negedge s_reset_n) begin
        if(!s_reset_n) begin
            for(int i = 0; i < RD_CDC_STAGE; i++) begin
                rd_ptr_cdc[i] <= '0;   
            end
            s_rd_ptr <= '0;
        end else begin
            rd_ptr_cdc[0] <= bin2gray(rd_ptr);
            for(int i = 1; i < RD_CDC_STAGE; i++) begin
                rd_ptr_cdc[i] <= rd_ptr_cdc[i-1];                
            end
            s_rd_ptr <= gray2bin(rd_ptr_cdc[RD_CDC_STAGE-1]);
        end
    end

    always_ff @(posedge s_clk or negedge s_reset_n) begin
        if(!s_reset_n) begin
            wr_ptr <= '0;
        end else begin
            wr_ptr <= wr_ptr + {{FIFO_DEPTH{1'b0}}, wr_en};
        end
    end


    always_ff @(posedge s_clk or negedge s_reset_n) begin
        if(!s_reset_n) begin
            s_fifo_usedw_o      <= '0;
            s_fifo_availwd_o    <= '0;
        end else begin
            s_fifo_usedw_o      <= wr_ptr - s_rd_ptr;
            s_fifo_availwd_o    <= 2**FIFO_DEPTH - wr_ptr + s_rd_ptr;
        end
    end

    assign s_fifo_empty_o = wr_ptr == s_rd_ptr;
    assign s_fifo_full_o = (wr_ptr[FIFO_DEPTH] ^ s_rd_ptr[FIFO_DEPTH]) & (wr_ptr[FIFO_DEPTH-1:0] == s_rd_ptr[FIFO_DEPTH-1:0]);
    assign s_ready_o = ~s_fifo_full_o;

    //domain b
    assign rd_en = m_ready & ~m_fifo_empty_o;

    always_ff @(posedge m_clk or negedge m_reset_n) begin
        if(!m_reset_n) begin
            for(int i = 0; i < WR_CDC_STAGE; i++) begin
                wr_ptr_cdc[i] <= '0;   
            end
            m_wr_ptr <= '0;
        end else begin
            wr_ptr_cdc[0] <= bin2gray(wr_ptr);
            for(int i = 1; i < WR_CDC_STAGE; i++) begin
                wr_ptr_cdc[i] <= wr_ptr_cdc[i-1];                
            end
            m_wr_ptr <= gray2bin(wr_ptr_cdc[WR_CDC_STAGE-1]);
        end
    end

    always_ff @(posedge m_clk or negedge m_reset_n) begin
        if(!m_reset_n) begin
            rd_ptr <= '0;
        end else begin
            rd_ptr <= rd_ptr + {{FIFO_DEPTH{1'b0}}, rd_en}; // с точки зрения энергопотребления не оптимально, т.к. триггер всегда щелкает, а это делать не обязательно!
        end
    end

    assign m_ready = m_ready_i | ~m_valid_o;

    always_ff @(posedge m_clk or negedge m_reset_n) begin
        if(!m_reset_n) begin
            m_valid_o <= 1'b0;
        end else if(m_ready) begin
            m_valid_o <= ~m_fifo_empty_o;
        end
    end

    always_ff @(posedge m_clk) begin
        if(m_ready) begin
            m_data_o <= ram[rd_ptr[FIFO_DEPTH-1:0]];
        end
    end


    always_ff @(posedge m_clk or negedge m_reset_n) begin
        if(!m_reset_n) begin
            m_fifo_usedw_o      <= '0;
            m_fifo_availwd_o    <= '0;
        end else begin
            m_fifo_usedw_o      <= m_wr_ptr - rd_ptr;
            m_fifo_availwd_o    <= 2**FIFO_DEPTH - m_wr_ptr + rd_ptr;
        end
    end


    assign m_fifo_empty_o = m_wr_ptr == rd_ptr;
    assign m_fifo_full_o = (m_wr_ptr[FIFO_DEPTH] ^ rd_ptr[FIFO_DEPTH]) & (m_wr_ptr[FIFO_DEPTH-1:0] == rd_ptr[FIFO_DEPTH-1:0]);


/***********************************************************************************************************************/
/***********************************************************************************************************************/
/*******************************************            ASSERTION        ***********************************************/
/***********************************************************************************************************************/
/***********************************************************************************************************************/
// sink
    SVA_CHECK_SIZE_FIFO_S: assert property (
        @(posedge s_clk) disable iff(!s_reset_n)
        s_fifo_usedw_o <= 2**FIFO_DEPTH
    ) else $error("dcfifo sink usedw > fifo size");

    SVA_CHECK_AVAILWD_S: assert property (
        @(posedge s_clk) disable iff(!s_reset_n)
        s_fifo_availwd_o <= 2**FIFO_DEPTH
    ) else $error("dcfifo sink availwd > fifo size");

// source
    SVA_CHECK_SIZE_FIFO_M: assert property (
        @(posedge m_clk) disable iff(!m_reset_n)
        m_fifo_usedw_o <= 2**FIFO_DEPTH
    ) else $error("dcfifo master usedw > fifo size");

    SVA_CHECK_AVAILWD_M: assert property (
        @(posedge m_clk) disable iff(!m_reset_n)
        m_fifo_availwd_o <= 2**FIFO_DEPTH
    ) else $error("dcfifo source availwd > fifo size");

endmodule