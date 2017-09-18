//********** EX/MEM Module *********************************************************************************//
//execute module buffer
//
//FILENAME   :    ex_mem.v
//FUCNTION   :    buffer from execute module to memory module
//
//**********************************************************************************************************//

`include "defines.v"

module ex_mem(
	input wire					clk,
	input wire					rst,

	//signals from execute module
	//GPR
	input wire[`RegAddrBus]		ex_wd,
	input wire					ex_wreg,
	input wire[`RegBus]			ex_wdata,
	//HILO reg
	input wire					ex_whilo,
	input wire[`RegBus]			ex_hi,
	input wire[`RegBus]			ex_lo,
	//for MADD MADDU MSUB MSUBU
	input wire[1:0]				ex_madd_msub_cnt,
	input wire[`DoubleRegBus]	ex_madd_msub_mul,

	//back to execute module
	output reg[1:0]				madd_msub_cnt,
	output reg[`DoubleRegBus]	madd_msub_mul,

	//regs to memory module
	//GPR
	output reg[`RegAddrBus]		mem_wd,
	output reg					mem_wreg,
	output reg[`RegBus]			mem_wdata,
	//HILO reg
	output reg					mem_whilo,
	output reg[`RegBus]			mem_hi,
	output reg[`RegBus]			mem_lo,

	//pause pipeline
	input wire[5:0]				stall
);

	always @ (posedge clk)
	begin
		if (rst == `RstEnable)
		begin
			//GPR
			mem_wd <= `NOPRegAddr;
			mem_wreg <= `WriteDisable;
			mem_wdata <= `ZeroWord;
			//HILO reg
			mem_whilo <= `WriteDisable;
			mem_hi <= `ZeroWord;
			mem_lo <= `ZeroWord;
			//MADD MADDU MSUB MSUBU
			madd_msub_cnt <= 2'b00;
			madd_msub_mul <= {`ZeroWord, `ZeroWord};
		end
		//normal status
		else if (stall[3] == `LogiFalse)
		begin
			//GPR
			mem_wd <= ex_wd;
			mem_wreg <= ex_wreg;
			mem_wdata <= ex_wdata;
			//HILO reg
			mem_whilo <= ex_whilo;
			mem_hi <= ex_hi;
			mem_lo <= ex_lo;
			//MADD MADDU MSUB MSUBU
			madd_msub_cnt <= 2'b00;
			madd_msub_mul <= {`ZeroWord, `ZeroWord};
		end
		//if EX pause while MEM/WB don't, then add NOP instruction to MEM/WB
		else if ((stall[3] == `LogiTrue) && (stall[4] == `LogiFalse))
		begin
			//GPR
			mem_wd <= `NOPRegAddr;
			mem_wreg <= `WriteDisable;
			mem_wdata <= `ZeroWord;
			//HILO reg
			mem_whilo <= `WriteDisable;
			mem_hi <= `ZeroWord;
			mem_lo <= `ZeroWord;
			//MADD MADDU MSUB MSUBU
			madd_msub_cnt <= ex_madd_msub_cnt;
			madd_msub_mul <= ex_madd_msub_mul;
		end
		//else pause the EX state
		else
		begin
			//GPR
			mem_wd <= mem_wd;
			mem_wreg <= mem_wreg;
			mem_wdata <= mem_wdata;
			//HILO reg
			mem_whilo <= mem_whilo;
			mem_hi <= mem_hi;
			mem_lo <= mem_lo;
			//MADD MADDU MSUB MSUBU
			madd_msub_cnt <= ex_madd_msub_cnt;
			madd_msub_mul <= ex_madd_msub_mul;
		end
	end

endmodule


