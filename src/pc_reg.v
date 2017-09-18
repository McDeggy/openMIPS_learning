//********** PC Module *************************************************************************************//
//Program Counter
//
//FILENAME   :    pc_reg.v
//FUCNTION   :    read instruction flow from ROM
//
//**********************************************************************************************************//

`include "defines.v"

module pc_reg(
	input wire					clk,
	input wire					rst,
	output reg[`InstAddrBus]	pc,		//program counter for ROM
	output reg					ce,		//ROM chip enable signal
	
	//pause pipeline
	input wire[5:0]				stall
);

	always @ (posedge clk)
	begin
		if (rst == `RstEnable)
		begin
			ce <= `ChipDisable;			//ROM disable when reset assert
		end
		else
		begin
			ce <= `ChipEnable;			//ROM enable after reset deassert
		end
	end

	always @ (posedge clk)
	begin
		if (ce == `ChipDisable)
		begin
			pc <= 32'h00000000;			//set pc to 0 when ROM disable		
		end
		//normal status
		else if (stall[0] == `LogiFalse)
		begin
			pc <= pc + 4'h4;			//[1:0] bit of instruction address is nop (32bit)
		end
		//do not read anther instruction if pipeline paused
		else
		begin
			pc <= pc;
		end
	end

endmodule




