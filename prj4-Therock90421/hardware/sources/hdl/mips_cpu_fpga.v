/* =========================================
* Top module of FPGA evaluation platform for
* MIPS CPU cores
*
* Author: Yisong Chang (changyisong@ict.ac.cn)
* Date: 19/03/2017
* Version: v0.0.1
*===========================================
*/

`timescale 10 ns / 1 ns

module mips_cpu_fpga (
`ifdef MIPS_CPU_FULL_SIMU
	input			mips_cpu_clk,
	input			mips_cpu_reset,

	output			mips_cpu_pc_sig,
	output [15:0]	mips_perf_cnt_flag
`endif
);

`ifndef MIPS_CPU_FULL_SIMU
  wire				mips_cpu_clk;
  reg [1:0]			mips_cpu_reset_n_i = 2'b00;
  wire				mips_cpu_reset_n;
  wire				mips_cpu_reset;
  wire				ps_user_reset_n;
`endif

  wire [31:0]		mips_cpu_axi_mem_araddr;
  wire				mips_cpu_axi_mem_arready;
  wire				mips_cpu_axi_mem_arvalid;
  wire [31:0]		mips_cpu_axi_mem_awaddr;
  wire				mips_cpu_axi_mem_awready;
  wire				mips_cpu_axi_mem_awvalid;
  wire				mips_cpu_axi_mem_bready;
  wire [1:0]		mips_cpu_axi_mem_bresp;
  wire				mips_cpu_axi_mem_bvalid;
  wire [31:0]		mips_cpu_axi_mem_rdata;
  wire				mips_cpu_axi_mem_rready;
  wire [1:0]		mips_cpu_axi_mem_rresp;
  wire				mips_cpu_axi_mem_rvalid;
  wire [31:0]		mips_cpu_axi_mem_wdata;
  wire				mips_cpu_axi_mem_wready;
  wire [3:0]		mips_cpu_axi_mem_wstrb;
  wire				mips_cpu_axi_mem_wvalid;

`ifndef MIPS_CPU_FULL_SIMU
  wire [39:0]		mips_cpu_axi_mmio_araddr;
  wire				mips_cpu_axi_mmio_arready;
  wire				mips_cpu_axi_mmio_arvalid;
  wire [39:0]		mips_cpu_axi_mmio_awaddr;
  wire				mips_cpu_axi_mmio_awready;
  wire				mips_cpu_axi_mmio_awvalid;
  wire				mips_cpu_axi_mmio_bready;
  wire [1:0]		mips_cpu_axi_mmio_bresp;
  wire				mips_cpu_axi_mmio_bvalid;
  wire [31:0]		mips_cpu_axi_mmio_rdata;
  wire				mips_cpu_axi_mmio_rready;
  wire [1:0]		mips_cpu_axi_mmio_rresp;
  wire				mips_cpu_axi_mmio_rvalid;
  wire [31:0]		mips_cpu_axi_mmio_wdata;
  wire				mips_cpu_axi_mmio_wready;
  wire [3:0]		mips_cpu_axi_mmio_wstrb;
  wire				mips_cpu_axi_mmio_wvalid;
`endif

  wire [32 * 16 - 1 : 0]	mips_perf_cnt;

//Instantiation of MIPS CPU core
mips_cpu_top		u_mips_cpu_top (
	.mips_cpu_clk				(mips_cpu_clk),
	.mips_cpu_reset				(mips_cpu_reset),
`ifdef MIPS_CPU_FULL_SIMU
	.mips_cpu_pc_sig			(mips_cpu_pc_sig),
`endif

	.mips_perf_cnt_0			(mips_perf_cnt[31:0]),
	.mips_perf_cnt_1			(mips_perf_cnt[63:32]),
	.mips_perf_cnt_2			(mips_perf_cnt[95:64]),
	.mips_perf_cnt_3			(mips_perf_cnt[127:96]),
	.mips_perf_cnt_4			(mips_perf_cnt[159:128]),
	.mips_perf_cnt_5			(mips_perf_cnt[191:160]),
	.mips_perf_cnt_6			(mips_perf_cnt[223:192]),
	.mips_perf_cnt_7			(mips_perf_cnt[255:224]),
	.mips_perf_cnt_8			(mips_perf_cnt[287:256]),
	.mips_perf_cnt_9			(mips_perf_cnt[319:288]),
	.mips_perf_cnt_10			(mips_perf_cnt[351:320]),
	.mips_perf_cnt_11			(mips_perf_cnt[383:352]),
	.mips_perf_cnt_12			(mips_perf_cnt[415:384]),
	.mips_perf_cnt_13			(mips_perf_cnt[447:416]),
	.mips_perf_cnt_14			(mips_perf_cnt[479:448]),
	.mips_perf_cnt_15			(mips_perf_cnt[511:480]),

	.mips_cpu_axi_if_araddr		(mips_cpu_axi_mem_araddr),
	.mips_cpu_axi_if_arready	(mips_cpu_axi_mem_arready),
	.mips_cpu_axi_if_arvalid	(mips_cpu_axi_mem_arvalid),
	.mips_cpu_axi_if_awaddr		(mips_cpu_axi_mem_awaddr),
	.mips_cpu_axi_if_awready	(mips_cpu_axi_mem_awready),
	.mips_cpu_axi_if_awvalid	(mips_cpu_axi_mem_awvalid),
	.mips_cpu_axi_if_bready		(mips_cpu_axi_mem_bready),
	.mips_cpu_axi_if_bresp		(mips_cpu_axi_mem_bresp),
	.mips_cpu_axi_if_bvalid		(mips_cpu_axi_mem_bvalid),
	.mips_cpu_axi_if_rdata		(mips_cpu_axi_mem_rdata),
	.mips_cpu_axi_if_rready		(mips_cpu_axi_mem_rready),
	.mips_cpu_axi_if_rresp		(mips_cpu_axi_mem_rresp),
	.mips_cpu_axi_if_rvalid		(mips_cpu_axi_mem_rvalid),
	.mips_cpu_axi_if_wdata		(mips_cpu_axi_mem_wdata),
	.mips_cpu_axi_if_wready		(mips_cpu_axi_mem_wready),
	.mips_cpu_axi_if_wstrb		(mips_cpu_axi_mem_wstrb),
	.mips_cpu_axi_if_wvalid		(mips_cpu_axi_mem_wvalid)
);

`ifndef MIPS_CPU_FULL_SIMU 
//Instantiation of MPSoC wrapper
mpsoc_wrapper		u_zynq_soc_wrapper (
	.mips_cpu_axi_mmio_araddr	(mips_cpu_axi_mmio_araddr),
	.mips_cpu_axi_mmio_arprot	(),
	.mips_cpu_axi_mmio_arready	(mips_cpu_axi_mmio_arready),
	.mips_cpu_axi_mmio_arvalid	(mips_cpu_axi_mmio_arvalid),
	.mips_cpu_axi_mmio_awaddr	(mips_cpu_axi_mmio_awaddr),
	.mips_cpu_axi_mmio_awprot	(),
	.mips_cpu_axi_mmio_awready	(mips_cpu_axi_mmio_awready),
	.mips_cpu_axi_mmio_awvalid	(mips_cpu_axi_mmio_awvalid),
	.mips_cpu_axi_mmio_bready	(mips_cpu_axi_mmio_bready),
	.mips_cpu_axi_mmio_bresp	(mips_cpu_axi_mmio_bresp),
	.mips_cpu_axi_mmio_bvalid	(mips_cpu_axi_mmio_bvalid),
	.mips_cpu_axi_mmio_rdata	(mips_cpu_axi_mmio_rdata),
	.mips_cpu_axi_mmio_rready	(mips_cpu_axi_mmio_rready),
	.mips_cpu_axi_mmio_rresp	(mips_cpu_axi_mmio_rresp),
	.mips_cpu_axi_mmio_rvalid	(mips_cpu_axi_mmio_rvalid),
	.mips_cpu_axi_mmio_wdata	(mips_cpu_axi_mmio_wdata),
	.mips_cpu_axi_mmio_wready	(mips_cpu_axi_mmio_wready),
	.mips_cpu_axi_mmio_wstrb	(mips_cpu_axi_mmio_wstrb),
	.mips_cpu_axi_mmio_wvalid	(mips_cpu_axi_mmio_wvalid),
	  
	.ps_fclk_clk0				(mips_cpu_clk),
	.ps_user_reset_n			(ps_user_reset_n),
	.mips_cpu_reset_n			(mips_cpu_reset_n),

	.mips_perf_cnt_0			(mips_perf_cnt[31:0]),
	.mips_perf_cnt_1			(mips_perf_cnt[63:32]),
	.mips_perf_cnt_2			(mips_perf_cnt[95:64]),
	.mips_perf_cnt_3			(mips_perf_cnt[127:96]),
	.mips_perf_cnt_4			(mips_perf_cnt[159:128]),
	.mips_perf_cnt_5			(mips_perf_cnt[191:160]),
	.mips_perf_cnt_6			(mips_perf_cnt[223:192]),
	.mips_perf_cnt_7			(mips_perf_cnt[255:224]),
	.mips_perf_cnt_8			(mips_perf_cnt[287:256]),
	.mips_perf_cnt_9			(mips_perf_cnt[319:288]),
	.mips_perf_cnt_10			(mips_perf_cnt[351:320]),
	.mips_perf_cnt_11			(mips_perf_cnt[383:352]),
	.mips_perf_cnt_12			(mips_perf_cnt[415:384]),
	.mips_perf_cnt_13			(mips_perf_cnt[447:416]),
	.mips_perf_cnt_14			(mips_perf_cnt[479:448]),
	.mips_perf_cnt_15			(mips_perf_cnt[511:480]),

	.mips_cpu_axi_mem_araddr	(mips_cpu_axi_mem_araddr + 32'h40000000),
	.mips_cpu_axi_mem_arprot	('d0),
	.mips_cpu_axi_mem_arready	(mips_cpu_axi_mem_arready),
	.mips_cpu_axi_mem_arvalid	(mips_cpu_axi_mem_arvalid),
	.mips_cpu_axi_mem_awaddr	(mips_cpu_axi_mem_awaddr + 32'h40000000),
	.mips_cpu_axi_mem_awprot	('d0),
	.mips_cpu_axi_mem_awready	(mips_cpu_axi_mem_awready),
	.mips_cpu_axi_mem_awvalid	(mips_cpu_axi_mem_awvalid),
	.mips_cpu_axi_mem_bready	(mips_cpu_axi_mem_bready),
	.mips_cpu_axi_mem_bresp		(mips_cpu_axi_mem_bresp),
	.mips_cpu_axi_mem_bvalid	(mips_cpu_axi_mem_bvalid),
	.mips_cpu_axi_mem_rdata		(mips_cpu_axi_mem_rdata),
	.mips_cpu_axi_mem_rready	(mips_cpu_axi_mem_rready),
	.mips_cpu_axi_mem_rresp		(mips_cpu_axi_mem_rresp),
	.mips_cpu_axi_mem_rvalid	(mips_cpu_axi_mem_rvalid),
	.mips_cpu_axi_mem_wdata		(mips_cpu_axi_mem_wdata),
	.mips_cpu_axi_mem_wready	(mips_cpu_axi_mem_wready),
	.mips_cpu_axi_mem_wstrb		(mips_cpu_axi_mem_wstrb),
	.mips_cpu_axi_mem_wvalid	(mips_cpu_axi_mem_wvalid)
);

  //generate positive reset signal for MIPS CPU core
  always @ (posedge mips_cpu_clk)
	  mips_cpu_reset_n_i <= {mips_cpu_reset_n_i[0], ps_user_reset_n};

  assign mips_cpu_reset_n = mips_cpu_reset_n_i[1];

  //Instantiation of AXI-Lite interface
  axi_lite_if 	u_axi_lite_slave (
	  .S_AXI_ACLK		(mips_cpu_clk),
	  .S_AXI_ARESETN	(mips_cpu_reset_n),
	  
	  .S_AXI_ARADDR		(mips_cpu_axi_mmio_araddr),
	  .S_AXI_ARREADY	(mips_cpu_axi_mmio_arready),
	  .S_AXI_ARVALID	(mips_cpu_axi_mmio_arvalid),
	  
	  .S_AXI_AWADDR		(mips_cpu_axi_mmio_awaddr),
	  .S_AXI_AWREADY	(mips_cpu_axi_mmio_awready),
	  .S_AXI_AWVALID	(mips_cpu_axi_mmio_awvalid),
	  
	  .S_AXI_BREADY		(mips_cpu_axi_mmio_bready),
	  .S_AXI_BRESP		(mips_cpu_axi_mmio_bresp),
	  .S_AXI_BVALID		(mips_cpu_axi_mmio_bvalid),
	  
	  .S_AXI_RDATA		(mips_cpu_axi_mmio_rdata),
	  .S_AXI_RREADY		(mips_cpu_axi_mmio_rready),
	  .S_AXI_RRESP		(mips_cpu_axi_mmio_rresp),
	  .S_AXI_RVALID		(mips_cpu_axi_mmio_rvalid),
	  
	  .S_AXI_WDATA		(mips_cpu_axi_mmio_wdata),
	  .S_AXI_WREADY		(mips_cpu_axi_mmio_wready),
	  .S_AXI_WSTRB		(mips_cpu_axi_mmio_wstrb),
	  .S_AXI_WVALID		(mips_cpu_axi_mmio_wvalid),
	  
	  .mips_rst			(mips_cpu_reset)
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

reg [1:0]		mips_cpu_ar_cs;
reg [1:0]		mips_cpu_aw_cs;

always @ (posedge mips_cpu_clk)
begin
	if (mips_cpu_reset == 1'b1)
		mips_cpu_ar_cs <= 2'b00;

	else if ((~|mips_cpu_ar_cs) & mips_cpu_axi_mem_arvalid)
		mips_cpu_ar_cs <= {mips_cpu_axi_mem_araddr[16], ~mips_cpu_axi_mem_araddr[16]};

	else if ((|mips_cpu_ar_cs) & mips_cpu_axi_mem_rvalid & mips_cpu_axi_mem_rready)
		mips_cpu_ar_cs <= 2'b00;

	else
		mips_cpu_ar_cs <= mips_cpu_ar_cs;
end
assign mips_cpu_axi_mem_arready = (mips_cpu_ar_cs[0] & axi_bram_arready) | 
			(mips_cpu_ar_cs[1] & axi_uart_arready);

assign mips_cpu_axi_mem_rdata = ({32{mips_cpu_ar_cs[0]}} & axi_bram_rdata) | 
			({32{mips_cpu_ar_cs[1]}} & axi_uart_rdata);

assign mips_cpu_axi_mem_rresp = ({2{mips_cpu_ar_cs[0]}} & axi_bram_rresp) | 
			({2{mips_cpu_ar_cs[1]}} & axi_uart_rresp);

assign mips_cpu_axi_mem_rvalid = (mips_cpu_ar_cs[0] & axi_bram_rvalid) | 
			(mips_cpu_ar_cs[1] & axi_uart_rvalid);

reg mips_cpu_aw_flag;
reg mips_cpu_w_flag;

always @ (posedge mips_cpu_clk)
begin
	if (mips_cpu_reset == 1'b1)
		mips_cpu_aw_flag <= 1'b0;
	else if (~mips_cpu_aw_flag & mips_cpu_axi_mem_awvalid & mips_cpu_axi_mem_awready)
		mips_cpu_aw_flag <= 1'b1;
	else if (mips_cpu_aw_flag & mips_cpu_w_flag)
		mips_cpu_aw_flag <= 1'b0;
	else
		mips_cpu_aw_flag <= mips_cpu_aw_flag;
end

always @ (posedge mips_cpu_clk)
begin
	if (mips_cpu_reset == 1'b1)
		mips_cpu_w_flag <= 1'b0;
	else if (~mips_cpu_w_flag & mips_cpu_axi_mem_wvalid & mips_cpu_axi_mem_wready)
		mips_cpu_w_flag <= 1'b1;
	else if (mips_cpu_aw_flag & mips_cpu_w_flag)
		mips_cpu_w_flag <= 1'b0;
	else
		mips_cpu_w_flag <= mips_cpu_w_flag;
end

always @ (posedge mips_cpu_clk)
begin
	if (mips_cpu_reset == 1'b1)
		mips_cpu_aw_cs <= 2'b00;

	else if ((~|mips_cpu_aw_cs) & mips_cpu_axi_mem_awvalid & mips_cpu_axi_mem_wvalid)
		mips_cpu_aw_cs <= {mips_cpu_axi_mem_awaddr[16], ~mips_cpu_axi_mem_awaddr[16]};

	else if ((|mips_cpu_aw_cs) & mips_cpu_aw_flag & mips_cpu_w_flag)
		mips_cpu_aw_cs <= 2'b00;

	else
		mips_cpu_aw_cs <= mips_cpu_aw_cs;
end
assign mips_cpu_axi_mem_awready = (mips_cpu_aw_cs[0] & axi_bram_awready) |
			(mips_cpu_aw_cs[1] & axi_uart_awready);

assign mips_cpu_axi_mem_wready = (mips_cpu_aw_cs[0] & axi_bram_wready) |
			(mips_cpu_aw_cs[1] & axi_uart_wready);

assign axi_bram_wdata = {32{mips_cpu_aw_cs[0]}} & mips_cpu_axi_mem_wdata;
assign axi_uart_wdata = {32{mips_cpu_aw_cs[1]}} & mips_cpu_axi_mem_wdata;

assign axi_bram_wstrb = {4{mips_cpu_aw_cs[0]}} & mips_cpu_axi_mem_wstrb;
assign axi_uart_wstrb = {4{mips_cpu_aw_cs[1]}} & mips_cpu_axi_mem_wstrb;

assign axi_bram_wvalid = mips_cpu_aw_cs[0] & mips_cpu_axi_mem_wvalid;
assign axi_uart_wvalid = mips_cpu_aw_cs[1] & mips_cpu_axi_mem_wvalid;

axi_bram_if		u_axi_bram_if (
	.s_axi_aclk		(mips_cpu_clk),
	.s_axi_aresetn	(~mips_cpu_reset),

	.s_axi_araddr	(mips_cpu_axi_mem_araddr[15:0]),
	.s_axi_arlen	('d0),
	.s_axi_arsize	('d2),
	.s_axi_arprot	('d0),
	.s_axi_arburst	('d1),
	.s_axi_arlock	('d0),
	.s_axi_arcache	('d0),
	.s_axi_arready	(axi_bram_arready),
	.s_axi_arvalid	(mips_cpu_axi_mem_arvalid & (~mips_cpu_axi_mem_araddr[16])),

	.s_axi_awaddr	(mips_cpu_axi_mem_awaddr[15:0]),
	.s_axi_awlen	('d0),
	.s_axi_awsize	('d2),
	.s_axi_awprot	('d0),
	.s_axi_awburst	('d1),
	.s_axi_awlock	('d0),
	.s_axi_awcache	('d0),
	.s_axi_awready	(axi_bram_awready),
	.s_axi_awvalid	(mips_cpu_axi_mem_awvalid & (~mips_cpu_axi_mem_awaddr[16])),

	.s_axi_bready	(mips_cpu_axi_mem_bready),
	.s_axi_bresp	(),
	.s_axi_bvalid	(),

	.s_axi_rdata	(axi_bram_rdata),
	.s_axi_rresp	(axi_bram_rresp),
	.s_axi_rvalid	(axi_bram_rvalid),
	.s_axi_rready	(mips_cpu_axi_mem_rready),
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

mips_bram		u_mips_bram (
	.clka			(bram_clk_a),
	.rsta			(bram_rst_a),
	.ena			(bram_en_a),
	.wea			(bram_we_a),
	.addra			({16'd0, bram_addr_a}),
	.dina			(bram_wrdata_a),
	.douta			(bram_rddata_a)
);

mips_uart		u_mips_uart (
	.s_axi_aclk		(mips_cpu_clk),
	.s_axi_aresetn	(~mips_cpu_reset),

	.s_axi_araddr	(mips_cpu_axi_mem_araddr[15:0]),
	.s_axi_arready	(axi_uart_arready),
	.s_axi_arvalid	(mips_cpu_axi_mem_arvalid & mips_cpu_axi_mem_araddr[16]),

	.s_axi_awaddr	(mips_cpu_axi_mem_awaddr[15:0]),
	.s_axi_awready	(axi_uart_awready),
	.s_axi_awvalid	(mips_cpu_axi_mem_awvalid & mips_cpu_axi_mem_awaddr[16]),

	.s_axi_bready	(mips_cpu_axi_mem_bready),
	.s_axi_bresp	(),
	.s_axi_bvalid	(),

	.s_axi_rdata	(axi_uart_rdata),
	.s_axi_rresp	(axi_uart_rresp),
	.s_axi_rvalid	(axi_uart_rvalid),
	.s_axi_rready	(mips_cpu_axi_mem_rready),

	.s_axi_wdata	({24'd0, axi_uart_wdata[7:0]}),
	.s_axi_wready	(axi_uart_wready),
	.s_axi_wstrb	(axi_uart_wstrb),
	.s_axi_wvalid	(axi_uart_wvalid)
);

`ifdef UART_SIM
uart_recv_sim	u_uart_sim(
	.clock			(mips_cpu_clk),
	.reset			(mips_cpu_reset),
	
	.io_en			(1'b1),
	.io_in			(uart_tx),
	.io_out_valid	(uart_tx_data_valid),
	.io_out_bits	(uart_tx_data),
	.io_div			(16'd868)			//100MHz / 115200
);

always @ (posedge mips_cpu_clk)
begin
	if (uart_tx_data_valid)
		$write("%c", uart_tx_data);
end
`endif

genvar i;
generate
begin
	for (i = 0; i < 16; i = i + 1)
	begin: MIPS_PERF_FLAG
		assign mips_perf_cnt_flag[i] = |mips_perf_cnt[(i + 1) * 32 - 1 : i * 32];
	end
end
endgenerate

`endif

endmodule

