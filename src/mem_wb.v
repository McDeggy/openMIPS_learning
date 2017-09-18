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
	//GPR
	input wire[`RegAddrBus]		mem_wd,
	input wire					mem_wreg,
	input wire[`RegBus]			mem_wdata,
	//HILO reg
	input wire					mem_whilo,
	input wire[`RegBus]			mem_hi,
	input wire[`RegBus]			mem_lo,

	//regs to writeback module
	//GPR
	output reg[`RegAddrBus]		wb_wd,
	output reg					wb_wreg,
	output reg[`RegBus]			wb_wdata,
	//HILO reg
	output reg					wb_whilo,
	output reg[`RegBus]			wb_hi,
	output reg[`RegBus]			wb_lo,

	//pause pipeline
	input wire[5:0]				stall

);

	always @ (posedge clk)
	begin
		if (rst == `RstEnable)
		begin
			//GPR
			wb_wd <= `NOPRegAddr;
			wb_wreg <= `WriteDisable;
			wb_wdata <= `ZeroWord;
			//HILO reg
			wb_whilo <= `WriteDisable;
			wb_hi <= `ZeroWord;
			wb_lo <= `ZeroWord;
		end
		//normal status
		else if (stall[4] == `LogiFalse)
		begin
			//GPR
			wb_wd <= mem_wd;
			wb_wreg <= mem_wreg;
			wb_wdata <= mem_wdata;
			//HILO reg
			wb_whilo <= mem_whilo;
			wb_hi <= mem_hi;
			wb_lo <= mem_lo;
		end
		//if MEM pause while WB don't, then add NOP instruction to WB
		else if ((stall[4] == `LogiTrue) && (stall[5] == `LogiFalse))
		begin
			//GPR
			wb_wd <= `NOPRegAddr;
			wb_wreg <= `WriteDisable;
			wb_wdata <= `ZeroWord;
			//HILO reg
			wb_whilo <= `WriteDisable;
			wb_hi <= `ZeroWord;
			wb_lo <= `ZeroWord;
		end
		//else pause the WB state
		else
		begin
			//GPR
			wb_wd <= wb_wd;
			wb_wreg <= wb_wreg;
			wb_wdata <= wb_wdata;
			//HILO reg
			wb_whilo <= wb_whilo;
			wb_hi <= wb_hi;
			wb_lo <= wb_lo;
		end
	end

endmodule


