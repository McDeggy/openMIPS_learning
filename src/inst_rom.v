//********** ROM Module ************************************************************************************//
//ROM initial and control
//
//FILENAME   :    inst_rom.v
//FUCNTION   :    initialize and control ROM
//
//**********************************************************************************************************//

`include "defines.v"

module inst_rom(
	input wire					ce,
	input wire[`InstAddrBus]	addr,
	output reg[`InstBus]		inst
);

	//define array for instruction, InstMemNum * InstBus
	reg[`InstBus]				inst_mem[`InstMemNum-1 : 0];

	//initial ROM for testbench
	initial $readmemh ("test.data", inst_mem);

	always @ (*)
	begin
		if (ce == `ChipDisable)
		begin
			inst = `ZeroWord;
		end
		else
		begin
			inst = inst_mem[addr[`InstMemNumLog2+1 : 2]];			//[1:0] of address is ignored for 32bit system
		end
	end

endmodule



