`timescale 10ns / 1ns

module adder_test
();

	reg	[7:0]			operand0;
    reg	[7:0]			operand1;

    wire [7:0]          result;

	initial
	begin
		operand0 = 0;
		operand1 = 0;
		forever begin
			#10
			operand0 = {$random} % 128;
			operand1 = {$random} % 128;
		end
	end


    adder    u_adder (
        .operand0       (operand0),
        .operand1     (operand1),

        .result    (result)
    );

endmodule
