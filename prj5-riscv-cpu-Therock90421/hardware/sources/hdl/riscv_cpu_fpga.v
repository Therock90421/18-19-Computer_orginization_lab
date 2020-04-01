/* =========================================
* Top module of FPGA evaluation platform for
* RISC-V CPU cores
*
* Author: Yisong Chang (changyisong@ict.ac.cn)
* Date: 19/03/2017
* Version: v0.0.1
*===========================================
*/

`timescale 10 ns / 1 ns

module riscv_cpu_fpga (
`ifdef RISCV_CPU_FULL_SIMU
	input riscv_cpu_clk,
	input riscv_cpu_reset,

	output riscv_cpu_pc_sig
`endif
);

`ifndef RISCV_CPU_FULL_SIMU
  wire				riscv_cpu_clk;
  reg [1:0]			riscv_cpu_reset_n_i = 2'b00;
  wire				riscv_cpu_reset_n;
  wire				riscv_cpu_reset;
  wire				ps_user_reset_n;
`endif

  wire [31:0]		riscv_cpu_axi_mem_araddr;
  wire				riscv_cpu_axi_mem_arready;
  wire				riscv_cpu_axi_mem_arvalid;
  wire [31:0]		riscv_cpu_axi_mem_awaddr;
  wire				riscv_cpu_axi_mem_awready;
  wire				riscv_cpu_axi_mem_awvalid;
  wire				riscv_cpu_axi_mem_bready;
  wire [1:0]		riscv_cpu_axi_mem_bresp;
  wire				riscv_cpu_axi_mem_bvalid;
  wire [31:0]		riscv_cpu_axi_mem_rdata;
  wire				riscv_cpu_axi_mem_rready;
  wire [1:0]		riscv_cpu_axi_mem_rresp;
  wire				riscv_cpu_axi_mem_rvalid;
  wire [31:0]		riscv_cpu_axi_mem_wdata;
  wire				riscv_cpu_axi_mem_wready;
  wire [3:0]		riscv_cpu_axi_mem_wstrb;
  wire				riscv_cpu_axi_mem_wvalid;

`ifndef RISCV_CPU_FULL_SIMU
  wire [39:0]		riscv_cpu_axi_mmio_araddr;
  wire				riscv_cpu_axi_mmio_arready;
  wire				riscv_cpu_axi_mmio_arvalid;
  wire [39:0]		riscv_cpu_axi_mmio_awaddr;
  wire				riscv_cpu_axi_mmio_awready;
  wire				riscv_cpu_axi_mmio_awvalid;
  wire				riscv_cpu_axi_mmio_bready;
  wire [1:0]		riscv_cpu_axi_mmio_bresp;
  wire				riscv_cpu_axi_mmio_bvalid;
  wire [31:0]		riscv_cpu_axi_mmio_rdata;
  wire				riscv_cpu_axi_mmio_rready;
  wire [1:0]		riscv_cpu_axi_mmio_rresp;
  wire				riscv_cpu_axi_mmio_rvalid;
  wire [31:0]		riscv_cpu_axi_mmio_wdata;
  wire				riscv_cpu_axi_mmio_wready;
  wire [3:0]		riscv_cpu_axi_mmio_wstrb;
  wire				riscv_cpu_axi_mmio_wvalid;
`endif

//Instantiation of RISC-V CPU core
riscv_cpu_top		u_riscv_cpu_top (
	.riscv_cpu_clk				(riscv_cpu_clk),
	.riscv_cpu_reset			(riscv_cpu_reset),
`ifdef RISCV_CPU_FULL_SIMU
	.riscv_cpu_pc_sig			(riscv_cpu_pc_sig),
`endif

	.riscv_cpu_axi_if_araddr	(riscv_cpu_axi_mem_araddr),
	.riscv_cpu_axi_if_arready	(riscv_cpu_axi_mem_arready),
	.riscv_cpu_axi_if_arvalid	(riscv_cpu_axi_mem_arvalid),
	.riscv_cpu_axi_if_awaddr	(riscv_cpu_axi_mem_awaddr),
	.riscv_cpu_axi_if_awready	(riscv_cpu_axi_mem_awready),
	.riscv_cpu_axi_if_awvalid	(riscv_cpu_axi_mem_awvalid),
	.riscv_cpu_axi_if_bready	(riscv_cpu_axi_mem_bready),
	.riscv_cpu_axi_if_bresp		(riscv_cpu_axi_mem_bresp),
	.riscv_cpu_axi_if_bvalid	(riscv_cpu_axi_mem_bvalid),
	.riscv_cpu_axi_if_rdata		(riscv_cpu_axi_mem_rdata),
	.riscv_cpu_axi_if_rready	(riscv_cpu_axi_mem_rready),
	.riscv_cpu_axi_if_rresp		(riscv_cpu_axi_mem_rresp),
	.riscv_cpu_axi_if_rvalid	(riscv_cpu_axi_mem_rvalid),
	.riscv_cpu_axi_if_wdata		(riscv_cpu_axi_mem_wdata),
	.riscv_cpu_axi_if_wready	(riscv_cpu_axi_mem_wready),
	.riscv_cpu_axi_if_wstrb		(riscv_cpu_axi_mem_wstrb),
	.riscv_cpu_axi_if_wvalid	(riscv_cpu_axi_mem_wvalid)
);


`ifndef RISCV_CPU_FULL_SIMU 
//Instantiation of MPSoC wrapper
mpsoc_wrapper		u_zynq_soc_wrapper (
	.riscv_cpu_axi_mmio_araddr	(riscv_cpu_axi_mmio_araddr),
	.riscv_cpu_axi_mmio_arprot	(),
	.riscv_cpu_axi_mmio_arready	(riscv_cpu_axi_mmio_arready),
	.riscv_cpu_axi_mmio_arvalid	(riscv_cpu_axi_mmio_arvalid),
	.riscv_cpu_axi_mmio_awaddr	(riscv_cpu_axi_mmio_awaddr),
	.riscv_cpu_axi_mmio_awprot	(),
	.riscv_cpu_axi_mmio_awready	(riscv_cpu_axi_mmio_awready),
	.riscv_cpu_axi_mmio_awvalid	(riscv_cpu_axi_mmio_awvalid),
	.riscv_cpu_axi_mmio_bready	(riscv_cpu_axi_mmio_bready),
	.riscv_cpu_axi_mmio_bresp	(riscv_cpu_axi_mmio_bresp),
	.riscv_cpu_axi_mmio_bvalid	(riscv_cpu_axi_mmio_bvalid),
	.riscv_cpu_axi_mmio_rdata	(riscv_cpu_axi_mmio_rdata),
	.riscv_cpu_axi_mmio_rready	(riscv_cpu_axi_mmio_rready),
	.riscv_cpu_axi_mmio_rresp	(riscv_cpu_axi_mmio_rresp),
	.riscv_cpu_axi_mmio_rvalid	(riscv_cpu_axi_mmio_rvalid),
	.riscv_cpu_axi_mmio_wdata	(riscv_cpu_axi_mmio_wdata),
	.riscv_cpu_axi_mmio_wready	(riscv_cpu_axi_mmio_wready),
	.riscv_cpu_axi_mmio_wstrb	(riscv_cpu_axi_mmio_wstrb),
	.riscv_cpu_axi_mmio_wvalid	(riscv_cpu_axi_mmio_wvalid),
	  
	.ps_fclk_clk0				(riscv_cpu_clk),
	.ps_user_reset_n			(ps_user_reset_n),
	.riscv_cpu_reset_n			(riscv_cpu_reset_n),

	.riscv_cpu_axi_mem_araddr	(riscv_cpu_axi_mem_araddr[16] ? {1'b1, riscv_cpu_axi_mem_araddr[30:0]} : {2'b01, riscv_cpu_axi_mem_araddr[29:0]}),
	.riscv_cpu_axi_mem_arprot	('d0),
	.riscv_cpu_axi_mem_arready	(riscv_cpu_axi_mem_arready),
	.riscv_cpu_axi_mem_arvalid	(riscv_cpu_axi_mem_arvalid),
	.riscv_cpu_axi_mem_awaddr	(riscv_cpu_axi_mem_awaddr[16] ? {1'b1, riscv_cpu_axi_mem_awaddr[30:0]} : {2'b01, riscv_cpu_axi_mem_awaddr[29:0]}),
	.riscv_cpu_axi_mem_awprot	('d0),
	.riscv_cpu_axi_mem_awready	(riscv_cpu_axi_mem_awready),
	.riscv_cpu_axi_mem_awvalid	(riscv_cpu_axi_mem_awvalid),
	.riscv_cpu_axi_mem_bready	(riscv_cpu_axi_mem_bready),
	.riscv_cpu_axi_mem_bresp	(riscv_cpu_axi_mem_bresp),
	.riscv_cpu_axi_mem_bvalid	(riscv_cpu_axi_mem_bvalid),
	.riscv_cpu_axi_mem_rdata	(riscv_cpu_axi_mem_rdata),
	.riscv_cpu_axi_mem_rready	(riscv_cpu_axi_mem_rready),
	.riscv_cpu_axi_mem_rresp	(riscv_cpu_axi_mem_rresp),
	.riscv_cpu_axi_mem_rvalid	(riscv_cpu_axi_mem_rvalid),
	.riscv_cpu_axi_mem_wdata	(riscv_cpu_axi_mem_wdata),
	.riscv_cpu_axi_mem_wready	(riscv_cpu_axi_mem_wready),
	.riscv_cpu_axi_mem_wstrb	(riscv_cpu_axi_mem_wstrb),
	.riscv_cpu_axi_mem_wvalid	(riscv_cpu_axi_mem_wvalid)
);

  //generate positive reset signal for RISC-V CPU core
  always @ (posedge riscv_cpu_clk)
	  riscv_cpu_reset_n_i <= {riscv_cpu_reset_n_i[0], ps_user_reset_n};

  assign riscv_cpu_reset_n = riscv_cpu_reset_n_i[1];


  //Instantiation of AXI-Lite interface
  axi_lite_if 	u_axi_lite_slave (
	  .S_AXI_ACLK		(riscv_cpu_clk),
	  .S_AXI_ARESETN	(riscv_cpu_reset_n),
	  
	  .S_AXI_ARADDR		(riscv_cpu_axi_mmio_araddr),
	  .S_AXI_ARREADY	(riscv_cpu_axi_mmio_arready),
	  .S_AXI_ARVALID	(riscv_cpu_axi_mmio_arvalid),
	  
	  .S_AXI_AWADDR		(riscv_cpu_axi_mmio_awaddr),
	  .S_AXI_AWREADY	(riscv_cpu_axi_mmio_awready),
	  .S_AXI_AWVALID	(riscv_cpu_axi_mmio_awvalid),
	  
	  .S_AXI_BREADY		(riscv_cpu_axi_mmio_bready),
	  .S_AXI_BRESP		(riscv_cpu_axi_mmio_bresp),
	  .S_AXI_BVALID		(riscv_cpu_axi_mmio_bvalid),
	  
	  .S_AXI_RDATA		(riscv_cpu_axi_mmio_rdata),
	  .S_AXI_RREADY		(riscv_cpu_axi_mmio_rready),
	  .S_AXI_RRESP		(riscv_cpu_axi_mmio_rresp),
	  .S_AXI_RVALID		(riscv_cpu_axi_mmio_rvalid),
	  
	  .S_AXI_WDATA		(riscv_cpu_axi_mmio_wdata),
	  .S_AXI_WREADY		(riscv_cpu_axi_mmio_wready),
	  .S_AXI_WSTRB		(riscv_cpu_axi_mmio_wstrb),
	  .S_AXI_WVALID		(riscv_cpu_axi_mmio_wvalid),
	  
	  .riscv_rst		(riscv_cpu_reset)
  );

`else

wire			bram_rst_a;
wire			bram_clk_a;
wire			bram_en_a;
wire [3:0]		bram_we_a;
wire [15:0]		bram_addr_a;
wire [31:0]		bram_wrdata_a;
wire [31:0]		bram_rddata_a;

wire			axi_bram_arready;
wire			axi_bram_awready;
wire [31:0]		axi_bram_wdata;
wire [3:0]		axi_bram_wstrb;
wire			axi_bram_wready;
wire			axi_bram_wvalid;
wire [31:0]		axi_bram_rdata;
wire [1:0]		axi_bram_rresp;
wire			axi_bram_rvalid;

wire			axi_uart_arready;
wire			axi_uart_awready;
wire [31:0]		axi_uart_wdata;
wire [3:0]		axi_uart_wstrb;
wire			axi_uart_wready;
wire			axi_uart_wvalid;
wire [31:0]		axi_uart_rdata;
wire [1:0]		axi_uart_rresp;
wire			axi_uart_rvalid;

reg [1:0]		riscv_cpu_ar_cs;
reg [1:0]		riscv_cpu_aw_cs;

always @ (posedge riscv_cpu_clk)
begin
	if (riscv_cpu_reset == 1'b1)
		riscv_cpu_ar_cs <= 2'b00;

	else if ((~|riscv_cpu_ar_cs) & riscv_cpu_axi_mem_arvalid)
		riscv_cpu_ar_cs <= {riscv_cpu_axi_mem_araddr[16], ~riscv_cpu_axi_mem_araddr[16]};

	else if ((|riscv_cpu_ar_cs) & riscv_cpu_axi_mem_rvalid & riscv_cpu_axi_mem_rready)
		riscv_cpu_ar_cs <= 2'b00;

	else
		riscv_cpu_ar_cs <= riscv_cpu_ar_cs;
end
assign riscv_cpu_axi_mem_arready = (riscv_cpu_ar_cs[0] & axi_bram_arready) | 
			(riscv_cpu_ar_cs[1] & axi_uart_arready);

assign riscv_cpu_axi_mem_rdata = ({32{riscv_cpu_ar_cs[0]}} & axi_bram_rdata) | 
			({32{riscv_cpu_ar_cs[1]}} & axi_uart_rdata);

assign riscv_cpu_axi_mem_rresp = ({2{riscv_cpu_ar_cs[0]}} & axi_bram_rresp) | 
			({2{riscv_cpu_ar_cs[1]}} & axi_uart_rresp);

assign riscv_cpu_axi_mem_rvalid = (riscv_cpu_ar_cs[0] & axi_bram_rvalid) | 
			(riscv_cpu_ar_cs[1] & axi_uart_rvalid);

reg riscv_cpu_aw_flag;
reg riscv_cpu_w_flag;

always @ (posedge riscv_cpu_clk)
begin
	if (riscv_cpu_reset == 1'b1)
		riscv_cpu_aw_flag <= 1'b0;
	else if (~riscv_cpu_aw_flag & riscv_cpu_axi_mem_awvalid & riscv_cpu_axi_mem_awready)
		riscv_cpu_aw_flag <= 1'b1;
	else if (riscv_cpu_aw_flag & riscv_cpu_w_flag)
		riscv_cpu_aw_flag <= 1'b0;
	else
		riscv_cpu_aw_flag <= riscv_cpu_aw_flag;
end

always @ (posedge riscv_cpu_clk)
begin
	if (riscv_cpu_reset == 1'b1)
		riscv_cpu_w_flag <= 1'b0;
	else if (~riscv_cpu_w_flag & riscv_cpu_axi_mem_wvalid & riscv_cpu_axi_mem_wready)
		riscv_cpu_w_flag <= 1'b1;
	else if (riscv_cpu_aw_flag & riscv_cpu_w_flag)
		riscv_cpu_w_flag <= 1'b0;
	else
		riscv_cpu_w_flag <= riscv_cpu_w_flag;
end

always @ (posedge riscv_cpu_clk)
begin
	if (riscv_cpu_reset == 1'b1)
		riscv_cpu_aw_cs <= 2'b00;

	else if ((~|riscv_cpu_aw_cs) & riscv_cpu_axi_mem_awvalid & riscv_cpu_axi_mem_wvalid)
		riscv_cpu_aw_cs <= {riscv_cpu_axi_mem_awaddr[16], ~riscv_cpu_axi_mem_awaddr[16]};

	else if ((|riscv_cpu_aw_cs) & riscv_cpu_aw_flag & riscv_cpu_w_flag)
		riscv_cpu_aw_cs <= 2'b00;

	else
		riscv_cpu_aw_cs <= riscv_cpu_aw_cs;
end
assign riscv_cpu_axi_mem_awready = (riscv_cpu_aw_cs[0] & axi_bram_awready) |
			(riscv_cpu_aw_cs[1] & axi_uart_awready);

assign riscv_cpu_axi_mem_wready = (riscv_cpu_aw_cs[0] & axi_bram_wready) |
			(riscv_cpu_aw_cs[1] & axi_uart_wready);

assign axi_bram_wdata = {32{riscv_cpu_aw_cs[0]}} & riscv_cpu_axi_mem_wdata;
assign axi_uart_wdata = {32{riscv_cpu_aw_cs[1]}} & riscv_cpu_axi_mem_wdata;

assign axi_bram_wstrb = {4{riscv_cpu_aw_cs[0]}} & riscv_cpu_axi_mem_wstrb;
assign axi_uart_wstrb = {4{riscv_cpu_aw_cs[1]}} & riscv_cpu_axi_mem_wstrb;

assign axi_bram_wvalid = riscv_cpu_aw_cs[0] & riscv_cpu_axi_mem_wvalid;
assign axi_uart_wvalid = riscv_cpu_aw_cs[1] & riscv_cpu_axi_mem_wvalid;

axi_bram_if		u_axi_bram_if (
	.s_axi_aclk		(riscv_cpu_clk),
	.s_axi_aresetn	(~riscv_cpu_reset),

	.s_axi_araddr	(riscv_cpu_axi_mem_araddr[15:0]),
	.s_axi_arlen	('d0),
	.s_axi_arsize	('d2),
	.s_axi_arprot	('d0),
	.s_axi_arburst	('d1),
	.s_axi_arlock	('d0),
	.s_axi_arcache	('d0),
	.s_axi_arready	(axi_bram_arready),
	.s_axi_arvalid	(riscv_cpu_axi_mem_arvalid & (~riscv_cpu_axi_mem_araddr[16])),

	.s_axi_awaddr	(riscv_cpu_axi_mem_awaddr[15:0]),
	.s_axi_awlen	('d0),
	.s_axi_awsize	('d2),
	.s_axi_awprot	('d0),
	.s_axi_awburst	('d1),
	.s_axi_awlock	('d0),
	.s_axi_awcache	('d0),
	.s_axi_awready	(axi_bram_awready),
	.s_axi_awvalid	(riscv_cpu_axi_mem_awvalid & (~riscv_cpu_axi_mem_awaddr[16])),

	.s_axi_bready	(riscv_cpu_axi_mem_bready),
	.s_axi_bresp	(),
	.s_axi_bvalid	(),

	.s_axi_rdata	(axi_bram_rdata),
	.s_axi_rresp	(axi_bram_rresp),
	.s_axi_rvalid	(axi_bram_rvalid),
	.s_axi_rready	(riscv_cpu_axi_mem_rready),
	.s_axi_rlast	(),

	.s_axi_wdata	(axi_bram_wdata),
	.s_axi_wready	(axi_bram_wready),
	.s_axi_wstrb	(axi_bram_wstrb),
	.s_axi_wvalid	(axi_bram_wvalid),
	.s_axi_wlast	(1'b1),

	.bram_rst_a		(bram_rst_a				),
	.bram_clk_a		(bram_clk_a				),
	.bram_en_a		(bram_en_a				),
	.bram_we_a		(bram_we_a				),
	.bram_addr_a	(bram_addr_a			),
	.bram_wrdata_a	(bram_wrdata_a			),
	.bram_rddata_a	(bram_rddata_a			)
);

riscv_bram		u_riscv_bram (
	.clka			(bram_clk_a),
	.rsta			(bram_rst_a),
	.ena			(bram_en_a),
	.wea			(bram_we_a),
	.addra			({16'd0, bram_addr_a}),
	.dina			(bram_wrdata_a),
	.douta			(bram_rddata_a)
);

wire		uart_tx;
wire		uart_tx_data_valid;
wire [7:0]	uart_tx_data;

riscv_uart		u_riscv_uart (
	.s_axi_aclk		(riscv_cpu_clk),
	.s_axi_aresetn	(~riscv_cpu_reset),

	.s_axi_araddr	(riscv_cpu_axi_mem_araddr[15:0]),
	.s_axi_arready	(axi_uart_arready),
	.s_axi_arvalid	(riscv_cpu_axi_mem_arvalid & riscv_cpu_axi_mem_araddr[16]),

	.s_axi_awaddr	(riscv_cpu_axi_mem_awaddr[15:0]),
	.s_axi_awready	(axi_uart_awready),
	.s_axi_awvalid	(riscv_cpu_axi_mem_awvalid & riscv_cpu_axi_mem_awaddr[16]),

	.s_axi_bready	(riscv_cpu_axi_mem_bready),
	.s_axi_bresp	(),
	.s_axi_bvalid	(),

	.s_axi_rdata	(axi_uart_rdata),
	.s_axi_rresp	(axi_uart_rresp),
	.s_axi_rvalid	(axi_uart_rvalid),
	.s_axi_rready	(riscv_cpu_axi_mem_rready),

	.s_axi_wdata	({24'd0, axi_uart_wdata[7:0]}),
	.s_axi_wready	(axi_uart_wready),
	.s_axi_wstrb	(axi_uart_wstrb),
	.s_axi_wvalid	(axi_uart_wvalid),

	.tx				(uart_tx)
);

`ifdef UART_SIM
uart_recv_sim	u_uart_sim(
	.clock			(riscv_cpu_clk),
	.reset			(riscv_cpu_reset),
	
	.io_en			(1'b1),
	.io_in			(uart_tx),
	.io_out_valid	(uart_tx_data_valid),
	.io_out_bits	(uart_tx_data),
	.io_div			(16'd868)			//100MHz / 115200
);

always @ (posedge riscv_cpu_clk)
begin
	if (uart_tx_data_valid)
		$write("%c", uart_tx_data);
end
`endif

`endif

endmodule

