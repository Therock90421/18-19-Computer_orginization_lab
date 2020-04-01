`timescale 1ns / 1ns

module riscv_cpu_test
();

	reg				riscv_cpu_clk;
    reg				riscv_cpu_reset;

    wire            riscv_cpu_pc_sig;

	initial begin
		riscv_cpu_clk = 1'b0;
		riscv_cpu_reset = 1'b1;
		# 30
		riscv_cpu_reset = 1'b0;

		//# 2000000
		//$finish;
	end

	always begin
		# 5 riscv_cpu_clk = ~riscv_cpu_clk;
	end

    riscv_cpu_fpga    u_riscv_cpu (
        .riscv_cpu_clk       (riscv_cpu_clk),
        .riscv_cpu_reset     (riscv_cpu_reset),

        .riscv_cpu_pc_sig    (riscv_cpu_pc_sig)
    );

endmodule
