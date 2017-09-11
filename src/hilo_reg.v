//********** HILO Module ***********************************************************************************//
//hi-lo reg for multiplier and divider
//
//FILENAME   :    hilo_reg.v
//FUCNTION   :    registers for multiplier higher 32bit and lower 32bit (divider, hi for remainder and lo for quotient )
//
//**********************************************************************************************************//

`include "defines.v"

module hilo_reg(
	input wire					clk,
	input wire					rst,

	//write port
	input wire					we,
	input wire[`RegBus]			hi_i,
	input wire[`RegBus]			lo_i,

	//read port
	output reg[`RegBus]			hi_o,
	output reg[`RegBus]			lo_o
);

	always @ (posedge clk)
	begin
		if (rst == `RstEnable)
		begin
			hi_o <= `ZeroWord;
			lo_o <= `ZeroWord;
		end
		else if (we == `WriteEnable)
		begin
			hi_o <= hi_i;
			lo_o <= lo_i;
		end
		else
		begin
			hi_o <= hi_o;
			lo_o <= lo_o;
		end
	end


endmodule


