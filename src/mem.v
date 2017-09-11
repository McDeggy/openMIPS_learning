//********** MEM Module ************************************************************************************//
//memory module
//
//FILENAME   :    mem.v
//FUCNTION   :    memory access module (ORI instruction do not need access memory)
//
//**********************************************************************************************************//

`include "defines.v"

module mem(
	input wire					rst,

	//signals from execute state
	//GPR
	input wire[`RegAddrBus]		wd_i,
	input wire					wreg_i,
	input wire[`RegBus]			wdata_i,
	//HILO reg
	input wire					whilo_i,
	input wire[`RegBus]			hi_i,
	input wire[`RegBus]			lo_i,

	//access regs/memory
	//GPR
	output reg[`RegAddrBus]		wd_o,
	output reg					wreg_o,
	output reg[`RegBus]			wdata_o,
	//HILO reg
	output reg					whilo_o,
	output reg[`RegBus]			hi_o,
	output reg[`RegBus]			lo_o
);

	always @ (*)
	begin
		if (rst == `RstEnable)
		begin
			//GPR
			wd_o = `NOPRegAddr;
			wreg_o = `WriteDisable;
			wdata_o = `ZeroWord;
			//HILO reg
			whilo_o = `WriteDisable;
			hi_o = `ZeroWord;
			lo_o = `ZeroWord;
		end
		else
		begin
			//GPR
			wd_o = wd_i;
			wreg_o = wreg_i;
			wdata_o = wdata_i;
			//HILO reg
			whilo_o = whilo_i;
			hi_o = hi_i;
			lo_o = lo_i;
		end
	end

endmodule


