`timescale 10 ns / 1 ns

`define DATA_WIDTH 32

module alu(
	input [`DATA_WIDTH - 1:0] A,
	input [`DATA_WIDTH - 1:0] B,
	input [2:0] ALUop,
	output Overflow,
	output CarryOut,
	output Zero,
	output [`DATA_WIDTH - 1:0] Result
);
   wire [31:0] registerAND;
   wire [31:0]registerOR;


   wire [32:0]BvertSIGNED;
   wire [32:0]BvertUNSIGNED;
   wire [32:0] calculate,calculate1;
   wire [32:0] BnumberSIGNED,BnumberUNSIGNED;
   assign registerAND = A&B;
  
   assign registerOR = A|B;
   
   assign BvertSIGNED = ~{B[31],B}+33'd1;
   assign BvertUNSIGNED = ~{1'b0,B}+33'd1;
   assign BnumberSIGNED = (ALUop==3'b010)?{B[31],B}:BvertSIGNED;
   assign BnumberUNSIGNED = (ALUop==3'b010)?{1'b0,B}:BvertUNSIGNED;

   
   assign calculate = {A[31],A}+BnumberSIGNED;
   assign calculate1 = {1'b0,A}+BnumberUNSIGNED;
   assign Overflow = calculate[32]^calculate[31];
   assign CarryOut = calculate1[32];
   

   

   assign Result = (ALUop==3'b000)? registerAND:(ALUop==3'b001)? registerOR:(ALUop==3'b010)?calculate[31:0]:(ALUop==3'b110)?calculate[31:0]:(ALUop==3'b111)?calculate[31]^Overflow:0;

   assign Zero = !Result;
    
   endmodule
  
/* edition 2  
   wire [31:0] registerAND;
   wire [31:0]registerOR;
   wire [32:0]registerADD;
   wire [32:0]registerADD1;
   wire [32:0]registerSUB;
   wire [32:0]registerSUB1;
   
   wire CarryOut1,CarryOut2,Overflow1,Overflow2;
   wire [31:0] result;
   wire carryOut;
   wire overflow;
   wire zero;

   
   assign registerAND = A&B;
  
   assign registerOR = A|B;
   
   assign registerADD ={A[31],A}+{B[31],B} ;
   assign Overflow1 = registerADD[32]^registerADD[31];
   assign registerADD1={32'd0,A}+{32'd0,B};
   assign CarryOut1 = registerADD1[32];
   
   assign registerSUB = {A[31],A}+{~{B[31],B}+32'd1};
   assign Overflow2 = registerSUB[32]^registerSUB[31];
   assign registerSUB1 = {32'd0,A}+~{32'd0,B}+32'd1;
   assign CarryOut2 = registerSUB1[32];
   

   assign result = (ALUop==3'b000)? registerAND:(ALUop==3'b001)? registerOR:(ALUop==3'b010)?registerADD[31:0]:(ALUop==3'b110)?registerSUB[31:0]:(ALUop==3'b111)?registerSUB1[31]^Overflow2:0;
   assign carryOut = (ALUop==3'b010)?CarryOut1:(ALUop==3'b110)?CarryOut2:0;
   assign overflow = (ALUop==3'b010)?Overflow1:(ALUop==3'b110||ALUop==3'b111)?Overflow2:0;
   assign zero = !result;
    
   assign Result = result;
   assign CarryOut = carryOut;
   assign Overflow = overflow;
   assign Zero = zero;
  
endmodule
*/










   /*origin version use [always]

   reg [31:0] registerAND;
   reg [31:0]registerOR;
   reg [32:0]registerADD;
   reg [32:0]registerSUB;
   reg [31:0]intervalB;
   reg [1:0]temp;            //传入最高位的进位 
   reg CarryOut1,CarryOut2,Overflow1,Overflow2;
   reg [31:0] result;
   reg carryOut;
   reg overflow;
   reg zero;
   reg Out1,Out2;
   always@(*)
   begin
   registerAND = A&B;
  
   registerOR = A|B;
   
   registerADD ={A[31],A}+{B[31],B} ;                        //33 adder
   Overflow1 = registerADD[32]^registerADD[31];              //we can use one adder to do all this calculater
   registerADD={32'd0,A}+{32'd0,B};
   CarryOut1 = registerADD[32];
   
   registerSUB <= {A[31],A}+{~{B[31],B}+32'd1};
   Overflow2 = registerSUB[32]^registerSUB[31];
   registerSUB = {32'd0,A}+~{32'd0,B}+32'd1;
   CarryOut2 = registerSUB[32];
   
  
   case(ALUop)
       3'b000: result <= registerAND;
       3'b001: result <= registerOR;
       3'b010: 
               begin
               result <= registerADD[31:0];
               carryOut <= CarryOut1;
               overflow <= Overflow1;
               end
        3'b110:
               begin
               result <= registerSUB[31:0];
               carryOut <= CarryOut2;
               overflow <= Overflow2;
               end
        3'b111:
               begin
               if(registerSUB[31]^Overflow2)         //差是正 且溢出    差是负且未溢出， 那么a小于b
               result <= 32'd1;
               else result <= 0;
               end
        default:;
        endcase
        
    if(!result)
        zero <= 1;
        else zero <= 0;
   end
   assign Result = result;
   assign CarryOut = carryOut;
   assign Overflow = overflow;
   assign Zero = zero;

endmodule
*/
