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

	//regs to memory module
	//GPR
	output reg[`RegAddrBus]		mem_wd,
	output reg					mem_wreg,
	output reg[`RegBus]			mem_wdata,
	//HILO reg
	output reg					mem_whilo,
	output reg[`RegBus]			mem_hi,
	output reg[`RegBus]			mem_lo
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
		end
		else
		begin
			//GPR
			mem_wd <= ex_wd;
			mem_wreg <= ex_wreg;
			mem_wdata <= ex_wdata;
			//HILO reg
			mem_whilo <= ex_whilo;
			mem_hi <= ex_hi;
			mem_lo <= ex_lo;
		end
	end

endmodule


