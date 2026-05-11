class axi_lite_access #(
        parameter int unsigned ADDR_WIDTH = 8,
        parameter int unsigned DATA_WIDTH = 8
);

    virtual axi_lite_if #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) vif_axi_lite;

	localparam int unsigned STRB_WIDTH = DATA_WIDTH/8;

	typedef logic [ADDR_WIDTH-1:0] 	addr_t;
	typedef logic [DATA_WIDTH-1:0] 	data_t;
	typedef logic [STRB_WIDTH-1:0] 	strb_t;
	typedef logic [1:0] 			resp_t;

    localparam logic [1:0]  RESP_OKAY 	= 2'b00, 
                            RESP_EXOKAY = 2'b01, 
                            RESP_SLVERR = 2'b10, 
                            RESP_DECERR = 2'b11;
    
	typedef struct packed {
		addr_t          addr;
        logic   [2:0]   prot;
		logic           valid;
		logic           ready;
	} ar_chan_t;

	// Read Data Channel
	typedef struct packed {
		data_t          data;
		resp_t          resp;
		logic           valid;
		logic           ready;
	} r_chan_t;

	// Write Address Channel
	typedef struct packed {
		addr_t          addr;
        logic   [2:0]   prot;
		logic           valid;
		logic           ready;
	} aw_chan_t;

	// Write Data Channel
	typedef struct packed {
		data_t          data;
		strb_t          strb;
		logic           valid;
		logic           ready;
	} w_chan_t;

	// Write Response Channel
	typedef struct packed {
		resp_t          resp;
		logic           valid;
		logic           ready;
	} b_chan_t;

    

    // create mailboxes
    mailbox #(aw_chan_t)   mbx_aw;
    mailbox #(w_chan_t)    mbx_w;
    mailbox #(b_chan_t)    mbx_b;
    mailbox #(ar_chan_t)   mbx_ar;
    mailbox #(r_chan_t)    mbx_r;
    
    function new();
        mbx_aw  = new();
        mbx_w   = new();
        mbx_b   = new();
        mbx_ar  = new();
        mbx_r   = new();
    endfunction //new()

    virtual task aw_driver();
        vif_axi_lite.awaddr     <= '0;
        vif_axi_lite.awprot     <= '0;
        vif_axi_lite.awvalid    <= '0;
        wait(vif_axi_lite.reset_n);
        forever begin
            aw_chan_t  aw_channel;
            mbx_aw.get(aw_channel);

            vif_axi_lite.awaddr     <= aw_channel.addr;
            vif_axi_lite.awprot     <= aw_channel.prot;
            vif_axi_lite.awvalid    <= 1'b1;
            do begin
                @(posedge vif_axi_lite.clk);
            end while(!vif_axi_lite.awready);

            vif_axi_lite.awaddr     <= '0;
            vif_axi_lite.awprot     <= '0;
            vif_axi_lite.awvalid    <= '0;    
        end
    endtask

    virtual task w_driver();
        vif_axi_lite.wdata  <= '0;
        vif_axi_lite.wstrb  <= '0;
        vif_axi_lite.wvalid <= '0;
        wait(vif_axi_lite.reset_n);
        forever begin
            w_chan_t w_channel;
            mbx_w.get(w_channel);

            vif_axi_lite.wdata  <= w_channel.data;
            vif_axi_lite.wstrb  <= w_channel.strb;
            vif_axi_lite.wvalid <= 1'b1;
            do begin
                @(posedge vif_axi_lite.clk);
            end while(!vif_axi_lite.wready);
            vif_axi_lite.wdata  <= '0;
            vif_axi_lite.wstrb  <= '0;
            vif_axi_lite.wvalid <= '0;    
        end
    endtask

    virtual task b_driver();
        vif_axi_lite.bready <= 1'b0;
        wait(vif_axi_lite.reset_n);
        forever begin
            vif_axi_lite.bready <= 1'b0;
            repeat($urandom_range(10,0)) @(posedge vif_axi_lite.clk);
            vif_axi_lite.bready <= 1'b1;
            repeat($urandom_range(10,0)) @(posedge vif_axi_lite.clk);
        end
    endtask

    virtual task b_monitor();
        wait(vif_axi_lite.reset_n);
        forever begin
            @(posedge vif_axi_lite.clk);
            if(vif_axi_lite.bvalid && vif_axi_lite.bready) begin
                b_chan_t   b_channel;
                b_channel.resp = vif_axi_lite.bresp;
                mbx_b.put(b_channel);
            end
        end
    endtask


    virtual task ar_driver();
        vif_axi_lite.araddr     <= '0;
        vif_axi_lite.arprot     <= '0;
        vif_axi_lite.arvalid    <= '0;
        wait(vif_axi_lite.reset_n);
        forever begin
            ar_chan_t  ar_channel;
            mbx_ar.get(ar_channel);

            vif_axi_lite.araddr     <= ar_channel.addr;
            vif_axi_lite.arprot     <= ar_channel.prot;
            vif_axi_lite.arvalid    <= 1'b1;
            do begin
                @(posedge vif_axi_lite.clk);
            end while(!vif_axi_lite.arready);

            vif_axi_lite.araddr     <= '0;
            vif_axi_lite.arprot     <= '0;
            vif_axi_lite.arvalid    <= '0;   
        end
    endtask


    
    virtual task r_driver();
        vif_axi_lite.rready <= 1'b0;
        wait(vif_axi_lite.reset_n);
        forever begin
            vif_axi_lite.rready <= 1'b0;
            repeat($urandom_range(10,0)) @(posedge vif_axi_lite.clk);
            vif_axi_lite.rready <= 1'b1;
            repeat($urandom_range(10,0)) @(posedge vif_axi_lite.clk);
        end
    endtask

    virtual task r_monitor();
        wait(vif_axi_lite.reset_n);
        forever begin
            @(posedge vif_axi_lite.clk);
            if(vif_axi_lite.rvalid && vif_axi_lite.rready) begin
                r_chan_t r_channel;
                r_channel.data = vif_axi_lite.rdata;
                r_channel.resp = vif_axi_lite.rresp;
                mbx_r.put(r_channel);
            end
        end
    endtask

    virtual task write_transaction (    logic [ADDR_WIDTH-1:0] address, 
                                        logic [STRB_WIDTH-1:0] strb, 
                                        logic [DATA_WIDTH-1:0] data);
        aw_chan_t   aw_channel;
        w_chan_t    w_channel;
        b_chan_t    b_channel;
        bit         write_ok = 0;

        while (!write_ok) begin
            automatic int unsigned cnt_repeat = 0;

            // address write channel
            aw_channel.addr = address;
            aw_channel.prot = '0;
            mbx_aw.put(aw_channel);

            // write channel
            w_channel.data = data;
            w_channel.strb = strb;
            mbx_w.put(w_channel);

            mbx_b.get(b_channel);

            if(b_channel.resp == RESP_DECERR) begin
                $error(" (!!!) Is no slave at the transaction address");
                cnt_repeat++;
            end else if(b_channel.resp == RESP_SLVERR) begin
                $error(" (!!!) The access has reached the slave successfully, but the slave wishes to return an error condition to the originating master.");
                cnt_repeat++;
            end else if(b_channel.resp == RESP_EXOKAY) begin
                // $display("Exclusive access okay");
                write_ok = 1;
            end else begin
                // $display("Access okay");
                write_ok = 1;
            end
            if(cnt_repeat > 10 && !write_ok) begin
                $display("Transaction address = %0h, strb = %0h, writedata = %0h", address, strb, data);
                $error("After 10 attempts, writing to the register failed");
                $fatal;
            end
        end
    endtask

    virtual task read_transaction ( logic [ADDR_WIDTH-1:0] address, ref logic [DATA_WIDTH-1:0] data);
        ar_chan_t   ar_channel;
        r_chan_t    r_channel;
        bit         read_ok = 0;

        while (!read_ok) begin
            automatic int unsigned cnt_repeat = 0;

            // address read channel
            ar_channel.addr = address;
            ar_channel.prot = '0;
            mbx_ar.put(ar_channel);

            mbx_r.get(r_channel);

            if(r_channel.resp == RESP_DECERR) begin
                $error(" (!!!) Is no slave at the transaction address");
                cnt_repeat++;
            end else if(r_channel.resp == RESP_SLVERR) begin
                $error(" (!!!) The access has reached the slave successfully, but the slave wishes to return an error condition to the originating master.");
                cnt_repeat++;
            end else if(r_channel.resp == RESP_EXOKAY) begin
                // $display("Exclusive access okay");
                read_ok = 1;
            end else begin
                // $display("Access okay");
                read_ok = 1;
            end
            if(cnt_repeat > 10) begin
                $display("Transaction address = %0h, readdata = %0h", address, r_channel.data);
                $error("After 10 attempts, writing to the register failed");
                $fatal;
            end
        end
        data = r_channel.data;
    endtask

    virtual task run();
        fork
            aw_driver();
            w_driver();
            b_driver();
            b_monitor();

            ar_driver();
            r_driver();
            r_monitor();
        join_none
    endtask

endclass //axil_access