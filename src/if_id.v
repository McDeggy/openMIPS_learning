//********** IF/ID Module **********************************************************************************//
//Instruction Fetch / Instruction Decoder reg buffer
//
//FILENAME   :    if_id.v
//FUCNTION   :    instructions buffer from ROM to decoder module
//
//**********************************************************************************************************//

`include "defines.v"

module if_id(
	input wire					clk,
	input wire					rst,

	//signals from PC module, InstBus for instruction width (32bit)
	input wire[`InstAddrBus]	if_pc,
	input wire[`InstBus]		if_inst,

	//output of ROM, register data and transit to decoder module
	output reg[`InstAddrBus]	id_pc,
	output reg[`InstBus]		id_inst,

	//pause pipeline
	input wire[5:0]				stall
);

	always @ (posedge clk)
	begin
		if (rst == `RstEnable)
		begin
			id_pc <= `ZeroWord;
			id_inst <= `ZeroWord;
		end
		//normal status
		else if (stall[1] == `LogiFalse)
		begin
			id_pc <= if_pc;
			id_inst <= if_inst;
		end
		//if IF pause while ID don't, then add NOP instruction to EX
		else if ((stall[1] == `LogiTrue) && (stall[2] == `LogiFalse))
		begin
			id_pc <= `ZeroWord;
			id_inst <= `ZeroWord;
		end
		//else pause the IF state
		else
		begin
			id_pc <= id_pc;
			id_inst <= id_inst;
		end
	end

endmodule



