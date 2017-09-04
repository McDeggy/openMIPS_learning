//********** MEM/WB Module *********************************************************************************//
//memory module buffer
//
//FILENAME   :    mem_wb.v
//FUCNTION   :    buffer from memory module to writeback module
//
//**********************************************************************************************************//

`include "defines.v"

module mem_wb(
	input wire					clk,
	input wire					rst,

	//signals from memory module
	input wire[`RegAddrBus]		mem_wd,
	input wire					mem_wreg,
	input wire[`RegBus]			mem_wdata,

	//regs to writeback module
	output reg[`RegAddrBus]		wb_wd,
	output reg					wb_wreg,
	output reg[`RegBus]			wb_wdata

);

	always @ (posedge clk)
	begin
		if (rst == `RstEnable)
		begin
			wb_wd <= `NOPRegAddr;
			wb_wreg <= `WriteDisable;
			wb_wdata <= `ZeroWord;
		end
		else
		begin
			wb_wd <= mem_wd;
			wb_wreg <= mem_wreg;
			wb_wdata <= mem_wdata;
		end
	end

endmodule


