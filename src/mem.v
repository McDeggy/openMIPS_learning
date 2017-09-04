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
	input wire[`RegAddrBus]		wd_i,
	input wire					wreg_i,
	input wire[`RegBus]			wdata_i,

	//access memory
	output reg[`RegAddrBus]		wd_o,
	output reg					wreg_o,
	output reg[`RegBus]			wdata_o
);

	always @ (*)
	begin
		if (rst == `RstEnable)
		begin
			wd_o = `NOPRegAddr;
			wreg_o = `WriteDisable;
			wdata_o = `ZeroWord;
		end
		else
		begin
			wd_o = wd_i;
			wreg_o = wreg_i;
			wdata_o = wdata_i;
		end
	end

endmodule


