//********** CTRL Module ***********************************************************************************//
//ctrl module to pause pipeline for multi-cycle instruction
//
//FILENAME   :    ctrl.v
//FUCNTION   :    input signal from multi-cycle instruction MADD/MADDU/MSUB/MSUBU
//
//**********************************************************************************************************//

`include "defines.v"

module ctrl(
	input wire					rst,
	input wire					stallreq_from_id,					//pause request from id state
	input wire					stallreq_from_ex,					//pause request from ex state
	output reg[5:0]				stall
);

//stall[4:0] indicate the state to pause
//stall[0] for PC module
//stall[1] for IF/ID module
//stall[2] for ID/EX module
//stall[3] for EX/MEM module
//stall[4] for MEM/WB module
	
	always @ (*)
	begin
		if (rst == `RstEnable)
		begin
			stall <= 6'b00000;
		end
		else
		begin
			if (stallreq_from_id == `LogiTrue)
			begin
				stall <= 6'b00111;
			end
			else if (stallreq_from_ex == `LogiTrue)
			begin
				stall <= 6'b01111;
			end
			else
			begin
				stall <= 6'b00000;
			end
		end
	end

endmodule


