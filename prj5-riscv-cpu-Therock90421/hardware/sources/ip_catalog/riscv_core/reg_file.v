`timescale 10 ns / 1 ns

`define DATA_WIDTH 32
`define ADDR_WIDTH 5

module reg_file(
	input clk,
	input rst,
	input [`ADDR_WIDTH - 1:0] waddr,
	input [`ADDR_WIDTH - 1:0] raddr1,
	input [`ADDR_WIDTH - 1:0] raddr2,
	input wen,
	input [`DATA_WIDTH - 1:0] wdata,
	output [`DATA_WIDTH - 1:0] rdata1,
	output [`DATA_WIDTH - 1:0] rdata2
);

	 reg [31:0] r[31:0];
   
    always@(posedge clk)begin
     if(rst==1)
     begin
    r[0]<=0;
    r[1]<=0;
    r[2]<=0;
    r[3]<=0;
    r[4]<=0;
    r[5]<=0;
    r[6]<=0;
    r[7]<=0;
    r[8]<=0;
    r[9]<=0;
    r[10]<=0;
    r[11]<=0;
    r[12]<=0;
    r[13]<=0;
    r[14]<=0;
    r[15]<=0;
    r[16]<=0;
    r[17]<=0;
    r[18]<=0;
    r[19]<=0;
    r[20]<=0;
    r[21]<=0;
    r[22]<=0;
    r[23]<=0;
    r[24]<=0;
    r[25]<=0;
    r[26]<=0;
    r[27]<=0;
    r[28]<=0;
    r[29]<=0;
    r[30]<=0;    
    r[31]<=0;
    end
    else if(wen == 1)begin
    r[waddr]<= wdata;
    r[0]<=32'b0;
    end
    end
    assign rdata1 = r[raddr1];
    assign rdata2 = r[raddr2];
	

endmodule
