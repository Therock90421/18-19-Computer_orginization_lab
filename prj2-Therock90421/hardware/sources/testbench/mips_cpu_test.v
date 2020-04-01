`timescale 10ns / 1ns

module mips_cpu_test
();

	reg				mips_cpu_clk;
    reg				mips_cpu_reset;

    wire            mips_cpu_pc_sig;

	initial begin
		mips_cpu_clk = 1'b0;
		mips_cpu_reset = 1'b1;
		# 3
		mips_cpu_reset = 1'b0;

		# 2000000
		$finish;
	end

	always begin
		# 1 mips_cpu_clk = ~mips_cpu_clk;
	end

    mips_cpu_top    u_mips_cpu (
        .mips_cpu_clk       (mips_cpu_clk),
        .mips_cpu_reset     (mips_cpu_reset),

        .mips_cpu_pc_sig    (mips_cpu_pc_sig)
    );

`ifdef TRACE_CMP
	`define RST u_mips_cpu.u_mips_cpu.rst

	`define RF_WEN   u_mips_cpu.u_mips_cpu.RF_wen
	`define RF_WADDR u_mips_cpu.u_mips_cpu.RF_waddr
	`define RF_WDATA u_mips_cpu.u_mips_cpu.RF_wdata

	`define MEM_WEN   u_mips_cpu.u_mips_cpu.MemWrite
	`define MEM_ADDR  u_mips_cpu.u_mips_cpu.Address
	`define MEM_WSTRB u_mips_cpu.u_mips_cpu.Write_strb
	`define MEM_WDATA u_mips_cpu.u_mips_cpu.Write_data
	`define MEM_READ  u_mips_cpu.u_mips_cpu.MemRead

	`define PC u_mips_cpu.u_mips_cpu.PC

	// _ref: reference from trace file
	// bit_cmp: specify whether the bit needs to be compared
	/*
		type:
		1: Write RF    1 PC(32'h) addr(5'd) data(32'h) bit_cmp(32'h) mem_read(1'b)
		2: Write Mem   2 PC(32'h) addr(32'h) strb(4'h) data(32'h) bit_cmp(32'h)
		3: Branch      3 PC(32'h) new_PC(32'h)
		4: jump & link 4 PC(32'h) new_PC(32'h) addr(5'd) data(32'h)
	*/
	integer trace_file, type, PC_ref, new_PC_ref;
	integer rf_waddr_ref, rf_wdata_ref, rf_bit_cmp_ref;
	integer mem_addr_ref, mem_wdata_ref, mem_bit_cmp_ref;
	reg [3:0] mem_wstrb_ref;
	reg mem_read_ref;
	integer ret;
  	initial
	begin
    	trace_file = $fopen(`TRACE_FILE, "r");
		if(trace_file == 0)
		begin
			$display("ERROR: open file failed.");
			$finish;
		end
	end

  	always @(posedge mips_cpu_clk)
	begin
		if(!`RST)
		begin
			ret = $fscanf(trace_file, "%d", type);
			if(ret == -1)
			begin
				$display("=================================================");
				$display("INFO: comparing trace finish, PASS!");
				$display("=================================================");
				$fclose(trace_file);
				$finish;
			end
			ret = $fscanf(trace_file, "%h", PC_ref);
			if(`PC !== PC_ref)
			begin
				$display("=================================================");
				$display("Error: at %d0ns.", $time);
				$display("Yours:     PC = 0x%h", `PC);
				$display("Reference: PC = 0x%h", PC_ref);
				$display("Please check assignment of PC at previous cycle.");
				$display("=================================================");
				$fclose(trace_file);
				$finish;
			end
			case(type)
				1:
					begin
						if(`MEM_WEN !== 1'b0)
						begin
							$display("=================================================");
							$display("Error: at %d0ns.", $time);
							$display("MemWrite should be 0 here.");
							$display("=================================================");
							$fclose(trace_file);
							$finish;
						end
						ret = $fscanf(trace_file, "%d %h %h %d", rf_waddr_ref, rf_wdata_ref, rf_bit_cmp_ref, mem_read_ref);
						if(rf_waddr_ref == 0)
						begin
							if((`RF_WEN !== 1'b0) && (`RF_WADDR !== 5'd0))
							begin
								$display("=================================================");
								$display("Error: at %d0ns.", $time);
								$display("Yours:     RF_waddr = %02d", `RF_WADDR);
								$display("Reference: RF_waddr = %02d", rf_waddr_ref);
								$display("Either RF_waddr or RF_wen should be 0 here.");
								$display("=================================================");
								$fclose(trace_file);
								$finish;
							end
							// because RF_waddr = 0, this case that mem_read_ref = 1 & MEM_READ = 0 is true
							if(!mem_read_ref && (`MEM_READ !== 1'b0))
							begin
								$display("=================================================");
								$display("Error: at %d0ns.", $time);
								$display("MemRead should be 0 here.");
								$display("=================================================");
								$fclose(trace_file);
								$finish;
							end
						end
						else if((`RF_WEN !== 1'b1) || (mem_read_ref !== `MEM_READ))
						begin
							$display("=================================================");
							$display("Error: at %d0ns.", $time);
							$display("Yours:     RF_wen = %1d, MemRead = %1d", `RF_WEN, `MEM_READ);
							$display("Reference: RF_wen = %1d, MemRead = %1d", 1, mem_read_ref);
							$display("=================================================");
							$fclose(trace_file);
							$finish;
						end
						else if((`RF_WADDR !== rf_waddr_ref) ||
								((`RF_WDATA & rf_bit_cmp_ref) !== (rf_wdata_ref & rf_bit_cmp_ref)))
						begin
							$display("=================================================");
							$display("Error: at %d0ns.", $time);
							$display("Yours:     RF_waddr = %02d, (RF_wdata & 0x%h) = 0x%h",
									 `RF_WADDR, rf_bit_cmp_ref, (`RF_WDATA & rf_bit_cmp_ref));
							$display("Reference: RF_waddr = %02d, (RF_wdata & 0x%h) = 0x%h",
									 rf_waddr_ref, rf_bit_cmp_ref, (rf_wdata_ref & rf_bit_cmp_ref));
							$display("=================================================");
							$fclose(trace_file);
							$finish;
						end
					end
				2:
					begin
						if({`MEM_WEN, `RF_WEN, `MEM_READ} !== 3'b100)
						begin
							$display("=================================================");
							$display("Error: at %d0ns.", $time);
							$display("Yours:     MemWrite = %1d, RF_wen = %1d, MemRead = %1d",
									 `MEM_WEN, `RF_WEN, `MEM_READ);
							$display("Reference: MemWrite = %1d, RF_wen = %1d, MemRead = %1d", 1, 0, 0);
							$display("=================================================");
							$fclose(trace_file);
							$finish;
						end
						ret = $fscanf(trace_file, "%h %h %h %h", mem_addr_ref, mem_wstrb_ref, mem_wdata_ref, mem_bit_cmp_ref);
						if((`MEM_ADDR !== mem_addr_ref) || (`MEM_WSTRB !== mem_wstrb_ref) ||
						   ((`MEM_WDATA & mem_bit_cmp_ref) !== (mem_wdata_ref & mem_bit_cmp_ref)))
						begin
							$display("=================================================");
							$display("Error: at %d0ns.", $time);
							$display("Yours:     Address = 0x%h, Write_strb = 0x%h, (Write_data & 0x%h) = 0x%h",
									 `MEM_ADDR, `MEM_WSTRB, mem_bit_cmp_ref, (`MEM_WDATA & mem_bit_cmp_ref));
							$display("Reference: Address = 0x%h, Write_strb = 0x%h, (Write_data & 0x%h) = 0x%h",
									 mem_addr_ref, mem_wstrb_ref, mem_bit_cmp_ref, (mem_wdata_ref & mem_bit_cmp_ref));
							$display("=================================================");
							$fclose(trace_file);
							$finish;
						end
					end
				3:
					begin
						if({`MEM_WEN, `RF_WEN, `MEM_READ} !== 3'b000)
						begin
							$display("=================================================");
							$display("Error: at %d0ns.", $time);
							$display("Yours:     MemWrite = %1d, RF_wen = %1d, MemRead = %1d",
									 `MEM_WEN, `RF_WEN, `MEM_READ);
							$display("Reference: MemWrite = %1d, RF_wen = %1d, MemRead = %1d", 0, 0, 0);
							$display("=================================================");
							$fclose(trace_file);
							$finish;
						end
						ret = $fscanf(trace_file, "%h", new_PC_ref);
					end
				4:
					begin
						if({`MEM_WEN, `RF_WEN, `MEM_READ} !== 3'b010)
						begin
							$display("=================================================");
							$display("Error: at %d0ns.", $time);
							$display("Yours:     MemWrite = %1d, RF_wen = %1d, MemRead = %1d",
									 `MEM_WEN, `RF_WEN, `MEM_READ);
							$display("Reference: MemWrite = %1d, RF_wen = %1d, MemRead = %1d", 0, 1, 0);
							$display("=================================================");
							$fclose(trace_file);
							$finish;
						end
						ret = $fscanf(trace_file, "%h %d %h", new_PC_ref, rf_waddr_ref, rf_wdata_ref);
						if((`RF_WADDR !== rf_waddr_ref) || (`RF_WDATA !== rf_wdata_ref))
						begin
							$display("=================================================");
							$display("Error: at %d0ns.", $time);
							$display("Yours:     RF_waddr = %02d, RF_wdata = 0x%h", `RF_WADDR, `RF_WDATA);
							$display("Reference: RF_waddr = %02d, RF_wdata = 0x%h",  rf_waddr_ref, rf_wdata_ref);
							$display("Please check implemention of jal & jalr.");
							$display("=================================================");
							$fclose(trace_file);
							$finish;
						end
					end
				default:
					begin
						$display("ERROR: unkonwn type.");
						$fclose(trace_file);
						$finish;
					end
			endcase
		end
  	end
`endif

endmodule
