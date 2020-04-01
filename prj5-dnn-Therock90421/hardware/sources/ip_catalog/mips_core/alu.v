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
   wire [31:0]registerXOR;

   wire [32:0]BvertSIGNED;
   wire [32:0]BvertUNSIGNED;
   wire [32:0] calculate,calculate1;
   wire [32:0] BnumberSIGNED,BnumberUNSIGNED;
   wire [31:0]registerRIGHT;
   wire [63:0]temp;
   assign registerAND = A&B;
  
   assign registerOR = A|B;
   
   assign registerXOR = A^B;

   assign BvertSIGNED = ~{B[31],B}+33'd1;
   assign BvertUNSIGNED = ~{1'b0,B}+33'd1;
   assign BnumberSIGNED = (ALUop==3'b010)?{B[31],B}:BvertSIGNED;
   assign BnumberUNSIGNED = (ALUop==3'b010)?{1'b0,B}:BvertUNSIGNED;
 
   assign temp = {32'hffffffff,A}>>B;
   assign registerRIGHT =(A[31]==1)?temp[31:0]:A>>B;
   
   assign calculate = {A[31],A}+BnumberSIGNED;
   assign calculate1 = {1'b0,A}+BnumberUNSIGNED;
   assign Overflow = calculate[32]^calculate[31];
   assign CarryOut = calculate1[32];
   

   

   assign Result = (ALUop==3'b011)?registerXOR:(ALUop==3'b000)? registerAND:(ALUop==3'b001)? registerOR:(ALUop==3'b010)?calculate[31:0]:(ALUop==3'b110)?calculate[31:0]:(ALUop==3'b111)?calculate[31]^Overflow:(ALUop == 3'b100)?registerRIGHT:(ALUop == 3'b101)?CarryOut:0;
 
  assign Zero = !Result;
    

  

  
endmodule
