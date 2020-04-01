`timescale 10ns / 1ns


module mips_cpu(
	input  rst,
	input  clk,

	output reg [31:0] PC,
	input  [31:0] Instruction,

	output [31:0] Address,
	output MemWrite,
	output [31:0] Write_data,
	output [3:0] Write_strb,

	input  [31:0] Read_data,
	output MemRead
);

	// THESE THREE SIGNALS ARE USED IN OUR TESTBENCH
	// PLEASE DO NOT MODIFY SIGNAL NAMES
	// AND PLEASE USE THEM TO CONNECT PORTS
	// OF YOUR INSTANTIATION OF THE REGISTER FILE MODULE
	wire			RF_wen;
	wire [4:0]		RF_waddr;
	wire [31:0]		RF_wdata;
       
	// TODO: PLEASE ADD YOUT CODE BELOW
        wire [31:0]             Rf_wdata;
        
        wire [5:0]              op;
        wire [4:0]              rs;
        wire [4:0]              rt;
        wire [4:0]              rd;
        wire [5:0]              func;
        wire [4:0]              sa;
        wire op_ADDIU,op_BNE,op_LW,op_SW,op_SLL,op_ADDU,op_BEQ,op_J,op_JAL,op_JR,
        op_LUI,op_OR,op_SLT,op_SLTI,op_SLTIU,
        op_AND,op_ANDI,op_BGEZ,op_BLEZ,op_BLTZ,op_JALR,op_LB,op_LBU,op_LH,op_LHU,op_LWL,op_LWR,
        op_MOVN,op_MOVZ,op_NOR,op_ORI,op_SB,op_SH,op_SWL,op_SWR,op_SLLV,op_SLTU,op_SRA,op_SRAV,
        op_SRL,op_SRLV,op_SUBU,op_XOR,op_XORI;
        
        wire RegDst,Branch,MemToReg,ALUSrc,RegWrite;
        wire [2:0]              ALUOp;
        wire Overflow,CarryOut,Zero,Overflow1,CarryOut1,Zero1;
        wire [31:0]             Result;
        
        wire [31:0]             data1;
        wire [31:0]             data2;
        
       
        wire  [31:0]            Mux_ALU;
        wire  [31:0]            Mux_Writedata;   
        wire  [31:0]            Sign_extend;
        wire   [31:0]            PC1; 
        wire   [31:0]            PC2;
        wire   [31:0]            PC3;
        wire   [31:0]            PCJUMP;
        wire   [31:0]            data;
        assign op     =   Instruction[31:26];
        assign rs     =   Instruction[25:21];
        assign rt     =   Instruction[20:16];
        assign rd     =   Instruction[15:11];
        assign sa     =   Instruction[10: 6];  
        assign func   =   Instruction[ 5: 0];
        
        assign op_ADDIU =   (op == 6'b001001); 
        assign op_BNE   =   (op == 6'b000101);
        assign op_LW    =   (op == 6'b100011);
        assign op_SW    =   (op == 6'b101011);
        assign op_SLL   =   (op == 6'b000000)&&( func == 6'b000000);
        assign op_ADDU  =   (op == 6'b000000)&&( func == 6'b100001);
        assign op_BEQ   =   (op == 6'b000100);
        assign op_J     =   (op == 6'b000010);
        assign op_JAL   =   (op == 6'b000011);
        assign op_JR    =   (op == 6'b000000)&&( func == 6'b001000);
        assign op_LUI   =   (op == 6'b001111);
        assign op_OR    =   (op == 6'b000000)&&( func == 6'b100101);
        assign op_SLT   =   (op == 6'b000000)&&( func == 6'b101010);
        assign op_SLTI  =   (op == 6'b001010);
        assign op_SLTIU =   (op == 6'b001011);
        
        assign op_AND   =   (op == 6'b000000)&&( func == 6'b100100);
        assign op_ANDI =   (op == 6'b001100);
        assign op_BGEZ =   (op == 6'b000001)&&( rt == 5'b00001);
        assign op_BLEZ =   (op == 6'b000110);
        assign op_BLTZ =   (op == 6'b000001);
        assign op_JALR =   (op == 6'b000000)&&( func == 6'b001001);
        assign op_LB   =   (op == 6'b100000);
        assign op_LBU  =   (op == 6'b100100);
        assign op_LH   =   (op == 6'b100001);
        assign op_LHU  =   (op == 6'b100101);
        assign op_LWL  =   (op == 6'b100010);
        assign op_LWR  =   (op == 6'b100110);
        assign op_MOVN =   (op == 6'b000000)&&( func == 6'b001011);
        assign op_MOVZ =   (op == 6'b000000)&&( func == 6'b001010);
        assign op_NOR  =   (op == 6'b000000)&&( func == 6'b100111);
        assign op_ORI  =   (op == 6'b001101);
        assign op_SB   =   (op == 6'b101000);
        assign op_SH   =   (op == 6'b101001);
        assign op_SWL  =   (op == 6'b101010);
        assign op_SWR  =   (op == 6'b101110);
        assign op_SLLV =   (op == 6'b000000)&&( func == 6'b000100);
        assign op_SLTU =   (op == 6'b000000)&&( func == 6'b101011);
        assign op_SRA  =   (op == 6'b000000)&&( func == 6'b000011);
        assign op_SRAV =   (op == 6'b000000)&&( func == 6'b000111);
        assign op_SRL  =   (op == 6'b000000)&&( func == 6'b000010);
        assign op_SRLV =   (op == 6'b000000)&&( func == 6'b000110);
        assign op_SUBU =   (op == 6'b000000)&&( func == 6'b100011);
        assign op_XOR  =   (op == 6'b000000)&&( func == 6'b100110);
        assign op_XORI =   (op == 6'b001110);
        
        
        
        assign RegDst   =   (op_SLL||op_ADDU||op_BEQ||op_OR||op_SLT||op_AND||op_BGEZ||op_JALR||op_MOVN||op_MOVZ||op_NOR||op_SLLV||op_SLTU||op_SRA||op_SRAV||op_SRL||op_SRLV||op_SUBU||op_XOR)?1:0;
        
        assign Branch   =   (op_BNE||op_BEQ||op_BGEZ||op_BLEZ||op_BLTZ)?1:0;
        
        assign MemRead  =   (op_LW||op_LB||op_LBU||op_LH||op_LHU||op_LWL||op_LWR)?1:0;
        
        assign MemToReg =   (op_LW||op_LB||op_LBU||op_LH||op_LHU||op_LWL||op_LWR)?1:0;
        
        assign ALUOp    =   (op_ADDIU || op_LW || op_SW||op_ADDU||op_LUI||op_LB||op_LBU||op_LH||op_LHU||op_MOVN||op_MOVZ||op_SB||op_SH||op_SWL||op_SWR||op_LWL||op_LWR)?3'b010:
                            (op_BNE||op_BEQ||op_SUBU)?3'b110:
                            (op_SRA||op_SRAV)?3'b100:
                            //(op_SLL||op_SLLV)?3'b100:
                            (op_OR||op_NOR||op_ORI)?3'b001:
                            (op_SLT||op_SLTI||op_BGEZ||op_BLEZ||op_BLTZ)?3'b111:
                            (op_SLTIU||op_SLTU)?3'b101:
                            (op_XOR||op_XORI)?3'b011:
                            3'b000;
                            
        assign MemWrite =   (op_SW||op_SB||op_SH||op_SWL||op_SWR)?1:0;
        
        assign ALUSrc   =   (op_ADDIU ||op_LW ||op_SW ||op_SLL||op_LUI||op_SLTI||op_SLTIU||op_ANDI||op_LB||op_LBU||op_LH||op_LHU||op_LWL||op_LWR||op_ORI||op_SB||op_SH||op_SWL||op_SWR||op_SRA||op_XORI)?1:0;
        
        assign RegWrite =   (op_ADDIU ||op_SLL||(op_LW && Address[1:0]==2'b00)||op_ADDU||op_JAL||op_LUI||op_OR||op_SLT||op_SLTI||op_SLTIU||op_AND||op_ANDI||op_JALR||op_LB||op_LBU||op_LH||op_LHU||op_LWL||op_LWR||(op_MOVN&&(!Zero))||(op_MOVZ&&Zero)||op_NOR||op_ORI||op_SLLV||op_SLTU||op_SRA||op_SRAV||op_SRL||op_SRLV||op_SUBU||op_XOR||op_XORI)?1:0;   
         
        assign Write_strb = (op_ADDIU ||op_BNE||op_LW||op_SW||op_SLL||op_ADDU||op_BEQ||op_J||op_JAL||op_JR||
        op_LUI||op_OR||op_SLT||op_SLTI||op_SLTIU||op_AND||op_ANDI||op_BGEZ||op_BLEZ||op_BLTZ||op_JALR||op_LB||op_LBU||op_LH||op_LHU||op_LWL||op_LWR||op_MOVN||op_MOVZ||op_NOR||op_ORI||op_SLLV||op_SLTU||op_SRA||op_SRAV||op_SRL||op_SRLV||op_SUBU||op_XOR)?4'b1111
        :(op_SB)?
                          (Result[1:0]==2'b00)?4'b0001:
                          (Result[1:0]==2'b01)?4'b0010:
                          (Result[1:0]==2'b10)?4'b0100:
                          (Result[1:0]==2'b11)?4'b1000:0
        :(op_SH)?
                          (Result[1]==1'b0)?4'b0011:
                          (Result[1]==1'b1)?4'b1100:0
        :(op_SWL)?              
                          (Result[1:0]==2'b00)?4'b0001:
                          (Result[1:0]==2'b01)?4'b0011:
                          (Result[1:0]==2'b10)?4'b0111:
                          (Result[1:0]==2'b11)?4'b1111:0
        :(op_SWR)?              
                          (Result[1:0]==2'b00)?4'b1111:
                          (Result[1:0]==2'b01)?4'b1110:
                          (Result[1:0]==2'b10)?4'b1100:
                          (Result[1:0]==2'b11)?4'b1000:0     
                                                                       
        :0;
        
        
       
        always@(posedge clk)
        begin
        if(rst)
        PC<=32'b0;
        else PC<=PC2;
        end
        assign PC3 = PC + 32'd4;
        assign PCJUMP = (op_JR||op_JALR)?data1:{PC3[31:28],Instruction[25:0],2'b00};
        
        alu alu2(PC3,(Sign_extend <<2),3'b010,Overflow1,CarryOut1,Zero1,PC1);
        
        assign PC2 = (op_J||op_JAL||op_JR||op_JALR)?PCJUMP:((Branch&&(!Zero)&&(!RegDst))||(Branch&&Zero&&RegDst))?PC1:PC3;
        
        
        reg_file reg_file1(clk,rst,RF_waddr,rs,rt,RF_wen,RF_wdata,data1,data2);
        
        assign RF_waddr = (op_JAL)?5'd31:(RegDst)?rd:rt;
        

        
        assign Sign_extend = (op_ANDI||op_ORI||op_XORI)?{16'd0,Instruction[15:0]}:(op_SRA)?{26'd0,sa}:
                             (Instruction[15]==1)?{16'hffff,Instruction[15:0]}:{16'd0,Instruction[15:0]};
                             
        assign Mux_ALU = //(op_SRAV)?data1[4:0]:(op_BLEZ||op_BGEZ)?32'd1:(op_MOVN||op_MOVZ)?32'd0:(ALUSrc)?Sign_extend:data2;    //BGEZ is not equal??? this problem solved
                         (op_SRAV)?data1[4:0]:(op_BLEZ)?32'd1:(op_BGEZ||op_MOVN||op_MOVZ)?32'd0:(ALUSrc)?Sign_extend:data2;
        
        assign data = (op_SLL||op_MOVN||op_MOVZ||op_SRAV||op_SRA)?data2:data1;
        
        alu alu1(data,Mux_ALU,ALUOp,Overflow,CarryOut,Zero,Result);
        
        assign Address = (op_LB||op_LBU||op_LH||op_LHU||op_LWL||op_LWR||op_SB||op_SH||op_SWL||op_SWR)?{Result[31:2],2'b00}:Result;
        
        assign Write_data = 
        (op_SB)?
        (Write_strb == 4'b0001)?{24'd0,data2[7:0]}:
        (Write_strb == 4'b0010)?{16'd0,data2[7:0],8'd0}:
        (Write_strb == 4'b0100)?{8'd0,data2[7:0],16'd0}:
        (Write_strb == 4'b1000)?{data2[7:0],24'd0}:0
        :(op_SH)?
        (Write_strb == 4'b0011)?{16'd0,data2[15:0]}:
        (Write_strb == 4'b1100)?{data2[15:0],16'd0}:0
        :(op_SWL)?
        (Write_strb == 4'b0001)?{24'd0,data2[31:24]}:
        (Write_strb == 4'b0011)?{16'd0,data2[31:16]}:
        (Write_strb == 4'b0111)?{8'd0,data2[31:8]}:
        (Write_strb == 4'b1111)?{data2[31:0]}:0
        :(op_SWR)?
        (Write_strb == 4'b1111)?{data2[31:0]}:
        (Write_strb == 4'b1110)?{data2[23:0],8'd0}:
        (Write_strb == 4'b1100)?{data2[15:0],8'b0}:
        (Write_strb == 4'b1000)?{data2[7:0],24'b0}:0
        :data2;
        
        assign RF_wen = RegWrite;
        
        assign RF_wdata = 
        (op_SRL)?(data2>>sa)
        :(op_SRLV)?(data2>>{data1[4:0]})
        :(op_SLL)?(data2<<sa)
        :(op_SLLV)?(data2<<{data1[4:0]})
        :(op_NOR)?~Result
        :(op_MOVN||op_MOVZ)?data1
        :(op_LB||op_LBU||op_LH||op_LHU||op_LWL||op_LWR)?Rf_wdata
        :(op_JAL||op_JALR)?PC+32'd8
        :(op_LUI)?{Instruction[15:0],16'd0}
        :(MemToReg)?Read_data
        :Result; 
        
        assign Rf_wdata = (op_LB)?           
                          (Result[1:0]==2'b00)?(Read_data[7]==1)?{24'hffffff,Read_data[7:0]}:{24'd0,Read_data[7:0]}:
                          (Result[1:0]==2'b01)?(Read_data[15]==1)?{24'hffffff,Read_data[15:8]}:{24'd0,Read_data[15:8]}:
                          (Result[1:0]==2'b10)?(Read_data[23]==1)?{24'hffffff,Read_data[23:16]}:{24'd0,Read_data[23:16]}:
                          (Result[1:0]==2'b11)?(Read_data[31]==1)?{24'hffffff,Read_data[31:24]}:{24'd0,Read_data[31:24]}:0
                          :(op_LBU)?
                          (Result[1:0]==2'b00)?$unsigned(Read_data[7:0]):
                          (Result[1:0]==2'b01)?$unsigned(Read_data[15:8]):
                          (Result[1:0]==2'b10)?$unsigned(Read_data[23:16]):
                          (Result[1:0]==2'b11)?$unsigned(Read_data[31:24]):0
                          :(op_LH)?
                          (Result[1]==1'b0)?(Read_data[15]==1)?{16'hffff,Read_data[15:0]}:{16'd0,Read_data[15:0]}:
                          (Result[1]==1'b1)?(Read_data[31]==1)?{16'hffff,Read_data[31:16]}:{16'd0,Read_data[31:16]}:0   //CONCERNNED!
                          :(op_LHU)?
                          (Result[1]==1'b0)?$unsigned(Read_data[15:0]):
                          (Result[1]==1'b1)?$unsigned(Read_data[31:16]):0                      
                          :(op_LWL)?
                          (Result[1:0]==2'b00)?{Read_data[7:0],data2[23:0]}:            //CONCERNNED!
                          (Result[1:0]==2'b01)?{Read_data[15:0],data2[15:0]}:
                          (Result[1:0]==2'b10)?{Read_data[23:0],data2[7:0]}:
                          (Result[1:0]==2'b11)?{Read_data[31:0]}:0
                          :(op_LWR)?
                          (Result[1:0]==2'b00)?{Read_data[31:0]}:
                          (Result[1:0]==2'b01)?{data2[31:24],Read_data[31:8]}:
                          (Result[1:0]==2'b10)?{data2[31:16],Read_data[31:16]}:
                          (Result[1:0]==2'b11)?{data2[31:8],Read_data[31:24]}:0
                          
                          :0;


endmodule

