/* =========================================
* Top module of FPGA evaluation platform for
* MIPS CPU cores
*
* Author: Yisong Chang (changyisong@ict.ac.cn)
* Date: 19/03/2017
* Version: v0.0.1
*===========================================
*/

`timescale 1 ps / 1 ps

module mips_cpu_fpga (
);

  wire				mips_cpu_clk;
  reg [1:0]			mips_cpu_reset_n_i = 2'b00;
  wire				mips_cpu_reset_n;
  wire				ps_user_reset_n;


  wire [39:0]		mips_cpu_axi_if_araddr;
  wire				mips_cpu_axi_if_arready;
  wire				mips_cpu_axi_if_arvalid;
  wire [39:0]		mips_cpu_axi_if_awaddr;
  wire				mips_cpu_axi_if_awready;
  wire				mips_cpu_axi_if_awvalid;
  wire				mips_cpu_axi_if_bready;
  wire [1:0]		mips_cpu_axi_if_bresp;
  wire				mips_cpu_axi_if_bvalid;
  wire [31:0]		mips_cpu_axi_if_rdata;
  wire				mips_cpu_axi_if_rready;
  wire [1:0]		mips_cpu_axi_if_rresp;
  wire				mips_cpu_axi_if_rvalid;
  wire [31:0]		mips_cpu_axi_if_wdata;
  wire				mips_cpu_axi_if_wready;
  wire [3:0]		mips_cpu_axi_if_wstrb;
  wire				mips_cpu_axi_if_wvalid;

  mpsoc_wrapper		u_zynq_soc_wrapper (
	  .mips_cpu_axi_if_araddr		(mips_cpu_axi_if_araddr),
	  .mips_cpu_axi_if_arprot		(),
	  .mips_cpu_axi_if_arready		(mips_cpu_axi_if_arready),
	  .mips_cpu_axi_if_arvalid		(mips_cpu_axi_if_arvalid),
	  .mips_cpu_axi_if_awaddr		(mips_cpu_axi_if_awaddr),
	  .mips_cpu_axi_if_awprot		(),
	  .mips_cpu_axi_if_awready		(mips_cpu_axi_if_awready),
	  .mips_cpu_axi_if_awvalid		(mips_cpu_axi_if_awvalid),
	  .mips_cpu_axi_if_bready		(mips_cpu_axi_if_bready),
	  .mips_cpu_axi_if_bresp		(mips_cpu_axi_if_bresp),
	  .mips_cpu_axi_if_bvalid		(mips_cpu_axi_if_bvalid),
	  .mips_cpu_axi_if_rdata		(mips_cpu_axi_if_rdata),
	  .mips_cpu_axi_if_rready		(mips_cpu_axi_if_rready),
	  .mips_cpu_axi_if_rresp		(mips_cpu_axi_if_rresp),
	  .mips_cpu_axi_if_rvalid		(mips_cpu_axi_if_rvalid),
	  .mips_cpu_axi_if_wdata		(mips_cpu_axi_if_wdata),
	  .mips_cpu_axi_if_wready		(mips_cpu_axi_if_wready),
	  .mips_cpu_axi_if_wstrb		(mips_cpu_axi_if_wstrb),
	  .mips_cpu_axi_if_wvalid		(mips_cpu_axi_if_wvalid),
	  
	  .ps_fclk_clk0					(mips_cpu_clk),
	  .ps_user_reset_n				(ps_user_reset_n),
	  .mips_cpu_reset_n				(mips_cpu_reset_n)
  );

  //generate positive reset signal for MIPS CPU core
  always @ (posedge mips_cpu_clk)
	  mips_cpu_reset_n_i <= {mips_cpu_reset_n_i[0], ps_user_reset_n};

  assign mips_cpu_reset_n = mips_cpu_reset_n_i[1];
 
  //Instantiation of MIPS CPU core
  mips_cpu_top		u_mips_cpu_top (
	  .mips_cpu_clk					(mips_cpu_clk),
	  .mips_cpu_reset				(~mips_cpu_reset_n),
	  
	  .mips_cpu_axi_if_araddr		(mips_cpu_axi_if_araddr[13:0]),
	  .mips_cpu_axi_if_arready		(mips_cpu_axi_if_arready),
	  .mips_cpu_axi_if_arvalid		(mips_cpu_axi_if_arvalid),
	  .mips_cpu_axi_if_awaddr		(mips_cpu_axi_if_awaddr[13:0]),
	  .mips_cpu_axi_if_awready		(mips_cpu_axi_if_awready),
	  .mips_cpu_axi_if_awvalid		(mips_cpu_axi_if_awvalid),
	  .mips_cpu_axi_if_bready		(mips_cpu_axi_if_bready),
	  .mips_cpu_axi_if_bresp		(mips_cpu_axi_if_bresp),
	  .mips_cpu_axi_if_bvalid		(mips_cpu_axi_if_bvalid),
	  .mips_cpu_axi_if_rdata		(mips_cpu_axi_if_rdata),
	  .mips_cpu_axi_if_rready		(mips_cpu_axi_if_rready),
	  .mips_cpu_axi_if_rresp		(mips_cpu_axi_if_rresp),
	  .mips_cpu_axi_if_rvalid		(mips_cpu_axi_if_rvalid),
	  .mips_cpu_axi_if_wdata		(mips_cpu_axi_if_wdata),
	  .mips_cpu_axi_if_wready		(mips_cpu_axi_if_wready),
	  .mips_cpu_axi_if_wstrb		(mips_cpu_axi_if_wstrb),
	  .mips_cpu_axi_if_wvalid		(mips_cpu_axi_if_wvalid)
  );

endmodule

