//********** ID/EX Module **********************************************************************************//
//instruction module/ execute module reg buffer
//
//FILENAME   :    id_ex.v
//FUCNTION   :    reg buffer from id.v to ex.v
//
//**********************************************************************************************************//

`include "defines.v"

module id_ex(
	input wire					clk,
	input wire					rst,

	//signals from instruction fetch state
	input wire[`AluOpBus]		id_aluop,
	input wire[`AluSelBus]		id_alusel,
	input wire[`RegBus]			id_reg1,
	input wire[`RegBus]			id_reg2,
	input wire[`RegAddrBus]		id_wd,
	input wire					id_wreg,

	//signals transmit to execute state
	output reg[`AluOpBus]		ex_aluop,
	output reg[`AluSelBus]		ex_alusel,
	output reg[`RegBus]			ex_reg1,
	output reg[`RegBus]			ex_reg2,
	output reg[`RegAddrBus]		ex_wd,
	output reg					ex_wreg,

	//pause pipeline
	input wire[5:0]				stall
);

	always @ (posedge clk)
	begin
		if (rst == `RstEnable)
		begin
			ex_aluop <= `EXE_NOP_OP;
			ex_alusel <= `EXE_RES_NOP;
			ex_reg1 <= `ZeroWord;
			ex_reg2 <= `ZeroWord;
			ex_wd <= `NOPRegAddr;
			ex_wreg <= `WriteDisable;
		end
		//normal status
		else if (stall[2] == `LogiFalse)
		begin
			ex_aluop <= id_aluop;
			ex_alusel <= id_alusel;
			ex_reg1 <= id_reg1;
			ex_reg2 <= id_reg2;
			ex_wd <= id_wd;
			ex_wreg <= id_wreg;
		end
		//if ID pause while EX don't, then add NOP instruction to MEM/WB
		else if ((stall[2] == `LogiTrue) && (stall[3] == `LogiFalse))
		begin
			ex_aluop <= `EXE_NOP_OP;
			ex_alusel <= `EXE_RES_NOP;
			ex_reg1 <= `ZeroWord;
			ex_reg2 <= `ZeroWord;
			ex_wd <= `NOPRegAddr;
			ex_wreg <= `WriteDisable;
		end
		//else pause the ID state
		else
		begin
			ex_aluop <= ex_aluop;
			ex_alusel <= ex_alusel;
			ex_reg1 <= ex_reg1;
			ex_reg2 <= ex_reg2;
			ex_wd <= ex_wd;
			ex_wreg <= ex_wreg;
		end
	end

endmodule





