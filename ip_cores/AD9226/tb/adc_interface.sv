interface axi_lite_if #(
	parameter int unsigned ADDR_WIDTH = 32,
	parameter int unsigned DATA_WIDTH = 32
) (
	input logic clk,
	input logic reset_n
);

	localparam int unsigned STRB_WIDTH = DATA_WIDTH/8;

	typedef logic [ADDR_WIDTH-1:0] 	addr_t;
	typedef logic [DATA_WIDTH-1:0] 	data_t;
	typedef logic [STRB_WIDTH-1:0] 	strb_t;
	typedef logic [1:0] 			resp_t;

	// Read Address Channel
	addr_t          araddr;
    logic   [2:0]   arprot;
	logic           arvalid;
	logic           arready;

	// Read Data Channel
	data_t          rdata;
	resp_t          rresp;
	logic           rvalid;
	logic           rready;

	// Write Address Channel
	addr_t          awaddr;
    logic   [2:0]   awprot;
	logic           awvalid;
	logic           awready;

	// Write Data Channel
	data_t          wdata;
	strb_t          wstrb;
	logic           wvalid;
	logic           wready;

	// Write Response Channel
	resp_t          bresp;
	logic           bvalid;
	logic           bready;

	modport master (
		output araddr, arprot, arvalid, input arready,
		input rdata, rresp, rvalid, output rready,
		output awaddr, awprot, awvalid, input awready,
		output 	wdata, wstrb, wvalid, input wready,
		input bresp, bvalid, output bready
	);

	modport slave (
		input araddr, arprot, arvalid, output arready,
		output rdata, rresp, rvalid, input rready,
		input awaddr, awprot, awvalid, output awready,
		input wdata, wstrb, wvalid, output wready,
		output bresp, bvalid, input bready
	);


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

endinterface