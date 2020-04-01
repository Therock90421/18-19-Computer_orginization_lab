/* =========================================
* Top module for RISC-V cores in the FPGA
* evaluation platform
*
* Author: Yisong Chang (changyisong@ict.ac.cn)
* Date: 19/03/2017
* Version: v0.0.1
*===========================================
*/

`timescale 10 ns / 1 ns

module riscv_cpu_top (
	input			riscv_cpu_clk,
    input			riscv_cpu_reset,
`ifdef RISCV_CPU_FULL_SIMU
	output			riscv_cpu_pc_sig,
`endif

	//AXI AR Channel
    output  [31:0]	riscv_cpu_axi_if_araddr,
    input			riscv_cpu_axi_if_arready,
    output			riscv_cpu_axi_if_arvalid,

	//AXI AW Channel
    output reg [31:0]	riscv_cpu_axi_if_awaddr,
    input			    riscv_cpu_axi_if_awready,
    output reg			riscv_cpu_axi_if_awvalid,

	//AXI B Channel
    output			riscv_cpu_axi_if_bready,
    input	[1:0]	riscv_cpu_axi_if_bresp,
    input			riscv_cpu_axi_if_bvalid,

	//AXI R Channel
    input	[31:0]	riscv_cpu_axi_if_rdata,
    output			riscv_cpu_axi_if_rready,
    input	[1:0]	riscv_cpu_axi_if_rresp,
    input			riscv_cpu_axi_if_rvalid,

	//AXI W Channel
    output reg [31:0]	riscv_cpu_axi_if_wdata,
    input			    riscv_cpu_axi_if_wready,
    output reg [3:0]	riscv_cpu_axi_if_wstrb,
    output reg			riscv_cpu_axi_if_wvalid
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
always @(posedge riscv_cpu_clk)
begin
	if (riscv_cpu_reset == 1'b1)
	begin
		riscv_cpu_axi_if_awaddr <= 'd0;
		riscv_cpu_axi_if_awvalid <= 1'b0;
		aw_req_ack_tag <= 1'b0;
	end

	else if (~riscv_cpu_axi_if_awvalid & (~riscv_cpu_axi_if_wvalid) & MemWrite & (~Mem_Req_Ack))
	begin
		riscv_cpu_axi_if_awaddr <= Address;
		riscv_cpu_axi_if_awvalid <= 1'b1;
		aw_req_ack_tag <= 1'b0;
	end

	else if (riscv_cpu_axi_if_awvalid & riscv_cpu_axi_if_awready)
	begin
		riscv_cpu_axi_if_awaddr <= 'd0;
		riscv_cpu_axi_if_awvalid <= 1'b0;
		aw_req_ack_tag <= 1'b1;
	end

	else if (aw_req_ack_tag & w_req_ack_tag)
	begin
		riscv_cpu_axi_if_awaddr <= riscv_cpu_axi_if_awaddr;
		riscv_cpu_axi_if_awvalid <= riscv_cpu_axi_if_awvalid;
		aw_req_ack_tag <= 1'b0;
	end

	else
	begin
		riscv_cpu_axi_if_awaddr <= riscv_cpu_axi_if_awaddr;
		riscv_cpu_axi_if_awvalid <= riscv_cpu_axi_if_awvalid;
		aw_req_ack_tag <= aw_req_ack_tag;
	end
end

/*AXI AW channel*/
always @(posedge riscv_cpu_clk)
begin
	if (riscv_cpu_reset == 1'b1)
	begin
		riscv_cpu_axi_if_wdata <= 'd0;
		riscv_cpu_axi_if_wstrb <= 4'b0;
		riscv_cpu_axi_if_wvalid <= 1'b0;
		w_req_ack_tag <= 1'b0;
	end

	else if (~riscv_cpu_axi_if_awvalid & (~riscv_cpu_axi_if_wvalid) & MemWrite & (~Mem_Req_Ack))
	begin
		riscv_cpu_axi_if_wdata <= Write_data;
		riscv_cpu_axi_if_wstrb <= Write_strb;
		riscv_cpu_axi_if_wvalid <= 1'b1;
		w_req_ack_tag <= 1'b0;
	end

	else if (riscv_cpu_axi_if_wvalid & riscv_cpu_axi_if_wready)
	begin
		riscv_cpu_axi_if_wdata <= 'd0;
		riscv_cpu_axi_if_wstrb <= 4'b0;
		riscv_cpu_axi_if_wvalid <= 1'b0;
		w_req_ack_tag <= 1'b1;
	end

	else if (aw_req_ack_tag & w_req_ack_tag)
	begin
		riscv_cpu_axi_if_wdata <= riscv_cpu_axi_if_wdata;
		riscv_cpu_axi_if_wstrb <= riscv_cpu_axi_if_wstrb;
		riscv_cpu_axi_if_wvalid <= riscv_cpu_axi_if_wvalid;
		w_req_ack_tag <= 1'b0;
	end

	else
	begin
		riscv_cpu_axi_if_wdata <= riscv_cpu_axi_if_wdata;
		riscv_cpu_axi_if_wstrb <= riscv_cpu_axi_if_wstrb;
		riscv_cpu_axi_if_wvalid <= riscv_cpu_axi_if_wvalid;
		w_req_ack_tag <= w_req_ack_tag;
	end
end

/*AXI AR channel*/
assign riscv_cpu_axi_if_araddr = Inst_Req_Valid ? PC : (MemRead ? Address : 'd0);
assign riscv_cpu_axi_if_arvalid = Inst_Req_Valid | MemRead;

always @(posedge riscv_cpu_clk)
begin
	if ( (~|ar_req_tag) & riscv_cpu_axi_if_arvalid & riscv_cpu_axi_if_arready )
		ar_req_tag <= {MemRead, Inst_Req_Valid};

	else if ((|ar_req_tag) & riscv_cpu_axi_if_rvalid & riscv_cpu_axi_if_rready)
		ar_req_tag <= 2'b00;

	else
		ar_req_tag <= ar_req_tag;
end

/*AXI R channel*/
assign riscv_cpu_axi_if_rready = (Inst_Ack | Read_data_Ack);

/*AXI B channel*/
assign riscv_cpu_axi_if_bready = 1'b1;

//riscv CPU cores
assign Inst_Req_Ack = Inst_Req_Valid & riscv_cpu_axi_if_arready;

assign Instruction = {32{ar_req_tag[0]}} & riscv_cpu_axi_if_rdata;
assign Inst_Valid = ar_req_tag[0] & riscv_cpu_axi_if_rvalid;

assign Read_data = {32{ar_req_tag[1]}} & riscv_cpu_axi_if_rdata;
assign Read_data_Valid = ar_req_tag[1] & riscv_cpu_axi_if_rvalid;

assign Mem_Req_Ack = (MemWrite & aw_req_ack_tag & w_req_ack_tag) | (MemRead & riscv_cpu_axi_if_arready);

riscv_cpu	u_riscv_cpu (	
	.clk			(riscv_cpu_clk),
	.rst			(riscv_cpu_reset),
	  
	//Instruction request channel
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
	.Read_data_Ack	(Read_data_Ack)
);

`ifdef RISCV_CPU_FULL_SIMU
	assign riscv_cpu_pc_sig = PC[2];
`endif

endmodule

