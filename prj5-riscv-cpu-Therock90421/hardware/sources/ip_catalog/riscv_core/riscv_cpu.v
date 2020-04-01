`timescale 10ns / 1ns

module riscv_cpu(
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
        wire			RF_wen;
	wire [4:0]		RF_waddr;
	wire [31:0]		RF_wdata;
       
	// TODO: PLEASE ADD YOUT CODE BELOW
        wire [31:0]             Rf_wdata;
        
        wire [6:0]              op;
        wire [4:0]              rd;
        wire [2:0]              func;
        wire [4:0]              rs1;
        wire [4:0]              rs2;
        wire [6:0]              top7;
        
        wire op_LUI,op_AUIPC,op_JAL,op_JALR,op_BEQ,op_BNE,op_BLT,op_BGE,op_BLTU,
        op_BGEU,op_LB,op_LH,op_LW,op_LBU,op_LHU,op_SB,op_SH,op_SW,op_ADDI,op_SLTI,
        op_SLTIU,op_XORI,op_ORI,op_ANDI,op_SLLI,op_SRLI,op_SRAI,op_ADD,op_SUB,op_SLL,
        op_SLT,op_SLTU,op_XOR,op_SRL,op_SRA,op_OR,op_AND;
        
        wire RegDst,Branch,MemToReg,ALUSrc,RegWrite;
        wire [2:0]              ALUOp;
        wire Overflow,CarryOut,Zero,Overflow1,CarryOut1,Zero1;
        wire [31:0]             Result;
        
        wire [31:0]             data1;
        wire [31:0]             data2;
        
       
        wire   [31:0]            Mux_ALU;
        wire   [31:0]            Mux_Writedata;   
        wire   [31:0]            Sign_extend;
        
        wire   [31:0]            PC2;
        wire   [31:0]            PC3;
        wire   [31:0]            PCJUMP;
        wire   [31:0]            data;
        wire                     RST;

        
        reg    [31:0]            p;
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
        5'd1:                if(Inst_Valid)   nextstate = 5'd7;   //ID
                             else             nextstate = 5'd1;
        5'd7:                                 nextstate = 5'd2;   //EX
        5'd2:                if(op == 7'b1100011)     nextstate = 5'd0; //B-type
                             else if(op == 7'b0000011)   nextstate = 5'd3; //I-type load
                             else if(op_SB||op_SH||op_SW)                   nextstate = 5'd4; //S-type store
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
        
        assign op     =   instruction[ 6: 0];
        assign rd     =   instruction[11: 7];
        assign func   =   instruction[14:12];
        assign rs1    =   instruction[19:15];
        assign rs2    =   instruction[24:20];  
        assign top7   =   instruction[31:25];

        assign op_LUI   =   (op == 7'b0110111);
        assign op_AUIPC =   (op == 7'b0010111);
        assign op_JAL   =   (op == 7'b1101111);
        assign op_JALR  =   (op == 7'b1100111)&&( func == 3'b000);
        assign op_BEQ   =   (op == 7'b1100011)&&( func == 3'b000);
        assign op_BNE   =   (op == 7'b1100011)&&( func == 3'b001);
        assign op_BLT   =   (op == 7'b1100011)&&( func == 3'b100);
        assign op_BGE   =   (op == 7'b1100011)&&( func == 3'b101);
        assign op_BLTU  =   (op == 7'b1100011)&&( func == 3'b110);
        assign op_BGEU  =   (op == 7'b1100011)&&( func == 3'b111);
        assign op_LB    =   (op == 7'b0000011)&&( func == 3'b000);
        assign op_LH    =   (op == 7'b0000011)&&( func == 3'b001);
        assign op_LW    =   (op == 7'b0000011)&&( func == 3'b010);
        assign op_LBU   =   (op == 7'b0000011)&&( func == 3'b100);
        assign op_LHU   =   (op == 7'b0000011)&&( func == 3'b101);
        assign op_SB    =   (op == 7'b0100011)&&( func == 3'b000);
        assign op_SH    =   (op == 7'b0100011)&&( func == 3'b001);
        assign op_SW    =   (op == 7'b0100011)&&( func == 3'b010);
        assign op_ADDI  =   (op == 7'b0010011)&&( func == 3'b000);
        assign op_SLTI  =   (op == 7'b0010011)&&( func == 3'b010);
        assign op_SLTIU =   (op == 7'b0010011)&&( func == 3'b011);
        assign op_XORI  =   (op == 7'b0010011)&&( func == 3'b100);
        assign op_ORI   =   (op == 7'b0010011)&&( func == 3'b110);
        assign op_ANDI  =   (op == 7'b0010011)&&( func == 3'b111);
        assign op_SLLI  =   (op == 7'b0010011)&&( func == 3'b001)&&( top7 == 7'b0000000);
        assign op_SRLI  =   (op == 7'b0010011)&&( func == 3'b101)&&( top7 == 7'b0000000);
        assign op_SRAI  =   (op == 7'b0010011)&&( func == 3'b101)&&( top7 == 7'b0100000);
        assign op_ADD   =   (op == 7'b0110011)&&( func == 3'b000)&&( top7 == 7'b0000000);
        assign op_SUB   =   (op == 7'b0110011)&&( func == 3'b000)&&( top7 == 7'b0100000);
        assign op_SLL   =   (op == 7'b0110011)&&( func == 3'b001)&&( top7 == 7'b0000000);
        assign op_SLT   =   (op == 7'b0110011)&&( func == 3'b010)&&( top7 == 7'b0000000);
        assign op_SLTU  =   (op == 7'b0110011)&&( func == 3'b011)&&( top7 == 7'b0000000);
        assign op_XOR   =   (op == 7'b0110011)&&( func == 3'b100)&&( top7 == 7'b0000000);
        assign op_SRL   =   (op == 7'b0110011)&&( func == 3'b101)&&( top7 == 7'b0000000);
        assign op_SRA   =   (op == 7'b0110011)&&( func == 3'b101)&&( top7 == 7'b0100000);
        assign op_OR    =   (op == 7'b0110011)&&( func == 3'b110)&&( top7 == 7'b0000000);
        assign op_AND   =   (op == 7'b0110011)&&( func == 3'b111)&&( top7 == 7'b0000000);
        
        
        
        
        
        assign Inst_Req_Valid = (RST)?0:(state == 5'd0)?1:0;
        assign Inst_Ack       = (RST)?1:(state == 5'd1)?1:0;
        assign Read_data_Ack  = (state == 5'd6)?1:0;
        
        
        //assign RegDst   =   (op_SLL||op_ADDU||op_BEQ||op_OR||op_SLT||op_AND||op_BGEZ||op_BGTZ||op_JALR||op_MOVN||op_MOVZ||op_NOR||op_SLLV||op_SLTU||op_SRA||op_SRAV||op_SRL||op_SRLV||op_SUBU||op_XOR)?1:0;
        
        assign Branch   =   (op == 7'b1100011)?1:0;
        
        assign MemRead  =   (state == 5'd3)?1:0;   //LOAD
        
        assign MemToReg =   (op == 7'b0000011)?1:0;
        
       /* assign ALUOp    =   (op_ADDIU || op_LW || op_SW||op_ADDU||op_LUI||op_LB||op_LBU||op_LH||op_LHU||op_MOVN||op_MOVZ||op_SB||op_SH||op_SWL||op_SWR||op_LWL||op_LWR)?3'b010:                                      //ADD
                            (op_BNE||op_BEQ||op_SUBU)?3'b110:        //SUB
                            (op_SRA||op_SRAV)?3'b100:
                            
                            (op_OR||op_NOR||op_ORI)?3'b001:          //OR
                            (op_SLT||op_SLTI||op_BGEZ||op_BGTZ||op_BLEZ||op_BLTZ)?3'b111:                                                     //SLT
                            (op_SLTIU||op_SLTU)?3'b101:              //SLTU
                            (op_XOR||op_XORI)?3'b011:                //XOR
                            3'b000;*/                                //AND
        assign ALUOp    =   (op_LUI||op_AUIPC||op_JAL||op_JALR||(op == 7'b0000011)||(op == 7'b0100011)||op_ADDI||op_ADD)?3'b010:
                            (op_BNE||op_BEQ||op_SUB)?3'b110:

                            (op_SRAI||op_SRA)?3'b100:

                            

                            (op_ORI||op_OR)?3'b001:

                            (op_SLT||op_SLTI||op_BLT||op_BGE)?3'b111:

                            (op_SLTIU||op_SLTU||op_BLTU||op_BGEU)?3'b101:

                            (op_XORI||op_XOR)?3'b011:

                            3'b000;                    
                            
        assign MemWrite =   (state == 5'd4)?1:0; //STORE
        
        //assign ALUSrc   =   (op_ADDIU ||op_LW ||op_SW ||op_SLL||op_LUI||op_SLTI||op_SLTIU||op_ANDI||op_LB||op_LBU||op_LH||op_LHU||op_LWL||op_LWR||op_ORI||op_SB||op_SH||op_SWL||op_SWR||op_SRA||op_XORI)?1:0;
        assign ALUSrc   =   (op_AUIPC||op_JAL||op_JALR||op_LB||op_LH||op_LW||op_LBU||op_LHU||op_SW||op_SB||op_SH||op_ADDI||op_SLTI||op_SLTIU||op_XORI||op_ORI||op_ANDI)?1:0;
        //assign RegWrite =   (state == 5'd2&&op_JAL)?1:(state == 5'd5)&&(op_ADDIU ||op_SLL||op_LW||op_ADDU||op_JAL||op_LUI||op_OR||op_SLT||op_SLTI||op_SLTIU||op_AND||op_ANDI||op_JALR||op_LB||op_LBU||op_LH||op_LHU||op_LWL||op_LWR||(op_MOVN&&(!Zero))||(op_MOVZ&&Zero)||op_NOR||op_ORI||op_SLLV||op_SLTU||op_SRA||op_SRAV||op_SRL||op_SRLV||op_SUBU||op_XOR||op_XORI||op_JALR)?1:0;   
        
        assign RegWrite =   (state == 5'd5)?1:0; 
                          
                          
        assign Write_strb = 
        (op_SB)?
                          (Result[1:0]==2'b00)?4'b0001:
                          (Result[1:0]==2'b01)?4'b0010:
                          (Result[1:0]==2'b10)?4'b0100:
                          (Result[1:0]==2'b11)?4'b1000:0
        :(op_SH)?
                          (Result[1]==1'b0)?4'b0011:
                          (Result[1]==1'b1)?4'b1100:0
            
                                                                       
        :4'b1111;
        
        
       
        always@(posedge clk)
        begin
        if(rst)
        PC<=32'b0;
        else if(state == 5'd2) PC<=PC2;
        else PC <= PC;
        end
        
        always@(posedge clk)
        begin
        if(rst)
        p <= 32'd0;
        else if(state == 5'd7) p <= PC;
        else p <= p;
        end
        
        assign PC3 = PC + 32'd4;
        assign PCJUMP = (op_JAL||op_JALR)?{Result[31:1],1'b0}:(PC+Sign_extend);
        
       
        
        assign PC2 = (op_JAL||op_JALR||(op_BEQ&&Zero)||(op_BNE&&!Zero)||((op_BLT||op_BLTU)&&!Zero)||((op_BGE||op_BGEU)&&Zero))?PCJUMP:PC3;
        
        
        //reg_file reg_file1(clk,rst,RF_waddr,rs,rt,RF_wen,RF_wdata,data1,data2);
        
        reg_file reg_file1(clk,rst,RF_waddr,rs1,rs2,RF_wen,RF_wdata,data1,data2);
        
        assign RF_waddr = rd; 
        
       // assign RF_waddr = (op_JAL)?5'd31:(RegDst)?rd:rt;
       
        

        
        //assign Sign_extend = (op_ANDI||op_ORI||op_XORI)?{16'd0,instruction[15:0]}:(op_SRA)?{26'd0,sa}:(instruction[15]==1)?{16'hffff,instruction[15:0]}:{16'd0,instruction[15:0]};
        assign Sign_extend = (op_LUI||op_AUIPC)?{instruction[31:12],12'd0}:
                             (op_JAL)?(instruction[31]==1'b1)?{11'b11111111111,instruction[31],instruction[19:12],instruction[20],instruction[30:21],1'd0}:
                                                             {11'd0,instruction[31],instruction[19:12],instruction[20],instruction[30:21],1'd0}:
                             (op_JALR||(op == 7'b0000011)||op_ADDI||op_SLTI||op_SLTIU||op_XORI||op_ORI||op_ANDI)?(instruction[31]==1'b1)?{20'hfffff,instruction[31:20]}:
                                                                                                                                        {20'd0,instruction[31:20]}:
                             (op == 7'b1100011)?(instruction[31]==1'b1)?{19'h7ffff,instruction[31],instruction[7],instruction[30:25],instruction[11:8],1'b0}:
                                                                       {19'd0,instruction[31],instruction[7],instruction[30:25],instruction[11:8],1'b0}:             
                                                                                                                                       
                             (instruction[31]==1'b1)?{20'hfffff,instruction[31:25],instruction[11:7]}:
                                                    {20'd0,instruction[31:25],instruction[11:7]};
         
                             
        //assign Mux_ALU = (op_SRAV)?data1[4:0]:(op_BLEZ||op_BGTZ)?32'd1:(op_BGEZ||op_MOVN||op_MOVZ)?32'd0:(ALUSrc)?Sign_extend:data2;
    
        //assign data = (op_SLL||op_MOVN||op_MOVZ||op_SRAV||op_SRA)?data2:data1;
        
        assign data = (op_JAL)?PC:(op_AUIPC)?p:data1;
        assign Mux_ALU = (op_SRAI)?rs2:(ALUSrc)?Sign_extend:data2;
        
        alu alu1(data,Mux_ALU,ALUOp,Overflow,CarryOut,Zero,Result);
        
        assign Address = (op_LB||op_LBU||op_LH||op_LHU||op_SB||op_SH)?{Result[31:2],2'b00}:Result;
        
        assign Write_data = 
        (op_SB)?
        (Write_strb == 4'b0001)?{24'd0,data2[7:0]}:
        (Write_strb == 4'b0010)?{16'd0,data2[7:0],8'd0}:
        (Write_strb == 4'b0100)?{8'd0,data2[7:0],16'd0}:
        (Write_strb == 4'b1000)?{data2[7:0],24'd0}:0
        :(op_SH)?
        (Write_strb == 4'b0011)?{16'd0,data2[15:0]}:
        (Write_strb == 4'b1100)?{data2[15:0],16'd0}:0
        
        :data2;
        
        assign RF_wen = RegWrite;
        
        
       
        
        assign RF_wdata = 
        (op_SLLI)?(data1<<rs2)
        :(op_SLL)?(data1<<{data2[4:0]})
        :(op_SRLI)?(data1>>rs2)
        :(op_SRL)?(data1>>{data2[4:0]})
        //:(op_SRAI)?
        //:(op_SRA)?
        
        
        :(op_LB||op_LBU||op_LH||op_LHU)?Rf_wdata
      
        :(op_JAL||op_JALR)?p+32'd4
        :(op_LUI)?{instruction[31:12],12'd0}
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
                          
                          
                          :0;




	
	
endmodule

