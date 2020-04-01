`timescale 10ns / 1ns

module mips_cpu(
	input  rst,
	input  clk,

	//Instruction request channel
	output reg [31:0] PC,
	output Inst_Req_Valid,
	input Inst_Req_Ack,

	//Instruction response channel
	input  [31:0] Instruction,
	input Inst_Valid,
	output Inst_Ack,

	//Memory request channel
	output [31:0] Address,
	output MemWrite,
	output [31:0] Write_data,
	output [3:0] Write_strb,
	output MemRead,
	input Mem_Req_Ack,

	//Memory data response channel
	input  [31:0] Read_data,
	input Read_data_Valid,
	output Read_data_Ack
);

	// TODO: Please add your logic code here
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
        op_AND,op_ANDI,op_BGEZ,op_BGTZ,op_BLEZ,op_BLTZ,op_JALR,op_LB,op_LBU,op_LH,op_LHU,op_LWL,op_LWR,
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
        wire                     RST;


        reg    [5:0]             state;  //state machine
        reg    [5:0]             nextstate;
        reg    [31:0]            instruction;
        reg    [31:0]            Read_data_continue;
        
        
        always@(posedge clk)            //control unit
        if(rst)              state <= 5'd0;  //IF
        else
                             state <= nextstate;
        always@(*)
        begin
        case(state)
        5'd0:                if(Inst_Req_Ack) nextstate = 5'd1;   //IW
                             else             nextstate = 5'd0;
        5'd1:                if(Inst_Valid)   nextstate = 5'd2;   //ID_EX
                             else             nextstate = 5'd1;
        5'd2:                if(op_BNE||op_BEQ||op_BGEZ||op_BGTZ||op_BLEZ||op_BLTZ||op_J||op_JR||op_JAL||op_JALR)     nextstate = 5'd0; //Branch & jump
                             else if(op_LW||op_LB||op_LBU||op_LH||op_LHU||op_LWL||op_LWR)   nextstate = 5'd3; //load
                             else if(op_SW||op_SB||op_SH||op_SWL||op_SWR)                   nextstate = 5'd4; //store
                             else                                                           nextstate = 5'd5; //Write reg_file WB
        5'd3:                if(Mem_Req_Ack)  nextstate = 5'd6; //RDW
                             else             nextstate = 5'd3;
        5'd4:                if(Mem_Req_Ack)  nextstate = 5'd0;
                             else             nextstate = 5'd4;
        5'd5:                nextstate = 5'd0;
        5'd6:                if(Read_data_Valid)  nextstate = 5'd5;
                             else             nextstate = 5'd6;
        default:             nextstate = 5'd0;
        endcase
        end                         
        
        
        
        
        always@(posedge clk)
        if(rst)
        instruction = 32'd0;
        else if(Inst_Valid && Inst_Ack)
        instruction = Instruction;
        //else instruction <= instruction;
        
        always@(posedge clk)
        if(rst)
        Read_data_continue = 32'd0;
        else if(Read_data_Valid && Read_data_Ack )
        Read_data_continue = Read_data;
        //else Read_data_continue <= Read_data_continue;
        
        
        assign RST    =   rst;
        
        assign op     =   instruction[31:26];
        assign rs     =   instruction[25:21];
        assign rt     =   instruction[20:16];
        assign rd     =   instruction[15:11];
        assign sa     =   instruction[10: 6];  
        assign func   =   instruction[ 5: 0];
        
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
        assign op_BGTZ =   (op == 6'b000111);
        
        
        
        assign Inst_Req_Valid = (RST)?0:(state == 5'd0)?1:0;
        assign Inst_Ack       = (RST)?1:(state == 5'd1)?1:0;
        assign Read_data_Ack  = (state == 5'd6)?1:0;
        
        
        assign RegDst   =   (op_SLL||op_ADDU||op_BEQ||op_OR||op_SLT||op_AND||op_BGEZ||op_BGTZ||op_JALR||op_MOVN||op_MOVZ||op_NOR||op_SLLV||op_SLTU||op_SRA||op_SRAV||op_SRL||op_SRLV||op_SUBU||op_XOR)?1:0;
        
        assign Branch   =   (op_BNE||op_BEQ||op_BGEZ||op_BGTZ||op_BLEZ||op_BLTZ)?1:0;
        
        assign MemRead  =   (state == 5'd3)?1:0;   //LOAD
        
        assign MemToReg =   (op_LW||op_LB||op_LBU||op_LH||op_LHU||op_LWL||op_LWR)?1:0;
        
        assign ALUOp    =   (op_ADDIU || op_LW || op_SW||op_ADDU||op_LUI||op_LB||op_LBU||op_LH||op_LHU||op_MOVN||op_MOVZ||op_SB||op_SH||op_SWL||op_SWR||op_LWL||op_LWR)?3'b010:
                            (op_BNE||op_BEQ||op_SUBU)?3'b110:
                            (op_SRA||op_SRAV)?3'b100:
                            
                            (op_OR||op_NOR||op_ORI)?3'b001:
                            (op_SLT||op_SLTI||op_BGEZ||op_BGTZ||op_BLEZ||op_BLTZ)?3'b111:
                            (op_SLTIU||op_SLTU)?3'b101:
                            (op_XOR||op_XORI)?3'b011:
                            3'b000;
                            
        assign MemWrite =   (state == 5'd4)?1:0; //STORE
        
        assign ALUSrc   =   (op_ADDIU ||op_LW ||op_SW ||op_SLL||op_LUI||op_SLTI||op_SLTIU||op_ANDI||op_LB||op_LBU||op_LH||op_LHU||op_LWL||op_LWR||op_ORI||op_SB||op_SH||op_SWL||op_SWR||op_SRA||op_XORI)?1:0;
        
        assign RegWrite =   (state == 5'd2&&(op_JAL||op_JALR))?1:(state == 5'd5)&&(op_ADDIU ||op_SLL||op_LW||op_ADDU||op_JAL||op_LUI||op_OR||op_SLT||op_SLTI||op_SLTIU||op_AND||op_ANDI||op_JALR||op_LB||op_LBU||op_LH||op_LHU||op_LWL||op_LWR||(op_MOVN&&(!Zero))||(op_MOVZ&&Zero)||op_NOR||op_ORI||op_SLLV||op_SLTU||op_SRA||op_SRAV||op_SRL||op_SRLV||op_SUBU||op_XOR||op_XORI)?1:0;   
                          
                          
        assign Write_strb = (op_ADDIU ||op_BNE||op_LW||op_SW||op_SLL||op_ADDU||op_BEQ||op_J||op_JAL||op_JR||
        op_LUI||op_OR||op_SLT||op_SLTI||op_SLTIU||op_AND||op_ANDI||op_BGEZ||op_BGTZ||op_BLEZ||op_BLTZ||op_JALR||op_LB||op_LBU||op_LH||op_LHU||op_LWL||op_LWR||op_MOVN||op_MOVZ||op_NOR||op_ORI||op_SLLV||op_SLTU||op_SRA||op_SRAV||op_SRL||op_SRLV||op_SUBU||op_XOR)?4'b1111
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
        else if(state == 5'd2) PC<=PC2;
        else PC <= PC;
        end
        
        assign PC3 = PC + 32'd4;
        assign PCJUMP = (op_JR||op_JALR)?data1:{PC3[31:28],instruction[25:0],2'b00};
        
        alu alu2(PC3,(Sign_extend <<2),3'b010,Overflow1,CarryOut1,Zero1,PC1);
        
        assign PC2 = (op_J||op_JAL||op_JR||op_JALR)?PCJUMP:((Branch&&(!Zero)&&(!RegDst))||(Branch&&Zero&&RegDst))?PC1:PC3;
        
        
        reg_file reg_file1(clk,rst,RF_waddr,rs,rt,RF_wen,RF_wdata,data1,data2);
        
        assign RF_waddr = (op_JAL)?5'd31:(RegDst)?rd:rt;
        

        
        assign Sign_extend = (op_ANDI||op_ORI||op_XORI)?{16'd0,instruction[15:0]}:(op_SRA)?{26'd0,sa}:
                             (instruction[15]==1)?{16'hffff,instruction[15:0]}:{16'd0,instruction[15:0]};
                             
        assign Mux_ALU = (op_SRAV)?data1[4:0]:(op_BLEZ||op_BGTZ)?32'd1:(op_BGEZ||op_MOVN||op_MOVZ)?32'd0:(ALUSrc)?Sign_extend:data2;
        
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
        :(op_LUI)?{instruction[15:0],16'd0}
        :(MemToReg)?Read_data_continue
        :Result; 
        
        assign Rf_wdata = (op_LB)?           
                          (Result[1:0]==2'b00)?(Read_data_continue[7]==1)?{24'hffffff,Read_data_continue[7:0]}:{24'd0,Read_data_continue[7:0]}:
                          (Result[1:0]==2'b01)?(Read_data_continue[15]==1)?{24'hffffff,Read_data_continue[15:8]}:{24'd0,Read_data_continue[15:8]}:
                          (Result[1:0]==2'b10)?(Read_data_continue[23]==1)?{24'hffffff,Read_data_continue[23:16]}:{24'd0,Read_data_continue[23:16]}:
                          (Result[1:0]==2'b11)?(Read_data_continue[31]==1)?{24'hffffff,Read_data_continue[31:24]}:{24'd0,Read_data_continue[31:24]}:0
                          :(op_LBU)?
                          (Result[1:0]==2'b00)?$unsigned(Read_data_continue[7:0]):
                          (Result[1:0]==2'b01)?$unsigned(Read_data_continue[15:8]):
                          (Result[1:0]==2'b10)?$unsigned(Read_data_continue[23:16]):
                          (Result[1:0]==2'b11)?$unsigned(Read_data_continue[31:24]):0
                          :(op_LH)?
                          (Result[1]==1'b0)?(Read_data_continue[15]==1)?{16'hffff,Read_data_continue[15:0]}:{16'd0,Read_data_continue[15:0]}:
                          (Result[1]==1'b1)?(Read_data_continue[31]==1)?{16'hffff,Read_data_continue[31:16]}:{16'd0,Read_data_continue[31:16]}:0   //CONCERNNED!
                          :(op_LHU)?
                          (Result[1]==1'b0)?$unsigned(Read_data_continue[15:0]):
                          (Result[1]==1'b1)?$unsigned(Read_data_continue[31:16]):0                      
                          :(op_LWL)?
                          (Result[1:0]==2'b00)?{Read_data_continue[7:0],data2[23:0]}:            //CONCERNNED!
                          (Result[1:0]==2'b01)?{Read_data_continue[15:0],data2[15:0]}:
                          (Result[1:0]==2'b10)?{Read_data_continue[23:0],data2[7:0]}:
                          (Result[1:0]==2'b11)?{Read_data_continue[31:0]}:0
                          :(op_LWR)?
                          (Result[1:0]==2'b00)?{Read_data_continue[31:0]}:
                          (Result[1:0]==2'b01)?{data2[31:24],Read_data_continue[31:8]}:
                          (Result[1:0]==2'b10)?{data2[31:16],Read_data_continue[31:16]}:
                          (Result[1:0]==2'b11)?{data2[31:8],Read_data_continue[31:24]}:0
                          
                          :0;




	
endmodule

