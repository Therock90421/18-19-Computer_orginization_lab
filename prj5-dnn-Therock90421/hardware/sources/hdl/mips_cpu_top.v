/* =========================================
* Top module for MIPS cores in the FPGA
* evaluation platform
*
* Author: Yisong Chang (changyisong@ict.ac.cn)
* Date: 19/03/2017
* Version: v0.0.1
*===========================================
*/

`timescale 10 ns / 1 ns

module mips_cpu_top (
	input			mips_cpu_clk,
    input			mips_cpu_reset,
`ifdef MIPS_CPU_FULL_SIMU
	output			mips_cpu_pc_sig,
`endif

    output [31:0]	mips_perf_cnt_0,
    output [31:0]	mips_perf_cnt_1,
    output [31:0]	mips_perf_cnt_2,
    output [31:0]	mips_perf_cnt_3,
    output [31:0]	mips_perf_cnt_4,
    output [31:0]	mips_perf_cnt_5,
    output [31:0]	mips_perf_cnt_6,
    output [31:0]	mips_perf_cnt_7,
    output [31:0]	mips_perf_cnt_8,
    output [31:0]	mips_perf_cnt_9,
    output [31:0]	mips_perf_cnt_10,
    output [31:0]	mips_perf_cnt_11,
    output [31:0]	mips_perf_cnt_12,
    output [31:0]	mips_perf_cnt_13,
    output [31:0]	mips_perf_cnt_14,
    output [31:0]	mips_perf_cnt_15,

	//AXI AR Channel
    output  [31:0]	mips_cpu_axi_if_araddr,
    input			mips_cpu_axi_if_arready,
    output			mips_cpu_axi_if_arvalid,

	//AXI AW Channel
    output reg [31:0]	mips_cpu_axi_if_awaddr,
    input			    mips_cpu_axi_if_awready,
    output reg			mips_cpu_axi_if_awvalid,

	//AXI B Channel
    output			mips_cpu_axi_if_bready,
    input	[1:0]	mips_cpu_axi_if_bresp,
    input			mips_cpu_axi_if_bvalid,

	//AXI R Channel
    input	[31:0]	mips_cpu_axi_if_rdata,
    output			mips_cpu_axi_if_rready,
    input	[1:0]	mips_cpu_axi_if_rresp,
    input			mips_cpu_axi_if_rvalid,

	//AXI W Channel
    output reg [31:0]	mips_cpu_axi_if_wdata,
    input			    mips_cpu_axi_if_wready,
    output reg [3:0]	mips_cpu_axi_if_wstrb,
    output reg			mips_cpu_axi_if_wvalid
);

wire [31:0] PC;
wire Inst_Req_Valid;
wire Inst_Req_Ack;

wire [31:0] Instruction;
wire Inst_Valid;
wire Inst_Ack;

wire [31:0] Address;
wire MemWrite;
wire [31:0] Write_data;
wire [3:0] Write_strb;
wire MemRead;
wire Mem_Req_Ack;

wire [31:0] Read_data;
wire Read_data_Valid;
wire Read_data_Ack;

reg aw_req_ack_tag;
reg w_req_ack_tag;

reg [1:0] ar_req_tag = 2'b00;

/*AXI AW channel*/
always @(posedge mips_cpu_clk)
begin
	if (mips_cpu_reset == 1'b1)
	begin
		mips_cpu_axi_if_awaddr <= 'd0;
		mips_cpu_axi_if_awvalid <= 1'b0;
		aw_req_ack_tag <= 1'b0;
	end

	else if (~mips_cpu_axi_if_awvalid & (~mips_cpu_axi_if_wvalid) & MemWrite & (~Mem_Req_Ack))
	begin
		mips_cpu_axi_if_awaddr <= Address;
		mips_cpu_axi_if_awvalid <= 1'b1;
		aw_req_ack_tag <= 1'b0;
	end

	else if (mips_cpu_axi_if_awvalid & mips_cpu_axi_if_awready)
	begin
		mips_cpu_axi_if_awaddr <= 'd0;
		mips_cpu_axi_if_awvalid <= 1'b0;
		aw_req_ack_tag <= 1'b1;
	end

	else if (aw_req_ack_tag & w_req_ack_tag)
	begin
		mips_cpu_axi_if_awaddr <= mips_cpu_axi_if_awaddr;
		mips_cpu_axi_if_awvalid <= mips_cpu_axi_if_awvalid;
		aw_req_ack_tag <= 1'b0;
	end

	else
	begin
		mips_cpu_axi_if_awaddr <= mips_cpu_axi_if_awaddr;
		mips_cpu_axi_if_awvalid <= mips_cpu_axi_if_awvalid;
		aw_req_ack_tag <= aw_req_ack_tag;
	end
end

/*AXI AW channel*/
always @(posedge mips_cpu_clk)
begin
	if (mips_cpu_reset == 1'b1)
	begin
		mips_cpu_axi_if_wdata <= 'd0;
		mips_cpu_axi_if_wstrb <= 4'b0;
		mips_cpu_axi_if_wvalid <= 1'b0;
		w_req_ack_tag <= 1'b0;
	end

	else if (~mips_cpu_axi_if_awvalid & (~mips_cpu_axi_if_wvalid) & MemWrite & (~Mem_Req_Ack))
	begin
		mips_cpu_axi_if_wdata <= Write_data;
		mips_cpu_axi_if_wstrb <= Write_strb;
		mips_cpu_axi_if_wvalid <= 1'b1;
		w_req_ack_tag <= 1'b0;
	end

	else if (mips_cpu_axi_if_wvalid & mips_cpu_axi_if_wready)
	begin
		mips_cpu_axi_if_wdata <= 'd0;
		mips_cpu_axi_if_wstrb <= 4'b0;
		mips_cpu_axi_if_wvalid <= 1'b0;
		w_req_ack_tag <= 1'b1;
	end

	else if (aw_req_ack_tag & w_req_ack_tag)
	begin
		mips_cpu_axi_if_wdata <= mips_cpu_axi_if_wdata;
		mips_cpu_axi_if_wstrb <= mips_cpu_axi_if_wstrb;
		mips_cpu_axi_if_wvalid <= mips_cpu_axi_if_wvalid;
		w_req_ack_tag <= 1'b0;
	end

	else
	begin
		mips_cpu_axi_if_wdata <= mips_cpu_axi_if_wdata;
		mips_cpu_axi_if_wstrb <= mips_cpu_axi_if_wstrb;
		mips_cpu_axi_if_wvalid <= mips_cpu_axi_if_wvalid;
		w_req_ack_tag <= w_req_ack_tag;
	end
end

`ifdef MIPS_CPU_FULL_SIMU
	wire io_wr_ack = MemWrite & Address[16] & ~Address[27];
	always @ (*)
	begin
		if (io_wr_ack)
			$write("%c", Write_data[7:0]);
	end
`endif

/*AXI AR channel*/
assign mips_cpu_axi_if_araddr = Inst_Req_Valid ? PC : (MemRead ? Address : 'd0);
assign mips_cpu_axi_if_arvalid = Inst_Req_Valid | MemRead;

always @(posedge mips_cpu_clk)
begin
	if ( (~|ar_req_tag) & mips_cpu_axi_if_arvalid & mips_cpu_axi_if_arready )
		ar_req_tag <= {MemRead, Inst_Req_Valid};

	else if ((|ar_req_tag) & mips_cpu_axi_if_rvalid & mips_cpu_axi_if_rready)
		ar_req_tag <= 2'b00;

	else
		ar_req_tag <= ar_req_tag;
end

/*AXI R channel*/
assign mips_cpu_axi_if_rready = (Inst_Ack | Read_data_Ack);

/*AXI B channel*/
assign mips_cpu_axi_if_bready = 1'b1;

//MIPS CPU cores
assign Inst_Req_Ack = Inst_Req_Valid & mips_cpu_axi_if_arready;

assign Instruction = {32{ar_req_tag[0]}} & mips_cpu_axi_if_rdata;
assign Inst_Valid = ar_req_tag[0] & mips_cpu_axi_if_rvalid;

assign Read_data = {32{ar_req_tag[1]}} & mips_cpu_axi_if_rdata;
assign Read_data_Valid = ar_req_tag[1] & mips_cpu_axi_if_rvalid;

assign Mem_Req_Ack = (MemWrite & aw_req_ack_tag & w_req_ack_tag) | (MemRead & mips_cpu_axi_if_arready);

mips_cpu	u_mips_cpu (	
	.clk			(mips_cpu_clk),
	.rst			(mips_cpu_reset),
	  
	.PC				(PC),
	.Inst_Req_Valid	(Inst_Req_Valid),
	.Inst_Req_Ack	(Inst_Req_Ack),
	  
	.Instruction	(Instruction),
	.Inst_Valid		(Inst_Valid),
	.Inst_Ack		(Inst_Ack),
	  
	.Address		(Address),
	.MemWrite		(MemWrite),
	.Write_data		(Write_data),
	.Write_strb		(Write_strb),
	.MemRead		(MemRead),
	.Mem_Req_Ack	(Mem_Req_Ack),
	  
	.Read_data		(Read_data),
	.Read_data_Valid(Read_data_Valid),
	.Read_data_Ack	(Read_data_Ack),

	.mips_perf_cnt_0	(mips_perf_cnt_0 ),
	.mips_perf_cnt_1	(mips_perf_cnt_1 ),
	.mips_perf_cnt_2	(mips_perf_cnt_2 ),
	.mips_perf_cnt_3	(mips_perf_cnt_3 ),
	.mips_perf_cnt_4	(mips_perf_cnt_4 ),
	.mips_perf_cnt_5	(mips_perf_cnt_5 ),
	.mips_perf_cnt_6	(mips_perf_cnt_6 ),
	.mips_perf_cnt_7	(mips_perf_cnt_7 ),
	.mips_perf_cnt_8	(mips_perf_cnt_8 ),
	.mips_perf_cnt_9	(mips_perf_cnt_9 ),
	.mips_perf_cnt_10	(mips_perf_cnt_10),
	.mips_perf_cnt_11	(mips_perf_cnt_11),
	.mips_perf_cnt_12	(mips_perf_cnt_12),
	.mips_perf_cnt_13	(mips_perf_cnt_13),
	.mips_perf_cnt_14	(mips_perf_cnt_14),
	.mips_perf_cnt_15	(mips_perf_cnt_15)
);

`ifdef MIPS_CPU_FULL_SIMU
	assign mips_cpu_pc_sig = PC[2];
`endif

endmodule

